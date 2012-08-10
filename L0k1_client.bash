#!/bin/bash
source lib/random.bash

# Settings
source settings.bash

touch ${logFile}

endIt() {
  # tell the server we are no longer running
  curl -s "${url}?poll=0" > /dev/null
  echo "$(date): Shutting down" >> ${logFile}
  exit 0
}

trap endIt EXIT

while true; do
  # Get bias percentile
  randomBetween 100 0 10

  # Check if it is bias range
  if [ ${randomBetweenAnswer} -gt ${biasPercentage} ]; then
    # Use full range (non-bias)
    randomBetween ${maxPollingMinutes} ${minPollingMinutes} 1
  else
    # Use biased range
    randomBetween ${maxBiasPollingMinutes} ${minBiasPollingMinutes} 1
  fi

  # minutes to seconds
  pollingIterval=$((randomBetweenAnswer*60))

  # Send pollingIterval to server and examine response if tunnel should start
  if curl -s "${url}?poll=${pollingIterval}" | grep "tunnel:true" >/dev/null 2>&1; then
    echo "$(date): Tunnel requested" >> ${logFile}
    # Check if tunnel already running
    if $(ps ax ${pid}) | grep -q -v "ssh"; then
      # start tunnel
      ssh -f -N ${sshTunnelArgs} -p ${sshTunnelPort} ${sshTunnelHost} "sleep ${tunnelWaitTime}" >/dev/null 2>&1 &
      pid=$!
      echo "$(date): Tunnel started (${pid})" >> ${logFile}
    else
      echo "$(date): Tunnel already running (${pid}), ignoring" >> ${logFile}
    fi
  fi

  echo "$(date): Polling in ${pollingIterval} seconds" >> ${logFile}
  sleep ${pollingIterval}
done
