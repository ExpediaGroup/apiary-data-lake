import logging
import json
import argparse
import os
import re


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

    return schema_index_map


def change_resource_indices(logger, tfstate, resource_type, resource_name, schema_index_map):
    logger.info("Updating resource indexes for "+ resource_type + "." + resource_name)
    for resource in tfstate['resources']:
        if (resource['name'] == resource_name and resource['type'] == resource_type):
            for resource_instance in resource['instances']:
                resource_instance['index_key'] = schema_index_map[resource_instance['index_key']]


def main():
    # Enable logging
    logging.basicConfig()
    logger = logging.getLogger("apiary-terraform-migrate")
    logger.setLevel(logging.INFO)

    logger.info("Initializing")

    parser = argparse.ArgumentParser(description='Get cmdline args for Apiary Terraform Migrator')
    parser.add_argument('--statefile', help="Terraform Apiary statefile to migrate", action="store")

    args = parser.parse_args()
    if not args.statefile:
        args.statefile = 'terraform.tfstate'

    if not os.path.exists(args.statefile):
        logger.error(args.statefile + " does not exist.")
        exit(1)

    logger.info('Loading state file: ' + args.statefile)
    with open(args.statefile) as json_file:
        tfstate = json.load(json_file)

    schema_index_map = get_schema_map(logger, tfstate)

    change_resource_indices(logger, tfstate, 'template_file', 'bucket_policy', schema_index_map)
    change_resource_indices(logger, tfstate, 'aws_s3_bucket', 'apiary_data_bucket', schema_index_map)
    change_resource_indices(logger, tfstate, 'aws_s3_bucket_inventory', 'apiary_bucket', schema_index_map)
    change_resource_indices(logger, tfstate, 'aws_s3_bucket_public_access_block', 'apiary_bucket', schema_index_map)
    change_resource_indices(logger, tfstate, "aws_s3_bucket_notification", "data_events", schema_index_map)
    change_resource_indices(logger, tfstate, "aws_s3_bucket_metric", "paid_metrics", schema_index_map)
    change_resource_indices(logger, tfstate, 'aws_sns_topic', 'apiary_data_events', schema_index_map)


    with open(args.statefile+'.new', 'w') as new_state_file:
        json.dump(tfstate, new_state_file, indent=2)

if __name__ == '__main__':
    main()