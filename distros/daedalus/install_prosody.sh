#---------------------------------------------------------------------
# Function: InstallProsody
#    Install prosody XMPP
#---------------------------------------------------------------------
InstallProsody() {
  echo -n "Installing Prosody... ";
  apt_install build-essential prosody luarocks liblua5.2-dev
  luarocks install $APWD/distros/beowulf/lpc-1.0.0-3.src.rock
  ln -s /etc/prosody/certs/localhost.crt /etc/prosody/certs/localhost.cert
  sed -i -e '50i\\t\tps aux | grep "lua5.2 $DAEMON"  | grep -v grep | tr -s " " | cut -d " " -f2 >$PIDFILE' /etc/init.d/prosody
  echo -e "[${green}DONE${NC}]\n"
}
