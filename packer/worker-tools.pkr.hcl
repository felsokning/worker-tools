packer {
  required_plugins {
    docker = {
      version = "1.1.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# variable "argocdVersion" {
#   type        = string
#   description = "The version of ArgoCD to install"
# }

variable "bicepVersion" {
  type        = string
  description = "The vesion of the bicep CLI to install"
}

variable "giteaVersion" {
  type        = string
  description = "The version of Gitea to install"
}

variable "groupId" {
  type        = string
  description = "The ID of the Custom Group to Create"
}

variable "groupName" {
  type        = string
  description = "The Name of the Custom Group to Create"
}

variable "kubectlVersion" {
  type        = string
  description = "The version of kubectl to install"
}

variable "kubeloginVersion" {
  type        = string
  description = "The version kubelogin to install"
}

variable "octoCliVersion" {
  type        = string
  description = "The version of the octo CLI to install"
}

variable "octopusCliVersion" {
  type        = string
  description = "The version of the octopus CLI to install"
}

variable "nodeJsVersion" {
  type        = string
  description = "The version of nodejs to install"
}

variable "nodeVersion" {
  type        = string
  description = "The version of node to install"
}

variable "npmVersion" {
  type        = string
  description = "The version of npm to install"
}

variable "powershellVersion" {
  type        = string
  description = "The version of PowerShell to install"
}

variable "terraformVersion" {
  type        = string
  description = "The version of terraform to install"
}

variable "tofuVersion" {
  type        = string
  description = "The version of tofu to install"
}

variable "ubuntuVersion" {
  type        = string
  description = "The version of Ubuntu to use for the base image."
}

variable "userId" {
  type        = string
  description = "The ID of the Custom User to Create"
}

variable "userName" {
  type        = string
  description = "The Name of the Custom User to Create"
}

source "docker" "noble" {
  image       = "ubuntu:${var.ubuntuVersion}"
  export_path = "../docker/rootfs/${var.ubuntuVersion}/worker_tools.tar.xz"
}

build {
  name = "worker-tools"
  sources = [
    "source.docker.noble"
  ]

  provisioner "shell" {
    inline = [
      # Setup time zone configuration for tzdata
      "ln -sf /usr/share/zoneinfo/UTC /etc/localtime",
      "apt-get update",
      "apt-get dist-upgrade -y -q",
      "apt-get upgrade -y -q",
      # Install require prequisites
      "apt-get install --no-install-recommends augeas-tools apt-transport-https apt-utils bash-completion ca-certificates colorized-logs curl dos2unix git gnupg gnupg2 groff jq lftp libc6 libgcc-s1 libgdiplus libicu-dev libicu74 liblttng-ust1 libssl3 libstdc++6 libunwind8 nano openssh-client passwd python3-cryptography python3-pip python3-setuptools software-properties-common rsync sudo unixodbc-dev unzip wget yq zlib1g -y -q",
      # Add NodeJS Repository
      "wget --quiet --secure-protocol=TLSv1_2 --https-only -O - https://deb.nodesource.com/setup_${var.nodeJsVersion}.x | bash",
      # Add Octopus Repository
      "curl -sSfL https://apt.octopus.com/public.key | sudo gpg --dearmor -o /usr/share/keyrings/octopus.com.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/octopus.com.gpg] https://apt.octopus.com/ stable main\" > /etc/apt/sources.list.d/octopus.com.list",
      # Add GitHub Repository (for gh cli)
      "out=$(mktemp)",
      "wget --quiet  --secure-protocol=TLSv1_2 --https-only -O $out https://cli.github.com/packages/githubcli-archive-keyring.gpg",
      "cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null",
      "chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null",
      # Install GitLab CLI
      "curl -sSL https://gitlab-cli.com/install.sh | sh",
      # Add Hashicorp Repository
      "wget --quiet -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
      # Add the kubectl Repository
      "curl -fsSL 'https://pkgs.k8s.io/core:/stable:/v${var.kubectlVersion}/deb/Release.key' | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo \"deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kubectlVersion}/deb/ /\" | tee /etc/apt/sources.list.d/kubernetes.list",
      # Install pre-requisite for Octopus CLI
      "wget --quiet http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu70_70.1-2ubuntu1_amd64.deb",
      "dpkg -i libicu70_70.1-2ubuntu1_amd64.deb",
      "rm -f libicu70_70.1-2ubuntu1_amd64.deb",
      # Add MSFT Repository
      "wget --quiet --secure-protocol=TLSv1_2 --https-only https://packages.microsoft.com/config/ubuntu/${var.ubuntuVersion}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb",
      "dpkg -i packages-microsoft-prod.deb",
      "rm -f packages-microsoft-prod.deb",
      "apt-get update -q",
      "ACCEPT_EULA=Y apt-get install --no-install-recommends aspnetcore-runtime-8.0 dotnet-runtime-8.0 dotnet-sdk-8.0 gh mssql-tools18 nodejs octopus-cli=${var.octopusCliVersion} octopuscli=${var.octoCliVersion} powershell=${var.powershellVersion} terraform=${var.terraformVersion} -y -q",
      # Install autocomplete for terraform
      "terraform -install-autocomplete",
      # Install PowerShell Modules
      "pwsh -c 'Install-Module -Name Az -AllowClobber -Scope AllUsers -Force'",
      "pwsh -c 'Install-Module -Name Az.OperationalInsights -AllowClobber -Scope AllUsers -Force'",
      "pwsh -c 'Install-Module -Name Pester -AllowClobber -Scope AllUsers -Force'",
      "pwsh -c 'Install-Module -Name PowerShellGet -AllowClobber -Scope AllUsers -Force'",
      "pwsh -c 'Install-Module -Name powershell-yaml -AllowClobber -Scope AllUsers -Force'",
      "pwsh -c 'Enable-AzureRmAlias -Scope LocalMachine'",
      # Install tofu
      "wget --quiet --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh",
      "chmod +x install-opentofu.sh",
      "./install-opentofu.sh --install-method deb",
      "rm -f install-opentofu.sh",
      # Update npm
      "npm config set fund false",
      "npm install -g n",
      "n ${var.nodeVersion}",
      "npm install -g npm@${var.npmVersion}",
      "npm install -g grunt grunt grunt-cli mocha",
      # Install Az CLI
      "curl -sL https://aka.ms/InstallAzureCLIDeb | bash",
      "az config set core.collect_telemetry=false --only-show-errors",
      "az config set core.login_experience_v2=off --only-show-errors",
      # Install Az CLI Extensions
      "az extension add --name azure-devops --allow-preview true --only-show-errors --yes",
      "az extension add --name azure-firewall --allow-preview true --only-show-errors --yes",
      "az extension add --name containerapp --allow-preview true --only-show-errors --yes",
      "az extension add --name functionapp --allow-preview true --only-show-errors --yes",
      "az extension add --name log-analytics --allow-preview true --only-show-errors --yes",
      "az extension add --name webapp --allow-preview true --only-show-errors --yes",
      # Install Gitea
      "wget --quiet --secure-protocol=TLSv1_2 --https-only -O tea https://github.com/go-gitea/gitea/releases/download/v${var.giteaVersion}/gitea-${var.giteaVersion}-linux-amd64",
      "chmod +x tea",
      "mv tea /usr/local/bin",
      # Install kubelogin
      "wget --quiet --secure-protocol=TLSv1_2 --https-only https://github.com/Azure/kubelogin/releases/download/v${var.kubeloginVersion}/kubelogin-linux-amd64.zip",
      "unzip kubelogin-linux-amd64.zip -d kubelogin-linux-amd64",
      "mv kubelogin-linux-amd64/bin/linux_amd64/kubelogin /usr/local/bin",
      "rm -rf kubelogin-linux-amd64",
      "rm -f kubelogin-linux-amd64.zip",
      # Install bicep CLI
      "wget --quiet --secure-protocol=TLSv1_2 --https-only -O bicep https://github.com/Azure/bicep/releases/download/v${var.bicepVersion}/bicep-linux-x64",
      "chmod +x ./bicep",
      "mv ./bicep /usr/local/bin/bicep",
      "sudo -s source /usr/share/bash-completion/bash_completion",
      # Source bashrc
      "sudo -s source ~/.bashrc",
      # Add Group and User
      "groupadd -g ${var.groupId} ${var.groupName}",
      "useradd -u ${var.userId} -g ${var.groupName} -s /bin/sh -m ${var.userName}",
      "usermod -a -G sudo ${var.userName}",
      # Make Paths for File Copy or Helm init
      "mkdir -p /root/.config/powershell/",
      "mkdir -p /home/${var.userName}/.config/powershell/",
      "mkdir -p /home/${var.userName}/.config/helm",
      "chown -R ${var.userName}:${var.groupName} /home/${var.userName}/.config/powershell/",
      "chown -R ${var.userName}:${var.groupName} /home/${var.userName}/.config/helm",
      # Create directory for Octopus use
      "mkdir -p /etc/octopus/default/Work",
      "chown -R ${var.userName}:${var.groupName} /etc/octopus/default/Work",
      "chmod -R 757 /etc/octopus/default/Work",
      # Remove Ubuntu reporting services
      "apt-get remove ubuntu-report popularity-contest apport whoopsie apport-symptoms -y -q",
      # Cleanup
      "apt-get autoremove -y -q",
      "apt-get clean -q",
    ]
  }

  provisioner "file" {
    source      = "../scripts/PowerShell/Microsoft.PowerShell_profile.ps1"
    destination = "/root/.config/powershell/Microsoft.PowerShell_profile.ps1"
  }

  provisioner "file" {
    source      = "../scripts/PowerShell/Microsoft.PowerShell_profile.ps1"
    destination = "/home/${var.userName}/.config/powershell/Microsoft.PowerShell_profile.ps1"
  }

  provisioner "file" {
    source      = "../scripts/PowerShell/Test-PesterTests.ps1"
    destination = "/home/${var.userName}/Test-PesterTests.ps1"
  }

  provisioner "shell" {
    inline = [
      "dos2unix /home/${var.userName}/Test-PesterTests.ps1",
      "dos2unix /root/.config/powershell/Microsoft.PowerShell_profile.ps1",
      "dos2unix /home/${var.userName}/.config/powershell/Microsoft.PowerShell_profile.ps1",
      "chown -R ${var.userName}:${var.groupName} /home/${var.userName}/Test-PesterTests.ps1",
      "chown -R ${var.userName}:${var.groupName} /home/${var.userName}/.config/powershell/Microsoft.PowerShell_profile.ps1"
    ]
  }
}