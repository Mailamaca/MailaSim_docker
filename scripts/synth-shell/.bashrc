# ~/.bashrc: executed by bash(1) for non-login shells.

HOME=/home/snail

##-----------------------------------------------------
## synth-shell-prompt
## https://github.com/andresgongora/synth-shell/
if [ -f ${HOME}/.config/synth-shell/synth-shell-prompt.sh ]; then
	source ${HOME}/.config/synth-shell/synth-shell-prompt.sh
fi

##-----------------------------------------------------
## better-ls
## https://github.com/andresgongora/synth-shell/
if [ -f ${HOME}/.config/synth-shell/better-ls.sh ]; then
	source ${HOME}/.config/synth-shell/better-ls.sh
fi

##-----------------------------------------------------
## alias
## https://github.com/andresgongora/synth-shell/
if [ -f ${HOME}/.config/synth-shell/alias.sh ]; then
	source ${HOME}/.config/synth-shell/alias.sh
fi

####################################### PERSONAL SETUP ####################

# Source ROS
source /opt/ros/$ROS_DISTRO/setup.bash
