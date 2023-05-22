kubeadm_vagrant_aws
=======

이 패키지는 kubeadm 을 aws ec2에 설치를 쉽게 하는 구축 프로젝트이다.

Getting Started
---------------

이 문서는 kubeadm을 vagrant를 이용하여, aws 환경에 세팅하는게 주 목적이다.

Requirements
~~~~~~~~~~~~

ec2를 생성할 aws cli 환경이 구축되어 있어야 한다.
python3 버전에 boto3 패키지가 설치되어 있어야 한다.
vagrant가 설치되어 있어야 한다. ( vagrant-env, vagrant-aws plugin 설치 필요)
default vpc가 존재해야 한다. 만약에 없다면, pre_condition_resource/create_security_group.py 에 default_vpc 정보 읽어 오는 부분을 수정해야 한다.

Notices
~~~~~~~

- 2023-05-22, ec2에 master node 1대와 worker node 2대를 생성

Installation
~~~~~~~~~~~~

ec2를 생성할 AWS Account에 대해서 default profile이 세팅한다. ( 세팅 부분 건너뜀 )

- 참고 자료 : https://github.com/aws/aws-cli

vagrant 설치 ( mac 기준 )

::

   $ brew install hashicorp/tap/hashicorp-vagrant

vagrant 관련 plugin 설치

::

   $ vagrant plugin install vagrant-env
   $ vagrant plugin install vagrant-aws
   $ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

.env_sample 파일을 .env로 변경하고, 설정 정보를 입력한다.

- 
::

   cp .env_sample .env
   vi .env

- ACCESS_KEY : 리소스를 생성할 AWS Access Key 정보
- SECRET_KEY : 리소스를 생성할 AWS Secret Key 정보

- KEY_PATH : ec2 instance에 사용할 KeyPair 위치
- REGION : 리소스를 생성할 AWS REGION 명
- KEY_NAME : Key 이름 ( .pem 제외 )
- SECURITY_GROUP : ec2 instance에 사용할 Security 이름

- AN2_AL2023_IMAGE : 서울 리전의 Amazon Linux 2023 Image Id
- AN1_AL2023_IMAGE : 도쿄 리전의 Amazon LINUX 2023 Image Id
- ANE2_UBUNTU_IMAGE : 서울 리전의 Ubuntu 22.04 Image Id

- SUBNET_ID=subnet-XXXXXXXXXX
- MASTER_IP : master node의 IP ( default : 172.31.32.10 )
- NODE1_IP : work node 1의 IP ( default : 172.31.32.11 )
- NODE2_IP : workder node 2의 IP ( default : 172.31.32.12 )
- AZ_ZONE : Instance가 배치할 Availibility zone ( default : ap-northeast-2c )
- S3_BUCKET_PATH : master에서 생성한 token 값을 node1 / node2 Instance에 전달하기 위해 파일을 업로드/다운로드 할 S3 bucket path를 지정한다.

Security Group을 생성한다.

::

   $ cd pre_condition_resource
   $ pip3 install -r Requirements.txt
   $ python3 create_security_group.py

vagrant 를 실행해서, ec2 instance를 생성한다.

::

   $ vagrant up

실행 상태를 체크해서 모두 running 상태인지 체크를 한다.

::

   $ vagrant status
   >> Current machine states:
   >> master                    running (aws)
   >> node1                     running (aws)
   >> node2                     running (aws)   

worker1 node에 접속해서 master node에 접속한다.

::

   $ vagrant ssh node1
   $ sudo -i
   $ $HOME/run.sh

worker2 node에 접속해서 master node에 접속한다.

::

   $ vagrant ssh node2
   $ sudo -i
   $ $HOME/run.sh   

master node에 접속이 잘 수행될때까지 대기 한다.

::

   $ vagrant ssh master
   $ sudo -i
   $ $HOME/waiting.sh

node 상태를 체크했을 때 아래와 같이 READY 상태인지 체크한다.

::

   $ kubectl get nodes
   >> NAME     STATUS   ROLES           AGE     VERSION
   >> master   Ready    control-plane   9m17s   v1.27.2
   >> node1    Ready    <none>          63s     v1.27.2
   >> node2    Ready    <none>          46s     v1.27.2

Destroy
~~~~~~~~~~~~

사용을 다 한 경우 삭제를 진행한다.
삭제 후 바로 재생성을 하는 경우 Private IP가 Release되지 않아 생성에 실패하는 경우가 있다, Release 될 때까지 잠깐 대기 한 후 재실행 한다.
::

   $ vagrant destroy