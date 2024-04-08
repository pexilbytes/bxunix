#!/bin/bash
# @Author: whybe
# Purpose: Automatically clean disk space using yes command

# --- <INCLUDES> & <SOURCES> ---
# current user home directory
# . $HOME/scripts/utils.sh
# . /home/whybe/scripts/utils.sh

# --- <UTILS> ---
color() {
  local color_code="$1"
  local text="$2"
  local emphasize="$3"
  local reset="\e[0m"
  local color="\e[${color_code}m"
  if [ "$emphasize" = "true" ]; then
    echo "${color}\e[1m${text}${reset}"
  else
    echo "${color}${text}${reset}"
  fi
}

alert() {
  local flag="$1"
  local message="$2"
  local status="$3"

  case "$status" in
    "Warning")
      color_code="93" ;; # light yellow
    "Info")
      color_code="94" ;; # light blue
    "Error")
      color_code="91" ;; # light red
    "Success")
      color_code="92" ;; # light green
    *)
      color_code="0" ;;   # reset color if status is unknown
  esac

  local colored_flag=$(color "$color_code" "[$flag]" true)
  local reset=$(color "0" "" false)
  
  echo "▩ ${colored_flag}: ${message}${reset}"
}

# --- ARGUMENTS ---
arg_docker_builder_cache=false # remove docker builder cache

while test $# -gt 0; do
  case "$1" in
    --docker_builder | -dockb)
      arg_docker_builder_cache=true
      ;;

    # default throw a message of the script benn passed an unknown argument
    *)
      echo "Unknown argument: $1"
      ;;
  esac
  shift
done

alert "INFO" "Cleaning disk space" "Info"
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo apt-get autoclean -y

# remove all files in /tmp and /var/tmp and the cache of apt
alert "INFO" "Removing all files in /tmp and /var/tmp and the cache of apt" "Info"
yes | rm -rf /tmp/* /var/tmp/*
yes | rm -rf /var/cache/apt/archives/*
yes | rm -rf /var/cache/debconf/*
yes | rm -rf /var/cache/apt/*.bin

# remove jornal logs and other logs tail 3 days
logs_vacuum_time='1d'
logs_vacuum_size='10M'
alert "INFO" "Removing jornal logs and other logs tail 3 days" "Info"
sudo journalctl --rotate --vacuum-time=${logs_vacuum_time} --vacuum-size=${logs_vacuum_size}

# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
alert "INFO" "Removing old revisions of snaps" "Info"
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
  while read snapname revision; do
    snap remove "$snapname" --revision="$revision"
  done

# remove docker builder cache
if [ "$arg_docker_builder_cache" = true ]; then
  alert "INFO" "Removing docker builder cache" "Info"
  docker builder prune -a -f
fi    