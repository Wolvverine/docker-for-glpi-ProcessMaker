# ProcessMaker Server 3.3.0-RE-1.7 Docker Container for GLPI.
This is the ProcessMaker Server 3.3.0-RE-1.7 Docker Image Container for GLPI [Available at Docker Hub](https://hub.docker.com/r/wolvverine/processmaker/)

### TODO Container instalation:

1. !!! Declare PM_HOST_FULL_NAME environment variable:

        -e PM_HOST_FULL_NAME="yourPMhost.domain.com"

2. !!! For container glpi and processmaker:

        dockerhost="yourdockerhost.domain.com"
        --add-host=$dockerhost:`ip addr show docker0 | grep -Po 'inet \K[\d.]+'`

### TODO after instalation:

1. Change server_name declaration:

        server_name  pmhost.domain.wew;
    in /etc/nginx/conf.d/default.conf

2. IPtables rules - do more limited access on production :

    172.xx.0.0/16 - subnet with glpi, processmaker, mariadb

        iptables --append INPUT --protocol tcp --src 172.xx.0.0/16 --jump ACCEPT
        iptables --append INPUT -s 172.xx.0.0/16 -p tcp -j ACCEPT
        iptables -A INPUT -d 172.xx.0.0/16 -p tcp -j ACCEPT

3. Mysql passwords - do more limited access on production:

    In mysql passwords without special chars !!!
    Set access for all or only from specific hosts/subnets.

        mysql -u root -p
        GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
        GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
        GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
        FLUSH PRIVILEGES;

4. Problem with expired admin account after instalation:

        UPDATE wf_workflow.RBAC_USERS SET USR_DUE_DATE='2030-01-01' WHERE `USR_UID`='00000000000000000000000000000001';
        UPDATE wf_workflow.USERS SET USR_DUE_DATE='2030-01-01' WHERE `USR_UID`='00000000000000000000000000000001';
