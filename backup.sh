#!/bin/sh

# Announcing world backup as well as asking the server to flush all pending writes to the disk 
mcrcon -s -H minecraft_server -p rconpassword "say Backing up the world..." save-all

# Creating a compressed tar of the world
tar -czf backup.tar.gz mountpoint/world

# Announcing backup upload
mcrcon -s -H minecraft_server -p rconpassword "say Uploading backup..."

# Uploading backup to Mega.io
megatools put --config $MEGA_CREDS backup.tar.gz --no-progress --disable-previews\
   --path /Root/$(date +%Y-%m-%d-%Hh%M).tar.gz

# Announcing success and remaining space on cloud
mcrcon -s -H minecraft_server -p rconpassword "say Backup done !"\
   "say $(megatools ls --config $MEGA_CREDS -n /Root | wc -l) backups (Used $(megatools df --config $MEGA_CREDS -h --used) out of $(megatools df --config $MEGA_CREDS -h --total))"
