# kf2server-updater

## Note
Currently this tool isn't working correctly because the steam api I'm using to check for updates always returns the same version.
I'll have to find another way to check for updates.

## Description
This tool automatically checks for updates for your Killing Floor 2 server every 15 Minutes.
If updates are available it notifies the players on your server, stops the server 5 minutes later and installs the updates.
The server is automatically started afterwards if it was running before updating.

## Dependencies
- [pup](https://github.com/ericchiang/pup)
- [jq](https://github.com/stedolan/jq)

## Installation
1. Clone this repo: `git clone https://github.com/jkhsjdhjs/kf2server-updater.git`
2. Set the path to your server executable in `systemd-units/kf2server.service`
3. If you didn't clone this repository to `~/kf2server-updater` adjust the path in both variables of `systemd-units/kf2server-update.service`
4. Enter the url, username and password of your webinterface in `config.bash`
5. Make sure your KF2 server is up to date!
6. Run `install.bash`
