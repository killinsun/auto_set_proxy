#!/usr/bin/env bash

HTTP_PROXY="user:pass@proxy.example.com"
HTTPS_PROXY="$HTTP_PROXY"

# Exit if already bootstrapped
#[ -f /etc/bootstrapped ] && exit

echo "Setting HTTP Proxy for /etc/environment"
cat << EOM >> /etc/environment

http_proxy="http://$HTTP_PROXY/"
https_proxy="http://$HTTPS_PROXY/"
EOM

if [ -d /etc/apt ]; then
  echo "Setting HTTP Proxy for /etc/apt/apt.conf"
  [ ! -f /etc/apt/apt.conf ]; touch /etc/apt/apt.conf
  sed "s/Acuire::http::proxy/D" /etc/apt/apt.conf
  sed "s/Acuire::https::proxy/D" /etc/apt/apt.conf

  cat << EOM >> /etc/apt/apt.conf
  Acquire::http::proxy "http://$HTTP_PROXY/";
  Acquire::https::proxy "http://$HTTPS_PROXY/";
EOM

elif [ -f /etc/yum.conf ]; then
  echo "Setting HTTP Proxy for /etc/yum.conf"
  sed "s/proxy=/D" /etc/yum.conf

  cat << EOM >> /etc/yum.conf
  proxy=http://$HTTP_PROXY/
EOM

#for dns-resolve configuration
/usr/bin/sudo /sbin/service network restart
else
  echo "no Ubuntu/CentOS"
fi

echo "Setting HTTP Proxy for cURL in Vagrant user directory"
if [ -d /home/vagrant ]; then

cat << EOM >> /home/vagrant/.curlrc
proxy = "http://$HTTP_PROXY/"
EOM

fi

if [ -f /etc/wgetrc ]; then

cat << EOM >> /etc/wgetrc
https_proxy = http://$HTTPS_PROXY/
http_proxy = http://$HTTP_PROXY/
ftp_proxy = http://$HTTP_PROXY/
use_proxy = on
EOM
fi

date > /etc/bootstrapped
