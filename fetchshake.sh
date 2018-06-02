#!/bin/sh
# chmod 0777 /opt/shake/
rsync -av myshake@192.168.1.4:/opt/data /opt/shake/
# chmod 0777 /var/www/html/weewx/myshake
rsync -av myshake@192.168.1.4:/opt/data/gifs//RC98F_EHZ_AM_00*.gif /var/www/html/weewx/myshake/

