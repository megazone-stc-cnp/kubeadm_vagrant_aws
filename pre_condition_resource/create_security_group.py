import sys
import boto3
import json
import botocore
from requests import get

def get_default_vpc_info():
    client = boto3.client('ec2')
    try:
        response = client.describe_vpcs()
        for vpc in response['Vpcs']:
            if vpc['IsDefault'] is True:
                return vpc['VpcId'], vpc['CidrBlock']
        print("default vpc not exist")
    except botocore.exceptions.ClientError as error:
        print(error)

def get_subnets(vpc_id):
    client = boto3.client('ec2')
    try:
        response = client.describe_subnets(
            Filters=[
                {
                    'Name': 'vpc-id',
                    'Values': [
                        vpc_id,
                    ]
                },
            ]
        )

        for subnet in response['Subnets']:
          print(f">> subnet : {subnet['SubnetId']} / {subnet['AvailabilityZone']} / {subnet['CidrBlock']}")
    except botocore.exceptions.ClientError as error:
        print(error)

def find_security_group(security_group_name, vpc_id):
    client = boto3.client('ec2')
    response=""
    try:
        response = client.describe_security_groups(
            Filters=[
                {
                    'Name': 'vpc-id',
                    'Values': [
                        f"{vpc_id}",
                    ]
                },
            ],
            GroupNames=[
                f"{security_group_name}",
            ]
        )
        print("describe_security_groups response", response)
        if len(response['SecurityGroups']) > 0:
            return True
    except botocore.exceptions.ClientError as error:
        if error.response['Error']['Code'] == "InvalidGroup.NotFound":
            return False
        print(error)
    return False

def create_security_group(security_group_name, vpc_id):
    client = boto3.client('ec2')
    response=""
    try:
        response = client.create_security_group(
            Description='k8s security_group',
            GroupName=security_group_name,
            VpcId=vpc_id
        )
        print("create_security_group response", response)
    except botocore.exceptions.ClientError as error:
        print(error)

def add_ingress_rule(sg_name, cidr_ip, port, description, protocol):
    client = boto3.client('ec2')
    response=""
    try:
        response = client.authorize_security_group_ingress(
            GroupName=sg_name,
            IpPermissions=[
                {
                    'FromPort': port,
                    'IpProtocol': protocol,
                    'IpRanges': [
                        {
                            'CidrIp': cidr_ip,
                            'Description': description,
                        },
                    ],
                    'ToPort': port,
                },
            ],
        )
        print("authorize_security_group_ingress response", response)
        if response['Return'] == True:
            print(f"success add {cidr_ip}:{port}")
    except botocore.exceptions.ClientError as error:
        print(error)

def find_my_ip():
    ip = get('https://ifconfig.me/').content.decode('utf8')
    return ip

def main(security_name):
    my_ip = find_my_ip()
    print(">> my_id : ", my_ip)
    vpc_id, default_cidr = get_default_vpc_info()
    print(">> vpc_id : ", vpc_id, " / default_cidr : ", default_cidr)
    get_subnets(vpc_id)
    is_find = find_security_group(security_name, vpc_id)
    any_cidr = "0.0.0.0/0"

    if is_find is False:
        create_security_group(security_name, vpc_id)
        add_ingress_rule(security_name, f"{my_ip}/32", 22, "ssh connect", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 22, "ssh connect", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 6443, "Master Node kube-apiserver", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 10250, "Master Node kubelet", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 2379, "Master Node kubelet", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 2380, "Master Node kubelet", "tcp")
        add_ingress_rule(security_name, f"{any_cidr}", 51820, "calico", "udp")
        add_ingress_rule(security_name, f"{any_cidr}", 179, "calico", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 443, "Master Node kube-apiserver", "tcp")
        add_ingress_rule(security_name, f"{default_cidr}", 5473, "calico", "tcp")
        add_ingress_rule(security_name, f"{any_cidr}", 4789, "calico", "udp")
        add_ingress_rule(security_name, f"{any_cidr}", 51821, "calico", "udp")

        # add_ingress_rule(NAME, f"{default_cidr}", 2380, "Workder Node kubelet")
    else:
        print("security group exist")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage create_security_group.py")

    main("k8s-sg")