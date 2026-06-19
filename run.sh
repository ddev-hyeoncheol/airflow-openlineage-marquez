#!/bin/bash
# Manage Airflow 3 local environment with Docker Compose

COMPOSE_FILE="docker-compose-airflow.yml"
NETWORK_NAME="lineage-network"

# Ensure external Docker network exists before startup
ensure_network() {
    if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
        echo "Creating external docker network: $NETWORK_NAME"
        docker network create "$NETWORK_NAME"
    fi
}

show_usage() {
    echo "Usage: $0 {up|down|restart|logs|ps|cli|build}"
    echo "  up      : Start Airflow 3.x containers"
    echo "  down    : Stop and remove Airflow 3.x containers"
    echo "  restart : Restart Airflow 3.x containers"
    echo "  logs    : Follow container logs (optionally pass service name, e.g., $0 logs airflow-scheduler)"
    echo "  ps      : Check status of running containers"
    echo "  cli     : Access the Airflow CLI container"
    echo "  build   : Build the custom Airflow image"
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

case "$1" in
    up)
        ensure_network
        echo "Starting Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" up -d
        ;;
    down)
        echo "Stopping Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" down
        ;;
    restart)
        ensure_network
        echo "Stopping Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" down
        echo "Starting Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" up -d
        ;;
    logs)
        docker compose -f "$COMPOSE_FILE" logs -f "$2"
        ;;
    ps)
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    cli)
        echo "Entering Airflow CLI session..."
        docker compose -f "$COMPOSE_FILE" run --entrypoint bash airflow-cli
        ;;
    build)
        echo "Building custom Airflow image..."
        docker compose -f "$COMPOSE_FILE" build
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
