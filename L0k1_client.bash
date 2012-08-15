#!/bin/bash
source lib/random.bash
[ $? -gt 0 ] && exit 1

# Settings
source settings.bash
[ $? -gt 0 ] && exit 1

touch ${logFile}

log() {
  msg="${2}"
  redirect=""
  [ -z "${msg}" ] && (msg="log(): wrong arguments"; level=1)
  case "${1}" in
    error) level=1;;
    warn) level=2;;
    info) level=3;;
    debug) level=4;;
    debug2) level=5;;
    *) level=1; msg="log(): unknown level ${1}";;
  esac
  if [ ${level} -le ${logLevel} ]; then
    if [ "${logFile}" = "-" ]; then
      echo "$(date): ${msg}"
    else
      echo "$(date): ${msg}" >> ${logFile}
    fi
  fi
}

closeComms() {
  # tell the server we are no longer running
  curl -s "${url}?poll=0" > /dev/null
  log debug "Close comms message sent"
}

endIt() {
  closeComms
  log info "Shutting down"
  exit 0
}

trap endIt EXIT

log info "Started"
while true; do
  # Get bias percentile
  randomBetween 100 0 10
  log debug2 "Bias precentile: ${randomBetweenAnswer}"

  # Check if it is bias range
  if [ ${randomBetweenAnswer} -gt ${biasPercentage} ]; then
    # Use full range (non-bias)
    randomBetween ${maxPollingMinutes} ${minPollingMinutes} 1
  else
    # Use biased range
    randomBetween ${maxBiasPollingMinutes} ${minBiasPollingMinutes} 1
  fi
  log debug2 "Random interval: ${randomBetweenAnswer}"

  # minutes to seconds
  pollingIterval=$((randomBetweenAnswer*60))

  # Send pollingIterval to server and examine response if tunnel should start
  if curl -s "${url}?poll=${pollingIterval}" | grep "tunnel:true" >/dev/null 2>&1; then
    log debug "Tunnel requested"
    # Check if tunnel already running
    if ps ax ${pid} | grep -q -v "ssh"; then
      # start tunnel
      ssh -f -N ${sshTunnelArgs} -p ${sshTunnelPort} ${sshTunnelHost} "sleep ${tunnelWaitTime}" >/dev/null 2>&1 &
      pid=$!
      log warn "Tunnel started (${pid})"
    else
      log warn "Tunnel already started (${pid}), ignoring"
    fi
  fi

  log debug "Polling in ${pollingIterval} seconds"
  sleep ${pollingIterval}
done
