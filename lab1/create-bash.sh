#!/usr/bin/env bash

if [ -e "$1" ]; then
	echo "File already exists."
	exit 1
fi

touch "$1" && \
	chmod +x "$1" && \
	echo "#!/usr/bin/env bash" >> "$1"
