This batch script enables and disables EasyAntiCheat on for Tom Clancy's Ghost Recon Wildlands for users on Windows who wish to play co-op with friends on Linux (like the Steam Deck.)

Currently, EasyAntiCheat automatically boots Linux players from co-op games. This can be fixed by Ubisoft, but until it is EasyAntiCheat must be disabled by all players for cross-platform play.

Linux users do not require this script, but may need to add `-eac_launcher` to the Launch Properties of their Wildlands game in Steam (under the game's Properties.)

To run on Windows, download and copy all three files to your Wildlands installation folder. Double-click the `.bat` file to run it (or right-click and "Run as administrator" if elevated permissions are required.)

If the game was installed through Steam then your Wildlands installation folder may be `C:\Program Files (x86)\Steam\steamapps\common\GhostReconWildlands\`.

If the Game was installed through Xbox Game Pass then your Wildlands installation folder may be `C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Tom Clancy's Ghost Recon Wildlands\`.

This script relies heavily on information found at https://www.protondb.com/app/460930.

tl;dr

I wrote this as a script for transparency. The intent is for the script to inform non-technical users of the current state of EasyAntiCheat and give them the chance to easily disable it without potentially accidentally deleting the files required to re-enable it.
