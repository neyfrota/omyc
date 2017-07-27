# "Old Man Yells at Cloud" development lab

Resources to run omyc in development mode, to hack/edit/modify.

* tested at linux/ubuntu/osx (experimental on osx. no idea about others)
* make sure you have docker
* make sure all exported ports are free (22, 80, 443, 55555)
* clone this repo `git clone git@github.com:nonlinear/cloud.git ./`
* run `./dev` to known status and commands
* run `./dev build` to build devlab image
* run `./dev start` to start devlab image
* run `./dev log` to see log in real time
* access web frontend at https://127.0.0.1 or https://localhost (user is `admin`, password `admin`)
* access sftp at 127.0.0.1 (admin/admin)
* run `./dev shell ` to enter shell at devlab image
* ./omyc folder (at host) is exported (at instance) to easy hack/edit/modify at host
* omyc is started in development mode (restart if source files change, use less resources)
* have fun hacking

