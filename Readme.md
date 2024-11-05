# Deployment Instructions for Private Laravel Repository on Ubuntu Server

## Step 1: Create a Personal Access Token (PAT) in GitHub

1. Log into your GitHub account.
2. Go to **Settings > Developer settings > Personal access tokens**.
3. Create a new token with the `repo` scope (required for accessing private repositories).
4. Copy the generated token (it will be displayed only once).

## Step 2: Save the Token on the Ubuntu Server

1. SSH into your Ubuntu server.
2. Open your `~/.bashrc` file and add the token as an environment variable:

    ```bash
    export GITHUB_TOKEN="your_personal_access_token"
    ```

3. Save the file and refresh the environment by running:

    ```bash
    source ~/.bashrc
    ```

## Step 3: Modify the Deployment Script to Use the Token

1. Open or create the `deploy.sh` script in your Laravel application directory.
2. Update the `git pull` command to include the token for private repository access:

    ```bash
    # deploy.sh
    cd /path/to/laravel-app
    git pull https://$GITHUB_TOKEN@github.com/username/repository-name.git main
    composer install --no-dev --optimize-autoloader
    php artisan migrate --force
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    npm install && npm run production  # If there are front-end assets
    ```

3. Make the script executable:

    ```bash
    chmod +x deploy.sh
    ```

4. Run the deployment script to verify it works:

    ```bash
    ./deploy.sh
    ```

With this setup, the `git pull` command will use the token stored in the `GITHUB_TOKEN` environment variable for authentication, enabling access to the private repository.