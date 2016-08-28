# "Old Man Yells at Cloud"
We are a minimal, self-hosted, easy to use file storage service, packed as a docker container. We help you run your own cloud service and rename "in the cloud" to "in my cloud". 

**Features** 
* Keep it simple and stupid (for a robust solution, we recommend owncloud)
* Web access to your files (can manage, preview, upload and download)
* Sftp access to your files (fast. secure. mount as local drive. native linux client. 3rd party apps for others)
* Sync folders (solid sync. linux/osx/windows/android/ios clients)
* Multi user (your mom files are your mom files. your files are your files)
* Disposable docker container (just pull latest image to upgrade)
* Portable/unlocked data (All data stored at host in plain format. We do not lock your data)
* no-ip integration (to easy and free Dynamic-DNS)

[![A poor edited video](http://img.youtube.com/vi/eXnrw_33HeQ/0.jpg)](http://www.youtube.com/watch?v=eXnrw_33HeQ)

No, we did not build all from scratch. We patchwork multiple projects and build a docker image to easy deploy. 

**This is what we use**
* Elfinder for web file view. http://elfinder.org/
* Proftpd as sftp server. http://www.proftpd.org/
* Btsync as sync engine. https://www.getsync.com/
* web stack with apache, perl, Mojolicious, php, angular, bootstrap
* Ubuntu as main os. http://www.ubuntu.com/
* docker to simplify deployment

We at omyc express infinite gratitude to all this projects. **"I am what I am because of who we all are."** :)

## Run your own OMYC instance
It takes 2 command lines to start a OMYC instance. (details at ["install recipes"](https://github.com/neyfrota/omyc/wiki/install-recipes) )
* no need pull github repo. We use image hosted at [hub.docker](https://hub.docker.com/r/omyc/main/)
* make sure you have docker
* make sure you have all exposed ports free (22, 80, 443, 55555)
* create a folder in your host machine to hold omyc data (users files and system settings)
```bash
mkdir /tmp/data
```
* start omyc/main docker image, point to data folder and expose ports
```bash
docker run -d \
          -v /tmp/data:/data \
          -p 22:22 \
          -p 80:80 \
          -p 443:443 \
          -p 55555:55555 \
          omyc/main
```
* open your browser at https://127.0.0.1 (or host ip)
* first user is admin password admin. CHANGE THIS ASAP
* sftp to 127.0.0.1 (or host ip)



## More information
To understand how works, roadmap or branch your version, please visit [wiki](https://github.com/neyfrota/omyc/wiki)
