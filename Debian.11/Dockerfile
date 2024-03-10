FROM debian:bullseye-slim as builder

ARG Azure_Powershell_Version=11.2.0
ARG Helm_Version=v3.7.1
ARG Octopus_Cli_Legacy_Version=9.1.7
ARG Octopus_Cli_Version=1.7.1
ARG Terraform_Version=1.6.6-1

ARG User=octoworker
ARG Group=octoworker

COPY keygen.sh /keygen.sh

RUN groupadd ${Group} \
    && useradd -m -g ${Group} -s /bin/bash ${User} \
    && apt-get update \
    && apt-get dist-upgrade \
    && apt-get upgrade \
    && apt-get install -y apt-transport-https apt-utils augeas-tools ca-certificates curl docker git gnupg2 gradle jq libc6 libgcc1 libgcc-s1 \
        libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 lsb-release maven openssh-client pass rsync software-properties-common unzip wget zlib1g \
    && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm -f packages-microsoft-prod.deb \
    && curl -sSfL https://apt.octopus.com/public.key | apt-key add - \
    && sh -c "echo deb https://apt.octopus.com/ stable main > /etc/apt/sources.list.d/octopus.com.list" \
    && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && wget --quiet -O - https://deb.nodesource.com/setup_20.x | bash \
    && wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_22.04/Release.key -O- | apt-key add - \
    && echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/" / > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
    && apt-get update \
    && apt-get install -y azure-cli aspnetcore-runtime-8.0 dotnet-runtime-8.0 dotnet-sdk-8.0 nodejs octopuscli=${Octopus_Cli_Legacy_Version} octopus-cli=${Octopus_Cli_Version} powershell skopeo terraform=${Terraform_Version} \
    && wget --quiet -O - https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- -v ${Helm_Version} \
    && curl -sL https://istio.io/downloadIstioctl | sh - \
    && mv /root/.istioctl/bin/istioctl /usr/local/bin/istioctl \
    && rm -rf /root/.istioctl \
    && curl -sL https://run.linkerd.io/install | sh \
    && cp /root/.linkerd2/bin/linkerd /usr/local/bin \
    && rm -rf /root/.linkerd2 \
    && pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'" -Verbose' \
    && chmod +x /keygen.sh
 
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