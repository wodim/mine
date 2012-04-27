#!/bin/bash

# This script makes a backup of several mysql databases, my irc logs,
# and then mails them to my mail account.
# It requires heirloom-mailx to work.
# Store it, for example, in the /root/ directory.
# Then create a cron job so it's executed every day:
#  0 3 * * * bash ~/backup.sh
# If the resulting backup files are too large, postfix won't want to send
#  the mail. Add this to /etc/postfix/main.cf and then restart the daemon:
#  message_size_limit = 512000000

date=$(date -I)
start=$(date +%s)

# smf forum
mysqldump -usmf -psmf smf > smf-${date}.sql
xz smf-${date}.sql

# qdb
mysqldump -uqdb -pqdb qdb > qdb-${date}.sql
xz qdb-${date}.sql

# mnm
mysqldump -umnm -pmnm mnm > mnm-${date}.sql
xz mnm-${date}.sql

# irclogs
mkdir logs-${date}
for i in /home/user/.znc/users/*; do cp -r $i/moddata/log logs-${date}/$(echo $i | cut - -d/ -f6-); done
tar Jcf logs-${date}.tar.xz logs-${date}
rm -rf logs-${date}/

end=$(expr $(date +%s) - ${start})

# send the mail
echo "Processed in ${end} seconds." | mail -asmf-${date}.sql.xz -aqdb-${date}.sql.xz -amnm-${date}.sql.xz -alogs-${date}.tar.xz -s "Server backup: ${date}" my.mail@account.com

# wipe
rm smf-${date}.sql.xz qdb-${date}.sql.xz mnm-${date}.sql.xz logs-${date}.tar.xz

