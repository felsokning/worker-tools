
FROM archlinux:base-devel-20240101.0.204074 as toolsbuilder

# Fix for pipx breaking docker output (via emoji)
ENV USE_EMOJI=false

# NOTE: makepkg output goes via stderror, so we have to silence this or we fill the runner's build log and the build fails.
RUN pacman-key --init \
    && pacman -Syu --noconfirm \
    && pacman -S --noconfirm cargo git go go-md2man make python python-pipx \
    && useradd -m -G wheel builder \
    && passwd -d builder \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    # Install Az CLI
    && pipx ensurepath \
    && pipx install azure-cli \
    # Make Umoci to Get Around CVEs (No New Releases Published Since 2022)
    && git clone https://github.com/opencontainers/umoci.git \
    && cd umoci \
    && make -si DESTDIR=/ install > /dev/null \
    && cd / \
    && rm -rf umoci \
    # Make MSFT SQL Server Tools
    && su - builder -c "git clone https://aur.archlinux.org/libldap24.git" \
    && su - builder -c "cd libldap24 && (makepkg -sirc --noconfirm > /dev/null 2>&1)" \
    && su - builder -c "git clone https://aur.archlinux.org/mssql-server.git" \
    && su - builder -c "cd mssql-server && (makepkg -sirc --noconfirm > /dev/null 2>&1)" \
    && su - builder -c "git clone https://aur.archlinux.org/msodbcsql.git" \
    && su - builder -c "cd msodbcsql && (makepkg -sirc --noconfirm > /dev/null 2>&1)" \
    && su - builder -c "git clone https://aur.archlinux.org/mssql-tools.git" \
    && su - builder -c "cd mssql-tools && (makepkg -sirc --noconfirm > /dev/null 2>&1)"

FROM archlinux:base-20240101.0.204074 as intermediary

ARG Azure_Powershell_Version=11.2.0
ARG Helm_Version=v3.7.1
ARG Kubelogin_Version=v0.0.30
ARG Octopus_Client_Version=9.1.7
ARG Powershell_Version=7.4.1
ARG Terraform_Version=1.6.6-1

COPY --from=toolsbuilder home/builder/libldap24/libldap24-2.4.59-2-x86_64.pkg.tar.zst /libldap24-2.4.59-2-x86_64.pkg.tar.zst
COPY --from=toolsbuilder home/builder/mssql-server/mssql-server-16.0.4105.2-1-x86_64.pkg.tar.zst /mssql-server-16.0.4105.2-1-x86_64.pkg.tar.zst
COPY --from=toolsbuilder home/builder/msodbcsql/msodbcsql-18.3.2.1-2-x86_64.pkg.tar.zst /msodbcsql-18.3.2.1-2-x86_64.pkg.tar.zst
COPY --from=toolsbuilder home/builder/mssql-tools/mssql-tools-18.2.1.1-1-x86_64.pkg.tar.zst /mssql-tools-18.2.1.1-1-x86_64.pkg.tar.zst
COPY --from=toolsbuilder /usr/local/bin/umoci /usr/local/bin/umoci
# IMPORTANT: The preceding and trailing '.' are required to not overwrite any existing files altogether (if any)
COPY --from=toolsbuilder ./root/.local/. /root/.local/

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=true
ENV POWERSHELL_TELEMETRY_OPTOUT=1

RUN pacman-key --init \
    && pacman -Syy --noconfirm \
    && pacman -Syu --noconfirm \
    && pacman -U --noconfirm /libldap24-2.4.59-2-x86_64.pkg.tar.zst \
    && pacman -U --noconfirm /mssql-server-16.0.4105.2-1-x86_64.pkg.tar.zst \
    && pacman -U --noconfirm /msodbcsql-18.3.2.1-2-x86_64.pkg.tar.zst \
    && pacman -U --noconfirm /mssql-tools-18.2.1.1-1-x86_64.pkg.tar.zst \
    && rm -f /libldap24-2.4.59-2-x86_64.pkg.tar.zst \
    && rm -f /mssql-server-16.0.4105.2-1-x86_64.pkg.tar.zst \
    && rm -f /msodbcsql-18.3.2.1-2-x86_64.pkg.tar.zst \
    && rm -f /mssql-tools-18.2.1.1-1-x86_64.pkg.tar.zst \
    && pacman -S --noconfirm aspnet-runtime-8.0 bash ca-certificates curl diffutils dotnet-runtime-8.0 dotnet-sdk-8.0 git glibc gnupg gradle groff libffi maven openssl rsync skopeo tar unzip wget \
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
    # Install octopus-cli
    && curl -L https://github.com/OctopusDeploy/cli/raw/main/scripts/install.sh | bash \
    # Install octopuscli
    && wget -O OctopusTools.9.1.7.linux-x64.tar.gz https://download.octopusdeploy.com/octopus-tools/9.1.7/OctopusTools.9.1.7.linux-x64.tar.gz \
    && tar zxf OctopusTools.9.1.7.linux-x64.tar.gz \
    && rm -f OctopusTools.9.1.7.linux-x64.tar.gz \
    && mv octo /usr/bin/octo \
    && chmod +x /usr/bin/octo \
    # Install PowerShell
    && curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${Powershell_Version}/powershell-${Powershell_Version}-linux-x64.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && rm -f /tmp/powershell.tar.gz \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    # Install Octopus.Client
    && pwsh -c 'Install-Package -Force Octopus.Client -MaximumVersion "'${Octopus_Client_Version}'" -source https://www.nuget.org/api/v2 -SkipDependencies -Verbose' \
    && octopusClientPackagePath=$(pwsh -c '(Get-Item ((Get-Package Octopus.Client).source)).Directory.FullName') \
    && cp -r $octopusClientPackagePath/lib/netstandard2.0/* . \
    # Install Az PowerShell Module(s)
    && pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'" -Verbose' \
    # Install Az CLI
    && ln -s /root/.local/bin/az /usr/bin/az \
    # Disable Az CLI Telemetry Collection
    && az config set core.collect_telemetry=no \
    # Add Az CLI Extensions
    && az extension add --name azure-devops \
    && az extension add --name azure-firewall \
    && az extension add --name functionapp \
    && az extension add --name webapp \
    # Install Terraform from Archive Package[s]
    && pacman -U --noconfirm https://archive.archlinux.org/packages/t/terraform/terraform-${Terraform_Version}-x86_64.pkg.tar.zst \
    && pacman -Scc --noconfirm

FROM scratch as final

COPY --from=intermediary / /