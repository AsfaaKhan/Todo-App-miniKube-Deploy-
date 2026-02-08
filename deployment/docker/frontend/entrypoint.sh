#!/bin/sh
set -e

echo "Starting Next.js frontend..."
echo "Environment: ${NODE_ENV}"
echo "API URL: ${NEXT_PUBLIC_API_URL}"

# Execute the main command
exec "$@"
