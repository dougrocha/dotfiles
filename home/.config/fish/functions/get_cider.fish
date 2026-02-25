function get_cider
  set pid (pgrep -x Cider | head -1)
  or return 1
  echo "chromium.instance$pid"
end
