#!/usr/bin/gawk -f

@include "lib.awk"

func main(	omm, devs, mnt, d, i, where, opt) {
	omm[0] = 4
	omm[1] = "/dev/sda1"
	omm[2] = "/dev/sda3"
	omm[3] = "/dev/sda6"

	for (;;) {
		lsdevs(devs)
		lsmntdevs(mnt)

		diff(devs, mnt, d)
		arrset(devs, d)
		diff(devs, omm, d)

		for (i = 1; i < d[0]; i++) {
			opt = "-o umask=000"

			if (ask("Mount "d[i]" ("devcapacity(d[i])")?", yn) != "yes") {
				omm[omm[0]++] = d[i]
				continue;
			}

			if (ask("Force to sync?", yn) == "yes")
				opt = opt ",sync"

			lsmntdirs(where)

			do
				dst = "/mnt/"ask("Where should we mount? (/mnt/)", where)
			while (dir(dst) == "yes" && mntdirvalid(dst) == "no")

			if (dir(dst) == "no")
				mkdir(dst)

			mount(d[i], dst, opt)
		}

		arrset(omm, devs)
		sleep(5)
	}
}

BEGIN {
	yn[0] = 3
	yn[1] = "yes"
	yn[2] = "no"

	main()
	exit 0
}
