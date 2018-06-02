#!/bin/sh
ind_html='index.html'
www_myshake='/var/www/html/weewx/myshake/'

cd $www_myshake

# chmod 0777 /opt/shake/
rsync -av myshake@192.168.1.4:/opt/data /opt/shake/
# chmod 0777 /var/www/html/weewx/myshake
rsync -av myshake@192.168.1.4:/opt/data/gifs//RC98F_EHZ_AM_00*.gif $www_myshake


#!/bin/bash
#
# old way: ls | bash ind.sh > index.html
# this version: bash
#
# https://odoepner.wordpress.com/2012/02/17/shell-script-to-generate-simple-index-html/


echo "<!doctype html>
<html lang=\"en\">
  <head>
   <title>$ind_html</title>
   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
  </head>
  <body>
  <p><a href=\"https://raspberryshake.org/about/\">Raspberryshake.org</a> is a project that encourages and assists with the deployment of personal seismographs. These seismographs use the raspberrypi mini computer to monitor and control the attached digitizer and the super sensitive motion sensor(s).
  </p>
  The network consists of many stations scattered throughout <a href=\"https://raspberryshake.net/stationview/\"> the world</a> that do their part to contribute to the data, and even the detection, of the activity that occurs on <a href=\"https://raspberryshake.net/eqview/\">this active planet.</a></p>
  <p>The following is the most recent helicorder image for the detector at this location - RC98F<br> It is updated every 2 minutes.<br><br> Click the image to further enlarge it.</p>" > $ind_html
for i in `find -L . -mount -depth -maxdepth 1 -type f ! -name 'ind*'`
 do
#  echo $i | sed 's/^.*/<a href="&">&<\/a><br>/' >> $ind_html
  echo $i | sed 's/^.*/<a href="&"><img src="&" alt="Helicorder image" style="width:628px;height:692px;border:0"><\/a><br>/' >> $ind_html
done
echo '</body></html>' >> $ind_html
