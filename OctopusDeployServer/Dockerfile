FROM octopusdeploy/octopusdeploy:latest as builder

RUN apt-get update \
    && apt-get -y upgrade

FROM scratch as intermediate

ARG User=octopus
COPY --from=builder / /

USER ${User}
WORKDIR /Octopus

ENTRYPOINT ["./install.sh"]