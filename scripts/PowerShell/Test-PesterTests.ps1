Describe 'Ubuntu-Version' {
    It 'Should Be the Correct Target Ubuntu Version' {
        $ubuntuVersion = $(lsb_release -r -s)
        $ubuntuVersion | Should -Be "24.04"
    }
}

Describe 'PowerShell-Version' {
    It 'Should Be the Correct Target PowerShell Version' {
        $powerShellVersion = $(pwsh --version)
        $powerShellVersion | Should -Be "PowerShell 7.5.0"
    }
}

Describe 'PowerShell-Profile' {
    It 'Shoud Load and Contain Necessary Functions for Octopus Automation by Default in PowerShell'{
        $addOctopusIpAddressToKeyVaultFirewallsCommandType = $((Get-Command Add-OctopusIpAddressToKeyVaultFirewalls).CommandType)
        $addOctopusIpAddressToKeyVaultFirewallsCommandType | Should -Be 'Function'
        $addOctopusIpAddressToSqlServerFirewallsCommandType = $((Get-Command Add-OctopusIpAddressToSqlServerFirewalls).CommandType)
        $addOctopusIpAddressToSqlServerFirewallsCommandType | Should -Be 'Function'
        $findTerraformExtendedExitCodeCommandType = $((Get-Command Find-TerraformExtendedExitCode).CommandType)
        $findTerraformExtendedExitCodeCommandType | Should -Be 'Function'
        $removeAzureLockCommandType = $((Get-Command Remove-AzureLock).CommandType)
        $removeAzureLockCommandType | Should -Be 'Function'
        $removeSqlServerFirewallCommandType = $((Get-Command Remove-SqlServerFirewall).CommandType)
        $removeSqlServerFirewallCommandType | Should -Be 'Function'
    }
}

Describe 'Octopus-User' {
    It 'Should Be the Correct User Context' {
        $whoAmI = $(whoami)
        $whoAmI | Should -Be 'octopus'
    }
}

Describe 'AzCli-Version' {
    It 'Should Be the Correct Target Az CLI Version' {
        $azCliVersion = $((az version | ConvertFrom-Json -Depth 100).'azure-cli')
        $azCliVersion | Should -Be "2.70.0"
    }
}

Describe 'Bicep-Version' {
    It 'Should Be the Correct bicep Version' {
        $bicepVersion = $(bicep --version)
        $bicepVersion | Should -Be "Bicep CLI version 0.33.93 (7a77c7f2a5)"
    }
}

Describe 'Gitea-Version' {
    It 'Should Be the Correct Target Gitea Version' {
        # Hacking our way to version because Go Devs don't make things easy....
        $teaVersion = $(tea --version)
        $teaVersion | Should -Be "Gitea version 1.23.5 built with GNU Make 4.3, go1.23.7 : bindata, sqlite, sqlite_unlock_notify"
    }
}

Describe 'Github-Version' {
    It 'Should Be the Correct Target GH Version' {
        $ghVersion = $(gh --version)
        $ghVersionVersion = $ghVersion[0]
        $ghVersionVersion | Should -Be "gh version 2.69.0 (2025-03-19)"
    }
}

Describe 'NPM-Version' {
    It 'Should Be the Correct Target NPM Version' {
        $npmVersion = $(npm --version)
        $npmVersion | Should -Be "11.1.0"
    }
}

Describe 'Octopus-CLI-Version' {
    It 'Should Be the Correct Octopus CLI Version' {
        $octopusVersion = $(octopus version)
        $octopusVersion | Should -Be "2.15.3"
    }
}

Describe 'Octo-CLI-Version' {
    It 'Should Be the Correct Octo CLI Version' {
        $octoVersion = $(octo version)
        $octoVersion | Should -Be "9.1.7"
    }
}