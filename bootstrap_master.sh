#! /usr/bin/env bash

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