func mount(dev, dir, opt,	cmd) {
	cmd = "lxsu \"mount "opt" '"dev"' '"dir"'\""
	system(cmd)
}

func umount(dir) {
	cmd = "lxsu \"umount '"dir"'\""
	system(cmd)
}

func devcapacity(d,	cmd, arr, s, cap, i) {
	sub("^/dev/", "", d)
	
	cmd = "cat /proc/partitions |sed -e 1d -e 2d|grep "d"$"
	cmd | getline s
	close(cmd)

	split(s, arr, " ")
	cap = arr[3]

	for (i = 0; cap / 1024 > 2; i++)
		cap /= 1024

	cap = sprintf("%.0f", cap)

	switch (i) {
		case 0:
			cap = cap "K"
			break;
		case 1:
			cap = cap "M"
			break;
		case 2:
			cap = cap "G"
			break;
		case 3:
			cap = cap "T"
			break;
		default:
			cap = "Its Over 9000!!!"
	}

	return cap
}

func devdir(d,	cmd, s) {
	cmd = "cat /proc/mounts|grep ^"d"|cut -d' ' -f2"
	cmd | getline s
	close(cmd)

	if (!s) {
		if (system("cat /proc/swaps|grep ^"d"") == 0)
			s = "swap"
		close(cmd)
	}

	return s
}

func mkdir(d) {
	cmd = "lxsu \"mkdir -p "d"\""
	system(cmd)
}

func lsdevs(res,	cmd, ln, i, md) {
	cmd = "ls /dev/sd*"
	i = 1

	while (cmd | getline ln > 0) {
		md = ln
		sub(/[0-9]+$/, "", md)
		if (i > 0 && res[i - 1] == md)
			res[i - 1] = ln
		else
			res[i++] = ln
	}

	res[0] = i
	close(cmd)
}

func lsmntdevs(res,	cmd, ln, i) {
	cmd = "cat /proc/mounts|grep ^/dev/sd|cut -d' ' -f1"

	i = 1

	while (cmd | getline ln > 0)
		res[i++] = ln

	close(cmd)
	cmd = "cat /proc/swaps|grep ^/dev/sd|cut -d' ' -f1"

	while (cmd | getline ln > 0)
		res[i++] = ln

	res[0] = i
	close(cmd)
}

func sleep(sec) {
	system("sleep " sec)
}

# Some python pseudocode
#
# c = []
# for thing in a:
#   if thing not in b:
#     c.append(thing)
func diff(c, a, b,	i, j, k, fl) {
	k = 1;

	for (i = 1; i < a[0]; i++) {
		fl = 0;

		for (j = 1; j < b[0]; j++) {
			if (a[i] == b[j]) {
				fl = 1
				break;
			}
		}

		if (fl == 1)
			continue

		c[k++] = a[i]
	}

	c[0] = k
}

func ask(s, l,	cmd, res, i) {
	cmd = "printf '"
	for (i = 1; i < l[0]; i++)
		cmd = cmd l[i] "\\n"
	cmd = cmd "'|dmenu -p '" s "'"

	cmd | getline res
	close(cmd)

	return res
}

# 'a' = 'b', if 'a' and 'b' are arrays
func arrset(a, b,	i) {
	for (i = 1; i < b[0]; i++)
		a[i] = b[i]
	a[0] = b[0]
}

func lsmntdirs(res,	i, ln, cmd) {
	cmd = "ls /mnt/"
	i = 1

	while (cmd | getline ln > 0)
		if (mntdirvalid("/mnt/"ln) == "yes")
			res[i++] = ln

	res[0] = i
	close(cmd)
}

func mntdevvalid(d,	cmd, devs, i) {
	if (d == "/dev/sda5" || d == "/dev/sda7")
		return "no"

	lsmntdevs(devs)

	for (i = 1; i < devs[0]; i++)
		if (devs[i] == d)
			return "yes"

	return "no"
}

func mntdirvalid(d,	cmd) {
	if (d !~ /^\//)
		return "no"

	if (dir(d) == "no")
		return "no"

	cmd = "cat /proc/mounts|cut -d' ' -f2|grep '"d"'"
	if (system(cmd) == 0) {
		close(cmd)
		return "no"
	}
	close(cmd)

	cmd = "ls "d
	if (cmd | getline > 0) {
		close(cmd)
		return "no"
	}
	close(cmd)

	return "yes"
}

func dir(d,	cmd) {
	cmd = "test -d '"d"'"
	if (system(cmd) != 0)
		return "no"
	return "yes"
}

