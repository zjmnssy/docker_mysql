#!/usr/bin/env bash

echo "/*************************************************************************/"
echo "/*                                                                       */"
echo "/*                                Deploy                                 */"
echo "/*                                                                       */"
echo "/*************************************************************************/"

# NOTE: 获取当前工作路径
currentPath=$(cd `dirname $0`; pwd)
echo "[INFO] current work path : $currentPath"

# **************************** 容器配置 start  (根据实际情况修改) ********************
# NOTE: Dockerfile生成的镜像的名称
imageName="mariadb"

# NOTE: Dockerfile生成的镜像的版本
imageVersion="latest"

# NOTE: 启动容器的名称
containerName="sql"
# *************************************** end ***********************************

# ******************************* 不需要修改的配置 start ***************************
imageNameVersion="$imageName:$imageVersion"

# NOTE: 物理主机目录，将要挂载到容器内的
hostVolumeAwaysBinPath="$currentPath/service/bin"
hostVolumeOnceBinPath="$currentPath/service/once_bin"
hostVolumeConfigPath="$currentPath/service/config"
hostVolumeDataPath="$currentPath/service/data"

# NOTE: 容器内目录，物理主机目录在容器内的挂载点
awaysBinPath="/work"
onceBinPath="/docker-entrypoint-initdb.d"
configPath="/etc/mysql/conf.d"
dataPath="/var/lib/mysql"

# *************************************** end ***********************************

# NOTE: 检查docker镜像，不存在则创建
checkDockerImage() {
    echo "[INFO] - checkDockerImage()：check '$imageName' image"
    imageCheck=$(sudo docker images | grep $imageName | awk '{print $1}')
    if [ "$imageCheck" ] ; then
        echo "[INFO] ----'$imageName' is exist, nothing to do."
    else
        echo "[INFO] ----'$imageName' not exist, begin download:"
        sudo docker pull mariadb 
    fi
}
checkDockerImage

# NOTE: 检查docker容器，不存在则创建并启动
checkDockerContainer() {
    echo "[INFO] - checkDockerContainer()：check '$containerName' container"
    containerCheck=$(sudo docker ps -a|grep $containerName)
    if [ "$containerCheck" ] ; then
        echo "[INFO] ----'$containerName' is exist, nothing need to start."
    else
        echo "[INFO] ----begin run $containerName container."
        
        sudo docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -v $hostVolumeConfigPath:$configPath -v $hostVolumeDataPath:$dataPath -v $hostVolumeAwaysBinPath:$awaysBinPath -v $hostVolumeOnceBinPath:$onceBinPath --restart always --name $containerName $imageNameVersion --init-file=$awaysBinPath/every_start_run.sql
    fi
}
checkDockerContainer
