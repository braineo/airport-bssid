# bssid — list and connect to Wi-Fi networks by BSSID on macOS

Once upon a time you could specify a BSSID to connect with
`airport -A=ssid -BSSID=bssidname -password=password`. That feature is gone.
`bssid` brings it back as a small, modern Swift CLI: scan nearby access points
and associate by BSSID (or SSID + channel).

Built with Swift 5.9+ (Swift Concurrency) and Apple's
[`swift-argument-parser`](https://github.com/apple/swift-argument-parser).
Requires **macOS 13 Ventura** or later.

## Usage

``` shell
# List visible APs
bssid scan

# Filter by one or more SSIDs
bssid scan <ssid1> <ssid2>

# Connect by BSSID (prompts for password)
bssid connect <bssid>

# Connect by SSID (optionally pin a specific AP with --channel)
bssid connect --ssid <ssid>
bssid connect --ssid <ssid> --channel <channelNumber>
```

## Build & install

``` shell
# Build (release) and ad-hoc codesign with location entitlement
make

# Symlink into /usr/local/bin
make install

# Or pick another prefix
PREFIX=$HOME/.local make install
```

The default target builds, then runs an ad-hoc `codesign` so macOS will issue
a stable identity to the binary for TCC (Location Services).

## Location permission (required on macOS 10.15+)

Starting in macOS 10.15, `CoreWLAN` only returns real BSSIDs to processes that
hold Location Services authorization. To make this work for a CLI, `bssid`:

1. Embeds an `Info.plist` (with `NSLocationUsageDescription` and a
   `CFBundleIdentifier` of `dev.braineo.bssid`) directly into the executable
   via `-sectcreate __TEXT __info_plist`.
2. Ships a `LocationAuthorizer` that pumps the main runloop and waits for
   `CLLocationManager` to resolve authorization on first run.
3. Is ad-hoc code-signed with `bssid.entitlements` so TCC has a stable
   identity to attach the grant to.

On first invocation you should see a one-shot system prompt asking to grant
Location access to `bssid`. Approve it. From then on, `bssid scan` will
return real MAC addresses instead of `00:00:00:00:00:00`.

If you previously denied the prompt (or installed an older unsigned build)
the prompt will not reappear. Reset the cached decision once:

``` shell
make reset-tcc
# equivalent to: tccutil reset Location dev.braineo.bssid
```

then run `bssid scan` again.

## Troubleshooting

- **`bssid scan` shows `bssid: 00:00:00:00:00:00`**: Location is denied. Run
  `make reset-tcc` and re-run `bssid scan` to re-trigger the prompt. Confirm
  the entry under System Settings → Privacy & Security → Location Services.
- **No prompt appears at all**: confirm the binary is signed
  (`codesign -dv .build/release/bssid` should show `Identifier=dev.braineo.bssid`),
  then `make reset-tcc` and retry.
- **macOS 14/15/26 still masking BSSID after permission is granted**: Apple
  has tightened these APIs over time. If a fully-permissioned, signed CLI
  still returns zeroes, the next step is wrapping the binary in a stub `.app`
  bundle. Open an issue if you hit this.

## Project layout

```
Package.swift              # Swift 5.9, swift-argument-parser, __info_plist linker flags
Resources/Info.plist       # Embedded bundle metadata for TCC
bssid.entitlements         # Location entitlement for codesigning
Sources/bssid/
  BSSID.swift              # @main AsyncParsableCommand root
  LocationAuthorizer.swift # CLLocationManager wrapper that drives the runloop
  WiFi.swift               # async wrappers over CoreWLAN
  Commands/
    Scan.swift
    Connect.swift
```
