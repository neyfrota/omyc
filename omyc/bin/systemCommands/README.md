
# our webapp has no permission to kill/hup root based process

Our workaround consist in:

* a user based command "systemCommands/add" to receive and queue system command 
* a root based command "systemCommands/runQueue" (at cron) that run queued commands
* multiple "systemCommands/command.*" with possible commands to run (no free form command as root)

# Usage

* we know we have a "systemCommands/command.disconnectFtpUser" to kill ftp connections for a user (we use when change user password)
* api/web run "systemCommands/add disconnectFtpUser username" to ask
* cron run in "systemCommands/runQueue" in next minute
* systemCommands/runQueue call "systemCommands/command.disconnectFtpUser username"
