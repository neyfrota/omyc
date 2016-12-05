
# Problem...
 
... our webapp has no permission to kill/hup root based process. Our workaround consist in:

* a user based command "/omyc/bin/systemCommands/add" to receive and queue system command 
* a root based command "/omyc/bin/systemCommands/runQueue" (at cron) that run queued commands
* multiple "/omyc/bin/systemCommands/command.*" with possible commands to run (no free form command as root)
* strong clean each and every string sent to command queue (no space to people inject commands)

# Example usage

* we have a "/omyc/bin/systemCommands/command.disconnectFtpUser" to kill ftp connections for a user
* user request password change at webapp
* webapp change password and run "/omyc/bin/systemCommands/add disconnectFtpUser username"
* cron (as root) run "/omyc/bin/systemCommands/runQueue" in next minute
* runQueue call "/omyc/bin/systemCommands/command.disconnectFtpUser username" as root
