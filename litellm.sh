#!/bin/bash
# LiteLLM Proxy Server Startup Script
# This starts the LiteLLM proxy configured for BMW GitHub Enterprise Copilot

# Change to the LiteLLM directory
cd "/c/Dev/Experimental/litellm" || exit 1

# Set encoding to UTF-8 to avoid Unicode issues with the banner
export PYTHONIOENCODING="utf-8"

export AIOHTTP_TRUST_ENV="true"

echo -e "\033[32mStarting LiteLLM Proxy Server...\033[0m"
echo -e "\033[36mConfiguration: proxy_server_config.yaml\033[0m"
echo ""
echo -e "\033[33mAvailable Models (via BMW GHE Copilot):\033[0m"
echo ""
echo -e "\033[37m  Claude Models (200k context windows):\033[0m"
echo -e "\033[90m    - claude-opus-4.5   (Greatest software engineer   @ 3.00x price)\033[0m"
echo -e "\033[90m    - claude-sonnet-4.5 (Balanced software engineer   @ 1.00x price)\033[0m"
echo -e "\033[90m    - claude-haiku-4.5  (Fastest software engineer    @ 0.33x price)\033[0m"
echo ""
echo -e "\033[37m  GPT Models (400k context windows):\033[0m"
echo -e "\033[90m    - gpt-5.2           (Greatest academic            @ 1.00x price)\033[0m"
echo -e "\033[90m    - gpt-5-mini        (Fast, cheap, general purpose @ free) \033[0m"
echo ""
echo -e "\033[37m  Gemini Models (1000k context windows):\033[0m"
echo -e "\033[90m    - gemini-2.5-pro    (Greatest context, outdated   @ 1.00x price)\033[0m"

poetry run litellm --port 4000 --config proxy_server_config.yaml
