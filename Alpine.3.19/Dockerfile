FROM alpine:3.19 as builder

COPY --from=octopusdeploy/octo:9.1.7 ./octo/. /octo/

ARG Azure_Powershell_Version=11.2.0
ARG Helm_Version=v3.7.1
ARG Kubelogin_Version=v0.0.30
ARG Terraform_Version=1.6.6

RUN apk update \
    && apk add --upgrade apk-tools \
    && apk upgrade --available \
    # Install .NET and PowerShell dependencies
    && apk add --no-cache bash ca-certificates cargo curl gcompat icu-libs krb5-libs less libffi-dev libgcc libintl libstdc++ make musl-dev ncurses-terminfo-base openssl openssl-dev pipx python3-dev py3-pip tzdata userspace-rcu zlib \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/community/ add --no-cache umoci \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/testing add --no-cache libssl1.1 \
    # .NET8 did not ship with 3.19 (See: https://github.com/dotnet/sdk/issues/37790)
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/community add --no-cache aspnetcore8-runtime dotnet8-runtime dotnet8-sdk \
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
    # Install PowerShell
    && curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    # Install Octopus.Client
    && pwsh -c 'Install-Package -Force Octopus.Client -MaximumVersion "'${Octopus_Client_Version}'" -source https://www.nuget.org/api/v2 -SkipDependencies -Verbose' \
    && octopusClientPackagePath=$(pwsh -c '(Get-Item ((Get-Package Octopus.Client).source)).Directory.FullName') \
    && cp -r $octopusClientPackagePath/lib/netstandard2.0/* . \
    # Install Az PowerShell Module(s)
    && pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'" -Verbose' \
    # Install octopus-cli
    && curl -L https://github.com/OctopusDeploy/cli/raw/main/scripts/install.sh | bash \
    # # Install octopuscli
    && echo "dotnet /octo/octo.dll \"\$@\"" > /octo/alpine \
    && ln /octo/alpine /usr/bin/octo \
    && chmod +x /usr/bin/octo \
    # Install Terraform
    && wget https://releases.hashicorp.com/terraform/${Terraform_Version}/terraform_${Terraform_Version}_linux_amd64.zip \
    && unzip terraform_${Terraform_Version}_linux_amd64.zip \
    && mv terraform /usr/bin/terraform \
    && rm -f terraform_${Terraform_Version}_linux_amd64.zip \
    && pipx install azure-cli \
    && ln -s /root/.local/bin/az /usr/bin/az \
    # Add Az CLI Extensions
    && az extension add --name azure-devops \
    && az extension add --name azure-firewall \
    && az extension add --name functionapp \
    && az extension add --name webapp

FROM scratch as final

COPY --from=builder / /