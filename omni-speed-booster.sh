cat << 'EOF' > /root/omni-speed-booster.sh
#!/bin/bash
echo "< MEMULAI OMNI SPEED BOOSTER V12.0 - GLOBAL INTERNET MENTOK 100% (Debian 13 Trixie) <"
echo "=¡ 100% Network + DNS-over-HTTPS Cloudflare | Tidak ada lagi yang bisa ditambahkan | No Hardware Tuning"
echo "=Ì Khusus Debian GNU/Linux 13 (trixie) | PRETTY_NAME=\"Debian GNU/Linux 13 (trixie)\""

# =============================================
# 1. UPDATE & INSTALL DEPENDENCIES (Minimal & Aman)
# =============================================
echo "=à Update sistem & install paket yang diperlukan..."
apt update && apt install -y dnscrypt-proxy nftables || true

# =============================================
# 2. DNS-OVER-HTTPS (CLOUDFLARE) - GLOBAL & MAXED
# =============================================
echo "= Mengaktifkan DNS-over-HTTPS (DoH) Cloudflare 1.1.1.1 + IPv6..."

# Matikan systemd-resolved agar tidak konflik (best practice server)
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable --now systemd-resolved 2>/dev/null || true

# Konfigurasi dnscrypt-proxy (native Debian, pakai DoH Cloudflare resmi)
cat << 'TOML' > /etc/dnscrypt-proxy/dnscrypt-proxy.toml
# =============================================
# OMNI SPEED BOOSTER - DNS-over-HTTPS CONFIG
# Cloudflare DoH: https://cloudflare-dns.com/dns-query
# IPv4 + IPv6 full support | Minimal & Super Fast
# =============================================
listen_addresses = ['127.0.0.1:53', '[::1]:53']

# Cloudflare DoH resmi (support IPv4 + IPv6)
server_names = ['cloudflare']

# Force DoH only (tidak pakai DNSCrypt lama)
dnscrypt_servers = false
doh_servers = true
ipv6_servers = true

# Keamanan & Privasi Max (no log, no filter, DNSSEC)
require_dnssec = true
require_nolog = true
require_nofilter = true

# Performance tuning
cache_size = 4096
max_clients = 250
timeout = 3000
keepalive = 30

# Matikan auto-update resolver list (lebih cepat & stabil)
#[sources]
#  [sources.'public-resolvers']
#  url = 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md'
#  cache_file = '/var/cache/dnscrypt-proxy/public-resolvers.md'
#  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
#  refresh_delay = 72
#  prefix = ''
TOML

# Restart & enable service
systemctl restart dnscrypt-proxy
systemctl enable dnscrypt-proxy

# =============================================
# 3. RESOLV.CONF - Lock ke Local DoH Proxy
# =============================================
echo "=á Mengunci /etc/resolv.conf ke Cloudflare DoH..."
chattr -i /etc/resolv.conf 2>/dev/null || true
cat << 'RES' > /etc/resolv.conf
# =============================================
# OMNI SPEED BOOSTER - DNS-over-HTTPS Cloudflare
# https://cloudflare-dns.com/dns-query
# IPv4: 1.1.1.1 & 1.0.0.1
# IPv6: 2606:4700:4700::1111 & 2606:4700:4700::1001
# =============================================
nameserver 127.0.0.1
nameserver ::1
options edns0 trust-ad
RES
chattr +i /etc/resolv.conf

# =============================================
# 4. TUNING JARINGAN - TCP BBR + BUFFER 128MB + GLOBAL MAX
# =============================================
echo "< 100% JARINGAN FULL MENTOK (BBR + Buffer Extreme + IPv6)..."

modprobe tcp_bbr 2>/dev/null || true

cat << 'SYSCTL' > /etc/sysctl.d/99-omni-speed-booster.conf
# =============================================
# OMNI SPEED BOOSTER V12.0 - NETWORK MAXED
# TCP BBR + LOW LATENCY + BUFFER 128MB + IPv4/IPv6
# Tidak ada lagi yang bisa ditambahkan (Debian 13 Trixie)
# =============================================

# === CONGESTION CONTROL & QDISC ===
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# === TCP FAST OPEN & LOW LATENCY ===
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_window_scaling = 1

# === BUFFER MENTOK 128MB (Global High-BDP) ===
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# IPv6 Buffer (full dual-stack)
net.ipv6.tcp_rmem = 4096 87380 134217728
net.ipv6.tcp_wmem = 4096 65536 134217728

# === KONEKSI MAX & STABIL ===
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.ip_forward = 1

# === OPTIMASI TAMBAHAN (tidak bisa ditambah lagi) ===
net.core.optmem_max = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 5
SYSCTL

sysctl --system 2>/dev/null || true

# =============================================
# 5. FIREWALL (NFTABLES) - OUTBOUND FULL OPEN, INPUT AMAN
# =============================================
echo "=á Konfigurasi Firewall (NFTables) - Aman untuk Bot/Server..."

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
# 6. PERSISTENCE (Systemd + sysctl.d sudah otomatis)
# =============================================
echo "= Semua sudah persistent via systemd & /etc/sysctl.d"

# =============================================
echo " SELESAI! Server sudah GLOBAL INTERNET MENTOK KANAN"
echo "   " DNS-over-HTTPS Cloudflare (https://cloudflare-dns.com/dns-query)"
echo "   " TCP BBR + Buffer 128MB + IPv6 full"
echo "   " Firewall aman + outbound terbuka"
echo "   " Siap upload ke GitHub (nama file: omni-speed-booster-debian13.sh)"
echo "   " Reboot direkomendasikan untuk efek maksimal: reboot"
EOF

chmod +x /root/omni-speed-booster.sh && /root/omni-speed-booster.sh