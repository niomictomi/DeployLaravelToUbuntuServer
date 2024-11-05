# deploy.sh
cd /path/to/laravel-app
git pull https://$GITHUB_TOKEN@github.com/username/repository-name.git main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
npm install && npm run production  # Kalau ada assets front-end
