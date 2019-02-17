# bssid command for macOS

Once upon a time, you can specify a BSSID to connect by doing `airport -A=ssid -BSSID=bssidname -password=password`, which is no longer supported.


this `bssid` provide a simple way to list BSSID and connect to one


## Usage

``` shell
# list BSSID given a SSID
bssid scan <ssid>


# connect to BSSID, will prompt for password
bssid connect <bssid>
```

# Build

``` shell
swift build
```
