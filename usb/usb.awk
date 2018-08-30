#!/usr/bin/gawk -f

@include "lib.awk"

func main(	devs, mnt, d, i, where, opt) {
	for (;;) {
		lsdevs(devs)
		lsmntdevs(mnt)

		diff(d, devs, mnt)
		arrset(devs, d)
		diff(d, devs, omm)
		arrset(devs, d)

		for (i = 1; i < d[0]; i++) {
			opt = "-o umask=000,sync"

			if (ask("Mount "d[i]" ("devcapacity(d[i])")?", yn) != "yes") {
				omm[omm[0]++] = d[i]
				continue;
			}

			lsmntdirs(where)

			do {
				dst = ask("Where should we mount? (/mnt/)", where)
				dst = "/mnt/" dst
			} while (dir(dst) == "yes" && mntdirvalid(dst) == "no")

			if (dir(dst) == "no")
				mkdir(dst)

			mount(d[i], dst, opt)
		}
		sleep(5)
	}
}

BEGIN {
	yn[0] = 3
	yn[1] = "yes"
	yn[2] = "no"

	# Add here devices what should be ommited
	# F.e. my /dev/sda1 device some backup windows partition
	#         /dev/sda3 is of type Extended
	omm[0] = 3
	omm[1] = "/dev/sda1"
	omm[2] = "/dev/sda3"

	main()
	exit 0
}
