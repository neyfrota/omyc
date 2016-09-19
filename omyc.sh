#!/bin/bash
echo "=========================================="
echo "OMYC development lab"
echo "=========================================="


# ==========================================
# Put us in the right path
# ==========================================
ABSPATH=`dirname $(readlink -f $0)`
cd $ABSPATH/
if [ ! -f omyc.sh ]
then
    echo "Oops! I do not know where i am :/"
    exit;
fi


# ==========================================
# prepare dev data folder
# ==========================================
mkdir /tmp/omyc 2>/dev/null
if [ ! -d /tmp/omyc ]
then
    echo "Oops! Fail create /tmp/omyc :/"
    exit;
fi


# ==========================================
# some functions
# ==========================================
print_usage() {
	echo "usage: $0 <command>"
	echo "commands:"
	echo "  (empty) -> display status"
	echo "  start   -> start development instance"
	echo "  stop    -> stop development instance"
	echo "  log     -> tail instance log"
	echo "  rebuild -> rebuild development instance"
	echo "  shell   -> access shell at development instance"
}
set_active_instance_id() {
	#
	active_id=;
	#
	now_id=`docker ps | tail -n +2 | awk '{print $1,$2}' | grep omyc-dev | awk '{print $1}'  | head -n 1 `
	#now_id=""
	#echo "now_id=$now_id"
	if [ -z $now_id ]; then
		#echo "no now_id"
		return 1
	fi
	#
	now_status=`docker inspect --format '{{ .State.Running }}' $now_id`
	#echo "now_status=$now_status"
	if [ $now_status == "true" ]; then
		active_id=$now_id;
		return 0
	fi
	#
	#echo "not running now_status"
	return 1
}





# =====================================================================
# actions
# =====================================================================
#
# empty
if [ -z "$1" ];  then
	print_usage
	echo ""
	set_active_instance_id
	if [ -z $active_id ]; then
		echo "NO running instance"
	else 
		echo "We have a running instance id=$active_id"
	fi
	echo ""
	exit;
fi
#
if [ $1 == "log" ]; then
	set_active_instance_id
	if [ -z $active_id ]; then
		echo "No running instance"
	else 
		echo "log instance id=$active_id"
		docker logs -f -t $active_id
	fi
	exit;
fi
#
if [ $1 == "rebuild" ]; then
	docker ps -a | tail -n +2 | awk '{print $1,$2}' | grep omyc-dev | awk '{print $1}' | xargs --no-run-if-empty docker kill 
	docker ps -a | tail -n +2 | awk '{print $1,$2}' | grep omyc-dev | awk '{print $1}' | xargs --no-run-if-empty docker rm 
	docker build -t omyc-dev .
	exit;
fi
#
if [ $1 == "start" ]; then
	set_active_instance_id
	if [ -z $active_id ]; then
		echo "No running instance, Lets start"
		docker run -d -e "development=true" -p 22:22 -p 80:80 -p 443:443 -p 55555:55555 -v /tmp/omyc/:/data -v $ABSPATH/omyc:/omyc omyc-dev 
		set_active_instance_id
		if [ -z $active_id ]; then
			echo "Fail start. No running instance"
		else 
			echo "New running instance id=$active_id"
		fi
	else 
		echo "We have a running instance id=$active_id"
	fi
	exit;
fi
#
if [ $1 == "stop" ]; then
	docker ps -a | tail -n +2 | awk '{print $1,$2}' | grep omyc-dev | awk '{print $1}' | xargs --no-run-if-empty docker kill 
	set_active_instance_id
	if [ -z $active_id ]; then
		echo "No running instance"
	else 
		echo "Fail stop. We still have a running instance id=$active_id"
	fi
	exit;
fi
#
if [ $1 == "shell" ]; then
	set_active_instance_id
	if [ -z $active_id ]; then
		echo "No running instance"
	else 
		echo "Connecting to instance id=$active_id"
		docker exec -i -t $active_id /bin/bash
	fi
	exit;
fi
#




