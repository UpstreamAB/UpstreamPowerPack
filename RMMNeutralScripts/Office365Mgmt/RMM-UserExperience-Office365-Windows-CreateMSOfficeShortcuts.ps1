<#
=================================================================================
Filename:           RMM-UserExperience-Office365-Windows-CreateMSOfficeShortcuts.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

# Let's look for Office 2016 on the local machine. Winword.exe 32Bit are used to validate.
# We are creating shortcuts for Outlook, Word and Excel.
If (Test-Path "C:\Program Files (x86)\Microsoft Office\Root\Office16\Winword.exe"){
    # Let's create a shortcut for Microsoft Outlook.
	$SourceFileLocation = "C:\Program Files (x86)\Microsoft Office\Root\Office16\Outlook.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Outlook.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
	
	# Let's create a shortcut for Microsoft Word.
	$SourceFileLocation = "C:\Program Files (x86)\Microsoft Office\Root\Office16\Winword.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Word.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
	
	# Let's create a shortcut for Microsoft Excel.
	$SourceFileLocation = "C:\Program Files (x86)\Microsoft Office\Root\Office16\Excel.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Excel.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
}

# Let's look for Office 2016 on the local machine. Winword.exe 64Bit are used to validate.
# We are creating shortcuts for Outlook, Word and Excel.
If (Test-Path -Path "C:\Program\Microsoft Office\Root\Office16\Outlook.exe"){
    # Let's create a shortcut for Microsoft Word.
	$SourceFileLocation = "C:\Program\Microsoft Office\Root\Office16\Outlook.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Outlook.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
	
	# Let's create a shortcut for Microsoft Word.
	$SourceFileLocation = "C:\Program\Microsoft Office\Root\Office16\Winword.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Word.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
	
	# Let's create a shortcut for Microsoft Excel.
	$SourceFileLocation = "C:\Program\Microsoft Office\Root\Office16\Excel.exe"
	$ShortcutLocation = "C:\Users\public\Desktop\Excel.lnk"
	#New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
	#-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
	$WScriptShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
	$Shortcut.TargetPath = $SourceFileLocation
	#Save the Shortcut to the TargetPath
	$Shortcut.Save()
}
