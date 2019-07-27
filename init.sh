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
  curl -o /bin/rke -L https://github.com/rancher/rke/releases/download/v0.2.2/rke_linux-amd64
  chmod +x /bin/rke
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

while getopts 'h' c
do
    case $c in
        h) HOME_DIR=$OPTARG ;;
    esac
done

install_azcli
install_kubectl
install_kubectx
install_rke
install_helm

ln -s $HOME_DIR/.ssh ~/.ssh