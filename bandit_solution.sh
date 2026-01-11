#!/bin/bash

. ./utils.sh

parser_b64=`base64 -w0 parse.sh`
l23_script_b64=`base64 -w0 level23.sh`


level_cmd=("cat readme | grep \"password\" | cut -d \":\" -f 2 | tr -d \" \"" \
	   "cat ./-" \
           "cat ./\"--spaces in this filename--\"" \
           "cat inhere/\"...Hiding-From-You\"" \
	   "file inhere/* | grep ASCII | cut -d \":\" -f 1 | xargs cat" \
	   "find . -size 1033c -type f ! -executable -print0 | xargs -0 file | grep \"ASCII\" | cut -d: -f1 | xargs cat | tr -d \" \t\"" \
	   "( find / -size 33c -user bandit7 -group bandit6 -readable 2> /dev/null || true ) | xargs cat" \
	   "grep millionth data.txt | tr [:blank:] \":\" | cut -d: -f2" \
	   "sort data.txt | uniq -u" \
	   "strings data.txt | grep -E -- '===+' | tail -n1 | cut -d\" \" -f2" \
	   "base64 -d data.txt | cut -d\" \" -f4" \
	   "cat data.txt | tr [a-mA-Mn-zN-Z] [n-zN-Za-mA-M] | cut -d\" \" -f4" \
	   "mkdir -p /tmp/scrpt; echo '$parser_b64' | base64 -d > /tmp/scrpt/parse.sh; chmod 755 /tmp/scrpt/parse.sh; /tmp/scrpt/parse.sh data.txt" \
	   "cat sshkey.private" \
	   "cat /etc/bandit_pass/bandit14 | nc localhost 30000 | grep -E \".{32,}\"" \
	   "cat /etc/bandit_pass/bandit15 | ncat --ssl localhost 30001 | grep -E \".{32,}\"" \
	   "nmap -l localhost -p 31000-32000 | grep \"/tcp\" | cut -d/ -f1 | while read -r port; do socat - OPENSSL:localhost:\$port,verify=0 < /etc/bandit_pass/bandit16 2> /dev/null || true; done | tail -n+3" \
	   "( diff passwords.new passwords.old || true ) | grep \"<\" | cut -d\" \" -f2" \
	   "cat readme" \
	   "\./bandit20-do cat /etc/bandit_pass/bandit20" \
	   "( cat /etc/bandit_pass/bandit20 | nc -l 30005 & ) ; \./suconnect 30005 | tail -n 1 > /dev/null" \
	   "cat /usr/bin/cronjob_bandit22.sh | tail -n1 | cut -d\">\" -f2 | xargs cat" \
	   "cat /tmp/`echo I am user bandit23 | md5sum | cut -d\" \" -f 1`" \
	   "cd /var/spool/bandit24/foo; echo '$l23_script_b64' | base64 -d > my-scrp.sh; chmod 777 my-scrp.sh; sleep 10; cat /tmp/my-scrp/pass" \
          )
levels_len=${#level_cmd[@]}
level=0

for cmd in "${level_cmd[@]}"; do
	if [ ! -f "level${level}.pass" ]; then
		echo "No password file for level ${level}" 
		exit 1
	fi

	# Debug ------------------------------------------
	if [ "$level" -lt "15" ]; then
       		 ((level+=1))
		 continue
	fi
	# Debug ------------------------------------------

	loading_animation Getting level "$((level + 1))" password &
	ANIM_PID=$!

	pass=$(sshpass -f ./level${level}.pass ssh bandit${level}@bandit.labs.overthewire.org -p 2220 -q  "bash -lc 'set -o pipefail; $cmd'")
	cmd_result="$?"
        ((level+=1))

	echo "$pass" | grep -i 'RSA private key' > /dev/null
	if [ "$?" -eq "0" ]; then
		echo "$pass" > sshkey.private
		chmod 700 sshkey.private
		pass=$(ssh -i ./sshkey.private bandit${level}@bandit.labs.overthewire.org -p 2220 -q "bash -lc 'set -o pipefail; cat /etc/bandit_pass/bandit${level}'")
		rm sshkey.private
	fi
	kill $ANIM_PID
	if [ $cmd_result -ne "0" ]; then
		echo "Something went wrong fetching level $level password."
		exit 1
	fi
	echo "Level $level password: $pass"
	echo "$pass" > "level${level}.pass"
done

