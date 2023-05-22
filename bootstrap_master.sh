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
  sudo unlink /bin/sh
  sudo ln -s /bin/bash /bin/sh
}

ubuntu_default_install
aws_cli_v2_install
aws_default_configure ${ACCESS_KEY} ${SECRET_KEY} ${REGION}
ubuntu_change_bash

# os 버전 체크
cat /etc/os-release

# 메모리 체크
free -h

# cpu
lscpu

# 외부 접속 테스트
ping -c 4 8.8.8.8

# Time zone 변경
date
cat /etc/localtime

rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date

# hostname 변경
hostnamectl set-hostname master

hostname

# host에 등록 확인
cat >> /etc/hosts <<EOF
${MASTER_IP} master
${NODE1_IP} node1
${NODE2_IP} node2
EOF

cat /etc/hosts

# 방화벽 확인
ufw status

# container runtime
# br_netfilter 모듈을 로드
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# bridge traffic 보게 커널 파라메터 수정
# 필요한 sysctl 파라미터를 /etc/sysctl.d/conf 파일에 설정하면, 재부팅 후에도 값이 유지된다.
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 재부팅하지 않고 sysctl 파라미터 적용하기
sysctl --system

# docker engine 설치
apt update
apt install -y docker.io
systemctl enable --now docker
systemctl status docker

# kubeadm,kubelet, kubectl 설치
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

# kubeadm 설치
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# cri-docker 설치
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb
dpkg -i cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb
systemctl status cri-docker
ls /var/run/cri-dockerd.sock

# control-plaine 컴포넌트 구성
kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock | tee $HOME/kubeadm_init.log
JOIN_COMMAND=$(tail -n 2 $HOME/kubeadm_init.log)

cat > token.join <<EOF
${JOIN_COMMAND} \
--cri-socket unix:///var/run/cri-dockerd.sock
EOF

aws s3 cp token.join ${S3_BUCKET_PATH}/token.join
# Kubectl을 명령 실행 허용하려면 kubeadm init 명령의 실행결과 나온 내용을 동작해야 함
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml

kubectl wait --for=condition=Ready pods --all -n calico-apiserver --timeout=180s
kubectl wait --for=condition=Ready pods --all -n calico-system --timeout=180s

cat > $HOME/waiting.sh <<EOF
kubectl wait --for=condition=Ready pods --all -n calico-system --timeout=180s
EOF

chmod +x $HOME/waiting.sh