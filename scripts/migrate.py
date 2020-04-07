import logging
import json
import argparse
import os
import re
import boto3
from packaging import version
from datetime import datetime
try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

"""Apiary 6.0.0 migration script

    This script is used to migrate an Apiary Terraform state file from using "count" for resource indexing to using
    "for_each", which is how apiary-data-lake v6.0.0+ handles indexed resources.  Without this script, doing an "apply" 
    will want to destroy all your S3 resources and then recreate them because they are stored in the .tfstate file
    differently.
    
    This script needs some external packages installed (see migrate_requirements.txt) and then should run in either
    Python 2.7+ or Python 3.6+.
    
    Migration procedure:
    - This procedure assumes you have a Terraform app called "apiary-terraform-app" that is the application using this module.
    - Upgrade "apiary-terraform-app" to "apiary-data-lake" v5.3.2.  This will necessitate using Terraform 0.12+ and
      resolving any TF 0.12 incompatibilities in your application code.  TF 0.12.21+ is recommended (will be required later).
    - Plan and apply your Terraform app to make sure it is working and up-to-date.
    - Install Python 3 if you don't yet have a Python installation.
    - Install requirements for this script with "pip install -r migrate_requirements.txt".
    - Run this script pointing to your terraform state file.  Script can read from either file system or S3. Run it first with dryrun, then live.  Example:
      - python migrate.py --dryrun --statefile s3://<bucket_name>/<path_to_statefile>/terraform.tfstate
      - python migrate.py --statefile s3://<bucket_name>/<path_to_statefile>/terraform.tfstate
      - Note that appropriate AWS credentials will be needed for S3: AWS_PROFILE, AWS_DEFAULT_REGION, etc.
    - Upgrade "apiary-terraform-app" to use "apiary-data-lake" v6.0.0.  Do NOT make any changes in the variables that
      are passed to the "apiary-data-lake" module.  If you are not yet using TF 0.12.21+, please upgrade to 0.12.21.
    - Now run a plan of your "apiary-terraform-app" that is using "apiary-data-lake" v6.0.0.  It should show no changes needed.
    - Now run an apply of the code.
"""

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
    logger.info("Getting Apiary schema names and indices:")

    bucket_resources = get_terraform_resource_instances(logger, tfstate, 'aws_s3_bucket', 'apiary_data_bucket')

    # Regex to get schema name from Apiary bucket name.  Handles instance names and any region.
    regex = re.compile("apiary.*-\d{12}-[a-zA-Z]+-[a-zA-Z]+-\d-(.+)")
    schema_index_map = { bucket['index_key'] : regex.match(bucket['attributes']['bucket']).group(1).replace('-', '_') for bucket in bucket_resources }

    for (k,v) in schema_index_map.items():
        logger.info("    Mapped index {} to schema {}".format(k, v))

    return schema_index_map


def change_resource_indices(args, logger, tfstate, resource_type, resource_name, schema_index_map):
    made_changes = False
    logger.info("Updating resource indexes for {}.{}:".format(resource_type, resource_name))
    for resource in tfstate['resources']:
        if (resource['name'] == resource_name and resource['type'] == resource_type):
            # Only do following code if count hasn't already been migrated to for_each (each:list --> each:map)
            if (resource['each'] == 'list'):
                logger.info('    Changing {0}.{1}.each="list" to {0}.{1}.each="map"'.format(resource_type, resource_name))
                if not args.dryrun:
                    resource['each'] = 'map'
                    made_changes = True

                for resource_instance in resource['instances']:
                    index = resource_instance['index_key']
                    schema = schema_index_map[resource_instance['index_key']]
                    logger.info('    Changing {0}.{1}[{2}] to {0}.{1}["{3}"]'.format(resource_type, resource_name, index, schema))

                    if not args.dryrun:
                        resource_instance['index_key'] = schema
                        made_changes = True
            else:
                logger.info("    {0}.{1}.each already is type 'map' - nothing to do.".format(resource_type, resource_name))
    return made_changes

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

def write_state_to_file(outfile, logger, tfstate):
    try:
        with open(outfile, 'w') as new_state_file:
            json.dump(tfstate, new_state_file, indent=2)
    except Exception as e:
        logger.error("Unable to write state file: ", exc_info=e)
        exit(1)


def get_args():
    parser = argparse.ArgumentParser(description='Get cmdline args for Apiary Terraform Migrator')
    parser.add_argument('--statefile', help="Terraform Apiary statefile to migrate", action="store")
    parser.add_argument('--outfile', help="Where to write migrated state", action="store")
    parser.add_argument('--dryrun', help="Print migration actions without actually migrating the state file.", action='store_true')

    args = parser.parse_args()
    if not args.statefile:
        args.statefile = 'terraform.tfstate'

    if not args.outfile:
        args.outfile = args.statefile

    return args


def main():
    # Enable logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)-5s: %(message)s', datefmt='%H:%M:%S')
    logger = logging.getLogger('migrate')
    logger.info("Initializing")

    args = get_args()

    if args.dryrun:
        logger.info(" ---- DRYRUN MODE - No changes will be written to output file {}. --\n".format(args.outfile))

    logger.info('Loading state file: ' + args.statefile)
    if (args.statefile.startswith('s3://')):
        tfstate = read_state_from_s3(args, logger)
    else:
        tfstate = read_state_from_file(args, logger)

    if not args.dryrun and (args.statefile == args.outfile):
        basename = os.path.basename(args.statefile)
        backupfile = "{}.premigrate.{}".format(basename, datetime.now().strftime("%Y%m%d-%H%M%S"))
        logger.info("Backing up {} to {}".format(args.statefile, backupfile))
        write_state_to_file(backupfile, logger, tfstate)

    if version.parse(tfstate['terraform_version']) < version.parse('0.12.1'):
        logger.error("This migration script only works on state files created by Terraform 0.12.1+")
        exit(1)

    made_changes = False
    # Change older version number to one that supports for_each
    if version.parse(tfstate['terraform_version']) < version.parse('0.12.21'):
        logger.info("Changing terraform_version from {} to {}.".format(tfstate['terraform_version'], '0.12.21'))
        if not args.dryrun:
            tfstate['terraform_version'] = '0.12.21'
            made_changes = True

    schema_index_map = get_schema_map(logger, tfstate)

    made_changes |= change_resource_indices(args, logger, tfstate, 'template_file', 'bucket_policy', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_s3_bucket', 'apiary_data_bucket', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_inventory', 'apiary_bucket', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_public_access_block', 'apiary_bucket', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_notification', 'data_events', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_s3_bucket_metric', 'paid_metrics', schema_index_map)
    made_changes |= change_resource_indices(args, logger, tfstate, 'aws_sns_topic', 'apiary_data_events', schema_index_map)

    if not made_changes:
        logger.info('State file was already migrated, no changes made, not saving to {}'.format(args.outfile))
    else:
        logger.info("Saving migrated state to {}".format(args.outfile))
        if not args.dryrun:
            if (args.outfile.startswith('s3://')):
                write_state_to_s3(args, logger, tfstate)
            else:
                write_state_to_file(args.outfile, logger, tfstate)

    if args.dryrun:
        logger.info(" ---- DRYRUN MODE - No changes were written to output file {}. --".format(args.outfile))


if __name__ == '__main__':
    main()
