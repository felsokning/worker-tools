FROM scratch

ADD ./rootfs/24.04/worker_tools.tar.xz /

ENV AZURE_CORE_COLLECT_TELEMTRY=false
ENV AZURE_CORE_DISABLE_CONFIRM_PROMPT=true
ENV AZURE_CORE_ONLY_SHOW_ERRORS=true
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV POWERSHELL_TELEMETRY_OPTOUT=1

USER octopus

# ADO Container Support
LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

#ENTRYPOINT [ "/bin/bash" ]

CMD [ "/bin/bash" ]
