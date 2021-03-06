#!/bin/bash

set -e

program_name=$0

function usage() {
  echo "Poppy robot installation script"
  echo ""
  echo "usage: $program_name"
  echo "   or: $program_name [--argument=argument-value]"
  echo ""
  echo "Arguments:"
  echo "  --creature           Set the robot type (default: poppy-ergo-jr)"
  echo "  --username           Set the Poppy user name (default: poppy)"
  echo "  --password           Set password for the Poppy user (default: poppy)"
  echo "  --hostname           Set the robot hostname (default: poppy)"
  echo "  --branch             Install from a given git branch (default: master)"
  echo "  --shutdown           Shutdown the system after installation"
  echo "  -?|--help            Show this help"
  echo ""
  echo "Example usage:"
  echo "  ./raspoppyfication.sh"
  echo "  ./raspoppyfication.sh --creature=poppy-ergo-starter --hostname=roboto"
  echo "  ./raspoppyfication.sh --help"
  exit
}

for i in "$@"
do
case $i in
  -?|--help)
  usage
  exit
  shift
  ;;
  --creature=*)
  poppy_creature="${i#*=}"
  shift
  ;;
  --username=*)
  poppy_username="${i#*=}"
  shift
  ;;
  --password=*)
  poppy_password="${i#*=}"
  shift
  ;;
  --hostname=*)
  poppy_hostname="${i#*=}"
  shift
  ;;
  --branch=*)
  git_branch="${i#*=}"
  shift
  ;;
  -s|--shutdown)
  shutdown_after_install=1
  shift
  ;;
esac
done

poppy_creature=${poppy_creature:-"poppy-ergo-jr"}
poppy_username=${poppy_username:-"poppy"}
poppy_password=${poppy_password:-"poppy"}
poppy_hostname=${poppy_hostname:-"poppy"}
git_branch=${git_branch:-"master"}
shutdown_after_install=${shutdown_after_install:-0}

url_root="https://raw.githubusercontent.com/poppy-project/raspoppy/$git_branch"

cd /tmp || exit
wget "$url_root/setup-system.sh"
bash setup-system.sh "$poppy_username" "$poppy_password" "$poppy_hostname"

wget "$url_root/setup-python.sh"
sudo -u "$poppy_username" bash setup-python.sh

wget "$url_root/setup-poppy.sh"
sudo -u "$poppy_username" bash setup-poppy.sh "$poppy_creature" "$poppy_hostname"

echo -e "\e[33mSetting hotspot.\e[0m"
wget "$url_root/setup-hotspot.sh"
bash setup-hotspot.sh

echo -e "\e[33mChange hostname to \e[4m$poppy_hostname.\e[0m"
sudo raspi-config --change-hostname "$poppy_hostname"

if [ $shutdown_after_install -eq 1 ]; then
  sudo shutdown -h now
fi
