# bssid command for macOS

Once upon a time, you can specify a BSSID to connect by doing `airport -A=ssid -BSSID=bssidname -password=password`, which is no longer supported.


this `bssid` provide a simple way to list BSSID and connect to one


## For people using macOS 10.15 or above

Start from 10.15, Apple seemed to change the policy on getting bssid that you need a developer account to sign the executable to get BSSID, otherwise you only get empty return.
But I encountered a problem for command line application the entitlement is not properly respected.

Some users suggested requiring location information in order to get location but some reported it did not work

https://developer.apple.com/forums/thread/124189


``` shell
# If you have a developer account
codesign --entitlements bssid.entitlements -s 'Your identity' ./.build/x86_64-apple-macosx/debug/bssid
# Seems you can also sign and run locally
codesign --force --sign - --entitlements bssid.entitlements --timestamp=none ./.build/x86_64-apple-macosx/debug/bssid
```

Theoretically this can fix the problem but I cannot test as I don't have a developer account :(

## Usage

``` shell
# list BSSID given a SSID

bssid scan # this will list all visible BSSID

bssid scan <ssid1> <ssid2> # only show result of <ssid1> and <ssid2>


# connect to BSSID, will prompt for password
bssid connect <bssid>
bssid connect --ssid <ssid>
bssid connect --ssid <ssid> --channel <channelNumber>
```

## Build

``` shell
swift build
```

## Add command to PATH

```
ln -fs PATH_TO_LOCAL_REPOSITORY/.build/x86_64-apple-macosx/debug/bssid /usr/local/bin/
```
