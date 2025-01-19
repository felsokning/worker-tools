<img src="./images/bmc_qr.png"  width=10% height=10% alt="Buy Me a Coffee!">  &larr; If you would like to buy me a coffee

![workflow](https://img.shields.io/github/actions/workflow/status/felsokning/worker-tools/docker-build-tag-and-publish.yaml) ![last commit](https://img.shields.io/github/last-commit/felsokning/worker-tools) ![commits since release](https://img.shields.io/github/commits-since/felsokning/worker-tools/latest.svg) ![top languages](https://img.shields.io/github/languages/top/felsokning/worker-tools) ![language count](https://img.shields.io/github/languages/count/felsokning/worker-tools) ![sponsors](https://img.shields.io/github/sponsors/felsokning)

# Worker Tools

Unofficially sanctioned worker images for Octopus Deploy available on [docker hub](https://hub.docker.com/r/felsokning/worker-tools)


| Operating System         | Installed Tools and Versions                                                           |
|--------------------------|----------------------------------------------------------------------------------------|
| Ubuntu 22.04             | ([Dockerfile](https://github.com/felsokning/worker-tools/blob/main/docker/Dockerfile)) |


## Management
The Worker Tools images provided by this repository are currently updated on at-best effort basis. This repository should contain the latest stable versions of all of the tools.

PRs are welcome. 

If the tools or the way they are managed don't fit your particular use case, it is easy to [create your own images](https://octopus.com/docs/projects/steps/execution-containers-for-workers#which-image) to use as execution containers.

## Getting Started
See the docs to get started using the `felsokning/worker-tools` image as an [execution container for workers](https://octopus.com/docs/deployment-process/execution-containers-for-workers).

The images I publish are [semantically versioned](https://semver.org/). 

To ensure stability within your deployment processes, I do not publish non-semantically versioned builds, to prevent breaking your deployment process. Use the full `major.minor.patch` tag when using the `felsokning/worker-tools` image - for example, use `felsokning/worker-tools:4.0.0`. 

# Contribute
![contributions](https://img.shields.io/badge/contributions-welcome-green)
