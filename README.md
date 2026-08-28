GRW EasyAntiCheat Toggle (Python Version)

What is this? This tool enables and disables EasyAntiCheat for Tom Clancy's Ghost Recon Wildlands on Windows. 
It allows Windows players to join co-op sessions with friends on Linux (including Steam Deck users running Linux-based Proton).


Currently, EasyAntiCheat automatically boots Linux players from co-op games. Until Ubisoft fixes this, all players must disable EAC for cross-platform play to work.


This Python version replaces the old .bat script, which is no longer reliable. The Python tool is safer, clearer, and prevents accidental deletion of required files.
Is it for Steam Deck players? No.

Linux players do not need this tool.

However, Linux users may need to add the following to the game's Launch Options in Steam (under the game's Properties):

-eac_launcher

Windows players do need this tool if they want to play with Linux friends.


How do I use it?

1. 	Download the three required files: GRW_EAC_toggle.py EasyAntiCheat_x64.dll.disable EasyAntiCheat_x86.dll.disable

2. 	Copy all three files into your Wildlands EasyAntiCheat folder.

2. 	If the game was installed through Steam, the folder is usually: C:\Program Files (x86)\Steam\steamapps\common\GhostReconWildlands\EasyAntiCheat\

2. 	If the game was installed through Xbox Game Pass / Ubisoft Connect, the folder is usually: C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Tom Clancy's Ghost Recon Wildlands\EasyAntiCheat\

3. 	Make sure Python 3 is installed on your system. On most systems, double-clicking GRW_EAC_toggle.py will open it with Python. If it does not, you can right-click the file, choose "Open with", and select Python, or run it from a command prompt with: python GRW_EAC_toggle.py

4. 	When you run GRW_EAC_toggle.py, a small window will open showing whether EAC is currently ENABLED or DISABLED.

5. 	Click the "Toggle EAC" button. The tool safely switches between the original DLLs and the dummy .dll.disable DLLs without deleting or renaming any of the .dll.disable files. The original DLLs are backed up and restored as needed.


Where was this information sourced? This method is based on community findings documented on ProtonDB: https://www.protondb.com/app/460930


Why do it like this? The original .bat script worked but was fragile. Windows permissions, antivirus, or timing issues could cause it to fail or delete files.


The Python version:
• 	Never deletes anything.
• 	Never renames the .dll.disable files.
• 	Uses hashing to detect the current state of the DLLs.
• 	Provides a simple graphical window for non-technical users.
• 	Ensures the original DLLs are always backed up safely.
The goal is transparency and safety: users should always know the current EAC state and be able to toggle it without risking their game installation.
