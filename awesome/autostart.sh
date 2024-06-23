#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run openrgb -p Default
run liquidctl --match kraken set lcd screen gif ~/Pictures/driving-chill.gif

run xrandr --output DP-4 --primary --mode 2560x1440 --rate 240 --pos 0x0 --rotate normal --output DP-2 --mode 2560x1440 --pos 2560x0 --rate 144 --rotate normal
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

run feh --no-fehbg --bg-fill '/home/dougr/.config/awesome/wallpapers/boat.png'
run picom -b

run cider
run discord
