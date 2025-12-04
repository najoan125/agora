import os

files_to_truncate = [
    (r'c:\Team_project\Agora\agora_front\lib\features\chat\screens\group_chat_screen.dart', 1064),
    (r'c:\Team_project\Agora\agora_front\lib\features\chat\screens\team_chat_screen.dart', 1093)
]

for file_path, line_count in files_to_truncate:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines[:line_count])
        print(f"Successfully truncated {file_path}")
    except Exception as e:
        print(f"Error truncating {file_path}: {e}")
