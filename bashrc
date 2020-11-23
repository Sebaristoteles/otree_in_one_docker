# from Debian Buster ~/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'


# added to standard bashrc
# from:
# https://otree.readthedocs.io/en/latest/server/ubuntu.html#server-ubuntu
# (not sure if necessary for Debian)
export DATABASE_URL=postgres://otree_user:mydbpassword@0.0.0.0:5432/django_test
export REDIS_URL=redis://localhost:6379
export OTREE_ADMIN_PASSWORD=my_admin_password
#export OTREE_PRODUCTION=1
export OTREE_AUTH_LEVEL=DEMO
