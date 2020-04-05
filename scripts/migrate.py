import logging
import json
import argparse
import os
import re
import boto3
try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

class S3Url(object):
    def __init__(self, url):
        self._parsed = urlparse(url, allow_fragments=False)

    @property
    def bucket(self):
        return self._parsed.netloc

    @property
    def key(self):
        if self._parsed.query:
            return self._parsed.path.lstrip('/') + '?' + self._parsed.query
        else:
            return self._parsed.path.lstrip('/')

    @property
    def url(self):
        return self._parsed.geturl()

def get_terraform_resource_instances(logger, tfstate, resource_type, resource_name):
    resource_instances = [resource['instances'] for resource in tfstate['resources']
                             if (resource['name'] == resource_name and resource['type'] == resource_type)][0]
    return resource_instances


def get_schema_map(logger, tfstate):
    logger.info("Getting Apiary schema names and indices.")

    bucket_resources = get_terraform_resource_instances(logger, tfstate, 'aws_s3_bucket', 'apiary_data_bucket')

    # Regex to get schema name from Apiary bucket name.  Handles instance names and any region.
    regex = re.compile("apiary.*-\d{12}-[a-zA-Z]+-[a-zA-Z]+-\d-(.+)")
    schema_index_map = { bucket['index_key'] : regex.match(bucket['attributes']['bucket']).group(1) for bucket in bucket_resources }

    if logger.isEnabledFor(logging.DEBUG):
        for (k,v) in schema_index_map.items():
            logger.debug(str.format("    Mapped index {} to schema {}", k, v))

    return schema_index_map


def change_resource_indices(args, logger, tfstate, resource_type, resource_name, schema_index_map):
    logger.info(str.format("Updating resource indexes for {}.{}", resource_type, resource_name))
    for resource in tfstate['resources']:
        if (resource['name'] == resource_name and resource['type'] == resource_type):
            if (resource['each'] == 'list'):
                if args.dryrun or logger.isEnabledFor(logging.DEBUG):
                    logger.debug(str.format('    Changing {0}.{1}.each="list" to {0}.{1}.each="map"', resource_type, resource_name))
                if not args.dryrun:
                    resource['each'] = 'map'

            for resource_instance in resource['instances']:
                index = resource_instance['index_key']
                schema = schema_index_map[resource_instance['index_key']]
                if args.dryrun or logger.isEnabledFor(logging.DEBUG):
                    logger.debug(str.format('    Changing {0}.{1}[{2}] to {0}.{1}["{3}"]', resource_type, resource_name, index, schema))

                if not args.dryrun:
                    resource_instance['index_key'] = schema


def read_state_from_s3(args, logger):
    s3Url = S3Url(args.statefile)
    try:
        s3 = boto3.resource("s3").Bucket(s3Url.bucket)
        content = s3.Object(key=s3Url.key).get()['Body']
        return json.loads(content.read().decode('utf-8'))
    except Exception as e:
        logger.error("Unable to open state file: ", exc_info=e)
        exit(1)


def write_state_to_s3(args, logger, tfstate):
    s3Url = S3Url(args.outfile)
    try:
        s3 = boto3.resource("s3").Bucket(s3Url.bucket)
        s3.Object(key=s3Url.key).put(Body=json.dumps(tfstate))
    except Exception as e:
        logger.error("Unable to open state file: ", exc_info=e)
        exit(1)


def read_state_from_file(args, logger):
    if not os.path.exists(args.statefile):
        logger.error(args.statefile + " does not exist.")
        exit(1)
    try:
        with open(args.statefile) as json_file:
            return json.load(json_file)
    except Exception as e:
        logger.error("Unable to open state file: ", exc_info=e)
        exit(1)

def write_state_to_file(args, logger, tfstate):
    try:
        with open(args.outfile, 'w') as new_state_file:
            json.dump(tfstate, new_state_file, indent=2)
    except Exception as e:
        logger.error("Unable to write state file: ", exc_info=e)
        exit(1)

def main():
    # Enable logging
    logging.basicConfig()
    logger = logging.getLogger('migrate')
    logger.setLevel(logging.DEBUG)

    logger.info("Initializing")

    parser = argparse.ArgumentParser(description='Get cmdline args for Apiary Terraform Migrator')
    parser.add_argument('--statefile', help="Terraform Apiary statefile to migrate", action="store")
    parser.add_argument('--outfile', help="Where to write migrated state", action="store")
    parser.add_argument('--dryrun', help="Print migration actions without actually migrating the state file.", action='store_true')

    args = parser.parse_args()
    if not args.statefile:
        args.statefile = 'terraform.tfstate'

    if not args.outfile:
        args.outfile = args.statefile

    if args.dryrun:
        logger.info(str.format("-- DRYRUN MODE - No changes will be written to output file {}. --", args.outfile))

    logger.info('Loading state file: ' + args.statefile)
    if (args.statefile.startswith('s3://')):
        tfstate = read_state_from_s3(args, logger)
    else:
        tfstate = read_state_from_file(args, logger)

    if tfstate['terraform_version'] < ('0.12.1'):
        logger.error("This migration script only works on state files created by Terraform 0.12.1+")
        exit(1)

    schema_index_map = get_schema_map(logger, tfstate)

    change_resource_indices(args, logger, tfstate, 'template_file', 'bucket_policy', schema_index_map)
    change_resource_indices(args, logger, tfstate, 'aws_s3_bucket', 'apiary_data_bucket', schema_index_map)
    change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_inventory', 'apiary_bucket', schema_index_map)
    change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_public_access_block', 'apiary_bucket', schema_index_map)
    change_resource_indices(args, logger, tfstate, "aws_s3_bucket_notification", "data_events", schema_index_map)
    change_resource_indices(args, logger, tfstate, "aws_s3_bucket_metric", "paid_metrics", schema_index_map)
    change_resource_indices(args, logger, tfstate, 'aws_sns_topic', 'apiary_data_events', schema_index_map)

    logger.info(str.format("Saving migrated state to {}", args.outfile))
    if not args.dryrun:
        if (args.outfile.startswith('s3://')):
            write_state_to_s3(args, logger, tfstate)
        else:
            write_state_to_file(args, logger, tfstate)

    if args.dryrun:
        logger.info(str.format("-- DRYRUN MODE - No changes were written to output file {}. --", args.outfile))
if __name__ == '__main__':
    main()