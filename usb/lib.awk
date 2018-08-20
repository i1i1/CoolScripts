func mount(dev, dir, opt,	cmd) {
	cmd = "lxsu \"mount "opt" '"dev"' '"dir"'\""
	system(cmd)
}

func umount(dir) {
	cmd = "lxsu \"umount '"dir"'\""
	system(cmd)
}

func devcapacity(d,	cmd) {
	sub("^/dev/", "", d)
	
	cmd = "lsblk -l|grep "d
	cmd | getline

	return $4
}

func devdir(d,	cmd) {
	sub("^/dev/", "", d)
	
	cmd = "lsblk -l|grep "d
	cmd | getline

	return $7
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
	cmd = "df --output='source'|grep ^/dev/sd"

	i = 1

	while (cmd | getline ln > 0)
		res[i++] = ln

	res[0] = i
	close(cmd)
}

func sleep(sec) {
	system("sleep " sec)
}

# Put all things which are not in 'b', but in 'a' to 'c'
func diff(a, b, c,	i, j, k, fl) {
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

	cmd = "df --output='target'|grep '"d"'"
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

