#!/bin/bash

# ------------------------------------------------------------------------------
# | Functions
# ------------------------------------------------------------------------------

# Displays current Git branch, if there is one.
parse-git-branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1] /'
}

# Downloads mp3 audio file from YouTube video.
yt-getaudio() {
  if [ $# -eq 0 ]; then
    echo 'Oops. Pass me a url.'
    echo 'Usage: yt-getaudio <youtube-link>'
  else
    echo 'Starting YouTube download. Hit Enter if prompted after metadata is added.'
    # --audio-quality [0-9]; 0 is best, 9 is worst.
    youtube-dl --extract-audio --audio-format mp3 --audio-quality 1 --embed-thumbnail --add-metadata $1
  fi
}

# Just a quick function to reduce an image's size in order to upload it faster or whatever.
shrink-image() {
  if [ $# -eq 0 ]; then
    echo 'Oops. Please give me a filename.'
    echo 'Usage: shrink-image <filename>'
  else
    magick $1 -resize 50% $1
  fi
}

# Quickly resize an image to a given width.
resize-image-width() {
  if [ $# -ne 2 ]; then
    echo 'Oops. Please give me a filename and desired width.'
    echo 'Usage: resize-image-width <filename> <width in pixels>'
  else
    magick $1 -resize $2 $1
  fi
}

# Prep high-res images for upload to log.jonathanbell.ca or other blog-like things.
blogimages() {
  echo 'Converting images to lo-res...'
  for i in *.jpg; do
    printf "Resizing $i\n"
    magick $i -resize 900 $i
  done
  echo 'Done.'
}

# Trim video to time parameters.
trim-video() {
  if [ $# -ne 3 ]; then
    echo 'Ops. Please pass in the new video start time and the total duration in seconds.'
    echo 'Usage: trim-video <input_movie.mov> <time in seconds from start> <duration of new clip in seconds>'
    echo 'Example: "trim-video myvideo.mov 3 10" Produces a 10 second video begining from 3 seconds inside of the original clip.'
  else
    echo 'Begining to trim video...'
    ffmpeg -i $1 -ss $2 -c copy -t $3 trimmed_$1
    echo 'Complete. Video trimmed.'
    open chrome trimmed_$1
  fi
}

# Turn that video into webm format and make a poster image for it!
webmify() {
  if [ $# -eq 0 ]; then
    echo 'Oops. Please tell me the filename.'
    echo 'Usage: webmify <filename>'
  else
    ffmpeg -i "$1" -vcodec libvpx -acodec libvorbis -isync -copyts -aq 80 -threads 3 -qmax 30 -y "$1.webm"
    ffmpeg -ss 00:00:15 -i "$1.webm" -vframes 1 -q:v 2 "$1.jpg"
    open chrome $1.webm
  fi
}

# Convert all mkv video files in a directory into mp4's.
mkvtomp4() {
  COUNTER=`ls -1 *.mkv 2>/dev/null | wc -l`
  if [ $COUNTER != 0 ]; then
    for filename in *.mkv; do
      ffmpeg -i "$filename" -c:v libx264 -c:a libvo_aacenc -b:a 128k "${filename%.mkv}.mp4"
      echo "Converted: $filename to ${filename%.mkv}.mp4"
      # Now delete the mkv file.
      rm "$filename"
    done
  else
    echo 'No mkv files were found in this directory.'
    echo 'mkvtomp4 Usage: "cd" to the directory where the mkv video files are located and run "mkvtomp4" (and then go grab a coffee).'
  fi
}

# Convert all mov video files in a directory into mp4's.
movtomp4() {
  COUNTER=`ls -1 *.mov 2>/dev/null | wc -l`
  if [ $COUNTER != 0 ]; then
    for filename in *.mov; do
      ffmpeg -i "$filename" -vcodec h264 -acodec aac -strict -2 "${filename%.mov}.mp4"
      echo "Converted: $filename to ${filename%.mkv}.mp4"
      # Now delete the mov file.
      rm "$filename"
    done
  else
    echo 'No mkv files were found in this directory.'
    echo 'mkvtomp4 Usage: "cd" to the directory where the mkv video files are located and run "mkvtomp4" (then go grab a coffee).'
  fi
}

# Make an animated gif from any video file.
# http://gist.github.com/SlexAxton/4989674
# https://eternallybored.org/misc/gifsicle/
# Requires gifsicle.
gifify() {
  if [[ -n "$1" ]]; then
    if [[ $2 == '--better' ]]; then
      # gifsicle --optimize=2; Can be 1, 2, or 3. 3 is most aggressive.
      ffmpeg -i "$1" -pix_fmt rgb24 -r 24 -f gif -vf scale=500:-1 - | gifsicle --optimize=2 > "$1.gif"
    elif [[ $2 == '--best' ]]; then
      ffmpeg -i "$1" -pix_fmt rgb24 -f gif -vf scale=700:-1 - | gifsicle > "$1.gif"
    elif [[ $2 == '--tumblr' ]]; then
      ffmpeg -i "$1" -pix_fmt rgb24 -f gif -vf scale=400:-1 - | gifsicle -i --optimize=3 > "$1.gif"
    else
      ffmpeg -i "$1" -pix_fmt rgb24 -r 10 -f gif -vf scale=400:-1 - | gifsicle --optimize=3 --delay=7 > "$1.gif"
    fi
    open chrome $1.gif
  else
    echo 'Ops. Please enter a filename.'
    echo 'Usage: gifify <input_movie.mov> [ --better | --best | --tumblr ]'
  fi
}

# Upload that file to https://s3-us-west-2.amazonaws.com/static-jonathanbell-ca/<filename>
# Requires awscli be setup and configured.
static() {
  if [ $# -eq 0 ]; then
    echo 'Oops. Please give me a filename.'
    echo 'Usage: static <filename>'
  else
    aws s3 cp $1 s3://static-jonathanbell-ca --acl public-read --cache-control max-age=7776000
    printf "https://s3-us-west-2.amazonaws.com/static-jonathanbell-ca/$1" > /dev/clipboard
    echo "File available at: https://s3-us-west-2.amazonaws.com/static-jonathanbell-ca/$1 (copied to clipboard)"
    open chrome https://s3-us-west-2.amazonaws.com/static-jonathanbell-ca/$1
  fi
}

# List available aliases.
lsaliases() {
  echo
  echo 'Available aliases:'
  echo '=================='
  echo
  alias | awk -F'=' '{print $1}' | grep "alias" | awk '{gsub("alias ", ""); print}'
  echo
}

# List available functions.
lsfunctions() {
  echo
  echo 'Available functions:'
  echo '===================='
  typeset -f | awk '/ \(\) $/ && !/^main / {print $1}' | awk '{gsub("command_not_found_handle", ""); print}'
  echo
}

if [ "$OSTYPE" = "linux-gnu" ]; then

  # List all PPA's (third-party packages) installed on the system.
  listppa() {
    echo
    echo 'Installed PPAs:'
    echo '==============='
    echo
    for APT in `find /etc/apt/ -name \*.list`; do
      grep -o "^deb http://ppa.launchpad.net/[a-z0-9\-]\+/[a-z0-9\-]\+" $APT | while read ENTRY; do
        USER=`echo $ENTRY | cut -d/ -f4`
        PPA=`echo $ENTRY | cut -d/ -f5`
        echo $USER/$PPA
      done
    done
    echo
    echo 'To remove a PPA do: sudo add-apt-repository --remove ppa:<USER>/<PPA>'
    echo
  }

fi

# ------------------------------------------------------------------------------
# | Aliases
# ------------------------------------------------------------------------------

# Edit hosts file quickly.
alias hosts='echo "Instructions: https://support.rackspace.com/how-to/modify-your-hosts-file/#windows" && cd /mnt/c/Windows/System32/drivers/etc && open .'

# Show diskspace usage on main volume.
alias diskspace='df -h | grep /mnt/c && df -h | grep /mnt/s'

# Restart Apache.
alias restartapache='sudo service apache2 restart'
# Configure VirtualHosts
alias configvhosts='sudo nano /etc/apache2/sites-enabled/000-default.conf'
# Configure Apache.
alias configapache='sudo code.exe /etc/apache2/apache2.conf'

# Restart MySQL.
alias restartmysql='sudo service mysql restart'

# Update Ubuntu.
alias updateubuntu='sudo apt update -y && sudo apt autoclean -y && sudo apt clean -y && sudo apt upgrade -y && sudo apt autoremove --purge -y'

# Open expoler from the command line. Left over from my OSX days.
alias open='cmd.exe /c start'

# Change directory to your dotfiles directory.
alias dot='cd ~/.dotfiles'

# Open your notes in code editor.
alias notes="cd ~/Dropbox/Notes"

# Dropbox directory. : )
alias d='cd ~/Dropbox'

# Sites folder
alias s='cd ~/Dropbox/Sites'

# Desktop
alias desk='cd ~/Desktop'

# Run a backup.
alias backup="~/Dropbox/Documents/personal-backup-script.bash"

# For when you make that typ-o that you *will* make.
alias cd..='cd ..'
alias ..='cd ..'

# Quickly clear the Terminal window.
alias c='clear'

# Pretty print Git's history.
alias gitlog='git log --graph --oneline --all --decorate'

# When you just want to commit some changes to a personal project. Not useful for "real" projects.
alias lazycommit="git add . && git commit -a --allow-empty-message -m '' && git push"

# Remove all Docker containers and images
# alias removealldocker="docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && docker rmi $(docker images -q)"

# Add a WTFP Licence to a directory/project.
alias addwtfpl='wget -O LICENCE http://www.wtfpl.net/txt/copying/'

# List all globally installed NPM packages
alias globalnpmpackages='npm list -g --depth 0'

# Correct SSH permissions
alias correctsshpermissions='sudo chmod 700 ~/.ssh && sudo chmod -R 600 ~/.ssh/*'

# ------------------------------------------------------------------------------
# | Colorize Things
# ------------------------------------------------------------------------------

# Colorize git branch and current directory in the command prompt.
export PS1="\[$(tput bold)\]\[\033[31m\]→ \[\033[0m\]\[\033[105m\]\$(parse-git-branch)\[\033[0m\]\[$(tput bold)\]\[\033[36m\] \W\[\033[0m\] \[\033[2m\]$\[\033[0m\] "

# Colors to differentiate various file types with 'ls'.
#alias ls="command ls --color"
export LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:"

# Colorize 'grep'.
alias grep='grep --color=auto'

# ------------------------------------------------------------------------------
# | Git
# ------------------------------------------------------------------------------

# Don't prompt for merge_msg in Git.
export GIT_MERGE_AUTOEDIT=no

# ------------------------------------------------------------------------------
# | Misc
# ------------------------------------------------------------------------------

#
# Mostly inspired by Sensible Bash: https://github.com/mrzool/bash-sensible/blob/master/sensible.bash
#

if ((BASH_VERSINFO[0] < 4)); then
  echo "Looks like you're running an older version of Bash."
  echo 'You need at least bash-4.0 or some options will not work correctly.'
fi

# Automatically trim long paths in the prompt (requires Bash 4.x).
PROMPT_DIRTRIM=2

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# Update window size after every command.
shopt -s checkwinsize

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards).
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Autocorrect typos in path names when using 'cd'.
shopt -s cdspell 2> /dev/null

# Prepend cd to directory names automatically.
shopt -s autocd 2> /dev/null

# Correct spelling errors during tab-completion.
shopt -s dirspell 2> /dev/null

# Omit duplicates from bash history and commands that begin with a space.
export HISTCONTROL='ignoreboth'

# Append to the Bash history file, rather than overwriting it.
shopt -s histappend

# Save multi-line commands as one command.
shopt -s cmdhist

# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=50000
HISTFILESIZE=1000

# Avoid duplicate entries.
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands.
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# Make VS Code the default editor.
export EDITOR='code'

# Use PHP XDebug
export XDEBUG_CONFIG='idekey=VSCODE'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Case-insensitive globbing (used in pathname expansion).
shopt -s nocaseglob

# Perform file completion in a case insensitive fashion.
bind 'set completion-ignore-case on'

# Treat hyphens and underscores as equivalent.
bind 'set completion-map-case on'

# Display matches for ambiguous patterns at first tab press.
bind 'set show-all-if-ambiguous on'

# Immediately add a trailing slash when autocompleting symlinks to directories.
bind 'set mark-symlinked-directories on'

# Change the title of the Bash terminal to show the User@Hostname connection.
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}\007"'

# Fix NPM global stuff
# https://stackoverflow.com/a/41395398/1171790
export NPM_CONFIG_PREFIX=~/.npm-global
export PATH=$PATH:~/.npm-global/bin

# Show a random quote at Bash startup.
echo $(shuf -n 1 "$HOME/.dotfiles/bash/quotes.txt")
