#!/bin/bash

TOPDIR=~/.config/wallpaper/

sites="https://www.reddit.com/r/EarthPorn+CityPorn+SkyPorn+WeatherPorn+BotanicalPorn+VillagePorn+Beachporn+waterporn+spaceporn+wallpapers+wallpaper/"

timeout=300
disp_x=2560
disp_y=1440

photocond() {
	return $(convert "$1" -print "%w %h\n" /dev/null| awk "
	{
		d_ideal = $disp_x * 100 / $disp_y

		d = \$1 * 100 / \$2

		if (\$2 < $disp_y || \$1 < $disp_x)
			exit 1

#		if (d != d_ideal)
		if (d > d_ideal * 1.14 || d < d_ideal * 0.86)
			exit 1

		exit 0
	}");
}

echo Starting > $TOPDIR/log

while [ 1 ]
do
	ls $TOPDIR/res | shuf | while read file
	do
		photocond $TOPDIR/res/$file || continue

		echo Setting res/$file >> $TOPDIR/log
		feh --bg-scale $TOPDIR/res/$file
		sleep $timeout
	done

	for i in $sites
	do
		wget -q -o /dev/null -O - $i |
			$TOPDIR/script.awk -v res=$TOPDIR/res >> $TOPDIR/log
	done
done

