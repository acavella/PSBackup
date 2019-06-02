<#
	.SYNOPSIS
		 Backup files to specified destination.

	.DESCRIPTION
		 Use function Get-WUHistory to get list of installed updates on current machine. It works similar like Get-Hotfix.
	       
	.PARAMETER ComputerName	
		Specify the name of the computer to the remote connection.
 	       
	.PARAMETER Debuger	
		Debug mode.
		
	.EXAMPLE
		Get updates histry list for sets of remote computers.
		
		PS C:\> "G1","G2" | Get-WUHistory

	.NOTES
		Author: Michal Gajda
		Blog  : http://commandlinegeeks.com/
		
	.LINK
		http://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc

	.LINK
		Get-WUList	
#>
Function Backup-Utility
{
	Param
	(
		#Mode options
		[parameter(Mandatory=$false)]
    	[switch]$Debuger=$false,
		[parameter(Mandatory=$true)]
		[String[]]$Sources,
		[parameter(Mandatory=$true)]
		[String]$Destination,
		[parameter(Mandatory=$false)]
		[Alias('Zip')]
        [Switch]$Compress
	)

	Begin
	{
		If($PSBoundParameters['Debuger'])
		{
			$DebugPreference = "Continue"
		} #End If $PSBoundParameters['Debuger'] 

		Write-Debug "Checking for administrative privileges."
		$User = [Security.Principal.WindowsIdentity]::GetCurrent()
		$Role = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

		if(!$Role)
		{
			Write-Warning "To perform some operations you must run an elevated Windows PowerShell console."	
		} #End If !$Role

		Write-Debug "Setting script variables."
		[string]$Filename = "backup_$(get-date -f yyyy-MM-dd)"

		Write-Debug "Checking for valid desination."
		$DestinationCheck = $(Test-Path -Path $Destination)

		if (!$DestinationCheck)
		{
			Write-Warning "Destination does not exist, creating directory."
			New-Item -ItemType "directory" -Path "$Destination"
		} #End If !$DesinationCheck
    }

    Process
    {
		Write-Verbose "Creating backup directory."
		New-Item -ItemType "directory" -Path "$Destination\$Filename"

		Write-Verbose "Copying files to backup directory."
		ForEach ($Source in $Sources)
		{
			Copy-Item -Path "$Source" -Destination "$Destination\$Filename" -Recurse
		}
		
		If ($Compress = $True) 
		{
			$ZipFilename = "$Destination\$Filename.zip"
			Write-Verbose "Adding files to Zip archive."
			Compress-Archive -Path "$Destination\$Filename" -DestinationPath "$ZipFilename"
			Write-Verbose "Cleaning up extra files."
			Remove-Item -Path "$Destination\$Filename" -Recurse
		}
    }

    End{}
}