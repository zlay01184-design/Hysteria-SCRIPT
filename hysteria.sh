
#!/bin/bash
# UDP Hysteria Auto Installer with Custom Password

echo "=================================================="
echo "          UDP Hysteria VIP Installer             "
echo "=================================================="
echo ""

# User ဆီကနေ Obfs Password တောင်းခြင်း
read -p "Bro ပေးချင်တဲ့ UDP Server Obfs Password ကို ရိုက်ထည့်ပါ: " USER_OBFS

# တကယ်လို့ ဘာမှမရိုက်ဘဲ Enter ခေါက်သွားရင် zawobfs ကို ပုံသေယူမယ်
if [ -z "$USER_OBFS" ]; then
    USER_OBFS="zawobfs"
fi

echo ""
echo "၁။ စနစ်ကို Update လုပ်နေပါသည်..."
apt update -y && apt upgrade -y
apt install -y wget curl openssl

echo "၂။ UDP Hysteria Core ကို ဒေါင်းလုဒ်ဆွဲနေပါသည်..."
wget -O /usr/local/bin/hysteria https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64
chmod +x /usr/local/bin/hysteria

echo "၃။ လုံခြုံရေးအတွက် Certificate တည်ဆောက်နေပါသည်..."
mkdir -p /etc/hysteria
openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -days 3650 -subj "/C=TH/ST=BKK/L=BKK/O=Zlay/OU=VPN/CN=zawvpn.com"

echo "၄။ Hysteria Config ဖိုင်ကို ရေးဆွဲနေပါသည်..."
cat <<EOF > /etc/hysteria/config.yaml
listen: :3699
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key
auth:
  type: password
  password: zlay01184
obfs:
  type: salamander
  password: $USER_OBFS
EOF

echo "၅။ System Service ဖန်တီးနေပါသည်..."
cat <<EOF > /etc/systemd/system/hysteria.service
[Unit]
Description=Hysteria UDP Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

echo "၆။ Hysteria Server ကို စတင်နေပါသည်..."
systemctl daemon-reload
systemctl enable hysteria
systemctl restart hysteria

echo ""
echo "=================================================="
echo "✅ UDP Hysteria Server အောင်မြင်စွာ တပ်ဆင်ပြီးပါပြီ!"
echo "📌 Bro သတ်မှတ်ခဲ့တဲ့ Obfs Password ကတော့: $USER_OBFS ဖြစ်ပါတယ်"
echo "=================================================="
