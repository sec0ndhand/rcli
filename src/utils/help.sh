#!/usr/bin/env bash

# Reset
Color_Off='\033[0m'       # Text Reset
Clear_Screen='\033[2K'    # Clear Screen
Clear_Screen_Reset_Position='\033[2K\033[0G'    # Clear Screen and reset cursor position

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
BGray='\033[1;38m'       # Gray

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

cli_help_args() {
  declare desc="help args indentation"
  echo -e "\t\t\t   $*"
}

# given a resource, print all of the commands in it's folder, and their descriptions
# find the default command, read the first line and print just the resource and description from the file
# the default command references
# handle the rest of the commands as described below
# grep the variable DESCRIPTION= from the file found in the $RESOURCE_PATH/$RESOURCE/$COMMAND
# print the resource command & description using printf so it feels tabular, with the correct indentation
# without the use of tabs
cli_help_commands() {
  local LENGTH=25
  declare desc="print all of the commands in a resource, and their descriptions"
  local RESOURCE=$1
  local RESOURCE_PATH=$2
  local RESOURCE_COMMANDS=$(find -L "$RESOURCE_PATH/$RESOURCE" -maxdepth 1 -type f -exec basename {} \; | grep -v "default" | sort)
  local DEFAULT_COMMAND=$(find -L "$RESOURCE_PATH/$RESOURCE" -maxdepth 1 -type f -name "*default*" -exec basename {} \;)

  printf "${BGray}------------------------------------------------------\n${Color_Off}"

  if [[ -n "$DEFAULT_COMMAND" ]]; then
    # Extract referenced script name from the default command
    local REFERENCED_SCRIPT=$(awk -F'"' '/'RESOURCE_PATH'/ {print $2}' "$RESOURCE_PATH/$RESOURCE/$DEFAULT_COMMAND")
    local REFERENCED_SCRIPT_NAME=$(basename "$REFERENCED_SCRIPT")

    # Fetch the description from the referenced script
    if [[ -f "$RESOURCE_PATH/$RESOURCE/$REFERENCED_SCRIPT_NAME" ]]; then
      local DEFAULT_DESCRIPTION=$(grep "^# HELP=" "$RESOURCE_PATH/$RESOURCE/$REFERENCED_SCRIPT_NAME" | sed 's/^# HELP=//g')
      printf "${BGreen}%-${LENGTH}s${Color_Off} ${BIBlue}default${Color_Off}: %s\n" "$RESOURCE" "$REFERENCED_SCRIPT_NAME -- $DEFAULT_DESCRIPTION"
    fi
  fi


  for COMMAND in $RESOURCE_COMMANDS; do
    if [[ -f "$RESOURCE_PATH/$RESOURCE/$COMMAND" ]]; then
      local DESCRIPTION=$(grep "^# HELP=" "$RESOURCE_PATH/$RESOURCE/$COMMAND" | sed 's/^# HELP=//g')
      printf "${BGreen}%-${LENGTH}s${Color_Off} %s\n" "$RESOURCE $COMMAND" "$DESCRIPTION"
    fi
  done
}



