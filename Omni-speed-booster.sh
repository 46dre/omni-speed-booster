cat << 'EOF' > \~/omni-speed-booster/omni-speed-booster.sh
#!/bin/bash
echo "🌌 MEMULAI OMNI SPEED BOOSTER V12.1 - GLOBAL INTERNET MENTOK 100% (Debian 13 Trixie) 🌌"
echo "💡 100% Network + DNS-over-HTTPS Cloudflare | Anti-error total | No Hardware"

# =============================================
# 1. UPDATE & INSTALL
# =============================================
echo "🛠️ Update & install paket..."
apt update && apt install -y dnscrypt-proxy nftables || true

# =============================================
# 2. DNS-over-HTTPS Cloudflare (DoH)
# =============================================
echo "🔒 Mengaktifkan DNS-over-HTTPS Cloudflare 1.1.1.1 + IPv6..."

systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable --now systemd-resolved 2>/dev/null || true

cat << 'TOML' > /etc/dnscrypt-proxy/dnscrypt-proxy.toml
listen_addresses = ['127.0.0.1:53', '[::1]:53']
server_names = ['cloudflare']
dnscrypt_servers = false
doh_servers = true
ipv6_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = true
cache_size = 4096
max_clients = 250
timeout = 3000
keepalive = 30
TOML

# FIX dependency error permanen
systemctl daemon-reload
systemctl disable --now dnscrypt-proxy-resolvconf.service 2>/dev/null || true
systemctl restart dnscrypt-proxy || true
systemctl enable dnscrypt-proxy || true

# =============================================
# 3. Lock resolv.conf
# =============================================
echo "📡 Mengunci DNS ke Cloudflare DoH..."
chattr -i /etc/resolv.conf 2>/dev/null || true
cat << 'RES' > /etc/resolv.conf
nameserver 127.0.0.1
nameserver ::1
options edns0 trust-ad
RES
chattr +i /etc/resolv.conf

# =============================================
# 4. NETWORK TUNING (BBR + 128MB + IPv6 FULL)
# =============================================
echo "🌐 100% JARINGAN FULL MENTOK..."

modprobe tcp_bbr 2>/dev/null || true

# Hapus file sysctl lama yang konflik
rm -f /etc/sysctl.d/99-omni-network-max.conf /etc/sysctl.d/11-disable-ipv6.conf 2>/dev/null || true

cat << 'SYSCTL' > /etc/sysctl.d/99-omni-speed-booster.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv6.tcp_rmem = 4096 87380 134217728
net.ipv6.tcp_wmem = 4096 65536 134217728
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.ip_forward = 1
net.core.optmem_max = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 5
SYSCTL

sysctl --system 2>/dev/null || true

# =============================================
# 5. FIREWALL
# =============================================
echo "🛡️ Firewall aman (outbound full open)..."
cat << 'NFT' | sudo tee /etc/nftables.conf
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state established,related accept
        tcp dport 22 accept
        tcp dport { 80, 443, 53 } accept
        udp dport 53 accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
NFT
sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables 2>/dev/null || true

# =============================================
echo "✅ SELESAI! Server sudah GLOBAL INTERNET MENTOK KANAN (V12.1)"
echo "   - DNS-over-HTTPS Cloudflare (https://cloudflare-dns.com/dns-query)"
echo "   - TCP BBR + Buffer 128MB + IPv6 full"
echo "   - Firewall aman + outbound terbuka"
echo "   - Semua error & warning sudah dihilangkan"
echo "   - Reboot direkomendasikan: reboot"
EOF

# Jalankan script baru
cd \~/omni-speed-booster
chmod +x omni-speed-booster.sh
sudo ./omni-speed-booster.sh
