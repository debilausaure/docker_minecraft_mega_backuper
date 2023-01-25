# A Mega.nz minecraft server backuper image

This image is meant to be run on a sibling container running [this minecraft server](https://github.com/debilausaure/docker_slim_minecraft_server) image.
Its purpose is to make a compressed tar of the minecraft world running on the sibling container, and to upload it to Mega.nz.

This is based on an original idea by [@scotow](https://github.com/scotow).

## Prerequisites

You must have enabled Rcon on your minecraft server.
This is done by setting `enable-rcon=true` in your server's `server.properties` file. Be sure to set a password too, otherwise your server will disregard the value of `enable-rcon`. Password needs to be set in the `rcon-password` field.

You must also create a [Mega.io](https://mega.io/) account, where your world backups will be uploaded.

## Setting up the container

### Build the image

Clone this repository, and build the image.

```sh
docker build -t minecraft_server_backuper /path/to/this/repo
```

### Create a virtual network

We will create a docker network in which both this container and the server will run. This will simplify the communications between the two, as well as preventing your other unrelated containers to interact with them.

You can use the following command to create a network :
```sh
docker network create --driver=bridge your_network_name
```

### Set up the credentials

You can then configure the credentials to be used by this image in the provided `minecraft.env` file. This file will not be included inside the image, but will be provided as an argument to your backup container. This has the upside of not revealing your credentials on the command line.

The image needs 4 variables to be set :
- `MEGA_IO_EMAIL` your Mega.io email
- `MEGA_IO_PASSWORD` your Mega.io password
- `MC_SERVER_CONTAINER_NAME` the name you gave to your server's container with the `--name` option.
- `MC_SERVER_RCON_PASSWORD` the password you set up in the `rcon-password` field of your `server.properties`.

**NB : this image expects the server to be configured to listen for rcon commands on port 25575 (which is the default)**

## Run the container

Make sure you started your server's container inside your new docker network. If you did not, remove it and create a new one adding `--network=your_network_name` to the command line.

For example :
```sh
docker run --name my_minecraft_server -p 25565:25565 --network=your_network_name -v my_minecraft_server_volume:/home/minecraft/conf --rm -d tag_of_your_image:latest
```

Once the server is started, you can run the backuper every time you want to backup your world. (More than once a minute will generate an error when uploading to Mega.io).
It expects the volume you created for the minecraft server to be mounted on `/home/minecraft/mountpoint`.

This is what the command line might look like:
```sh
docker run --network=your_network_name --env-file ../minecraft.env -v your_minecraft_volume:/home/minecraft/mountpoint --rm minecraft_server_backuper:latest
```
