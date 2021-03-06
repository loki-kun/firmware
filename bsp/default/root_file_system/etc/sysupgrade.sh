#!/bin/sh

BOARD=`uci get board.model.name`

case $BOARD in
    tl-wdr4900-v1 )
        SOC="mpc85xx" ;;
    * )
        SOC="ar71xx" ;;
esac

FILE="openwrt-${SOC}-generic-${BOARD}-squashfs-sysupgrade.bin"

echo -ne "\nHardware: $BOARD\n"
echo -ne "Downloading $FILE\n\n"
cd /tmp/
wget $(uci get firmware.upgrade.path)/${FILE}
wget $(uci get firmware.upgrade.path)/${FILE}.md5
echo -ne "\ndone. Comparing md5 sums: "
md5sum -c ${FILE}.md5
ret=$?
echo
if [ $ret -ne 0 ]; then
  echo -ne "md5 sums do not match. Try restarting this script to redownload the firmware.\n\n"
  rm -f ${FILE}*
  exit 1
else
  while true; do
    read -p "md5 sums correct. Should I start upgrading the firmware (y/N)? " yn
    case $yn in
        [Yy] ) echo -ne "\nStarting firmware upgrade. Don't touch me until I reboot.\n\n\n"; sysupgrade ${FILE}; break;;
        [Nn]|* ) echo -ne "\nAborting firmware upgrade.\n\n"; rm -f ${FILE}*; exit 0;;
    esac
  done
fi