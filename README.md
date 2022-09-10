# laravel-docker-setup

How to create a single Docker container that:
- Installs PHP 8.1
- Adds all composer packages
- Adds all npm packages & builds the app using `npm run production`
- Serves the app on port 80

## HOW TO
1. Copy the `Dockerfile` into the root of your Laravel Project
2. Copy the `docker` folder into our laravel project
3. Run `docker buid -t [DOCKER_IMAGE_TAG] .`
