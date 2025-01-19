packer {
  required_plugins {
    docker = {
      version = "1.1.1"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable "kubectlVersion" {
    type = string
    description = "The version of kubectl to install"
}

variable "nodeJsVersion" {
    type = string
    description = "The version of nodejs to install"
}

variable "nodeVersion" {
    type = string
    description = "The version of node to install"
}

variable "npmVersion" {
    type = string
    description = "The version of npm to install"
}

source "docker" "worker-tools" {
  image  = "octopusdeploy/worker-tools:6.3-ubuntu.22.04"
  export_path = "../docker/rootfs/worker_tools.tar.xz"
}

build {
  name    = "worker-tools"
  sources = [
      "source.docker.worker-tools"
  ]

  provisioner "shell" {
      inline = [
          # Dump the old and busted Kubectl Repository
          "rm -f /etc/apt/sources.list.d/kubernetes.list",
          "rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
          # Remove old nodejs
          "apt-get remove nodejs -y",
          "wget --quiet -O - https://deb.nodesource.com/setup_${var.nodeJsVersion}.x | bash",
          # Install the new Kubectl Repository
          "curl -fsSL 'https://pkgs.k8s.io/core:/stable:/v${var.kubectlVersion}/deb/Release.key' | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
          "echo \"deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kubectlVersion}/deb/ /\" | tee /etc/apt/sources.list.d/kubernetes.list",
          # Install terraform Repository
          "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
          "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
          # Remove the old terraform version to prevent muxing
          "rm -f /usr/local/bin/terraform",
          "apt-get update",
          "apt-get dist-upgrade -y",
          "apt-get upgrade -y",
          "apt-get install bash-completion colorized-logs docker.io nodejs terraform -y",
          "pwsh -c 'Get-Module -All | ForEach-Object{Update-Module -Name $_.Name}'",
          "pip3 install ansi2html sfctl",
          "az config set collect.telemetry=false",
          "az extension add --name azure-devops --allow-preview true",
          "npm config set fund false",
          "npm install -g npm@${var.npmVersion}",
          "npm install -g grunt grunt-cli mocha",
          # Upgrade AWS CLI
          "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
          "unzip awscliv2.zip",
          "./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update",
          "rm -rf ./aws",
          "/usr/local/bin/aws --version"
      ]
  }
}