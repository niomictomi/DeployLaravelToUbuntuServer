#!/bin/bash
# deploy vvip to ubuntu
# author: tomslock
# github: niomictomi
# version: 1
# @05112024

echo "Updating package list..."
sudo apt update

echo "Installing PHP..."
echo "Installing software-properties-common for adding PHP PPA..."
sudo apt install software-properties-common -y

echo "Adding PHP 8.3 repository..."
sudo add-apt-repository ppa:ondrej/php -y

echo "Installing PHP 8.3 and necessary extensions..."
sudo apt install php8.3 php8.3-fpm php8.3-cli php8.3-mbstring php8.3-xml php8.3-curl  php8.3-zip php8.3-mysql -y


echo "PHP Installed successfully"

echo "----------------------------------------------------------------"

echo "Installing Composer..."
sudo apt update
sudo apt install php-cli unzip

echo "Downloading Composer installer..."
cd ~
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php

HASH=`curl -sS https://composer.github.io/installer.sig`
echo $HASH


php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"


echo "Installing Composer globally..."
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer


echo "Verifying Composer installation..."
composer -V


echo "Composer Installed successfully"

echo "----------------------------------------------------------------"


echo "Installing Nginx..."
sudo apt install nginx -y

echo "Nginx Installed successfully"


echo "----------------------------------------------------------------"


echo "Setting up MySQL database and user for Laravel..."
sudo apt upgrade
sudo apt install mysql-server -y

echo "Securing MySQL Installation..."
sudo mysql_secure_installation

# Ganti 'database_name', 'database_user', dan 'user_password' dengan detail yang sesuai
sudo mysql -e "CREATE DATABASE vvip;"
sudo mysql -e "CREATE USER 'vvip'@'localhost' IDENTIFIED BY '53m0944m@n5!h123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON vvip.* TO 'vvip'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"


echo "Mysql Installed successfully"


echo "----------------------------------------------------------------"


echo "Installing Node JS..."

echo "Updating package list again for Node.js installation..."
sudo apt update

echo "Setting up Node.js 22 repository..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

echo "Installing Node.js and npm..."
sudo apt install -y nodejs

echo "Verifying Node.js and npm installation..."
node -v
npm -v

echo "NodeJS Installed successfully"


echo "Navigating to project directory..."
cd /home/vvip/dev

echo "Pulling latest code from GitHub..."

# Ganti /home/vvip/dev sesuai dengan path yang diinginkan

PROJECT_DIR="/home/vvip/dev"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning repository from GitHub..."
    git clone https://$GITHUB_TOKEN@github.com/niomictomi/platform-vvip.git -b dev $PROJECT_DIR
else
    echo "Directory $PROJECT_DIR already exists. Please remove it before re-cloning."
    exit 1
fi

echo "Navigating to project directory..."
cd $PROJECT_DIR


echo "Installing PHP dependencies with Composer..."
composer install --no-dev --optimize-autoloader

# echo "Running database migrations..."
# php artisan migrate --force

echo "Caching configuration files..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Caching views..."
php artisan view:cache

echo "Installing and building front-end assets..."
npm install && npm run production


echo "Setting up Nginx configuration for Laravel..."
# Replace 'platform-vvip' with your actual domain or project name
sudo tee /etc/nginx/sites-available/platform-vvip > /dev/null <<EOF
server {
    listen 80;
    server_name your_domain_or_ip;

    root /home/vvip/dev/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "Enabling Nginx configuration..."
sudo ln -s /etc/nginx/sites-available/platform-vvip /etc/nginx/sites-enabled/

echo "Testing Nginx configuration..."
sudo nginx -t

echo "Restarting Nginx to apply changes..."
sudo systemctl restart nginx


echo "Deployment completed successfully!"
