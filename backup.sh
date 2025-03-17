#!/bin/sh

# Announcing world backup as well as asking the server to flush all pending writes to the disk 
mcrcon -s -H minecraft_server -p rconpassword "say Backing up the world..." save-all

cd mountpoint
# Creating a compressed tar of the world
tar -czf ../backup.tar.gz banned-ips.json banned-players.json config eula.txt fabric-server-launcher.properties logs ops.json server.properties usercache.json whitelist.json world

# Remove included logs
rm -rf logs/*.log.gz
cd ..

# Get remaining space in the mega.nz storage
MEGA_FREE_SPACE=$(megatools df --mb --config $MEGA_CREDS --free)

# Get the backup size
BACKUP_SIZE=$(du -m backup.tar.gz | cut -f1)

while [ $MEGA_FREE_SPACE -lt $BACKUP_SIZE ]
do
   # Announcing lack of space
   mcrcon -s -H minecraft_server -p rconpassword "say Out of storage ! Removing oldest backup..."

   # list and sort files under /Root, ignore the first entry (/Root), take the first of the list
   OLDEST_BACKUP=$(megatools ls --config $MEGA_CREDS /Root | sort | tail -n +2 | head -1)

   # Remove the oldest backup
   megatools rm --config $MEGA_CREDS $OLDEST_BACKUP

   # Announcing suppression of backup
   mcrcon -s -H minecraft_server -p rconpassword "say Removed backup \"$OLDEST_BACKUP\""

   # Get remaining space in the storage Mega.nz
   MEGA_FREE_SPACE=$(megatools df --mb --config $MEGA_CREDS --free)
done

# Announcing backup upload
mcrcon -s -H minecraft_server -p rconpassword "say Uploading backup (${BACKUP_SIZE}MB)..."

# Uploading backup to mega.nz
megatools put --config $MEGA_CREDS backup.tar.gz --no-progress --disable-previews\
   --path /Root/$(date +%Y-%m-%d-%Hh%M).tar.gz

# Announcing success and remaining space on cloud
mcrcon -s -H minecraft_server -p rconpassword "say Backup done !"\
   "say $(megatools ls --config $MEGA_CREDS -n /Root | wc -l) backups (Used $(megatools df --config $MEGA_CREDS -h --used) out of $(megatools df --config $MEGA_CREDS -h --total))"
