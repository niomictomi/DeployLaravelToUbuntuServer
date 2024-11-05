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

echo "Adding PHP 8.2 repository..."
sudo add-apt-repository ppa:ondrej/php -y

echo "Installing PHP 8.2 and necessary extensions..."
sudo apt install php8.2 php8.2-fpm php8.2-cli php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-mysql -y


echo "PHP Installed successfully"

echo "----------------------------------------------------------------"

echo "Installing Composer..."

echo "Downloading Composer installer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

echo "Installing Composer globally..."
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo "Removing Composer installer script..."
rm composer-setup.php

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
git pull https://$GITHUB_TOKEN@github.com/niomictomi/platform-vvip.git dev

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
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
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
