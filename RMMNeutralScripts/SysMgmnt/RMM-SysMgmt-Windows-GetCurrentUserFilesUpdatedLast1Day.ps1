$UserPath = [Environment]::GetFolderPath("user")
Get-ChildItem $UserPath -recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) } | Sort-Object Length
