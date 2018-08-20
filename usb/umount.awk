#!/usr/bin/awk -f

@include "lib.awk"


func main(	devs, dev, i) {
	lsmntdevs(devs)

	for (i = 1; i < devs[0]; i++)
		devs[i] = devs[i] " ("devdir(devs[i])")"

	dev = ask("What device to umount?", devs)
	sub(" .+$", "", dev)

	if (mntdevvalid(dev) == "no")
		exit 0

	umount(dev)
}

BEGIN {
	main()
	exit 0
}

