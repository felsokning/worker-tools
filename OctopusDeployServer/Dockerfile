FROM octopusdeploy/octopusdeploy:latest as builder

RUN apt-get update \
    && apt-get -y upgrade \
    && usermod -a -G docker octopus \
    && chown -R octopus:octopus /opt/

FROM scratch as intermediate

ARG User=octopus
COPY --from=builder / /

WORKDIR /Octopus

ENTRYPOINT ["./install.sh"]