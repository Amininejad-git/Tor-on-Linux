#!/bin/bash
sudo apt update 
sleep 2
sudo apt install tor -y &
sleep 2
sudo apt install obfs4proxy -y &
sleep 2

echo " #add bridge
SocksPolicy accept 192.168.0.0/16
SocksPort 127.0.0.1:9050
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
Bridge obfs4 185.120.77.129:443 3218F7484BD3456A44351F61ED6F71164605EFE3 cert=r78FCpxq/CZIiWQ0k4gnv9J1sBly5vAxOCUHW+I8m9rA8s73lgGHTYFVHaB5f+p1pH6DWg iat-mode=0
Bridge obfs4 94.242.249.4:9904 E25A95F1DADB739F0A83EB0223A37C02FD519306 cert=j530B23jE9LX81BOl/cqdjaTVMOXSjPDxevcwq6jKVvnDgvQk/4Gsqfmnc8/wAFzAqtRWg iat-mode=0
Bridge obfs4 50.3.72.238:443 EF870A94B09A90C3C5E3BD6115C33635CDE5D100 cert=u/Q/4VXrf6SbGbBMyApndlDdRh8DWa4HYM6ijjeEI60ZZbfFzcpULJ/VlXxM0o/elsfxEg iat-mode=0 " | tee -a /etc/tor/torrc
sleep 5
#systemctl reload tor
systemctl start tor

echo "  ..............
..................................
.............[ TOR IS READY ] ........................
............................................
.............................."

exit 0
