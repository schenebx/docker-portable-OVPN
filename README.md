# docker-portable-OVPN

An OVPN server that is:

- without leak
- customizable
- portable
- stable

# Usage:

- on the server

```sh
# the client cred will be outputted to here
mkdir -p /out

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
