set -e
mkdir -p ~/.local/share/hhd && cd ~/.local/share/hhd
python3 -m venv --system-site-packages venv
source venv/bin/activate
pip3 install --upgrade hhd adjustor
sudo mkdir -p /etc/udev/rules.d/
sudo mkdir -p /etc/udev/hwdb.d/
sudo curl https://raw.githubusercontent.com/hhd-dev/hhd/master/usr/lib/udev/rules.d/83-hhd.rules -o /etc/udev/rules.d/83-hhd.rules
sudo curl https://raw.githubusercontent.com/hhd-dev/hhd/master/usr/lib/udev/hwdb.d/83-hhd.hwdb -o /etc/udev/hwdb.d/83-hhd.hwdb
sudo curl https://raw.githubusercontent.com/hhd-dev/hhd/master/usr/lib/systemd/system/hhd_local%40.service -o /etc/systemd/system/hhd_local@.service
mkdir -p ~/.local/bin
ln -sf ~/.local/share/hhd/venv/bin/hhd ~/.local/bin/hhd
ln -sf ~/.local/share/hhd/venv/bin/hhd.contrib ~/.local/bin/hhd.contrib

FINAL_URL='https://api.github.com/repos/hhd-dev/hhd-ui/releases/latest'
curl -L $(curl -s "${FINAL_URL}" | grep "browser_download_url" | cut -d '"' -f 4) -o $HOME/.local/bin/hhd-ui
chmod +x $HOME/.local/bin/hhd-ui

if [ -f /sys/fs/selinux/enforce ]; then
  # The presence of this file means SELinux is loaded in the kernel.
  # A value of 0 means Permissive, 1 means Enforcing.
  selinux_enforcing=$(cat /sys/fs/selinux/enforce)
  if [[ "$selinux_enforcing" != "0" ]]; then
    echo "SELinux is loaded and in enforcing mode: changing hhd file security contextes:"
    # Fedora Atomic derived distros (e.g. bazzite-gnome) have /home as a symlink to /var/home
    user_home_dir=$(readlink -f $HOME)
    sudo semanage fcontext -a -t bin_t $user_home_dir/.local/share/hhd/venv/bin/'.*'
    sudo restorecon -Rv $user_home_dir//.local/share/hhd/venv/bin/
  fi
fi

# Start service and reboot
sudo systemctl enable --now hhd_local@$(whoami)

echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! Do not forget to remove a Bundled Handheld Daemon if your distro preinstalls it. !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo "Reboot!"
