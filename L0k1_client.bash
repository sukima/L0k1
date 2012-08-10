#!/bin/bash
source lib/random.bash

# Settings
source settings.bash

# tell the server we are no longer running
trap "{ curl -s \"${url}?poll=0\" > /dev/null ; exit 255; }" EXIT

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
  if $(curl -s "${url}?poll=${pollingIterval}") | grep "tunnel:true" >/dev/null 2>&1; then
    # Check if tunnel already running
    if $(ps ax ${pid}) | grep -q -v "ssh"; then
      # start tunnel
      ssh -f -N ${sshTunnelArgs} -p ${sshTunnelPort} ${sshTunnelHost} "sleep ${tunnelWaitTime}" >/dev/null 2>&1 &
      pid=$!
    fi
  fi

  sleep ${pollingIterval}
done
