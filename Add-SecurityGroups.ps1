<# 
.SYNOPSIS
    Creates groups in Active Directory for new server builds

.DESCRIPTION
    Based on the name of the host, the OS, and the Environment, this script will create groups in Active Directory in the appropriate OUs.
    See the IT Group Standard for more information.

.EXAMPLE
    ./Add-SecurityGroups.ps1 -HostName isim-test-tst1 -OS Linux -Environ MSU -Desc "ISIM Test Web Servers" 

.PARAMETER HostName
    The hostname of the system to create groups for

.PARAMETER OS
    The Operating System of the system

.PARAMETER Environ
    Which environment the system is deployed in, either MSU, PS, or BNR

.PARAMETER Desc
    A short description of the system, eg. "ISIM Test Web Server"

.NOTES
    This script must be run as a user that has group creation privileges in the /Groups OU

.LINK
    https://security.montclair.edu
#>


# Gather the parameters from the command line
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$HostName,
	
   [Parameter(Mandatory=$True)]
   [string]$OS,
   
   [Parameter(Mandatory=$True)]
   [string]$Environ,
   
   [Parameter(Mandatory=$True)]
   [string]$Desc
)

## Local Function: add_group

function add_group ($Name, $Desc, $Path) {
    New-ADGroup -GroupScope Global -Name $Name -Description $Desc -Path $Path -DisplayName $Name
}

## MAIN

if($OS -like "Linux"){

    # Set the OU name based on what environment was chosen
    switch ($Environ){
        "MSU" { $Path = "OU=Linux MSU Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu" }
        "BNR" { $Path = "OU=Linux Banner Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu" }
        "PS"  { $Path = "OU=Linux Peoplesoft Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu" }
        default { Write-Error "Error 1: Environ must be MSU, BNR, or PS"; exit }
    }
    
    # Format the names of the groups to match the specs
    $NameUsers = "sec_$($HostName)_users"
    $NameAdmins = "sec_$($HostName)_admins"

    # Format the descriptions for each group
    $DescUsers = "Basic rights to $($Desc)"
    $DescAdmins = "Admin rights to $($Desc)"

    # Add the two groups
    Write-Host "Adding group: $($NameUsers) - $($DescUsers)"
    add_group $NameUsers $DescUsers $Path

    Write-Host "Adding group: $($NameAdmins) - $($DescAdmins)"
    add_group $NameAdmins $DescAdmins $Path
}
elseif ($OS -like "Windows") {

    switch ($Environ){
        "MSU" { $PathAdmins = "OU=Windows MSU Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu" }
        "BNR" { $PathAdmins = "OU=Windows Banner Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu"}
        "PS"  { $PathAdmins = "OU=Windows Peoplesoft Servers,OU=Security Groups,OU=Groups,DC=admsu,DC=montclair,DC=edu"}
    }

    $PathUsers = "OU=Remote Desktop Local Users,OU=Groups,DC=admsu,DC=montclair,DC=edu"

    # Format the names of the groups to match the specs
    $NameUsers = "rdp_$($HostName)_users"
    $NameAdmins = "sec_$($HostName)_admins"

    # Format the descriptions for each group
    $DescUsers = "Remote desktop access to $($Desc)"
    $DescAdmins = "Admin rights to $($Desc)"

    Write-Host "Adding group: $($NameUsers) - $($DescUsers)"
    add_group $NameUsers $DescUsers $PathUsers
    
    Write-Host "Adding group: $($NameAdmins) - $($DescAdmins)"
    add_group $NameAdmins $DescAdmins $PathAdmins

}
else {
    Write-Error("Error 2: OS must be either Windows or Linux")
    exit
}


