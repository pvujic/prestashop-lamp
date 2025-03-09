#!/usr/bin/env bash

# Copy sample.env to .env
if [ ! -f .env ]; then
    cp sample.env .env
    echo "Copied sample.env to .env"
else
    echo ".env file already exists. Skipping copy."
fi

# Define valid options
VALID_PHP_VERSIONS=(php54 php56 php71 php72 php73 php74 php8 php81 php82 php83)
VALID_DATABASE_VERSIONS=(mariadb103 mariadb104 mariadb105 mariadb106)
DEFAULT_PRESTASHOP_VERSION="8.2.1"

# Function to validate user input
validate_input() {
    local input="$1"
    shift
    local valid_options=("$@")
    for option in "${valid_options[@]}"; do
        if [[ "$input" == "$option" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to validate Docker project name (only allows alphanumeric and underscores)
validate_project_name() {
    if [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt user for Docker project name
while true; do
    echo "Enter the Docker project name (default: lamp, only letters, numbers, and underscores allowed):"
    read -r COMPOSE_PROJECT_NAME
    COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-lamp}
    if validate_project_name "$COMPOSE_PROJECT_NAME"; then
        break
    else
        echo "Invalid project name. Use only letters, numbers, and underscores."
    fi
done

# Prompt user for PHP version
while true; do
    echo "Select PHP version (default: php83):"
    echo "Available options: ${VALID_PHP_VERSIONS[*]}"
    read -r PHPVERSION
    PHPVERSION=${PHPVERSION:-php83}
    if validate_input "$PHPVERSION" "${VALID_PHP_VERSIONS[@]}"; then
        break
    else
        echo "Invalid PHP version. Choose from the available options."
    fi
done

# Prompt user for Database version
while true; do
    echo "Select Database version (default: mariadb105):"
    echo "Available options: ${VALID_DATABASE_VERSIONS[*]}"
    read -r DATABASE
    DATABASE=${DATABASE:-mariadb105}
    if validate_input "$DATABASE" "${VALID_DATABASE_VERSIONS[@]}"; then
        break
    else
        echo "Invalid Database version. Choose from the available options."
    fi
done

# Prompt user for PrestaShop version
echo "Enter PrestaShop version (default: $DEFAULT_PRESTASHOP_VERSION):"
read -r PRESTASHOP_VERSION
PRESTASHOP_VERSION=${PRESTASHOP_VERSION:-$DEFAULT_PRESTASHOP_VERSION}

# Validate PrestaShop version
PRESTASHOP_URL="https://github.com/PrestaShop/PrestaShop/releases/download/$PRESTASHOP_VERSION/prestashop_$PRESTASHOP_VERSION.zip"
if ! curl --output /dev/null --silent --head --fail "$PRESTASHOP_URL"; then
    echo "Invalid or unavailable PrestaShop version. Using default version: $DEFAULT_PRESTASHOP_VERSION"
    PRESTASHOP_VERSION="$DEFAULT_PRESTASHOP_VERSION"
    PRESTASHOP_URL="https://github.com/PrestaShop/PrestaShop/releases/download/$PRESTASHOP_VERSION/prestashop_$PRESTASHOP_VERSION.zip"
fi

# Detect OS and use appropriate sed syntax
if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i "" -e "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME/" .env
    sed -i "" -e "s/^PHPVERSION=.*/PHPVERSION=$PHPVERSION/" .env
    sed -i "" -e "s/^DATABASE=.*/DATABASE=$DATABASE/" .env
else
    sed -i "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME/" .env
    sed -i "s/^PHPVERSION=.*/PHPVERSION=$PHPVERSION/" .env
    sed -i "s/^DATABASE=.*/DATABASE=$DATABASE/" .env
fi

# Generate SSL certificates (Linux/macOS only)
echo "Generating SSL certificates..."
mkdir -p ./config/ssl

if command -v mkcert &> /dev/null; then
    mkcert prestashop.loc localhost 127.0.0.1 ::1
    
    mv prestashop.loc+3.pem ./config/ssl/prestashop-lamp.pem
    mv prestashop.loc+3-key.pem ./config/ssl/prestashop-lamp-key.pem
    
    echo "SSL certificates generated successfully."
else
    echo "mkcert is not installed. Please install mkcert and run the command manually:"
    echo "mkcert prestashop.loc localhost 127.0.0.1 ::1"
    echo "Then move the generated files to:"
    echo "./config/ssl/prestashop-lamp.pem"
    echo "./config/ssl/prestashop-lamp-key.pem"
fi

# Install PrestaShop
echo "Installing PrestaShop $PRESTASHOP_VERSION..."
mkdir -p ./www/prestashop.loc/
cd ./www/prestashop.loc/
curl -L -o prestashop_download.zip "$PRESTASHOP_URL"

# Extract the main PrestaShop ZIP
unzip prestashop_download.zip && rm prestashop_download.zip

rm index.php Install_PrestaShop.html

# If another prestashop.zip exists inside, extract it
if [[ -f prestashop.zip ]]; then
    unzip prestashop.zip && rm prestashop.zip
fi

cd -

echo "PrestaShop $PRESTASHOP_VERSION installed in ./www/prestashop.loc/"

echo "Configuration updated in .env file."
