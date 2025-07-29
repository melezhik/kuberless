 while true; do
  sleep 2
  s6 --index-update
  s6 --plg-run nano-setup
 done
