#!/bin/sh

ENV1=$1

#####################################################
case ${ENV1} in
  start) chmod 700 nginx/entrypoint.sh;
         docker-compose up --build -d;;
  stop) docker-compose down;;
  restart) docker-compose restart;;
  build) docker-compose build --no-cache;;
  #rmdb) docker-compose down && sudo rm -rf store/db;;
  dev) chmod 700 nginx/entrypoint.sh;
       docker-compose down && docker-compose up;;
  *) echo "start | stop | restart | build | dev";;
esac
#####################################################
