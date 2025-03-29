function Add-OctopusIpAddressToKeyVaultFirewalls {
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string]$ResourceGroup,
        [switch]$RemovePreviousEntries
    )

    $currentIpAddress = Invoke-RestMethod -Uri "https://ifconfig.me/ip"
    $targetKeyVaults = az keyvault list --resource-group $ResourceGroup | ConvertFrom-Json -Depth 100 | Sort-Object -Property name | Select-Object -ExpandProperty name
    foreach($targetKeyVault in $targetKeyVaults) {
        if($RemovePreviousEntries) {
            $previousEntries = az keyvault network-rule list --resource-group $ResourceGroup --name $targetKeyVault | ConvertFrom-Json -Depth 100 | Select-Object -ExpandProperty ipRules | Sort-Object -Property value | Select-Object -ExpandProperty value
            if ($null -ne $previousEntries) {
                foreach($previousEntry in $previousEntries) {
                    Write-Output "Removing IP Address '$($previousEntry)' from the Firewall for '$($targetKeyVault)' on '$($ResourceGroup)'"
                    az keyvault network-rule remove --resource-group $ResourceGroup --name $targetKeyVault --ip-address $previousEntry | Out-Null
                }
            }
        }

        Write-Output "Adding IP Address '$($currentIpAddress)' to the Firewall for '$($targetKeyVault)' on '$($ResourceGroup)'"
        az keyvault network-rule add --resource-group $ResourceGroup --name $targetKeyVault --ip-address $currentIpAddress | Out-Null
    }
}

function Add-OctopusIpAddressToSqlServerFirewalls {
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string]$ResourceGroup
    )

    $sqlServerFirewallRuleName = "octopus-workers"
    $currentIpAddress = Invoke-RestMethod -Uri "https://ifconfig.me/ip"
    $targetSqlServers = az sql server list --resource-group $ResourceGroup | ConvertFrom-Json -Depth 100 | Select-Object -ExpandProperty name
    foreach($targetSqlServer in $targetSqlServers) {
        $sqlServerFirewallRule = az sql server firewall-rule show --resource-group $ResourceGroup --server $targetSqlServer --name $sqlServerFirewallRuleName | ConvertFrom-Json -Depth 100 -ErrorAction SilentlyContinue
        if($null -eq $sqlServerFirewallRule) {
            # The SQL Server Firewall Doesn't Exist, So Let's Create It
            Write-Output -InputObject $("Creating SQL Server Firewall Rule $($sqlServerFirewallRuleName) on the SQL Server $($targetSqlServer) on $($ResourceGroup) with IP Address $($currentIpAddress.Trim()) added.")
            az sql server firewall-rule create --resource-group $ResourceGroup --server $targetSqlServer --name $sqlServerFirewallRuleName --start-ip-address $currentIpAddress.Trim() --end-ip-address $currentIpAddress.Trim() 
        }
        else {
            # The SQL Server Firewall Rule Exists, So Let's Modify It If Our Address Doesn't Exist In it
            if (($sqlServerFirewallRule.startIpAddress.Trim() -ne $currentIpAddress.Trim()) -or ($sqlServerFirewallRule.endIpAddress.Trim() -ne $currentIpAddress.Trim())) {
                Write-Output -InputObject $("Modifying SQL Server Firewall Rule $($sqlServerFirewallRuleName) on the SQL Server $($targetSqlServer) on $($ResourceGroup) with IP Address $($currentIpAddress.Trim()).")
                az sql server firewall-rule update --ids $sqlServerFirewallRule.id --start-ip-address $currentIpAddress.Trim() --end-ip-address $currentIpAddress.Trim() | Out-Null
            }
            else {
                Write-Output -InputObject $("No Modifications of the SQL Server Firewall Rule $($sqlServerFirewallRuleName) on the SQL Server $($targetSqlServer) on $($ResourceGroup) were required, as IP Address $($currentIpAddress.Trim()) already existed.")
            }
        }
    }
}

function Find-TerraformExtendedExitCode {
    param (
        [ValidateNotNullOrWhiteSpace()]
        [string]$VariableName,
        [ValidateNotNullOrWhiteSpace()]
        [string]$VariableValue
    )

    # NOTE: This depends on using the -detailed-exitcode flag in terraform
    # SEE: https://developer.hashicorp.com/terraform/cli/commands/plan#detailed-exitcode
    if($LASTEXITCODE -ne 0) {
        if($LASTEXITCODE -eq 2) {
            Set-OctopusVariable -Name $VariableName -Value $VariableValue
        }
    }
}

function Remove-AzureLock {
    param (
        [ValidateNotNullOrWhiteSpace()]
        [string]$ResourceGroup,
        [ValidateNotNullOrWhiteSpace()]
        [string]$LockName
    )

    $locks = az lock list --resource-group $ResourceGroup | ConvertFrom-Json -Depth 100 | Sort-Object -Property name
    foreach($lock in $locks) {
        if($lock.Contains($LockName)) {
            Write-Output -InputObject $("Deleting Lock $($lock.name) on Resource Group $($lock.resourceGroup)")
            az lock delete --resource-group $ResourceGroup --ids $lock.id
        }
    }
}

function Remove-SqlServerFirewall {
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string]$ResourceGroup,
        [ValidateNotNullOrWhiteSpace()]
        [string]$SqlServerFirewallRuleName
    )

    $sqlServerFirewallRuleName = "octopus-workers"
    $currentIpAddress = Invoke-RestMethod -Uri "https://ifconfig.me/ip"
    $targetSqlServers = az sql server list --resource-group $ResourceGroup | ConvertFrom-Json -Depth 100 | Select-Object -ExpandProperty name
    foreach($targetSqlServer in $targetSqlServers) {
        $sqlServerFirewallRule = az sql server firewall-rule show --resource-group $ResourceGroup --server $targetSqlServer --name $sqlServerFirewallRuleName | ConvertFrom-Json -Depth 100 -ErrorAction SilentlyContinue
        if($null -eq $sqlServerFirewallRule) {
            # The SQL Server Firewall Doesn't Exist, So Let's Create It
            Write-Output -InputObject $("Removing SQL Server Firewall Rule $($sqlServerFirewallRuleName) on the SQL Server $($targetSqlServer) on $($ResourceGroup) with IP Address $($currentIpAddress.Trim()) added.")
            az sql server firewall-rule delete --resource-group $ResourceGroup --server $targetSqlServer --name $sqlServerFirewallRuleName
        }
        else {
            Write-Output -InputObject $("No Modifications of the SQL Server Firewall Rule $($sqlServerFirewallRuleName) on the SQL Server $($targetSqlServer) on $($ResourceGroup) were required, as the rule did not exist.")
        }
    }
}