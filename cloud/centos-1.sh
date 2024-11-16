# sshd
cat > /etc/ssh/sshd_config.d/99-liuxu.conf <<eof
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication yes
ClientAliveInterval 30
ClientAliveCountMax 3
eof
systemctl restart sshd.service

# net tools
dnf install -y wget curl git vim net-tools

# caddy
# dnf install 'dnf-command(copr)'
dnf copr enable @caddy/caddy -y
dnf install -y caddy
systemctl enable --now caddy.service

# ss
dnf copr enable atim/shadowsocks-rust -y
dnf install -y shadowsocks-rust
mkdir /etc/shadowsocks-rust/server/liuux/
cat > /etc/shadowsocks-rust/server/liuxu/ss.json5 <<eof
{
    "server": "::",
    "server_port":1024,
    "password":"xxxxxx",
    "timeout":600,
    "method":"chacha20-ietf-poly1305",
    "mode":"tcp_only",
    "fast_open":false
}
eof
systemctl enable --now shadowsocks-rust-server@liuxu.service

# alist
mkdir /opt/alist
cd /tmp/
wget https://github.com/AlistGo/alist/releases/latest/download/alist-linux-amd64.tar.gz
tar xzvf alist-linux-amd64.tar.gz -C /opt/alist/
cat > /usr/lib/systemd/system/alist.service <<eof
[Unit]
Description=Alist service
Wants=network.target
After=network.target network.service

[Service]
Type=simple
WorkingDirectory=/opt/alist
ExecStart=/opt/alist/alist server
KillMode=process

[Install]
WantedBy=multi-user.target
eof
systemctl enable --now alist.service

# jupyter / user
cd /tmp/
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
bash Miniforge3-Linux-x86_64.sh -b
mamba install jupyterlab matplotlib bokeh ipython
mkdir notebooks
cat > /usr/lib/systemd/system/jupyter.service <<eof
[Unit]
Description=Jupyter Lab

[Service]
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=/bin/bash -c "source /home/liuxu/.bashrc && jupyter lab" 
User=liuxu
Group=liuxu
WorkingDirectory=/home/liuxu/notebooks
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
eof
systemctl enable --now jupyter.service
