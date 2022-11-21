# Old Man Yells at Cloud

Minimalistic easy to use file storage service packed in a docker container.

The goal is serve a small group (5 to 10 users). 

In my case, I use as a easy backup storage for my family

* Keep it simple and stupid (if you need more, go nextcloud)
* Web access (can manage, preview, upload and download)
* sftp access (fast. secure. mount as local drive. native linux client. 3rd party apps for others)
* Sync service (resilio sync is solid!. linux/osx/windows/android/ios)
* Multi user (your mom files are your mom files. your files are your files)
* folder friendly (All data stored in plain files/folders. We do not lock your data)

No, we did not build all from scratch. We patchwork multiple projects and build a docker image to easy deploy. This is what we use:

* Elfinder web file manager. http://elfinder.org/
* Proftpd sftp server. http://www.proftpd.org/
* Resilio sync engine. https://www.resilio.com/individuals/
* stack with apache, perl, Mojolicious, php, angular, bootstrap
* Ubuntu as main os.
* docker to simplify deployment

We at omyc express infinite gratitude to all this projects. "I am what I am because of who we all are." :)

# Run your instance

Need NO github pull. Just use docker image 

* make sure you have docker
* make sure you have all exposed ports free (22, 80, 443, 55555)
* start omyc image exporting /data folder ato your host 

```
docker run -d \
	-v /tmp/data:/data \
	-p 22:22 \
	-p 80:80 \
	-p 443:443 \
	-p 55555:55555 \
	omyc/omyc
```
* Access https://127.0.0.1 (or host ip)
* first user is admin password admin. CHANGE THIS ASAP!
* sftp to 127.0.0.1 (or host ip)
