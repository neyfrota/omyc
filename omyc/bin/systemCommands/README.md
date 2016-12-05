
# Problem...
 
... our webapp has no permission to kill/hup root based process. Our workaround consist in:

* a user based command "systemCommands/add" to receive and queue system command 
* a root based command "systemCommands/runQueue" (at cron) that run queued commands
* multiple "systemCommands/command.*" with possible commands to run (no free form command as root)
* strong clean each and every string sent to command queue (no space to people inject commands)

# Usage

* we have a "systemCommands/command.disconnectFtpUser" to kill ftp connections for a user when he change password
* api/web run "systemCommands/add disconnectFtpUser username" to queue this command
* cron (as root) run "systemCommands/runQueue" in next minute
* systemCommands/runQueue call "systemCommands/command.disconnectFtpUser username" as root
