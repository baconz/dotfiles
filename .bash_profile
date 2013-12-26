# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth
HISTSIZE=10000
# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PS1='\[\033[01;32m\]\u@mac\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

export PAGER=less
alias compete_vpn='sudo /usr/local/sbin/vpnc --dpd-idle 0 /etc/vpnc/vpnc.conf'
alias compete_vpn_wireless='sudo /usr/local/sbin/vpnc --dpd-idle 0 /etc/vpnc/vpnc_wireless.conf'
alias vpn_disconnect='sudo /usr/local/sbin/vpnc-disconnect'
# TODO NOTE: After disconnecting, need to do route -n flush && ifconfig en0 down && ifconfig en0 up

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

[ -f /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion
