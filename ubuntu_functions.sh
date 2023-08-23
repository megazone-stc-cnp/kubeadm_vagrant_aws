#!/bin/bash

function ubuntu_default_install {
    # default install
    apt -y update
    apt install -y git unzip
}

function aws_default_configure {
    ACCESS_KEY=$1
    SECRET_KEY=$2
    REGION=$3

    # aws cli configure
    aws configure set aws_access_key_id ${ACCESS_KEY}
    aws configure set aws_secret_access_key ${SECRET_KEY}
    aws configure set region ${REGION}
    aws configure set output json
}
function aws_cli_v2_install {
    # AWS CLI v2 install
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
}

function ubuntu_change_bash {
  unlink /bin/sh
  ln -s /bin/bash /bin/sh
}

ubuntu_default_install
aws_cli_v2_install
aws_default_configure ${ACCESS_KEY} ${SECRET_KEY} ${REGION}
ubuntu_change_bash