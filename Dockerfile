# Minimal build image
FROM alpine:latest AS builder

RUN apk add --no-cache gcc musl-dev

# Get the statically built megatools binary and extract it
RUN wget https://xff.cz/megatools/builds/builds/megatools-1.11.5.20250706-linux-x86_64.tar.gz -q -O megatools.tar.xz \
 && mkdir -p megatools \
 && tar -xzf megatools.tar.xz -C megatools --strip-components=1

# Statically compile mcrcon
RUN wget -q https://raw.githubusercontent.com/Tiiffi/mcrcon/master/mcrcon.c \
 && gcc -std=gnu99 -Wpedantic -Wall -Wextra -Os -s -static -o mcrcon mcrcon.c

################

# Run from alpine
FROM alpine:latest

# Create a group and user minecraft
RUN addgroup -g 1002 -S minecraft && adduser minecraft -S -G minecraft -u 1002 -s /sbin/nologin
# Tell docker that all future commands should run as minecraft user
USER minecraft

# Copy the megatools binary from the builder stage
COPY --from=builder /megatools/megatools /bin/megatools
# Copy the mcrcon binary from the builder stage
COPY --from=builder /mcrcon /bin/mcrcon

# declare the volume that will hold the files to backup
VOLUME /home/minecraft/mountpoint

#copy the script to the home of the new user
WORKDIR /home/minecraft
COPY --chown=minecraft:minecraft backup.sh .

ENTRYPOINT ["./backup.sh"]
