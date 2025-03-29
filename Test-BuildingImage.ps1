Set-Location .\packer

packer build .

Set-Location ..
Set-Location .\docker

docker build -t worker-tools-local:alpha --attest type=provenance,mode=max .
docker scout quickview docker.io/library/worker-tools-local:alpha

Set-Location ..
docker run --rm docker.io/library/worker-tools-local:alpha pwsh -c "Invoke-Pester /home/octopus/Test-PesterTests.ps1"