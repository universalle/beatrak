declare -a BEAPLANE_PIDS
declare -a ENVOY_PIDS
declare -a OBUS_CLIENT_PIDS

kill_obus_server_60001() {
    # need to do this twice
    (forever stopall &>>$LOGFILE)&
    (forever stopall &>>$LOGFILE)&
    forever cleanlogs
}


kill_obus_server_all() {

    local log=${2:-$LOGFILE}
    
    # need to do this twice
    (forever stopall &>>$log)&
    (forever stopall &>>$log)&
    forever cleanlogs
}

run_obus_server_60001() {
    (DEBUG=obus-server:* PORT=60001 ID=60001 forever start --minUptime=1000 --spinSleepTime=1000 --append -l /tmp/test-obus-server-60001-run.log -o /dev/null -e /dev/null ../../src/obus/obus-server.js &>> $LOGFILE)&
}


run_obus_server_60002() {

    local log=${1:-$LOGFILE}
    
    (DEBUG=obus-server:* PORT=60002 ID=60002 forever start --minUptime=1000 --spinSleepTime=1000 --append -l $log -o /dev/null -e /dev/null ../../src/obus/obus-server.js &>> $LOGFILE)&
}



# pass $1 config file location
run_envoy() {
    local log=${2:-$LOGFILE}

    local pid_file="/tmp/envoy.pid"
    log "RUN_ENVOY(): start..."
    log "RUN_ENVOY(): LOGFILE="$log

    if [ -e $pid_file ]; then
	log "RUN_ENVOY(): $pid_file exists"
	return
    else
	log "RUN_ENVOY(): $pid_file does not exist"
	(${ENVOY} -c $1 --drain-time-s 1 --v2-config-only &>> $log)&
	local pid=$!
	echo $pid &> $pid_file
	ENVOY_PIDS[${#ENVOY_PIDS}]=$ENVOY_PID
    fi
    log "RUN_ENVOY(): finish."
}

kill_envoy() {
    local pid_file="/tmp/envoy.pid"
    log "KILL_ENVOY(): start..."
    log "KILL_ENVOY(): ENVOY_PIDS=${ENVOY_PIDS[@]}"

    if [ -e $pid_file ]; then
	log "KILL_ENVOY(): $pid_file exists"
	pid=$(cat $pid_file)
	log "KILL_ENVOY(): killing envoy pid=$pid..."
	kill $pid || true
	log "KILL_ENVOY(): waiting..."
	wait $pid 2> /dev/null || true
	log "KILL_ENVOY(): removing ${pid_file}..."
	rm -f $pid_file
    else
	log "KILL_ENVOY(): $pid_file does not exist"
    fi
    log "KILL_ENVOY(): finish."
}


run_beaplane() {
    local log=${1:-$LOGFILE}
    touch $log
    
    local pid_file="/tmp/beaplane.pid"
    log "RUN_BEAPLANE(): start..."
    log "RUN_BEAPLANE(): LOGFILE="$log

    if [ -e $pid_file ]; then
	log "RUN_BEAPLANE(): $pid_file exists"
	return
    else
	log "RUN_BEAPLANE(): $pid_file does not exist"
	(../../src/beaplane/beaplane -debug &>> $log)&
	local pid=$!
	echo $pid &> $pid_file
	BEAPLANE_PIDS[${#BEAPLANE_PIDS}]=$pid
    fi
    log "RUN_BEAPLANE(): finish."
}

kill_beaplane() {
    local pid_file="/tmp/beaplane.pid"
    log "KILL_BEAPLANE(): start..."
    log "KILL_BEAPLANE(): BEAPLANE_PIDS=${BEAPLANE_PIDS[@]}"

    if [ -e $pid_file ]; then
	log "KILL_BEAPLANE(): $pid_file exists"
	pid=$(cat $pid_file)
	log "KILL_BEAPLANE(): killing beaplane pid=$pid..."
	kill $pid || true
	log "KILL_BEAPLANE(): waiting..."
	wait $pid 2> /dev/null || true
	log "KILL_BEAPLANE(): removing ${pid_file}..."
	rm -f $pid_file
    else
	log "KILL_BEAPLANE(): $pid_file does not exist"
    fi
    log "KILL_BEAPLANE(): finish."
}

write_obus_client_pid() {
    log "WRITE_OBUS_CLIENT_PID(): OBUS_CLIENT_PIDFILE=$OBUS_CLIENT_PIDFILE"
    touch $OBUS_CLIENT_PIDFILE
    echo "$1 " >> $OBUS_CLIENT_PIDFILE
}

killall_obus_clients() {
    log "KILLALL_OBUS_CLIENTS: OBUS_CLIENT_PIDFILE=$OBUS_CLIENT_PIDFILE"
    kill $(cat $OBUS_CLIENT_PIDFILE) &> /dev/null || true
    rm $OBUS_CLIENT_PIDFILE
}


