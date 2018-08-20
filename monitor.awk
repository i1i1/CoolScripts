#!/usr/bin/gawk -f


func ask(s, l,	cmd, res, i) {
	cmd = "printf '"
	for (i = 1; i < l[0]; i++)
		cmd = cmd l[i] "\\n"
	if (s != "")
		cmd = cmd "'|dmenu -i -p '" s "'"
	else
		cmd = cmd "'|dmenu -i"

	cmd | getline res
	close(cmd)

	return res
}

func getmons(mons,	cmd, s, i, arr, n) {
	cmd = "xrandr|grep \" conn\""
	i = 1

	while (cmd | getline s > 0) {
		sub(/ \(normal.+$/, "" ,s)

		n = split(s, arr, " ")

		if (n == 4 && arr[4] ~ resolution) {
			mons[i][1] = "enabled"
			sub(/\+.*$/, "", arr[4])
			mons[i][2] = arr[4]
			arr[1] = arr[1] "*"
		} else if (n == 3 && arr[3] ~ resolution) {
			mons[i][1] = "enabled"
			sub(/\+.*$/, "", arr[3])
			mons[i][2] = arr[3]
		} else if (n == 2) {
			mons[i][1] = "disabled"
			mons[i][2] = ""
		}

		mons[i][3] = arr[1]
		i++
	}

	close(cmd)
	return i
}

func getres(res, mon,	cmd, s, found, i, cur) {
	cmd = "xrandr"
	found = 0
	i = 1

	while (cmd | getline s > 0) {
		if (s !~ "^" mon && !found)
			continue

		if (!found) {
			found = 1
			continue
		}

		cur = 0

		if (s !~ /^ +[0-9]+x[0-9]+/)
			break;

		if (s ~ /\*/)
			cur = 1

		sub(/^ +/, "", s)
		sub(/ +.*$/, "", s)


		if (cur == 1)
			res[i] = s "*"
		else
			res[i] = s

		i++
	}

	res[0] = i
	close(cmd)
}

func setmon(mon, res, lrs, mon2) {
	sub(/\*/, "", mon)
	sub(/\*/, "", mon2)

	cmd = "xrandr --output "mon" --mode "res" "

	if (res ~ /\*/)
		return

	if (lrs == "") {
		system(cmd)
		return
	}

	if (lrs == "same")
		cmd = cmd "--same-as "mon2
	else if (lrs == "left")
		cmd = cmd "--left-of "mon2
	else if (lrs == "right")
		cmd = cmd "--right-of "mon2
	else if (lrs == "off")
		cmd = "xrandr --output "mon" --off"

	system(cmd)
}

func main() {
	n = getmons(mons);

	for (i = 1; i < n; i++)
		m[i] = mons[i][3]
	m[0] = n

	mon = ask("What device to configure?", m)

	if (!mon)
		return

	pos = ask("", leftrightsameoff)

	if (!pos)
		return

	if (pos == "off") {
		setmon(mon, "", "off", "")
		return;
	}

	getres(res, mon);

	resol = ask("What resolution?", res)

	if (!resol)
		return

	mon2 = ask("Secondary monitor?", m)

	if ((n - 1) == 1) {
		setmon(mon, resol, "", "")
		return
	}

	setmon(mon, resol, pos, mon2)
}

BEGIN {
	resolution=/[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/

	leftrightsameoff[0] = 5
	leftrightsameoff[1] = "left"
	leftrightsameoff[2] = "right"
	leftrightsameoff[3] = "same"
	leftrightsameoff[4] = "off"

	main()
	exit
}
