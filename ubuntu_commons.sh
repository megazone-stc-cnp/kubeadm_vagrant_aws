#!/bin/bash

NAME=$1

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
hostnamectl set-hostname ${NAME}

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
