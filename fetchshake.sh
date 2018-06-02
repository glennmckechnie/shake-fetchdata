#!/bin/sh

# use crontab to fetch every 2 minutes

ind_html='index.html'
www_myshake='/var/www/html/weewx/myshake/'
Utc=$(date -u)
Local=$(date)

if [ $# -eq 1 ]
 then
  # we want to fetch all the data
  # chmod 0777 /opt/shake/
  rsync -av myshake@192.168.1.4:/opt/data /opt/shake/
else
  # or we just want to fetch the image
  # chmod 0777 /var/www/html/weewx/myshake
  cd $www_myshake
  rsync -av myshake@192.168.1.4:/opt/data/gifs//RC98F_EHZ_AM_00*.gif $www_myshake
fi

echo "<!doctype html>
<html lang=\"en\">
  <head>
   <title>MyShake - seismology for the masses!</title>
   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
  </head>
  <body>
  <h1>MyShake: seismology for the masses!</h1>
  <p><a href=\"https://raspberryshake.org/about/\">Raspberryshake.org</a> is a project that encourages and assists with the deployment of personal seismographs.<br> These seismographs use the raspberrypi mini computer to monitor an attached digitizer and a super sensitive motion sensor(s).
  </p><p>
  The network consists of many stations scattered throughout <a href=\"https://raspberryshake.net/stationview/\"> the world</a> that do their part to contribute to the data, and even the detection, of the activity that occurs on <a href=\"https://raspberryshake.net/eqview/\">this active planet.</a></p>
  <p>The following is the most recent helicorder image for the detector at this location - <a href=\"https://raspberryshake.net/stationview/#?net=AM&sta=RC98F\">AM.RC98F</a><br>
  </p><p>
  The time is recorded as UTC time ( $Utc ), not as local time ( $Local ).<br>The resulting image is updated every 2 minutes, although there will be a time lag as it needs to be fetched from the unit first.<br><br> Click the image to further enlarge it.</p>" > $ind_html
for i in `find -L . -mount -depth -maxdepth 1 -type f ! -name 'ind*'`
 do
#  echo $i | sed 's/^.*/<a href="&">&<\/a><br>/' >> $ind_html
  echo $i | sed 's/^.*/<a href="&"><img src="&" alt="Helicorder image" style="width:628px;height:692px;border:0"><\/a><br>/' >> $ind_html
done
echo '</body></html>' >> $ind_html
