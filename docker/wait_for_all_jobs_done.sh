#!/bin/bash
PASSED_WAIT_TIME=$1
PASSED_MAX_RETRY=$2
JOB_FINISH_WAIT_TIME_IN_SECOND="${PASSED_WAIT_TIME:=30}"
JOB_FINISH_WAIT_MAX_COUNT="${PASSED_MAX_RETRY:=60}"
APP_URL=http://127.0.0.1:${CONTAINER_PORT}

echo "Wait time: ${JOB_FINISH_WAIT_TIME_IN_SECOND}(s)"
echo "Max Retry: ${JOB_FINISH_WAIT_MAX_COUNT}"
echo "App url: ${APP_URL}"

function pause_application() {
  echo "Make instance status DOWN in eureka"
  res=$(curl -s --noproxy 127.0.0.1 -X POST ${APP_URL}/pause)
  echo "Pause result: ${res}"
}

function is_empty(){
  if [[ "$1" == [] ]]
  then
    return 0
  else
    return 1
  fi
}

function has_no_executing_job() {
 res=$(curl -s --noproxy 127.0.0.1 -X POST ${APP_URL}/api/executor)
 return $(is_empty ${res})
}

function has_no_queued_job() {
 res=$(curl -s --noproxy 127.0.0.1 -X POST ${APP_URL}/api/queue)
 return $(is_empty ${res})
}

function service_status_code() {
 res_code=$(curl -X GET --noproxy 127.0.0.1 -o /dev/null -s -w %{http_code } ${APP_URL}/info)
 echo $res_code
}

function main(){
  pause_application
  retry=0
  while (( "$retry" < "$JOB_FINISH_WAIT_MAX_COUNT"))
  do
    [[ $(service_status_code) -ne "200" ]] && echo "Service is NOT available,exit ..." && exit 0
    if has_no_executing_job && has_no_queued_job
    then
      echo "No job is running. Service can be stoped."
      exit 0
    else
      echo "There is still some job running or queued. Sleep for $JOB_FINISH_WAIT_TIME_IN_SECOND seconds"
      sleep "$JOB_FINISH_WAIT_TIME_IN_SECOND"
    fi
      retry=$(( ${retry} + 1 ))
      echo "RETRY: ${retry}"
  done
}

main
