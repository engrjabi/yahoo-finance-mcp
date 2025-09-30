#!/bin/bash
# run-mcp-proxy.sh - Start Yahoo Finance MCP server with proxy

set -e

# Configuration
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="8080"
MCP_SERVER_CMD="uv run server.py"

# Parse arguments
HOST="${1:-$DEFAULT_HOST}"
PORT="${2:-$DEFAULT_PORT}"

echo "🚀 Starting MCP Proxy for Yahoo Finance MCP Server"
echo "🌐 Host: $HOST"
echo "🔌 Port: $PORT"

# Load environment variables
if [ -f ".env" ]; then
    echo "📋 Loading environment variables from .env file..."
    set -a
    source .env
    set +a
fi

echo "🌐 Starting proxy server at http://$HOST:$PORT"
echo "🔗 SSE endpoint: http://$HOST:$PORT/sse"
echo "❤️  Health check: http://$HOST:$PORT/health"
echo ""
echo "Available Yahoo Finance Tools:"
echo "  • get_historical_stock_prices"
echo "  • get_stock_info"
echo "  • get_yahoo_finance_news"
echo "  • get_stock_actions"
echo "  • get_financial_statement"
echo "  • get_holder_info"
echo "  • get_option_expiration_dates"
echo "  • get_option_chain"
echo "  • get_recommendations"

# Start mcp-proxy
exec mcp-proxy --host="$HOST" --port="$PORT" --stateless $MCP_SERVER_CMD