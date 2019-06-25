#!/usr/bin/env python
import sys
import logging
import pymysql
import os
import boto3
import base64
import json
from botocore.exceptions import ClientError

def get_aws_secret(secret_name,region):
    client = None
    try:
        client = boto3.client('secretsmanager',region_name=region)
    except NoRegionError:
        fatal('Unable to connect to AWS secrets manager in region {0}: {1}'.format(region, e.message))

    try:
        response = client.get_secret_value(SecretId=secret_name)
        data = response['SecretString']
        return data
    except ClientError as ce:
        if ce.response['Error']['Code'] != 'ResourceNotFoundException':
            logging.error('Failed to get AWS secret \'{0}\': {1}'.format(secret_name, ce.message))
        return None
    except Exception as e:
        loggin.error('Failed to get AWS secret \'{0}\': {1}'.format(secret_name, e.message))
        return None

def main():
    secret_json = json.loads(get_aws_secret(os.environ['mysql_secret_arn'],os.environ['region']))

    try:
        conn = pymysql.connect(os.environ['mysql_db_host'], user=secret_json['username'], passwd=secret_json['password'], db=os.environ['mysql_db_name'], connect_timeout=5)
    except:
        logging.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        sys.exit()

    sql = "insert into DBS(DB_ID,DB_LOCATION_URI,NAME,OWNER_NAME,OWNER_TYPE) values(%s,%s,%s,'root','USER') on duplicate key update DB_LOCATION_URI=%s"
    hive_db_names = os.environ['managed_schemas'].split(',')
    apiary_data_buckets = os.environ['apiary_data_buckets'].split(',')

    curr_id = 0
    index = 0
    for hive_db in hive_db_names:

        with conn.cursor() as cur:
            cur.execute("select MAX(DB_ID)+1 from DBS")
            curr_id = cur.fetchone()

        with conn.cursor() as cur:
            db_location='s3://'+apiary_data_buckets[index]
            cur.execute(sql,(curr_id,db_location,hive_db,db_location))
            conn.commit()

        index = index + 1

def lambda_handler(event, context):
    main()
    return {
        'message': "hive databases update completed."
    }

if __name__== "__main__":
    main()
