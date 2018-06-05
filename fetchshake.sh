#!/bin/sh

# crontab: your path will be different
# use somethinglike this to fetch images only, every 2 minutes
# */2 * * * * bash /home/pi/git-masterofpis/myshake/fetchshake.sh
# or use this entry to fetch ALL the data, twice daily (consider it a backup script)
# nothe the final argument on the line - 'all' It could be anything, but it's needed!
# 1 0,12  * * * bash /home/pi/git-masterofpis/myshake/fetchshake.sh all

# Unless you're using weewx and the seasons skin, or need an include file,
# then leave this as is, otherwise weewx='weewx'
weewx='none'

# This entry will be unique to your setup
login='myshake@192.168.1.4'
# These are derived from your stations name - these are for station AM.RC98F
# ie: AM.RC98F is split as... stat_id_1.sta_id_2
stat_id_1='AM'
stat_id_2='RC98F'
# This is the path to YOUR webserver
www_myshake='/var/www/html/weewx/myshake'
# This is the html formatted output file
# This gives you an index.html page in the previous www_shake directory
ind_html='index.html'

# leave the following 3 variables as is.
Utc=$(date -u)
Local=$(date)
flag=1
# this can be safely ignored.
if [ $weewx = 'weewx' ]
then
  ind_html='/tmp/myshake.inc'
fi

# code starts here. html text fields can be adjusted to suit your tastes.

if [ ! -d "$www_myshake" ]
then
   mkdir "$www_myshake"
   if [ $? -ne 0 ]
   then
   logger "$0 failed to find and create $www_myshake directory"
      exit 1
   fi
fi

if [ $# -eq 1 ]
 then
  # we don't care what the option is. It tells us we want to fetch all the data
  # chmod 0777 /opt/shake/
  rsync -a $login:/opt/data /opt/shake/
else
  # zilch, so we just want to fetch the image
  # chmod 0777 /var/www/html/weewx/myshake
  cd $www_myshake
  rsync -a $login:/opt/data/gifs/RC98F_EHZ_AM_00*.gif .
fi


    if [ $weewx != 'weewx' ]
    then
        echo "<!DOCTYPE HTML>
        <html lang=\"en\">
         <head>
          <title>Myshake results</title>
          <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
         </head>
        <body>" > $ind_html
    else
        # only here to start the file, a pre-append statement
        echo "" > $ind_html
    fi

 echo "
 <h2>MyShake: seismology for the masses!</h2>
 <p>The following is the most recent helicorder image for the detector at this location - <a href=\"https://raspberryshake.net/stationview/#?net=AM&sta=RC98F\">AM.RC98F</a><br>
 </p><p>
 The time is recorded as UTC time ( $Utc ), not as local time ( $Local ).<br>The resulting image is updated every 2 minutes, although there will be a time lag as it needs to be fetched from the unit first.</p><p>Click on the image to enlarge it.</p>" >> $ind_html

style="<img src=\"&\" alt=\"Helicorder image\" style=\"width:500px;height:550px;border:0\">"
style2="<img src=\"thumb.&\" alt=\"Helicorder image\" style=\"width:100px;height:110px;border:0\"><\/a>"
# ignore ind* files and thumb* ; and don't have anything else in the directory either.
for i in `find -L . -mount -depth -maxdepth 1 -type f ! -name 'ind*' ! -name 'thumb*'`
 do
  if [ $flag -eq 1 ]
  then
    echo `basename $i` | sed "s/^.*/<a href=\"&\">$style<\/a>/" >> $ind_html
    echo "<p><a href=\"https://raspberryshake.org/about/\">Raspberryshake.org</a> is a project that encourages and assists with the deployment of personal seismographs.<br> These seismographs use the raspberrypi mini computer to monitor an attached digitizer and a super sensitive motion sensor(s).
    </p><p>
    The network consists of many stations scattered throughout <a href=\"https://raspberryshake.net/stationview/\"> the world</a> that do their part to contribute to the data, and even the detection, of the seismic events that occur <a href=\"https://raspberryshake.net/eqview/\">around the world.</a></p>" >> $ind_html
    if [ $weewx != 'weewx' ]
    then
       echo "<hr><h2>Archive</h2>" >> $ind_html
    else
       echo "</div><div id=\"history_week\" class=\"plot_container\" style=\"display:none\">" >> $ind_html
    fi
    echo "<p>This is the archive for previous Helicorder results, click on an entry to load an image for the corresponding time period.</p>" >> $ind_html
    flag=0
  else
    b_name=$(basename $i)
    base_str=$(echo $b_name | cut -d'.' -f2)
    YMD=$(echo  $base_str | awk '{print substr($0,0,8)}')
    HH=$(echo  $base_str | awk '{print substr($0,9,3)}')
    fdate=`date -d $YMD +'%Y-%m-%d'`
    # text and image
    if [ ! -f thumb.$b_name ]
    then
        /usr/bin/convert -thumbnail 100 $b_name thumb.$b_name
    fi

    # text with a thumbnail image
    echo $b_name | sed "s/^.*/<a href=\"&\">$fdate ($HH)<br> $style2<br>/" >> $ind_html
    # text only
    #echo $b_name | sed "s/^.*/<a href=\"&\">$fdate ($HH)<\/a><br>/" >> $ind_html
  fi
done
if [ $weewx != 'weewx' ]
then
   echo "</body></html>" >> $ind_html
else
   echo '<br>' >> $ind_html
fi
