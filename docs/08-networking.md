# 08 — Red y VPN

## Estado: Pendiente

---

## Objetivos

- DNS seguro (DoH o DoT)
- Configuracion correcta de NetworkManager
- VPN (WireGuard o OpenVPN)
- Aislamiento de red por aplicacion (opcional)

---

## 1. Estado actual de red

```bash
ip addr show
ip route show
nmcli device status
nmcli connection show
```

---

## 2. DNS Seguro

### Opcion A: systemd-resolved con DoT

```bash
sudo nano /etc/systemd/resolved.conf
```

```ini
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
FallbackDNS=8.8.8.8#dns.google
DNSOverTLS=yes
DNSSEC=yes
```

```bash
sudo systemctl restart systemd-resolved
resolvectl status
resolvectl query github.com     # verificar que resuelve via DoT
```

### Opcion B: Nextdns (control por dispositivo)

```bash
curl -sSL https://nextdns.io/install | sh
nextdns install --config TU_ID_DE_NEXTDNS --report-client-info
nextdns status
```

---

## 3. NetworkManager — configuraciones de privacidad

Aleatorizar MAC address en WiFi:

```bash
sudo nano /etc/NetworkManager/NetworkManager.conf
```

Agregar:

```ini
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
```

```bash
sudo systemctl restart NetworkManager
```

Verificar:

```bash
ip link show wlp3s0 | grep ether
```

---

## 4. WireGuard VPN

### Instalar

```bash
sudo apt install -y wireguard wireguard-tools
```

### Generar claves

```bash
wg genkey | tee ~/.wireguard/privatekey | wg pubkey > ~/.wireguard/publickey
chmod 600 ~/.wireguard/privatekey
cat ~/.wireguard/publickey    # compartir con servidor
```

### Configurar interfaz

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = TU_CLAVE_PRIVADA
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = CLAVE_PUBLICA_DEL_SERVIDOR
Endpoint = IP_SERVIDOR:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
sudo wg-quick up wg0
sudo wg show
```

Activar en boot:

```bash
sudo systemctl enable wg-quick@wg0
```

---

## 5. Verificacion de privacidad

```bash
curl https://ipinfo.io/json           # ver IP publica y ubicacion
resolvectl status | grep "DNS Servers"
nmap -sV --version-intensity 0 localhost   # puertos abiertos locales
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->
