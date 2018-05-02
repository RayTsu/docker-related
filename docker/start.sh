#!/bin/bash

env_flag=${APP_ENV}         #profile to use,e.g. local/sit/uat/prod
jar_name=${APP_JAR}         #jar file to execute
app_name=${APP_NAME}        #service name to register in eureka
external_port=${APP_PORT}   #application port exposed on node 
etcd_host=${ETCD_MASTER}

internal_ip=$(hostname -i | sed 's/[0-9 ]\+$/0-24/g')
external_ip=$(curl -s --noproxy ${etcd_host} http://${etcd_host}:2379/v2/keys/coreos.com/network/subnets/${internal_ip} | grep -o 'PublicIP[^}]*' | grep -o '[0-9.]\+')

if [[ $external_ip == "" ]]
  then 
    echo "Can not get k8s node ip,exit..."
    exit 1
fi

if [[ $env_flag =~ ^gl]]
  then 
  mkdir -p /root/.subversion
  echo -e "[groups]\n[global]\nhttp-proxy-host=10.93.210.244\nhttp-proxy-port=8123" > /root/.subversion/servers
fi

echo "Service ${app_name} of en ${env_flag} started at port ${external_port} on Host IP: ${external_ip}"

exec java -jar -Dspring.application.name=$app_name \
     -Dspring.profiles.active=$env_flag \
     -Deureka.instance.hostname=$external_ip \
     -Deureka.instance.nonSecurePort=$external_port \
     -Dccloud.monit.enable=true \
     -Xmx2500m \
     ${jar_name}
