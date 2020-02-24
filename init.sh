#!/bin/bash

install_azcli () {
    echo "Installing AZ CLI" | tee ${LOG_FILE} 2>&1
    apt-get update > /dev/null 2>&1
    apt-get install curl apt-transport-https lsb-release gpg -y >> ${LOG_FILE} 2>&1
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list
    apt-get update > /dev/null
    apt-get install azure-cli -y >> ${LOG_FILE} 2>&1
    az extension add --name azure-cli-iot-ext  >> ${LOG_FILE} 2>&1
}

install_git () {
  echo "Installing Git" | tee ${LOG_FILE} 2>&1
  apt-get install -y git git-secret >> ${LOG_FILE} 2>&1
}

install_kubectl() {
    echo "Installing kubectl" | tee ${LOG_FILE} 2>&1
    apt-get update > /dev/null && apt-get install -y apt-transport-https >> ${LOG_FILE} 2>&1
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg 2>>${LOG_FILE} | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    apt-get update >> ${LOG_FILE} 2>&1
    apt-get install -y kubectl >> ${LOG_FILE} 2>&1
    kubectl completion bash > /etc/bash_completion.d/kubectl
}

install_kubectx() {
    echo "Installing kubectx" | tee ${LOG_FILE} 2>&1
    curl -s https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
    chmod a+x /usr/local/bin/kubectx
    curl -s https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
    chmod a+x /usr/local/bin/kubens
}

install_sops() {
    apt install python-pip
}

install_rke() {
  echo "Installing RKE" | tee ${LOG_FILE} 2>&1
  curl -o /bin/rke -L https://github.com/rancher/rke/releases/download/v0.2.7/rke_linux-amd64 >> ${LOG_FILE} 2>&1
  chmod +x /bin/rke 
}

install_terraform() {
  echo "Installing Terraform" | tee ${LOG_FILE} 2>&1
  curl -o /tmp/terraform.zip -L https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip >> ${LOG_FILE} 2>&1
  cat /tmp/terraform.zip | gunzip > /bin/terraform
  chmod +x /bin/terraform
}

install_helm() {
  echo "Installing Helm" | tee ${LOG_FILE} 2>&1
  curl -o /tmp/helm.tar.gz -L https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz >> ${LOG_FILE} 2>&1
  tar -C /tmp -xvzf /tmp/helm.tar.gz >> {LOG_FILE}
  mv /tmp/linux-amd64/helm /bin/helm
  mv /tmp/linux-amd64/tiller /bin/tiller
}

install_jq() {
    echo "Installing jq" | tee ${LOG_FILE} 2>&1
    apt-get install -y jq >> ${LOG_FILE} 2>&1
}

install_kubeps1() {
  echo "Installing Kubeps1" | tee ${LOG_FILE} 2>&1
  curl -o /bin/kube-ps1.sh -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh >> ${LOG_FILE} 2>&1
  SOURCECMD="source /bin/kube-ps1.sh"
  PROMPTCMD="PS1='[\u@\h:\W \$(kube_ps1)]\\\$ '"
  if grep --quiet ^${SOURCECMD} /home/${USER_NAME}/.bashrc; then
    echo "Source for Kube-ps1 already exists" >> ${LOG_FILE} 2>&1
  else
    echo ${SOURCECMD} >> /home/${USER_NAME}/.bashrc
  fi
  if grep --quiet "PS1=.*kube_ps1" /home/${USER_NAME}/.bashrc; then
    echo "Kube-ps1 already exists" >> ${LOG_FILE} 2>&1
  else
    echo ${PROMPTCMD} >> /home/${USER_NAME}/.bashrc
  fi
}

install_awscli() {
  echo "Installing AWS CLI"
  apt-get install -y awscli >> ${LOG_FILE} 2>&1
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

LOG_FILE=/var/log/wsl_init.log
echo "" > ${LOG_FILE}

install_azcli
install_awscli
install_kubectl
install_kubectx
install_rke
install_helm
install_terraform
install_jq
install_kubeps1