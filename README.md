# PrestaShop LAMP Installation Guide

## Installation Instructions

To set up your PrestaShop LAMP environment, simply run:

```sh
git clone https://github.com/pvujic/prestashop-lamp
cd prestashop-lamp
sh install.sh
```

The script will prompt you for configuration options including:

- Docker project name
- PHP version
- Database type
- PrestaShop version

Once completed, it will download and install PrestaShop along with the required dependencies.

## SSL Certificate Setup

### Windows Users

1. Install Chocolatey by running the following command in PowerShell:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force;
   [System.Net.ServicePointManager]::SecurityProtocol =
   [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex
   ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```
2. Install `mkcert` using Chocolatey:
   ```powershell
   choco install mkcert
   ```
3. Run:
   ```powershell
   mkcert -install
   ```
4. Move to your preferred directory (e.g., `C:\Users\Administrator`) and generate SSL certificates:
   ```powershell
   mkcert prestashop.loc 127.0.0.1 localhost ::1
   ```
5. Move the generated certificates to the SSL folder inside your LAMP directory in WSL:
   ```sh
   sudo cp ./prestashop.loc+3.pem /<lamp directory>/config/ssl/prestashop-lamp.pem
   sudo cp ./prestashop.loc+3-key.pem /<lamp directory>/config/ssl/prestashop-lamp-key.pem
   ```

### Linux / MacOS Users

No manual action is required. The installation script will generate and place the SSL certificates automatically.

## Running the Environment

Once the installation is complete, start the environment with:

```sh
docker compose up -d
```

You can then access PrestaShop via:

```sh
https://localhost
```

This will open the PrestaShop installation assistant.

## Database Configuration in PrestaShop Installation

When setting up PrestaShop, use the following database credentials:

- **Database server address:** `database` (for macOS) or `127.0.0.1` (on other systems)
- **Database name:** `docker`
- **Database login:** `root`
- **Database password:** `tiger`

Once entered, follow the PrestaShop installation steps to complete the setup.

## Contributing

We are happy if you want to create a pull request or help people with their issues. If you want to create a PR, please remember that this stack is not built for production usage, and changes should be good for general purpose and not overspecialized.

> Please note that we simplified the project structure from several branches for each php version, to one centralized master branch. Please create your PR against master branch.
>
> Thank you!

## Why you shouldn't use this stack unmodified in production

We want to empower developers to quickly create creative Applications. Therefore we are providing an easy to set up a local development environment for several different Frameworks and PHP Versions.
In Production you should modify at a minimum the following subjects:

- php handler: mod_php=> php-fpm
- secure mysql users with proper source IP limitations
