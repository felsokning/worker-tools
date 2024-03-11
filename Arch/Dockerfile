ARG tag

FROM archlinux/archlinux:base-${tag} as builder

ARG Azure_Powershell_Version=11.2.0
ARG Helm_Version=v3.7.1
ARG Kubelogin_Version=v0.1.1

COPY keygen.sh /keygen.sh
COPY pacman.conf /etc/pacman.conf
COPY chaotic-mirrorlist /etc/pacman.d/chaotic-mirrorlist

ARG User=octoworker
ARG Group=octoworker
ARG OctoGroup=octopus

RUN groupadd -g 1999 ${OctoGroup} \
    && groupadd -g 2000 ${Group} \
    && useradd -m -g ${Group} -g ${OctoGroup} -s /bin/bash ${User} \
    && pacman-key --init \
    # Populate Arch Linux Keys.
    && pacman-key --populate archlinux \
    # Receive Chaotic AUR Key.
    && pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com \
    # Sign Chaotic AUR Key.
    && pacman-key --lsign-key 3056513887B78AEB \
    # Add Chaotic AUR Keyring.
    && pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    && pacman --noconfirm -Syyu \
    && pacman --noconfirm -S aspnet-runtime chaotic-aur/azure-cli curl dotnet-runtime dotnet-sdk extra/argocd extra/code \
        extra/docker extra/eksctl extra/gradle core/groff extra/jq extra/kubectl extra/maven extra/nodejs extra/rsync \
        extra/skopeo extra/terraform extra/umoci extra/yq gnupg nano pass powershell unzip wget \
    # Install ECS CLI
    && curl --silent --location "https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-v${Ecs_Cli_Version}" -o /usr/local/bin/ecs-cli \
    && chmod +x /usr/local/bin/ecs-cli \
    # Install Helm 3
    && wget --quiet -O - https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- -v ${Helm_Version} \
    # Install Istio CLI
    && curl -sL https://istio.io/downloadIstioctl | sh - \
    && mv /root/.istioctl/bin/istioctl /usr/local/bin/istioctl \
    && rm -rf /root/.istioctl \
    # Install Linkerd CLI
    && curl -sL https://run.linkerd.io/install | sh \
    && mv /root/.linkerd2/bin/linkerd /usr/local/bin \
    && rm -rf /root/.linkerd2 \
    # Install octopus-cli
    && curl -L https://github.com/OctopusDeploy/cli/raw/main/scripts/install.sh | bash \
    # Install Az PowerShell Module(s)
    && pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'" -Verbose' \
    # Disable Az CLI Telemetry Collection
    && az config set core.collect_telemetry=no \
    # Install Azure Kubelogin
    && wget --quiet https://github.com/Azure/kubelogin/releases/download/${Kubelogin_Version}/kubelogin-linux-amd64.zip \
    && unzip kubelogin-linux-amd64.zip -d kubelogin-linux-amd64 \
    && mv kubelogin-linux-amd64/bin/linux_amd64/kubelogin /usr/local/bin \
    && rm -rf kubelogin-linux-amd64 \
    && rm kubelogin-linux-amd64.zip \
    # Setup for Docker Credentials Helper
    && chmod +x /keygen.sh \
    && gpg2 --update-trustdb \
    && wget -O /usr/bin/docker-credential-pass https://github.com/docker/docker-credential-helpers/releases/download/v0.8.1/docker-credential-pass-v0.8.1.linux-amd64 \
    && chmod +x /usr/bin/docker-credential-pass \
    && pacman --noconfirm -Scc

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
    && pass init $(echo $fingerprint) \
    # Build-Kit Sandbox keeps a lock, so let's remove it
    && rm ~/.gnupg/public-keys.d/pubring.db.lock