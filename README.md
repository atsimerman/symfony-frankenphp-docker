# Symfony with FrankenPHP Docker Scaffolding

A complete Docker-based development scaffold for building Symfony applications with FrankenPHP. This project combines the modern PHP framework with FrankenPHP, a high-performance PHP application server, and includes pre-configured PostgreSQL and RabbitMQ services.

## What is FrankenPHP?

FrankenPHP is a modern PHP app server written in Go. It provides:
- **Better performance** than traditional PHP-FPM by keeping PHP in memory
- **HTTP/2 and HTTP/3 support** out of the box
- **Built-in HTTPS** support with automatic certificate management via Caddy
- **Worker mode** for long-running processes
- **Simplified deployment** - single binary instead of multiple components

Learn more at [frankenphp.dev](https://frankenphp.dev)

## Tech Stack

- **PHP 8.5** with FrankenPHP
- **Symfony 8.0** - Latest LTS version
- **PostgreSQL 18** - Database
- **RabbitMQ 4.2** - Message queue
- **Caddy** - Web server (built into FrankenPHP)
- **Doctrine ORM** - Database abstraction and migrations
- **Composer** - PHP dependency manager

## Prerequisites

- Docker and Docker Compose
- Make
- Git
- 4GB+ RAM (for comfortable development)

## Getting Started

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd symfony-frankenphp-docker

# Build the Docker images
make build
```

### 2. Start the Application

```bash
# Start all services (attach to logs)
make up

# Or in another terminal, just follow logs
make logs
```

The application will be available at:
- **HTTP/HTTPS**: https://localhost or https://php
- **RabbitMQ Management**: http://localhost:15672

### 3. Install Dependencies

```bash
# Install PHP dependencies
make install
```

### 4. Create Environment File

```bash
cp .env.example .env  # Create from template if it exists
# or manually set DATABASE_URL and other variables
```

### 5. Run Database Migrations

```bash
make shell
php bin/console doctrine:migrations:migrate
```

## Available Make Commands

| Command | Description |
|---------|-------------|
| `make help` | Show this help message |
| `make build` | Build project containers |
| `make up` | Start project containers |
| `make down` | Stop and remove containers |
| `make stop` | Stop containers without removing |
| `make restart` | Restart containers |
| `make shell` | Enter PHP container as current user |
| `make logs` | Follow project logs in real-time |
| `make test` | Run tests in PHP container |
| `make install` | Install composer dependencies |
| `make update` | Update composer dependencies |

## Project Structure

```
.
├── bin/
│   └── console              # Symfony console entry point
├── config/
│   ├── bundles.php          # Bundle configuration
│   ├── services.yaml        # Service container configuration
│   ├── routes.yaml          # Application routes
│   ├── preload.php          # Preload optimization
│   ├── packages/            # Bundle configuration files
│   │   ├── doctrine.yaml
│   │   ├── framework.yaml
│   │   ├── mailer.yaml
│   │   └── messenger.yaml
│   └── routes/              # Additional route definitions
├── infra/
│   └── docker/
│       ├── Dockerfile       # Multi-stage Docker build
│       └── frankenphp/
│           ├── Caddyfile    # Web server configuration
│           ├── docker-entrypoint.sh  # Startup script
│           └── conf.d/      # PHP configuration
├── migrations/              # Doctrine migration files
├── public/
│   └── index.php           # Public entry point
├── src/
│   ├── Kernel.php          # Symfony kernel
│   ├── Controller/         # Application controllers
│   ├── Entity/             # Doctrine entities
│   └── Repository/         # Doctrine repositories
├── var/
│   └── cache/              # Application cache
├── vendor/                 # Composer dependencies
├── compose.yaml            # Main Docker Compose configuration
├── compose.override.yaml   # Development overrides
├── compose.prod.yaml       # Production configuration
├── composer.json           # PHP dependencies
├── Makefile               # Make targets
└── README.md              # This file
```

## Services

### PHP (FrankenPHP)

The main application container running Symfony with FrankenPHP server.

- **Ports**: 80 (HTTP), 443 (HTTPS), 443 (HTTP/3 UDP)
- **Environment**: Set by `APP_ENV` variable
- **Features**: Auto-reload in development, HTTPS by default, HTTP/2 and HTTP/3 support

### PostgreSQL Database

Persistent relational database for your application.

- **Port**: 5432 (internal only, exposed via DATABASE_URL)
- **Default DB**: `app`
- **User**: `app`
- **Version**: 18.2

**Environment Variables:**
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_VERSION` - PostgreSQL version

### RabbitMQ MessageQueue

Message broker for asynchronous task processing with Symfony Messenger.

- **Port**: 5672 (AMQP protocol)
- **Management UI**: http://localhost:15672
- **Default Vhost**: `app`
- **User**: `app`
- **Version**: 4.2

**Environment Variables:**
- `RABBITMQ_DEFAULT_VHOST` - Virtual host
- `RABBITMQ_DEFAULT_USER` - Username
- `RABBITMQ_DEFAULT_PASS` - Password
- `RABBITMQ_VERSION` - RabbitMQ version

## Development Workflow

### Entering the Container

Access the PHP container as the current user:

```bash
make shell
# Now you're inside the container
php bin/console list
composer install
```

### Database Management

```bash
# Access PHP container
make shell

# Create a new migration after changing entities
php bin/console make:migration

# Run migrations
php bin/console doctrine:migrations:migrate

# Check migration status
php bin/console doctrine:migrations:status

# Rollback last migration
php bin/console doctrine:migrations:execute --down DoctrineMigrations\\Version20240101000000
```

### Running Tests

```bash
# Run all tests
make test

# Or from within container
make shell
php bin/console test
```

### Viewing Logs

```bash
# Follow all service logs
make logs

# Or filter specific service
docker compose logs -f php
docker compose logs -f database
docker compose logs -f messenger
```

### Managing Dependencies

```bash
# Add a new package
make shell
composer require symfony/validator

# Update all dependencies
make update
```

## Environment Configuration

Configure the application by setting environment variables in `.env` or `.env.local`:

```bash
# Application environment
APP_ENV=dev
APP_DEBUG=1
APP_SECRET=<your-secret-key>

# Database connection
DATABASE_URL="postgresql://app:!ChangeMe!@database:5432/app?serverVersion=18&charset=utf8"

# Server configuration
SERVER_NAME=localhost
TRUSTED_PROXIES=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
TRUSTED_HOSTS=^localhost|php$

# Message queue
MESSENGER_TRANSPORT_DSN=amqp://app:!ChangeMe!@messenger:5672/%2Fapp

# Mailer
MAILER_DSN=null://null

# RabbitMQ
RABBITMQ_DEFAULT_USER=app
RABBITMQ_DEFAULT_PASS=!ChangeMe!
RABBITMQ_DEFAULT_VHOST=app
```

Replace `!ChangeMe!` with secure values for production.

## Docker Compose Configurations

### Development (compose.yaml + compose.override.yaml)

Optimized for development with:
- Auto-reload on file changes
- Xdebug enabled (disabled by default, set `XDEBUG_MODE=debug`)
- Non-root user with sudo access
- Volume mounts for live code editing

### Production (compose.prod.yaml)

```bash
docker compose -f compose.yaml -f compose.prod.yaml up
```

Includes:
- Optimized PHP configuration
- No development tools
- Health checks for all services

## File Permissions

The entrypoint script automatically manages file permissions:

- Sets ACLs for the `var/` directory
- Makes cache writable by both the web server and container user
- Ensures proper permissions for migration and log files

## Building Custom Images

The Dockerfile uses multi-stage builds for different deployment scenarios:

```dockerfile
FROM frankenphp_dev  # Development image with Xdebug
FROM frankenphp_prod # Production image (optimized)
```

Build a specific stage:

```bash
docker compose build --target frankenphp_dev
```

## Troubleshooting

### Database connection fails

```bash
# Check database is healthy
docker compose ps

# View database logs
docker compose logs database

# Ensure DATABASE_URL is set correctly
docker compose exec php printenv DATABASE_URL
```

### Port already in use

Change the ports in `compose.override.yaml`:

```yaml
services:
  php:
    ports:
      - target: 80
        published: 8080  # Changed from 80
      - target: 443
        published: 8443  # Changed from 443
```

### Permission denied errors

```bash
# Rebuild with correct user IDs
make build

# Or manually fix permissions in container
make shell
sudo chown -R app:app .
```

### Redis/Cache issues

Clear the cache:

```bash
make shell
php bin/console cache:clear
```

## Performance Tips

1. **Enable Opcode Caching**: Already enabled in production configuration
2. **Use Worker Mode**: FrankenPHP keeps PHP in memory, improving response times
3. **Database Indexing**: Add indexes to frequently queried columns
4. **Message Queue**: Use Messenger for heavy operations
5. **Eager Loading**: Use Doctrine's eager loading to prevent N+1 queries

## Security Considerations

- Change all default passwords in `.env`
- Use strong `APP_SECRET`
- Enable HTTPS (automatic with FrankenPHP)
- Restrict `TRUSTED_PROXIES` and `TRUSTED_HOSTS`
- Keep dependencies updated: `composer update`
- Review Symfony security advisories: `composer audit`

## Useful Resources

- [Symfony Documentation](https://symfony.com/doc/current/)
- [FrankenPHP Documentation](https://frankenphp.dev)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Doctrine ORM Guide](https://www.doctrine-project.org/)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)

## License

This scaffolding is provided as-is. See LICENSE file for details.

## Contributing

Contributions are welcome! Please follow standard Git workflow:

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Support

For issues specific to this scaffold, check the project repository. For framework-specific issues:

- Symfony: https://symfony.com/support
- FrankenPHP: https://frankenphp.dev/docs/
- Docker: https://docs.docker.com/
