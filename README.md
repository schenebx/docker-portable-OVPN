# docker-portable-OVPN

An OVPN server that is:

- without leak
- customizable
- portable
- stable

# Usage:

- on the server

```sh
# UPDATE the `#VOLATILE` section in the server_setup.sh
# THEN, RUN `server_setup.sh` on the server.
# Assume UBUNTU 20.04
bash ./server_setup.sh && bash

# the client cred will be outputted to /out

# to start the server
docker-compose build
docker-compose up

# to shut down the server
docker-compose down
```

- on the client

```sh
# get the .gz file, then to unzip it:
tar xvf *.gz

# to start the client
sudo openvpn client.ovpn
```

## CREDIT:

- https://github.com/jpetazzo/dockvpn
- https://github.com/kylemanna/docker-openvpn
