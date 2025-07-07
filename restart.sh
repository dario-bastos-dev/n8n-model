#!/bin/bash
# This script restarts the Docker Compose services defined in the compose.yml file.
docker compose down && docker compose up -d