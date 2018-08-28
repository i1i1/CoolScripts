#!/usr/bin/gawk -f

function download(link,		arr, file) {
	split(link, arr, "/")

	file = res "/" arr[length(arr)]

	if (system("test -f " file) != 0) {
		cmd = "basename " file
		cmd | getline out
		close(cmd)

		print "Downloading " out
		system("wget -q -o /dev/null -O " file " " link)
	}
}

BEGIN {
	DU="data-url=\"https?://([a-zA-Z0-9.-]*/)*[a-zA-Z0-9.-]*\""
	beg=length("data-url=\"")
}

DU {
	while (match($0, DU)) {
		s = substr($0, RSTART+beg, RLENGTH-beg-1);
		$0 = substr($0, RSTART + RLENGTH);

		if (s ~ "\\.jpg$")
			download(s)
		else if (s ~ /imgur\.com/) {
			sub("https?://", "", s)
			download("i." s ".jpg")
		}
	}
}

