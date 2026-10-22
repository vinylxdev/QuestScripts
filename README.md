# Quest Scripts
Some shrimple Quest scripts to make my life easier.

Untested on Windows.

## Install
Click Code->Download ZIP and unzip where ever convenient.
On Linux you probably have to add execute permission.

Developer Mode and USB debugging is needed.

## Quest Proximity Script
Used to disable or enable the proximity sensor, changes are temporary (I wish Meta would allow this to be permanent :[)

Usage:
`./quest-proximity.sh on|off [IP:port]`

A USB connection is required if no IP or port is provided.

The script will walk you through the rest.

## Wireless ADB
Wireless ADB is supported if enabled, just pass the IP:port as an argument.
e.g. `./quest-proximity.sh off 192.168.1.50:5555`
