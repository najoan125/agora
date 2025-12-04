$groupChatPath = "c:\Team_project\Agora\agora_front\lib\features\chat\screens\group_chat_screen.dart"
$teamChatPath = "c:\Team_project\Agora\agora_front\lib\features\chat\screens\team_chat_screen.dart"

Get-Content $groupChatPath -TotalCount 1064 -Encoding UTF8 | Set-Content "${groupChatPath}.tmp" -Encoding UTF8
Move-Item -Force "${groupChatPath}.tmp" $groupChatPath

Get-Content $teamChatPath -TotalCount 1093 -Encoding UTF8 | Set-Content "${teamChatPath}.tmp" -Encoding UTF8
Move-Item -Force "${teamChatPath}.tmp" $teamChatPath
