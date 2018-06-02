#!/bin/sh

# use crontab to fetch every 2 minutes

login='myshake@192.168.1.4'
ind_html='index.html'
www_myshake='/var/www/html/weewx/myshake/'
Utc=$(date -u)
Local=$(date)
flag=1

if [ $# -eq 1 ]
 then
  # we want to fetch all the data
  # chmod 0777 /opt/shake/
  rsync -av $login:/opt/data /opt/shake/
else
  # or we just want to fetch the image
  # chmod 0777 /var/www/html/weewx/myshake
  cd $www_myshake
  rsync -av $login:/opt/data/gifs//RC98F_EHZ_AM_00*.gif $www_myshake
fi

echo "<!doctype html>
<html lang=\"en\">
  <head>
   <title>MyShake - seismology for the masses!</title>
   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
    <link rel=\"icon\" type=\"image/png\" href=\"../favicon.ico\" />
    <link rel=\"stylesheet\" type=\"text/css\" href=\"../seasons.css\"/>
    <script src=\"../standard.js\"></script>
  </head>
 <body onload=\"setup();\">
 <div id=\"title_bar\">
  <div id=\"title\">
    <h1 class=\"page_title\">Messmate Farm, Broomfield, Victoria</h1>
  </div>
</div>
<div id=\"contents\">
   <p><a href=\"../index.html\">&#10096; Current Conditions</a></p>
  <h1>MyShake: seismology for the masses!</h1>
  <p><a href=\"https://raspberryshake.org/about/\">Raspberryshake.org</a> is a project that encourages and assists with the deployment of personal seismographs.<br> These seismographs use the raspberrypi mini computer to monitor an attached digitizer and a super sensitive motion sensor(s).
  </p><p>
  The network consists of many stations scattered throughout <a href=\"https://raspberryshake.net/stationview/\"> the world</a> that do their part to contribute to the data, and even the detection, of the activity that occurs on <a href=\"https://raspberryshake.net/eqview/\">this active planet.</a></p>
  <p>The following is the most recent helicorder image for the detector at this location - <a href=\"https://raspberryshake.net/stationview/#?net=AM&sta=RC98F\">AM.RC98F</a><br>
  </p><p>
  The time is recorded as UTC time ( $Utc ), not as local time ( $Local ).<br>The resulting image is updated every 2 minutes, although there will be a time lag as it needs to be fetched from the unit first.<br><br> Click on an image to further enlarge it.</p>" > $ind_html

style="<img src=\"&\" alt=\"Helicorder image\" style=\"width:628px;height:692px;border:0\">"
style2="<img src=\"&\" alt=\"Helicorder image\" style=\"width:157px;height:173px;border:0\"><\/a>"
for i in `find -L . -mount -depth -maxdepth 1 -type f ! -name 'ind*'`
 do
  if [ $flag -eq 1 ]
  then
    echo `basename $i` | sed "s/^.*/<a href=\"&\">$style<\/a><hr><h2>Archives<\/h2>/" >> $ind_html
    flag=0
  else
    base_str=$(echo `basename $i` | cut -d'.' -f2)
    YMD=$(echo  $base_str | awk '{print substr($0,0,8)}')
    HH=$(echo  $base_str | awk '{print substr($0,9,3)}')
    fdate=`date -d $YMD +'%Y-%m-%d'`
    # text and image
    echo `basename $i` | sed "s/^.*/<a href=\"&\">$fdate ($HH)<br> $style2<br>/" >> $ind_html
    # text only
    #echo `basename $i` | sed "s/^.*/<a href=\"&\">$fdate ($HH)<\/a><br>/" >> $ind_html
  fi
done
echo '<br><hr></div></body></html>' >> $ind_html
