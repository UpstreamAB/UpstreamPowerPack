Get-ChildItem  C:\ -recurse | Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-10)} | Sort-Object Length
