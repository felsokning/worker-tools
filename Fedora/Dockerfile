FROM fedora:40 as builder

ARG Azure_Powershell_Version=11.2.0
ARG Helm_Version=v3.7.1
ARG Kubelogin_Version=v0.0.30
ARG Terraform_Version=1.6.6

COPY keygen.sh /keygen.sh

ARG User=octoworker
ARG Group=octoworker

RUN groupadd ${Group} \
    && useradd -m -g ${Group} -s /bin/bash ${User} \
    && dnf remove 'dotnet*' 'aspnet*' 'netstandard*' \
    && dnf update -y \
    && dnf upgrade -y \
    && dnf install aspnetcore-runtime-8.0 azure-cli curl dotnet-runtime-8.0 dotnet-sdk-8.0 git gnupg2 libicu make nano openssl pass python3-pip unzip wget -y \
    # Add MSFT Respository
    && wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh --version latest \
    && ./dotnet-install.sh --version latest --runtime aspnetcore \
    && ./dotnet-install.sh --version latest --runtime dotnet \
    # Install PowerShell
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/microsoft.repo \
    && dnf makecache \
    && dnf install powershell -y \
    # Install Helm 3
    && wget --quiet -O - https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- -v ${Helm_Version} \
    # Install Istio CLI
    && curl -sL https://istio.io/downloadIstioctl | sh - \
    && mv /root/.istioctl/bin/istioctl /usr/local/bin/istioctl \
    && rm -rf /root/.istioctl \
    # Install kubectl
    && curl -LO https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin \
    # Install kubelogin
    && wget https://github.com/Azure/kubelogin/releases/download/${Kubelogin_Version}/kubelogin-linux-amd64.zip \
    && unzip kubelogin-linux-amd64.zip -d kubelogin-linux-amd64 \
    && mv kubelogin-linux-amd64/bin/linux_amd64/kubelogin /usr/local/bin \
    && rm -rf kubelogin-linux-amd64 \
    && rm kubelogin-linux-amd64.zip \
    # Install Linkerd CLI
    && curl -sL https://run.linkerd.io/install | sh \
    && mv /root/.linkerd2/bin/linkerd /usr/local/bin \
    && rm -rf /root/.linkerd2 \
    # Install Octopus.Client
    && pwsh -c 'Install-Package -Force Octopus.Client -MaximumVersion "'${Octopus_Client_Version}'" -source https://www.nuget.org/api/v2 -SkipDependencies -Verbose' \
    && octopusClientPackagePath=$(pwsh -c '(Get-Item ((Get-Package Octopus.Client).source)).Directory.FullName') \
    && cp -r $octopusClientPackagePath/lib/netstandard2.0/* . \
    # Install Az PowerShell Module(s)
    && pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'" -Verbose' \
    # Install octopus-cli
    && curl -L https://github.com/OctopusDeploy/cli/raw/main/scripts/install.sh | bash \
    # Install octopuscli
    && wget -O OctopusTools.9.1.7.linux-x64.tar.gz https://download.octopusdeploy.com/octopus-tools/9.1.7/OctopusTools.9.1.7.linux-x64.tar.gz \
    && tar zxf OctopusTools.9.1.7.linux-x64.tar.gz \
    && rm -f OctopusTools.9.1.7.linux-x64.tar.gz \
    && mv octo /usr/bin/octo \
    && chmod +x /usr/bin/octo \
    # Install Terraform
    && wget https://releases.hashicorp.com/terraform/${Terraform_Version}/terraform_${Terraform_Version}_linux_amd64.zip \
    && unzip terraform_${Terraform_Version}_linux_amd64.zip \
    && mv terraform /usr/bin/terraform \
    && rm -f terraform_${Terraform_Version}_linux_amd64.zip \
    # Add Az CLI Extensions
    && az extension add --name azure-devops \
    && az extension add --name azure-firewall \
    && az extension add --name functionapp \
    && az extension add --name webapp \
    # Make Umoci to Get Around CVEs (No New Releases Published Since 2022)
    && git clone https://github.com/opencontainers/umoci.git \
    && cd umoci \
    && make -si DESTDIR=/ install > /dev/null \
    && cd / \
    && rm -rf umoci 

FROM scratch as intermediary

ARG User=octoworker
COPY --from=builder / /

USER ${User}
RUN mkdir -p /home/${User}/.docker/ \
    && touch /home/${User}/.docker/config.json \
    && printf "{\n\t\"credsStore\":\"pass\"\n}\n" >> /home/${User}/.docker/config.json \
    && export GPG_TTY=$(tty) \
    && /keygen.sh \
    && fingerprint=$(gpg2 --list-keys | grep -Po '\w{20,}') \
    && pass init $(echo $fingerprint)