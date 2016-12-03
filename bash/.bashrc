# determine the system OS: http://stackoverflow.com/a/8597411/1171790

# stuff to do on a Linux/Ubuntu or Mac system...
if [ "$OSTYPE" = "linux-gnu" ] || [ "$OSTYPE" = "darwin"* ]; then

	# change directory to working folder for web projects
	if [ -d "$HOME/Dropbox/Sites" ]; then
		cd $HOME/Dropbox/Sites;
	fi

	# shortcuts
	alias dot="cd ~/.dotfiles"
	alias sublimedir="cd ~/.config/sublime-text-3/Packages/User"
	alias resartapache="sudo service apache2 restart"
	alias l="ls -laF ${colorflag}"
	alias d="cd ~/Dropbox"
	alias s="cd ~/Dropbox/Sites"
	alias small="export PS1=\"\$ \""
  alias hosts="sudo nano /etc/hosts"
  alias configapache="sudo subl /etc/apache2/apache2.conf"

	# make sure we have a good gamma for coding set
	echo "Setting screen gama..."
	xgamma -gamma 0.91
	echo

	echo "Dropbox Status:"
	dropbox status
	echo

fi # end if Ubuntu/Mac

# if [ $(which ssh-agent) ]; then
# 	echo
# 	echo "Starting SSH Agent: $(which ssh-agent)"
# 	# http://stackoverflow.com/questions/5727555/remember-password-git-bash-under-windows
# 	eval `ssh-agent -s`
# 	ssh-add
# 	echo
# else
# 	echo "No SSH Agent found. You should install one."
# fi

# make sublime text the default editor
export EDITOR='subl';

# omit duplicates from bash history and commands that begin with a space
export HISTCONTROL='ignoreboth';

# prefer US English and use UTF-8
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# append to the Bash history file, rather than overwriting it
shopt -s histappend;

# autocorrect typos in path names when using `cd`
shopt -s cdspell;

# don't prompt for merge_msg in git
export GIT_MERGE_AUTOEDIT=no

# show Git branch and current working directory in Bash
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# shows something like: jonathan@jonathan-thinkpad ~/Desktop/nodepwdmanager (master) $ 
# export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
# shows something like: ~/.dotfiles (master) $  
export PS1="\[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \$ "
# change \W to \w to show all parts of the current working directory

# Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
