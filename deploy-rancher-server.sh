#!/bin/bash
echo "Root password:"
read rootPassw
echo "DB password:"
read dbPassw

docker run -d --restart=unless-stopped \
  --name infrastruct_mariadb -h mariadb.infrastruct \
  -e ALLOW_EMPTY_PASSWORD=yes \
  -e MARIADB_ROOT_PASSWORD=$rootPassw \
  -e MARIADB_DATABASE=rancher \
  -e MARIADB_USER=rancher \
  -e MARIADB_PASSWORD=$dbPassw \
  -v infrastruct_mariadb_bitnami:/bitnami \
  bitnami/mariadb:latest

docker run -d --restart=unless-stopped \
  --name infrastruct_rancher -h rancher.infrastruct \
  --link infrastruct_mariadb \
  -p 8080:8080 -p 9345:9345 \
  -v infrastruct_rancher_var-lib-cattle:/var/lib/cattle \
  -v infrastruct_rancher_unused1:/var/lib/mysql \
  -v infrastruct_rancher_unused2:/var/log/mysql \
  rancher/server \
    --db-host mariadb.infrastruct \
    --db-port 3306 \
    --db-name rancher \
    --db-user rancher \
    --db-pass $dbPassw \
    --advertise-address ipify
