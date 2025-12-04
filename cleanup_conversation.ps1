$path = "c:\Team_project\Agora\agora_front\lib\features\chat\screens\conversation_screen.dart"
Get-Content $path -TotalCount 1417 -Encoding UTF8 | Set-Content "${path}.tmp" -Encoding UTF8
Move-Item -Force "${path}.tmp" $path
