#!/usr/bin/env bash
#
# Kodra Docker Database Manager
# Quickly spin up database containers for local development
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Default settings
DEFAULT_POSTGRES_VERSION="16"
DEFAULT_MYSQL_VERSION="8"
DEFAULT_REDIS_VERSION="7"
DEFAULT_MONGO_VERSION="7"
DEFAULT_NETWORK="kodra-db-net"

# Check docker
check_docker() {
    if ! command -v docker &>/dev/null; then
        log_error "Docker is required. Install with: kodra install docker-ce"
        exit 1
    fi
    
    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
}

# Create network if not exists
ensure_network() {
    if ! docker network inspect "$DEFAULT_NETWORK" &>/dev/null; then
        docker network create "$DEFAULT_NETWORK" &>/dev/null
    fi
}

# ─────────────────────────────────────────────────────────────
# PostgreSQL
# ─────────────────────────────────────────────────────────────

start_postgres() {
    local name="${1:-kodra-postgres}"
    local version="${2:-$DEFAULT_POSTGRES_VERSION}"
    local port="${3:-5432}"
    local password="${4:-postgres}"
    
    check_docker
    ensure_network
    
    log_info "Starting PostgreSQL $version..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker start "$name" &>/dev/null
        log_success "PostgreSQL container resumed: $name"
    else
        docker run -d \
            --name "$name" \
            --network "$DEFAULT_NETWORK" \
            -e POSTGRES_PASSWORD="$password" \
            -e POSTGRES_USER=postgres \
            -e POSTGRES_DB=postgres \
            -p "$port:5432" \
            -v "${name}-data:/var/lib/postgresql/data" \
            "postgres:$version" &>/dev/null
        log_success "PostgreSQL $version started"
    fi
    
    echo ""
    echo "  Connection:"
    echo "    Host:     localhost:$port"
    echo "    User:     postgres"
    echo "    Password: $password"
    echo "    Database: postgres"
    echo ""
    echo "  Connect:    psql -h localhost -p $port -U postgres"
    echo "  GUI:        pgAdmin, DBeaver, or TablePlus"
}

stop_postgres() {
    local name="${1:-kodra-postgres}"
    docker stop "$name" &>/dev/null && log_success "PostgreSQL stopped"
}

# ─────────────────────────────────────────────────────────────
# MySQL
# ─────────────────────────────────────────────────────────────

start_mysql() {
    local name="${1:-kodra-mysql}"
    local version="${2:-$DEFAULT_MYSQL_VERSION}"
    local port="${3:-3306}"
    local password="${4:-mysql}"
    
    check_docker
    ensure_network
    
    log_info "Starting MySQL $version..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker start "$name" &>/dev/null
        log_success "MySQL container resumed: $name"
    else
        docker run -d \
            --name "$name" \
            --network "$DEFAULT_NETWORK" \
            -e MYSQL_ROOT_PASSWORD="$password" \
            -e MYSQL_DATABASE=mydb \
            -p "$port:3306" \
            -v "${name}-data:/var/lib/mysql" \
            "mysql:$version" &>/dev/null
        log_success "MySQL $version started"
    fi
    
    echo ""
    echo "  Connection:"
    echo "    Host:     localhost:$port"
    echo "    User:     root"
    echo "    Password: $password"
    echo "    Database: mydb"
    echo ""
    echo "  Connect:    mysql -h 127.0.0.1 -P $port -u root -p"
}

stop_mysql() {
    local name="${1:-kodra-mysql}"
    docker stop "$name" &>/dev/null && log_success "MySQL stopped"
}

# ─────────────────────────────────────────────────────────────
# Redis
# ─────────────────────────────────────────────────────────────

start_redis() {
    local name="${1:-kodra-redis}"
    local version="${2:-$DEFAULT_REDIS_VERSION}"
    local port="${3:-6379}"
    
    check_docker
    ensure_network
    
    log_info "Starting Redis $version..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker start "$name" &>/dev/null
        log_success "Redis container resumed: $name"
    else
        docker run -d \
            --name "$name" \
            --network "$DEFAULT_NETWORK" \
            -p "$port:6379" \
            -v "${name}-data:/data" \
            "redis:$version" &>/dev/null
        log_success "Redis $version started"
    fi
    
    echo ""
    echo "  Connection:"
    echo "    Host:     localhost:$port"
    echo ""
    echo "  Connect:    redis-cli -h localhost -p $port"
}

stop_redis() {
    local name="${1:-kodra-redis}"
    docker stop "$name" &>/dev/null && log_success "Redis stopped"
}

# ─────────────────────────────────────────────────────────────
# MongoDB
# ─────────────────────────────────────────────────────────────

start_mongo() {
    local name="${1:-kodra-mongo}"
    local version="${2:-$DEFAULT_MONGO_VERSION}"
    local port="${3:-27017}"
    
    check_docker
    ensure_network
    
    log_info "Starting MongoDB $version..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker start "$name" &>/dev/null
        log_success "MongoDB container resumed: $name"
    else
        docker run -d \
            --name "$name" \
            --network "$DEFAULT_NETWORK" \
            -p "$port:27017" \
            -v "${name}-data:/data/db" \
            "mongo:$version" &>/dev/null
        log_success "MongoDB $version started"
    fi
    
    echo ""
    echo "  Connection:"
    echo "    URI:      mongodb://localhost:$port"
    echo ""
    echo "  Connect:    mongosh mongodb://localhost:$port"
}

stop_mongo() {
    local name="${1:-kodra-mongo}"
    docker stop "$name" &>/dev/null && log_success "MongoDB stopped"
}

# ─────────────────────────────────────────────────────────────
# Status & Management
# ─────────────────────────────────────────────────────────────

list_databases() {
    check_docker
    
    echo "Running database containers:"
    echo ""
    
    local running=$(docker ps --filter "name=kodra-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
    
    if [ -z "$running" ] || [ "$running" = "NAMES	STATUS	PORTS" ]; then
        echo "  No database containers running"
        echo ""
        echo "Start one with:"
        echo "  kodra db postgres"
        echo "  kodra db mysql"
        echo "  kodra db redis"
        echo "  kodra db mongo"
    else
        echo "$running" | sed 's/^/  /'
    fi
}

stop_all() {
    check_docker
    
    log_info "Stopping all database containers..."
    docker ps -q --filter "name=kodra-" | xargs -r docker stop &>/dev/null
    log_success "All database containers stopped"
}

clean_all() {
    check_docker
    
    log_warning "This will remove all Kodra database containers and volumes!"
    echo ""
    
    if command -v gum &>/dev/null; then
        if ! gum confirm "Are you sure?"; then
            log_info "Cancelled"
            exit 0
        fi
    else
        read -p "Type 'yes' to confirm: " confirm
        if [ "$confirm" != "yes" ]; then
            log_info "Cancelled"
            exit 0
        fi
    fi
    
    log_info "Removing containers..."
    docker ps -aq --filter "name=kodra-" | xargs -r docker rm -f &>/dev/null
    
    log_info "Removing volumes..."
    docker volume ls -q --filter "name=kodra-" | xargs -r docker volume rm &>/dev/null
    
    log_success "Cleaned up all database containers and volumes"
}

# ─────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────

show_help() {
    echo "Usage: kodra db <database> [command] [options]"
    echo ""
    echo "Databases:"
    echo "  postgres [start|stop]    PostgreSQL (default: v$DEFAULT_POSTGRES_VERSION)"
    echo "  mysql [start|stop]       MySQL (default: v$DEFAULT_MYSQL_VERSION)"
    echo "  redis [start|stop]       Redis (default: v$DEFAULT_REDIS_VERSION)"
    echo "  mongo [start|stop]       MongoDB (default: v$DEFAULT_MONGO_VERSION)"
    echo ""
    echo "Management:"
    echo "  list                     Show running database containers"
    echo "  stop-all                 Stop all database containers"
    echo "  clean                    Remove all containers & volumes"
    echo ""
    echo "Examples:"
    echo "  kodra db postgres        Start PostgreSQL"
    echo "  kodra db postgres stop   Stop PostgreSQL"
    echo "  kodra db mysql           Start MySQL"
    echo "  kodra db redis           Start Redis"
    echo "  kodra db list            Show what's running"
    echo ""
    echo "All containers use persistent volumes, so data survives stops."
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

case "${1:-}" in
    postgres|pg)
        case "${2:-start}" in
            start) start_postgres "${3:-}" "${4:-}" "${5:-}" "${6:-}" ;;
            stop)  stop_postgres "${3:-}" ;;
            *)     start_postgres ;;
        esac
        ;;
    mysql)
        case "${2:-start}" in
            start) start_mysql "${3:-}" "${4:-}" "${5:-}" "${6:-}" ;;
            stop)  stop_mysql "${3:-}" ;;
            *)     start_mysql ;;
        esac
        ;;
    redis)
        case "${2:-start}" in
            start) start_redis "${3:-}" "${4:-}" "${5:-}" ;;
            stop)  stop_redis "${3:-}" ;;
            *)     start_redis ;;
        esac
        ;;
    mongo|mongodb)
        case "${2:-start}" in
            start) start_mongo "${3:-}" "${4:-}" "${5:-}" ;;
            stop)  stop_mongo "${3:-}" ;;
            *)     start_mongo ;;
        esac
        ;;
    list|ls)
        list_databases
        ;;
    stop-all|stopall)
        stop_all
        ;;
    clean|cleanup)
        clean_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
