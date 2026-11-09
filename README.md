# steam-termux

Download Steam games on an Android phone (ARM64) using Termux and
[DepotDownloader](https://github.com/SteamRE/DepotDownloader), then move them to
your gaming PC. Useful when your home internet is slow or metered, and you have
access to a faster connection with your phone.

Inspired by [graffic's steamcmd guide](https://gist.github.com/graffic/47322e42e42d46dc02981e3c8e8eb3f8).

## Why not steamcmd?

`steamcmd` is a 32-bit x86 binary. Modern phones such as the Pixel 8 Pro have no
32-bit support, so emulating it (box86) fails. DepotDownloader is a .NET tool
that runs natively on ARM64 and downloads from Steam using your own account.

## Tested on

- Google Pixel 8 Pro, Android 17
- Termux from F-Droid, Debian via proot-distro
- Counter-Strike 2 (app 730)

Other ARM64 devices should work, but are untested.

## Requirements

- [Termux from F-Droid](https://f-droid.org/packages/com.termux/) (the Play Store version is outdated)
- A Steam account that owns the game (free-to-play games work too)
- Your Steam Guard code ready (email or Steam app)
- Free storage of about 2x the game size (one copy inside Debian, one in shared storage)
- At least 4 GB of free RAM is recommended. Close other apps before starting

## Usage

```bash
pkg install -y wget
wget https://raw.githubusercontent.com/Fadili-Ma/steam-termux/main/steam-termux.sh
bash steam-termux.sh <steam_user> <appid> "<installdir>"
```

Find `appid` and `installdir` on [SteamDB](https://steamdb.info) (the `installdir`
value is on the game's "Info" or "Depots" page and must match exactly).

Example, Counter-Strike 2:

```bash
bash steam-termux.sh your_steam_username 730 "Counter-Strike Global Offensive"
```

The script will:

1. Install Debian (proot-distro), .NET 8 runtime and DepotDownloader
2. Ask for your Steam **password** and **Steam Guard code** (typed directly in Termux, never stored in the script)
3. Download the Windows 64-bit build of the game
4. Generate the `appmanifest_<appid>.acf` file
5. Copy everything to `Internal storage/SteamDownload/<appid>`

If the download is interrupted, run the same command again. It resumes.

## Installing on your PC

1. Close Steam.
2. Move the game folder (everything except `steamapps`) to
   `steamapps\common\<installdir>`. The folder name must match `installdir`.
3. Put `appmanifest_<appid>.acf` into the `steamapps` folder.
4. Open Steam, then right-click the game, **Properties**, **Installed Files**,
   **Verify integrity of game files**. Steam will fix anything missing.

Transfer tip: a USB 3 cable is much faster than USB 2. You can also use
`adb pull /sdcard/SteamDownload/<appid> C:\steam_copy` (enable USB debugging first).

## Troubleshooting

**`GC heap initialization failed with error 0x8007000E`**
.NET cannot reserve its default heap under proot/Android. The script sets
`DOTNET_GCHeapHardLimit=0x40000000` (1 GB) to fix this. If it still fails, raise it
to `0x60000000` in `/root/dd/env.sh` inside Debian.

**`proot info: vpid 1: terminated with signal 11` (exit code 139)**
Do not set `DOTNET_GCName=libclrgc.so`. On this setup it causes a segfault.
Use only the hard limit.

**Termux gets killed during the download**
Close other apps to free RAM, keep the phone charged, keep Termux in the
foreground, and let `termux-wake-lock` do its job (the script runs it for you).

**Not enough storage**
The script keeps two copies (inside Debian and in shared storage). Delete the
Debian copy after transferring:
`rm -rf $PREFIX/var/lib/proot-distro/containers/debian/rootfs/root/game_<appid>`

**Steam Guard / login errors**
Make sure the account owns the game and the code has not expired. Enter the code
quickly, or run the script again for a fresh one.

## Notes and disclaimer

- Use your own Steam account and only download games you own or that are free.
- Never share your password, Steam Guard codes, or tokens in issues or pull requests.
- This project is not affiliated with Valve or Steam. DepotDownloader is a
  separate open-source project, see its repository for its license.

## License

MIT, see [LICENSE](LICENSE).
