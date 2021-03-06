#!/bin/bash
########################################################
#                                                      #
# This is a script for control my local docker         #
# environment on Ubuntu 14.04                          #
#                                                      #
# Koma <komazhang@foxmail.com>                         #
#                                                      #
########################################################

echo "##############################";
echo "# Koma local Docker 环境管理 #"
echo "# 1 启动Docker环境           #"
echo "# 2 关闭Docker环境           #"
echo "# 3 重启Docker环境           #"
echo "# 4 清理noneDocker           #"
echo "##############################";
read -p "请输入对应操作编号：" op

mysql_server_name="dbserver"
phpmyadmin_name="phpmyadmin"
ticket_name="easemob-tickets"
docker_image="docker-registry.easemob.com/easemob-wb/ticket_rel_im_v1_23"

function startDocker()
{
    ##启动mysql docker
    sudo docker run -d --rm -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Hong_Kong --name $1 mysql:5.6

    ##启动phpmyadmin docker
    sudo docker run --rm -d -e SERVER_NAME=www.koma.org -v /data/www/local:/var/www/html --link $1 --name $2 $4

    ##启动工单系统docker
    sudo docker run --rm -d -e SERVER_NAME=www.emticket.org -v /data/www/emticket:/var/www/html --link $1 dockerkafka_kafka_1 --name $3 $4
}

function stopDocker()
{
    sudo docker stop $3 $2 $1
}

function restartDocker()
{
    stopDocker $1 $2 $3
    startDocker $1 $2 $3
}

function clearNoneDocker()
{

    sudo docker ps -a | grep "Exited" | awk '{print $1 }'|xargs sudo docker stop
    sudo docker ps -a | grep "Exited" | awk '{print $1 }'|xargs sudo docker rm
    sudo docker images| grep none | awk '{print $3 }'| xargs sudo docker rmi
}

case $op in
    1)
        startDocker ${mysql_server_name} ${phpmyadmin_name} ${ticket_name} ${docker_image}
        exit 0
        ;;
    2)
        stopDocker ${mysql_server_name} ${phpmyadmin_name} ${ticket_name}
        exit 0
        ;;
    3)
        restartDocker ${mysql_server_name} ${phpmyadmin_name} ${ticket_name}
        exit 0
        ;;
    4)
	clearNoneDocker
	exit 0
	;;
    *)
        echo "Exit";
        exit 0
        ;;
esac

