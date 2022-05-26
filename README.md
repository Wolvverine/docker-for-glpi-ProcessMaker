# ProcessMaker Server 3.3.0-RE-1.7 Docker Container for GLPI.
This is the ProcessMaker Server 3.3.0-RE-1.7 Docker Image Container for GLPI [Available at Docker Hub](https://hub.docker.com/r/wolvverine/processmaker/)


## Instalation
script:

```sh
#!/bin/sh
set -a
set -x

containername="processmaker_for_glpi"
imagename="wolvverine/processmaker_server_glpi"
imagetag="latest"
restartpolicy="always"
dockerhost="yourdocker.host.domain"
pmhost="yourPM.host.domain"

#first time only
docker volume create "$containername"-Backup
docker network create glpi-network


sudo docker stop $glpicontainername
sudo docker stop $containername
sudo docker rm $containername
sudo docker pull  $imagename:$imagetag

docker run --detach --restart $restartpolicy --name "$containername" \
        --add-host=$dockerhost:`ip addr show docker0 | grep -Po 'inet \K[\d.]+'` \
        -e PM_HOST_FULL_NAME="$pmhost" \
        --volume "$containername-Backup":/opt/processmaker-server/Backup:Z \
        --net $glpicontainername-network -p 8090:8090 -d $imagename:$imagetag

docker exec -it $containername /bin/sh -c "export TZ='Europe/Warsaw'"
docker exec -it $containername /bin/sh -c "rm /etc/localtime"
docker exec -it $containername /bin/sh -c "ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone"

```

### TODO

- Regular backup

### TODO after instalation:

1. IPtables rules - do more limited access on production :

    172.xx.0.0/16 - subnet with glpi, processmaker, mariadb

        iptables --append INPUT --protocol tcp --src 172.xx.0.0/16 --jump ACCEPT
        iptables --append INPUT -s 172.xx.0.0/16 -p tcp -j ACCEPT
        iptables -A INPUT -d 172.xx.0.0/16 -p tcp -j ACCEPT

2. Mysql passwords - do more limited access on production:

    In mysql passwords without special chars !!!
    Set access for all or only from specific hosts/subnets.

        mysql -u root -p
        GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
        GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
        GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
        FLUSH PRIVILEGES;

3. Problem with expired admin account after instalation:

        UPDATE wf_workflow.RBAC_USERS SET USR_DUE_DATE='2030-01-01' WHERE `USR_UID`='00000000000000000000000000000001';
        UPDATE wf_workflow.USERS SET USR_DUE_DATE='2030-01-01' WHERE `USR_UID`='00000000000000000000000000000001';
