#!/usr/bin/env bash

all_emails() {
	grep -EIwoh '[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+' -r "$1" --no-messages
}

for email in `all_emails /etc`; do
	emails_str+="$email, "
done

echo "$emails_str"
