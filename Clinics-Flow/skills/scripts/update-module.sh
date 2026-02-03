#!/bin/bash
# Quick script to update an Odoo module in a running instance

set -e

MODULE_NAME=$1
DB_NAME=${2:-"odoo"}
ODOO_CONTAINER=${3:-"odoo"}

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <module_name> [database_name] [container_name]"
    echo "Example: $0 clinic_management my_db odoo"
    exit 1
fi

echo "🔄 Updating module '$MODULE_NAME' in database '$DB_NAME'..."

docker-compose exec "$ODOO_CONTAINER" odoo \
    -u "$MODULE_NAME" \
    -d "$DB_NAME" \
    --stop-after-init

echo "✅ Module updated successfully!"
echo "   Please restart Odoo container if needed:"
echo "   docker-compose restart $ODOO_CONTAINER"
