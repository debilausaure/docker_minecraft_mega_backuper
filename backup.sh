#!/bin/sh

# Announcing world backup as well as asking the server to flush all pending writes to the disk 
mcrcon -s -H $MC_SERVER_CONTAINER_NAME -p $MC_SERVER_RCON_PASSWORD "say Backing up the world..." save-all

# Creating a compressed tar of the world
tar -czf backup.tar.gz mountpoint/world

# Announcing backup upload
mcrcon -s -H $MC_SERVER_CONTAINER_NAME -p $MC_SERVER_RCON_PASSWORD "say Uploading backup..."

# Uploading backup to Mega.nz
megatools put -u $MEGA_NZ_EMAIL -p $MEGA_NZ_PASSWORD backup.tar.gz --no-progress --disable-previews\
   --path /Root/$(date -Iminutes | cut -d '+' -f1 | sed -e 's/T/-/g' -e 's/:/h/g').tar.gz

# Announcing success and remaining space on cloud
mcrcon -s -H $MC_SERVER_CONTAINER_NAME -p $MC_SERVER_RCON_PASSWORD "say Backup done !"\
   "say $(megatools ls -u $MEGA_NZ_EMAIL -p $MEGA_NZ_PASSWORD -n /Root | wc -l) backups (Used $(megatools df -u $MEGA_NZ_EMAIL -p $MEGA_NZ_PASSWORD -h --used) out of $(megatools df -u $MEGA_NZ_EMAIL -p $MEGA_NZ_PASSWORD -h --total))"
