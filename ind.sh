#!/bin/bash
#
# old way: ls | bash ind.sh > index.html
# this version: bash
#
# https://odoepner.wordpress.com/2012/02/17/shell-script-to-generate-simple-index-html/

ind_html='indexx.html'

echo "<!doctype html>
<html lang=\"en\">
  <head>
   <title>$ind_html</title>
   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
  </head>
  <body>" > $ind_html
for i in `find -L . -mount -depth -maxdepth 1 -type f ! -name 'ind*'`
 do
  echo $i | sed 's/^.*/<a href="&">&<\/a><br>/' >> $ind_html
done
echo '</body></html>' >> $ind_html
