#!/bin/bash

# Ruby script to check SuperDuper! logs for successful backup, as defined by:

# 1) Find the latest log file, or possibly except the path as an argument (prone to change)
# 2) Verify that it is no more than 24-hours old
# 3) Check for errors and warnings
# 4) Output OK, Warning, or Error

# find ~/Library/Application\ Support/SuperDuper\!/Scheduled\ Copies/ -name *.sdlog -mtime -1 -exec grep "Copy complete" {} +

# See https://kb.paessler.com/en/topic/39513-is-there-a-shell-script-example-for-the-prtg-ssh-script-sensor

# This file is intended to run as the user who has SuperDuper installed (servadmin in most cases)

#PATH="/bin:/usr/bin:/sbin:/usr/sbin"

LOGFILES=`find $HOME/Library/Application\ Support/SuperDuper\!/Scheduled\ Copies/ -name '*.sdlog' -mtime -2`

# Error unless all OK
CODE=-1
MESSAGE="Check failed!"

while read -r line; do

	#echo "Checking file: $line"
	# RTF log file, data lines start with |.  Find any datalines not marked "Info"
	WARNERR=`grep "^|" "$line" | grep -v "| Info |"`

	WARNINGS=`grep -i warn <<< "$WARNERR"`
	# If there are warnings, set CODE to 1 ("warning" status)
	if [ "$?" -eq "0" ]; then
		#echo "Found warnings!"
		CODE=1
		MESSAGE="Warning: $WARNINGS"
	fi

	ERRORS=`grep -i "error" <<< "$WARNERR"`
	# If there are errors, set CODE to 2 ("error" status)
	if [ "$?" -eq "0" ]; then
		#echo "Found Errors"
		CODE=2
		MESSAGE="Error: $ERRORS"
	fi

	if [ "$CODE" -gt "0" ]; then
		echo "0:$CODE:$MESSAGE"
		exit 0;
	fi

done <<< "$LOGFILES"

echo "0:0:OK"