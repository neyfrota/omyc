# Old Man Yells at Cloud

Minimalistic easy to use NAS service packed in a docker container to help you run your own cloud service. 

<a href="http://www.youtube.com/watch?feature=player_embedded&v=eXnrw_33HeQ
" target="_blank"><img src="http://img.youtube.com/vi/eXnrw_33HeQ/0.jpg" 
alt="alexa interaction by command line" width="850" height="480" border="1" /></a>

* Keep it simple and stupid (for a robust solution, we recommend owncloud/nextcloud)
* Web access your files (can manage, preview, upload and download)
* Sftp access your files (fast. secure. mount as local drive. native linux client. 3rd party apps for others)
* Sync folders (solid sync. linux/osx/windows/android/ios clients)
* Multi user (your mom files are your mom files. your files are your files)
* Disposable docker container (just pull latest image to upgrade)
* Portable/unlocked data (All data stored at host in plain format. We do not lock your data)
* no-ip integration (to easy and free Dynamic-DNS)

No, we did not build all from scratch. We patchwork multiple projects and build a docker image to easy deploy. This is what we use:

* Elfinder web file viewer. http://elfinder.org/
* Proftpd sftp server. http://www.proftpd.org/
* Resilio sync engine. https://www.resilio.com/individuals/
* web stack with apache, perl, Mojolicious, php, angular, bootstrap
* Ubuntu as main os. http://www.ubuntu.com/
* docker to simplify deployment

We at omyc express infinite gratitude to all this projects. "I am what I am because of who we all are." :)

# Start your own OMYC instance

Just one command line.</p>

* no need pull github repo. We use image hosted at hub.docker
* make sure you have docker
* make sure you have all exposed ports free (22, 80, 443, 55555)
* start omyc image, point to data folder at /tmp/data and expose ports 
```
docker run -d \
	-v /tmp/data:/data \
	-p 22:22 \
	-p 80:80 \
	-p 443:443 \
	-p 55555:55555 \
	omyc/omyc
```
* open your browser at https://127.0.0.1 (or host ip)
* first user is admin password admin. CHANGE THIS ASAP
* sftp to 127.0.0.1 (or host ip)

