import socket
import os
import boto3
import datetime

client = boto3.client('logs')
 
INSTANCE_PRIVATE_IP = os.environ['INSTANCE_PRIVATE_IP']
LOG_GROUP = os.environ['LOG_GROUP']
LOG_STREAM = os.environ['LOG_STREAM']
 
def publish_logs(message):
    response = client.put_log_events(
    logGroupName= LOG_GROUP,
    logStreamName=LOG_STREAM,
    logEvents=[
        {
            'timestamp': datetime.datetime.now(),
            'message': message
        },
    ]
)
 
def lambda_handler(event, context):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(10)
    try:
        result = sock.connect_ex((INSTANCE_PRIVATE_IP, 22))
        if result == 0:
            print("Port is open")
            publish_logs("Port 22 is open")
        else:
            publish_logs("Port 22 is not open")
    except Exception as e:
        print("Port is not open. Exception: " + e)
    sock.close()




