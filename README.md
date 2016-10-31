# "Old Man Yells at Cloud" development lab

Devlab are resources to run omyc in development mode, to hack/edit/modify.
If your plan its just use/launch/run your own omyc instance, visit https://omyc.github.io/  

To hack/edit/modify:

* make sure you have docker
* make sure all exported ports are free 
* tested at linux/ubuntu/osx (experimental on osx. no idea about others)
* clone this repo `git clone git@github.com:omyc/docker.git ./`
* run `./omyc.sh` to known status and commands
* run `./omyc.sh build` to build devlab image
* run `./omyc.sh start` to start devlab image
* run `./omyc.sh log` to see log in real time
* access web frontend at https://127.0.0.1 (admin/admin) 
* access sftp at 127.0.0.1 (admin/admin) 
* run `./omyc.sh shell ` to enter shell at devlab image
* ./omyc folder (at host) is exported (at instance) to easy hack/edit/modify at host
* omyc is started (maybe) in development mode (restart if source files change, use less resources)
* have fun hacking

