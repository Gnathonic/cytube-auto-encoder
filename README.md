# cytube-auto-encoder
Turns videos into cytube ready videos. Complete with json file and tiered resolutions.


Usage.
1. Configure path variables inside the script to suite your configuration.
2. Download and add ffmpeg.exe and ffprobe.exe to the folder with these scripts.
3. Run "auto encoder.bat".
4. Add files to encode folder.
5. Enjoy.


This script has been configured to optionally be used with resilio sync to form a redundant/distributed encoding network.
Just make a sync folder for the encoding folder and use it on all the systems running this script. You can use this folder to conveniently add content from any system, even mobile.
When using multiple systems you will need to sync the "target" folder as well.
If using sync pro you can use selective sync for the target folder on encoding systems, but selective sync must be disabled for the file server.
For the "queue" folder Selective sync can be used by uploaders, but must be disabled on encoding systems.
The file server doesn't need the queue folder. And uploaders don't need access to the target folder or your file server.