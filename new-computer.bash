#!/bin/bash

# ------------------------------------------------------------------------------
# | Functions # http://stackoverflow.com/a/6347145
# ------------------------------------------------------------------------------

# Checks if a package is installed. If it is not, the function installs it.
installifnotinstalled() {
  command -v $1 >/dev/null 2>&1 || {
    echo "$1 is not installed. Installing $1..." >&2;
    sudo apt-get install -y "$1";
  }
}

# Syslink a file to the location where it is normally located.
# Removes the original file if one exists.
link() {
  from="$1"
  to="$2"
  echo "Linking $from to $to"
  rm -f "$to"
  ln -s "$from" "$to"
}

# ------------------------------------------------------------------------------

# Check if this script is running on a Linux system.
if ! [ "$OSTYPE" = "linux-gnu" ]; then
  echo "You are not using a Linux computer. Run this script on a Linux system with Ubuntu or Lubuntu installed."
  exit
else
  # OK, the script is running on Linux.
  # Now check if we have 'gawk'.
  command -v gawk >/dev/null 2>&1 || { echo "Please enter your password so that I can install gawk..." >&2; sudo apt-get install -y gawk; }
  # Now that we have 'gawk', we can check if this flavour of Linux is Ubuntu.
  OPERATINGSYSTEM=$(gawk -F= '/^NAME/{print $2}' /etc/os-release)
  if [ ! "$OPERATINGSYSTEM" = "\"Ubuntu\"" ]; then
    echo "This script is meant to be run on an Ubuntu based system with \"apt-get\" available."
    echo "Exiting..."
    exit
  fi
fi

# OK, looks like we have the enviroment we are expecting.. Proceed.

# Update current packages?
read -p "Before installing some new software packages, do you want to update your existing system? (Y/n?) " choice
case "$choice" in
  y|Y ) echo; echo "Sure, why not eh?!"; sudo apt-get update -y; sudo apt-get upgrade -y; sudo apt-get autoremove -y;;
  n|N ) echo; echo "OK."; echo;;
  * ) echo "Invalid response. Choose Y or N next time, bro."; echo "Exiting..."; exit;;
esac

# Install all the softwares.
PACKAGES=(
  apache2
  curl
  ffmpeg
  gnome-terminal
  imagemagick
  libapache2-mod-php
  libapache2-mod-php
  meld
  mysql-client
  mysql-server
  mysql-workbench
  nodejs
  npm # do we still need this? is npm included with nodejs nowadays?
  pgadmin3
  php
  php-cli
  php-mcrypt
  php-mysql
  python-pip
  ruby
  rubygems
  skypeforlinux
  sqlite3
  sqlitebrowser
  trimage
  wget
  xclip
  youtube-dl
)

for i in "${PACKAGES[@]}"
do
  installifnotinstalled "$i"
done

# On Ubuntu, 'node' is not 'node' until it's linked to 'nodejs' ¯\_(ツ)_/¯
# https://github.com/nodejs/node-v0.x-archive/issues/3911#issuecomment-8956154
sudo ln -s /usr/bin/nodejs /usr/bin/node
echo

# Setup Numix theme for use on Ubuntu.
echo "-------Setup Ubuntu-------"
sudo add-apt-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install -y numix-gtk-theme numix-icon-theme numix-icon-theme-square
echo

# TODO: Remove/uninstall packages that come with (L)ubuntu that we don't want.

# Setup Bash.
echo "-------Setup Bash-------"
for file in `ls -A ./bash`
do
  # Link Bash dotfiles.
  link "`pwd`/bash/$file" "$HOME/$file"
done
echo

# Setup Git.
# Is Git installed?
command -v git >/dev/null 2>&1 || { echo "Git is not installed. Please install it before proceeding." >&2; echo "Exiting..."; exit; }

echo
echo "All done. Your softwares are installed! :)"
echo
echo "Your NodeJS version is: $(node -v)"
echo "Your npm version is: $(npm -v)"
echo "Do: 'git config --list' to view your Git configuration."
echo

exit
