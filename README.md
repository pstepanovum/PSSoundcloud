# PSSoundcloud
**SoundCloud without ads.**\
`Version v0.1.0` | `Tested on SoundCloud 8.73.0`

PSSoundcloud is an iOS tweak for the SoundCloud app: no audio ads between tracks, no video ads, no banners on track, playlist, profile and search pages, and no "Enjoying SoundCloud?" prompts.

Sister projects: [PSInstagram](https://github.com/pstepanovum/PSInstagram), [PSLinkedIn](https://github.com/pstepanovum/PSLinkedIn) and [PSYoutube](https://github.com/pstepanovum/PSYoutube).

---

## What you get
- **No ads**: SoundCloud's own checks for whether to request ads say no, its ad-free mode is turned on, and requests to ad servers (SoundCloud's ad endpoints, Pandora, Google, Prebid, Aditude, Facebook and ad measurement services) fail
- **No empty ad slots**: banner spaces aren't created in the first place
- **No rating prompts**: no "Enjoying SoundCloud?" popup and no system rate-this-app sheet
- **Settings that don't slip**: backed up to the iOS keychain and restored after a reinstall

## Opening the settings
Hold **four fingers** anywhere on the screen for a second.

## Installing
PSSoundcloud is sideloaded: you inject it into a decrypted SoundCloud IPA and sign that with your own certificate. It gets its own bundle ID (`com.pstepanovum.pssoundcloud`), so it installs next to the official SoundCloud app.

### Prerequisites
- Xcode with the command-line tools, and [Homebrew](https://brew.sh)
- [Theos](https://theos.dev/docs/installation) with the iOS 16.2 SDK in `~/theos/sdks` ([SDKs](https://github.com/xybp888/iOS-SDKs))
- [cyan](https://github.com/asdfzxcvbn/pyzule-rw) and [zsign](https://github.com/zhlynn/zsign)
- A decrypted SoundCloud IPA

> [!NOTE]
> Newer Theos versions ship a Logos change that breaks `%orig` inside macros. Pin Logos to the last working commit:
> ```sh
> cd ~/theos/vendor/logos && git checkout a62370066a97e36d59b200a9fa10c5091f5e8972
> ```

### Setup
```sh
git clone --recurse-submodules https://github.com/pstepanovum/PSSoundcloud
cd PSSoundcloud
mkdir -p packages certs
```
Then add:
- `packages/com.soundcloud.TouchApp.ipa`: the decrypted SoundCloud IPA
- `certs/dev.p12`: your signing certificate
- `certs/dev.mobileprovision`: its provisioning profile
- `certs/p12-password`: the certificate password

`packages/` and `certs/` are ignored by git.

### Build, sign and install
With your iPhone connected:
```sh
./dev.sh              # build, sign and install
./dev.sh --clean      # full rebuild first
./dev.sh --no-install # only create packages/PSSoundcloud-signed.ipa
BUNDLE_ID=com.example.soundcloud ./dev.sh   # use a different bundle ID
```

Shared decrypted IPAs often come with other tweaks already injected. `dev.sh` removes them first (`tools/clean-ipa.py`), so only PSSoundcloud runs. It also signs with a minimal set of entitlements taken from your profile, because some reseller profiles contain malformed wildcard entitlements that crash apps.

## Known limitations
- **The first launch after installing closes once.** SoundCloud resets its local data on a fresh install; open it again.
- **Updating over an existing install can fail**, in which case `dev.sh` reinstalls it. Your PSSoundcloud settings come back from the keychain, but you may need to log in to SoundCloud again.
- **App extensions are removed** (share sheet, widgets, rich notifications).
- **Use at your own risk.** Modified clients are against SoundCloud's terms of use.

## Credits
The settings screen and the sideloading fixes come from [PSInstagram](https://github.com/pstepanovum/PSInstagram), which is a fork of [SCInsta](https://github.com/SoCuul/SCInsta) by SoCuul. See [NOTICE](NOTICE).

Bundled libraries:
- [FLEXing](https://github.com/SoCuul/FLEXing) / [FLEX](https://github.com/FLEXTool/FLEX): in-app debugging
- [fishhook](https://github.com/facebook/fishhook): symbol rebinding for the keychain fixes

## License
[GNU General Public License v3.0](LICENSE)
