#!/bin/bash

set -e

echo "Welcome to Werewolf for Telegram Local Setup (Linux)!"
echo "====================================================="

echo ""
echo "Select setup mode:"
echo "  1. Release / normal setup"
echo "  2. Debug / dev setup"
read -p "Enter 1 or 2 [1]: " SETUP_MODE

if [ "$SETUP_MODE" = "2" ]; then
    BUILD_CONFIG="Debug"
    API_VAR="WEREWOLF_DEBUG_API"
else
    BUILD_CONFIG="Release"
    API_VAR="WEREWOLF_PRODUCTION_API"
fi

read -p "Telegram Bot Token: " API_TOKEN

if [ -z "$API_TOKEN" ]; then
    echo "API token is required."
    exit 1
fi

read -p "OpenAI API Key (optional): " OPENAI_TOKEN

echo ""
echo "Starting MSSQL..."

sudo docker run \
    -e "ACCEPT_EULA=Y" \
    -e "MSSQL_SA_PASSWORD=Werewolf@12345" \
    -p 1433:1433 \
    --name werewolf-sql \
    -d mcr.microsoft.com/mssql/server:2022-latest \
    >/dev/null 2>&1 || sudo docker start werewolf-sql

echo "Waiting for SQL Server..."

until sudo docker exec werewolf-sql \
    /opt/mssql-tools18/bin/sqlcmd \
    -C \
    -S localhost \
    -U SA \
    -P "Werewolf@12345" \
    -Q "SELECT 1" >/dev/null 2>&1
do
    sleep 5
done

echo "SQL Server is ready."

echo ""
echo "Checking database..."

DB_EXISTS=$(sudo docker exec werewolf-sql \
    /opt/mssql-tools18/bin/sqlcmd \
    -C \
    -S localhost \
    -U SA \
    -P "Werewolf@12345" \
    -h -1 \
    -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name='werewolf'" \
    | tr -d '[:space:]')

if [ "$DB_EXISTS" != "1" ]; then
    echo "Creating database..."

    cp werewolf.sql /tmp/werewolf_docker.sql

    sed -i \
      's|C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA\\|/var/opt/mssql/data/|g' \
      /tmp/werewolf_docker.sql

    sudo docker cp \
      /tmp/werewolf_docker.sql \
      werewolf-sql:/var/opt/mssql/data/werewolf_docker.sql

    sudo docker exec -i werewolf-sql \
      /opt/mssql-tools18/bin/sqlcmd \
      -C \
      -S localhost \
      -U SA \
      -P "Werewolf@12345" \
      -i /var/opt/mssql/data/werewolf_docker.sql
else
    echo "Database already exists. Skipping import."
fi

echo ""
echo "Writing .env..."

cat > .env <<EOF
$API_VAR=$API_TOKEN
WEREWOLF_BOT_API_TOKEN=$API_TOKEN
WEREWOLF_OPENAI_API_KEY=$OPENAI_TOKEN
WEREWOLF_DB_CONNECTION_STRING='metadata=res://*/Database.WerewolfModel.csdl|res://*/Database.WerewolfModel.ssdl|res://*/Database.WerewolfModel.msl;provider=System.Data.SqlClient;provider connection string="data source=localhost,1433;initial catalog=werewolf;user id=SA;password=Werewolf@12345;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=True;App=EntityFramework"'
EOF

source .env

echo ""
echo "Building solution..."

dotnet build \
  "Werewolf for Telegram/WerewolfForTelegram.sln" \
  -c "$BUILD_CONFIG"

echo ""
echo "Preparing deployment..."

ROOT_DIR="$(pwd)/Server"

mkdir -p "$ROOT_DIR/Control"
mkdir -p "$ROOT_DIR/Node 1"
mkdir -p "$ROOT_DIR/Logs"
mkdir -p "$ROOT_DIR/Languages"

cp -r \
  "Werewolf for Telegram/Werewolf Control/bin/$BUILD_CONFIG/net8.0/." \
  "$ROOT_DIR/Control/"

cp -r \
  "Werewolf for Telegram/Werewolf Node/bin/$BUILD_CONFIG/net8.0/." \
  "$ROOT_DIR/Node 1/"

cp -r \
  "Werewolf for Telegram/Languages/"* \
  "$ROOT_DIR/Languages/"

echo ""
echo "Starting Control..."

(
    cd "$ROOT_DIR/Control"
    nohup ./WerewolfControl > control.log 2>&1 &
)

sleep 3

echo "Starting Node..."

(
    cd "$ROOT_DIR/Node 1"
    nohup ./WerewolfNode > node.log 2>&1 &
)

echo ""
echo "Setup complete."
echo ""
echo "Logs:"
echo "  Server/Control/control.log"
echo "  Server/Node 1/node.log"