#!/bin/bash
set -e

DOMAIN="miweb.com"
GITHUB_USER="mradom"
MYSQL_PASSWORD="owlit_secure_password"

echo "[1/10] Creando usuario owlit..."
useradd -m -s /bin/bash owlit
echo "owlit ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/owlit
chmod 0440 /etc/sudoers.d/owlit

echo "[2/10] Configurando llave SSH desde GitHub..."
mkdir -p /home/owlit/.ssh
curl -fsSL https://github.com/mradom.keys -o /home/owlit/.ssh/authorized_keys
chmod 600 /home/owlit/.ssh/authorized_keys
chmod 700 /home/owlit/.ssh
chown -R owlit:owlit /home/owlit/.ssh

echo "[3/10] Instalando paquetes esenciales..."
apt update && apt upgrade -y
apt install -y software-properties-common curl wget zip unzip git fish \
               ca-certificates lsb-release gnupg2 ufw

chsh -s /usr/bin/fish owlit

echo "[4/10] Instalando Nginx..."
apt install -y nginx
sed -i 's/^user .*/user owlit owlit;/' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl start nginx

echo "[5/10] Instalando PHP 8.2..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl \
               php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-bcmath \
               php8.2-soap php8.2-intl php8.2-readline php8.2-opcache

sed -i 's/^user = .*/user = owlit/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/^group = .*/group = owlit/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/^listen.owner = .*/listen.owner = owlit/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/^listen.group = .*/listen.group = owlit/' /etc/php/8.2/fpm/pool.d/www.conf
systemctl restart php8.2-fpm

echo "[6/10] Instalando MySQL 8..."
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
mysql -u root <<EOF
CREATE USER 'owlit'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'owlit'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "[7/10] Instalando Supervisor..."
apt install -y supervisor
systemctl enable supervisor
systemctl start supervisor

echo "[8/10] Instalando Certbot..."
apt install -y certbot python3-certbot-nginx

#ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

echo "[9/10] Configurando SWAP (2 GB)..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Opcional: optimizar uso de swap
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

echo "[10/10] Otros complementos"
echo "[+] Instalando Composer..."
cd /tmp
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

echo "[+] Instalando Node.js, npm y yarn..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g yarn

echo "[+] Deshabilitando acceso SSH del usuario root..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh


echo "[+] Descargando sitio por defecto desde GitHub..."

mkdir -p /home/owlit/default-site

# Descargar el HTML
curl -fsSL https://raw.githubusercontent.com/mradom/owlit/main/default-site/index.html -o /home/owlit/default-site/index.html

# Descargar el logo
curl -fsSL https://raw.githubusercontent.com/mradom/owlit/main/owlit-transparente.png -o /home/owlit/default-site/owlit.png

# Asignar permisos
chown -R owlit:owlit /home/owlit/default-site


# Configurar default site en Nginx
cat <<'NGINXEOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /home/owlit/default-site;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINXEOF

# Enlace ya debería existir, pero por las dudas lo recreamos
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Reiniciar nginx
nginx -t && systemctl reload nginx

echo "[10/10] ¡Servidor Owlit listo!"
