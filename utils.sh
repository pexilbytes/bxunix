#!/bin/bash

# Declare all the usful reusable shell functions
# === [UTILS] ===
# CLI color function that colors the text passed to it, based on the color code, and `emphasize` the text if the 3rd argument is set to `true`
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

# a separator title function that prints a separator with the title passed to it
title() {
  # make the title uppercase
  
  local title=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  echo ""
  echo "════▩▶ \e[1;95m${title}\e[0m ◀▩════"
}

# Function that exucutes commands with sudo if the user is not root or the script is not run as root
# EXAMPLE: `rm -rf ./logs` or `sudo rm -rf ./logs`
# USAGE: `umd rm -rf ./logs`
umd() {
  if [ "$(id -u)" -ne 0 ]; then
    "$@" >/dev/null 2>&1
  else
    sudo "$@" >/dev/null 2>&1
  fi
}


# alter between `docker compose` and `docker-compose` commands witth sudo and without sudo using the `umd` function
# EXAMPLE: `docker compose up -d` or `docker-compose down`, `sudo docker-compose up -d` or `sudo docker compose down`
# USAGE: `docker_compose up -d` or `docker_compose down`
# NOTE: using the `umd` function to execute the commands with sudo if the user is not root or the script is not run as root
docker_compose() {
  # check if the `docker compose` command exists
  if command -v "docker compose" &> /dev/null; then
    # run the command with sudo if the user is not root or the script is not run as root
    if [ "$(id -u)" -ne 0 ]; then
      docker compose $@
    else
      sudo docker compose $@
    fi
  else
    if [ "$(id -u)" -ne 0 ]; then
      docker-compose $@
    else
      sudo docker-compose $@
    fi
  fi
}

# Function that return the docker image id of bassed on the arg Image and tag
# USAGE: `docker_image_id "odoo" "14.0"`
docker_image_id() {
  local image="$1"
  local tag="$2"
  local docker_image_id=$(docker images | grep $image | grep $tag | awk '{print $3}')
  echo $docker_image_id
}
