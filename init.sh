#!/bin/bash

install_azcli () {
    apt-get update
    apt-get install curl apt-transport-https lsb-release gpg
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        tee /etc/apt/sources.list.d/azure-cli.list
    apt-get update
    apt-get install azure-cli
    az extension add --name azure-cli-iot-ext
}

install_kubectl() {
    apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubectl
    
}

install_kubectx() {
    curl -s https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
    chmod a+x /usr/local/bin/kubectx
    curl -s https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
    chmod a+x /usr/local/bin/kubens
}

install_sops() {
    apt install python-pip
}

install_rke() {
  curl -o /bin/rke -L https://github.com/rancher/rke/releases/download/v0.2.7/rke_linux-amd64
  chmod +x /bin/rke
}

install_terraform() {
  curl -o /tmp/terraform.zip -L https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
  cat /tmp/terraform.zip | gunzip > /bin/terraform
  chmod +x /bin/terraform
}

install_helm() {
  curl -o /tmp/helm.tar.gz -L https://storage.googleapis.com/kubernetes-helm/helm-v2.14.0-linux-amd64.tar.gz
  tar -C /tmp -xvzf /tmp/helm.tar.gz
  mv /tmp/linux-amd64/helm /bin/helm
  mv /tmp/linux-amd64/tiller /bin/tiller
}

install_jq() {
    apt-get install -y jq
}

install_kubeps1() {
  curl -o /bin/kube-ps1.sh -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
  SOURCECMD="source /bin/kube-ps1.sh"
  PROMPTCMD="PS1='[\u@\h:\W $(kube_ps1)]\$ '"
  if grep --quiet ^${SOURCECMD} /home/${USER_NAME}/.bashrc; then
    echo "Source for Kube-ps1 already exists"
  else
    echo ${SOURCECMD} >> /home/${USER_NAME}/.bashrc
  fi
  if grep -F --quiet ${PROMPTCMD} /home/${USER_NAME}/.bashrc; then
    echo "Source for Kube-ps1 already exists"
  else
    echo ${PROMPTCMD} >> /home/${USER_NAME}/.bashrc
  fi
}

while getopts 'h:u:' c
do
    case $c in
        h) HOME_DIR=$OPTARG ;;
        u) USER_NAME=$OPTARG ;;
    esac
done

echo "User name is $USER_NAME"
echo "Home directory is ${HOME_DIR}"

install_azcli
install_kubectl
install_kubectx
install_rke
install_helm
install_terraform
install_jq
install_kubeps1