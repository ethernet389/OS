#!/usr/bin/env bash

commands=('vi' 'nano' 'links' 'exit')


for ((i=0; i<${#commands[@]}; i++)); do
	echo "$((i + 1)). ${commands[i]}"
done

echo -n "Input menu entry index: "
read menu_entry_idx

if [[ $menu_entry_idx -le 0 ]] || [[ $menu_entry_idx -gt ${#commands[@]} ]]; then
	echo "Invalid index"
	exit 1
fi

${commands[$((menu_entry_idx - 1))]}
