#!/bin/bash

# This script makes a backup of several sqlite databases, my irc logs,
# and then mails them to my mail account. Then, it wipes the irc logs
# for greater security.
# It works with vanilla `mail' from Debian.
# Store it, for example, in the /root/ directory.
# Then create a cron job so it's executed every day:
#  0 3 * * * bash ~/backup.sh
# If you don't have root access, you still can use it through other means.
# For example, start a screen session and, inside it, use:
#  while (true); do bash backup.sh; sleep 86400; done
# That will run it once each 24 hours.
# If the resulting backup files are too large, postfix won't want to send
#  the mail. Add this to /etc/postfix/main.cf and then restart the daemon:
#  message_size_limit = 512000000

echo ====
echo Starting backup: $(date)

date=$(date -I)
start=$(date +%s)

mkdir tmp

# irclogs
mkdir tmp/logs-${date}
for network in /home/user/irclogs/*; do cp -r $network tmp/logs-${date}/$(echo $network | cut - -d/ -f6-); done
tar Jcf tmp/logs-${date}.tar.xz tmp/logs-${date}
rm -rf tmp/logs-${date}/ /home/user/irclogs/

# irssi configuration :-P
tar Jcf tmp/irssi-${date}.tar.xz -C /home/user/.irssi/ .

# sqlite database
xz --stdout /home/user/database.sqlite > tmp/database-${date}.sqlite.xz

end=$(expr $(date +%s) - ${start})

# create uuencoded temporary file
files="database-${date}.sqlite.xz irssi-${date}.tar.xz logs-${date}.tar.xz"
echo -e "Processed in ${end} seconds.\n\n" > tmp/temporary.uuencode
for file in $files; do cat tmp/$file | uuencode $file >> tmp/temporary.uuencode; done

# send the mail
cat tmp/temporary.uuencode | mail -s "Server backup: ${date}" my.mail@account.com

# wipe
rm -rf tmp

echo ---- [${end} seconds later]
echo Finishing backup: $(date)
echo ====
echo
