#!/bin/sh

echo "Initializing project..." >&2


# Only initialize if not initialzed before
if [ -d "${PLUGIN_PATH}/logs" ]; then
    echo "Project already initialized!" >&2
    exit 0
fi

# Get configuration
if [ -f "$PLUGIN_PATH/project.cfg" ]; then
    echo "Reading configuration file..." >&2
    source $PLUGIN_PATH/project.cfg
else
    echo "Failed: Configuration file not found!";
    exit 1
fi

echo "Container: $WP_CONTAINER_NAME"

echo "Waiting for Server..."
sleep 20

echo "Installing WordPress..."
docker exec ${WP_CONTAINER_NAME} wp core install --url=localhost --title=WPPlugin --admin_user=admin --admin_password=admin --admin_email=info@example.com --allow-root

#Installing plugins from config
for PLUGIN in  $(echo $REQUIRED_PLUGINS | sed "s/,/ /g"); do
    echo "Installing WordPress Plugin \"${WP_CONTAINER_NAME}\"..."
    docker exec ${WP_CONTAINER_NAME} wp plugin install $PLUGIN --allow-root && docker exec ${WP_CONTAINER_NAME} wp plugin activate $PLUGIN --allow-root
    docker exec ${WP_CONTAINER_NAME} wp plugin activate $PLUGIN --allow-root
done

REMOTE_PLUGIN_PATH=${PLUGIN_PATH}/wordpress/plugins/
rsync -rv --exclude-from=${BIN_PATH}/exclude-plugin-files.txt ${PLUGIN_PATH} ${REMOTE_PLUGIN_PATH}
docker exec ${WP_CONTAINER_NAME} wp plugin activate $PLUGIN_SLUG --allow-root

# Custom user scripts
if [ -f "$PLUGIN_PATH/project.sh" ]; then
    echo "Starting project scripts..."
    $PLUGIN_PATH/project.sh
fi