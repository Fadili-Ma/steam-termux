#!/data/data/com.termux/files/usr/bin/bash
# Install git and the GitHub CLI, then log in
pkg install -y git gh
gh auth login

# Clone your repo
git clone https://github.com/Fadili-Ma/steam-termux.git
cd steam-termux

# Copy your script into the repo folder (adjust the path if it is elsewhere)
cp ~/steam-termux.sh .

# Stage, commit and upload
git add steam-termux.sh
git commit -m "Add Termux script to download Steam games"
git push
