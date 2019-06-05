<#
	.SYNOPSIS
		 Backs up files and directories to a specified location.

	.DESCRIPTION
		 Use function Backup-FilesFolders to backup source directories/files to a destination.
	       
	.PARAMETER Sources	
		Specify the source directory or file to be backed up (Can be multiple).

	.PARAMETER Destination	
		Specify the destination folder to save archived files/folders.

	.PARAMETER Compress	
		Archived files/folders will be saved in a Zip compressed archive.
 	       
	.PARAMETER Debuger	
		Debug mode.
		
	.EXAMPLE
		Backup single directory and save as compress archive.
		
		PS C:\> Backup-FilesFolders -Sources "C:\TestDirectory" -Destination "D:\BackupDirectory" -Compress

	.NOTES
		Author: Tony Cavella
		Blog  : https://revokehq.github.io
		
	.LINK
		https://github.com/revokehq/psbackup

	.LINK
		Backup-Utility	
#>

Function Backup-FilesFolders
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
        [Switch]$Compress=$false
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

		If(!$Role)
		{
			Write-Warning "To perform some operations you must run an elevated Windows PowerShell console."	
		} #End If !$Role

		Write-Debug "Setting script variables."
		[string]$Filename = "backup_$(get-date -f yyyy-MM-dd)"

		Write-Debug "Checking for valid desination."
		$DestinationCheck = $(Test-Path -Path $Destination)

		If (!$DestinationCheck)
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