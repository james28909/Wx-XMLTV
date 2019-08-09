# Wx-XMLTV
simple grid style epg xmltv/m3u viewer

This simply displays an xmltv format file along with a m3u formatted file from iptv providers. 
you absolutely must have data that aligns... eg: an xmltv file with corresponding tags in an m3u 
or it will not work. I will be adding support for m3u only and/or xmltv only in the future.

so far, the only features i have added is cell highlighting on mouse hover, and when you select a 
show/channel it opens in vlc. other media players will be added in the future as well. as of 
right now you need to specify the group (eg: 'USA HD/UHD' or 'USA REGIONALS' or 'CANADA' ect) on
the command line. these groups can be found in the m3u file itself. there is a combo dropdown box
that lists the groups but it is non functional.
