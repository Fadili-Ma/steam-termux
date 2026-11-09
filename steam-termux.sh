#!/data/data/com.termux/files/usr/bin/bash
# Download Steam games on Android (ARM64) with Termux + DepotDownloader
# Usage: bash steam-termux.sh <steam_user> <appid> "<installdir>"
# Example: bash steam-termux.sh myuser 730 "Counter-Strike Global Offensive"
set -e

# Check the arguments
if [ $# -lt 3 ]; then
  echo "Usage: bash $0 <steam_user> <appid> \"<installdir>\""
  echo "Find appid and installdir on https://steamdb.info"
  exit 1
fi

STEAM_USER="$1"
APPID="$2"
INSTALLDIR="$3"

# Storage access and keep the phone awake during the download
termux-setup-storage || true
termux-wake-lock || true

# Install base packages and a Debian container
pkg update -y && pkg upgrade -y
pkg install -y proot-distro wget
proot-distro install debian || true

# Install .NET runtime + DepotDownloader inside Debian
proot-distro login debian -- bash -c '
set -e
apt update
apt install -y wget unzip ca-certificates libicu-dev

# Install the .NET 8 runtime only if it is missing
if [ ! -x /usr/share/dotnet/dotnet ]; then
  wget -q https://dot.net/v1/dotnet-install.sh -O /root/dotnet-install.sh
  chmod +x /root/dotnet-install.sh
  /root/dotnet-install.sh --channel 8.0 --runtime dotnet --install-dir /usr/share/dotnet
  ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet
fi

# Download DepotDownloader (ARM64 build) only if it is missing
mkdir -p /root/dd && cd /root/dd
if [ ! -f DepotDownloader ]; then
  wget -q https://github.com/SteamRE/DepotDownloader/releases/latest/download/DepotDownloader-linux-arm64.zip
  unzip -o DepotDownloader-linux-arm64.zip
fi
chmod +x DepotDownloader

# Fix for GC heap error 0x8007000E (do NOT set DOTNET_GCName, it segfaults)
cat > env.sh << "EOF"
export DOTNET_GCHeapHardLimit=0x40000000
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
EOF
'

# Download the Windows 64-bit build (asks for password + Steam Guard code)
proot-distro login debian -- bash -c "
source /root/dd/env.sh
cd /root/dd
./DepotDownloader -app $APPID -os windows -osarch 64 -username $STEAM_USER -remember-password -dir /root/game_$APPID
"

# Create the manifest so Steam recognizes the game
ROOTFS="$PREFIX/var/lib/proot-distro/containers/debian/rootfs/root"
mkdir -p "$ROOTFS/game_$APPID/steamapps"
cat > "$ROOTFS/game_$APPID/steamapps/appmanifest_$APPID.acf" << EOF
"AppState"
{
	"appid"		"$APPID"
	"Universe"		"1"
	"installdir"		"$INSTALLDIR"
	"StateFlags"		"4"
}
EOF

# Copy to phone storage (then move to the PC over USB)
OUT=~/storage/shared/SteamDownload/$APPID
mkdir -p "$OUT"
cp -r "$ROOTFS/game_$APPID/." "$OUT/"
echo "Done! Files are in Internal storage/SteamDownload/$APPID"
echo "On PC: rename the game folder to '$INSTALLDIR' and put it in steamapps\\common,"
echo "put appmanifest_$APPID.acf in steamapps, then Verify integrity in Steam."
