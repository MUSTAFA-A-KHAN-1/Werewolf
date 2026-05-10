# OpenAI API Configuration for Werewolf Bot

## Overview
The Werewolf bot now supports AI-powered defense statements for dummy players using OpenAI's GPT-4 model. This creates more dynamic and confusing gameplay by generating varied, in-character responses.

## Configuration

### Option 1: Using setup.bat (Recommended)
The easiest way to configure the OpenAI API key is during the initial setup:

1. Run `setup.bat` as Administrator
2. Enter your Telegram Bot API Token when prompted
3. When prompted for the OpenAI API Token, enter your key or press Enter to skip
4. The setup script will automatically configure the registry key

### Option 2: Manual Registry Configuration (Advanced)
If you need to configure the API key after initial setup or prefer manual configuration:

**Registry Path:** `HKEY_LOCAL_MACHINE\SOFTWARE\Werewolf`

**Registry Key:** `OpenAIAPIKey`

**Value:** Your OpenAI API key (string)

### Registry Setup Commands
Run these commands in an elevated Command Prompt or PowerShell:

```cmd
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Werewolf" /v OpenAIAPIKey /t REG_SZ /d "your-openai-api-key-here"
```

Or using PowerShell:
```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\Werewolf" -Name "OpenAIAPIKey" -Value "your-openai-api-key-here" -PropertyType String
```

### Verification
- If configured during setup.bat: The script will confirm "OpenAI API Key configured."
- If configured manually: Verify the registry key exists: `HKEY_LOCAL_MACHINE\SOFTWARE\Werewolf\OpenAIAPIKey`
- Ensure the key value is correct (starts with `sk-`)
- Check that the application has read access to the registry
- Restart the Werewolf Node service after configuration
- Check the console/logs for any API key loading errors
- If the key is missing or invalid, the bot will fall back to hardcoded defense statements

## Features

### AI-Generated Defense Statements
- Uses GPT-4 for generating context-aware defense statements
- Creates confusion by making statements sound suspicious regardless of role
- Adapts to the player's role and current game situation
- Includes fallback to hardcoded statements if AI fails

### Fallback Mechanism
- If OpenAI API is unavailable or key is not configured, the bot uses predefined statement templates
- Ensures the game continues even if external services fail
- Logs errors for troubleshooting

## Usage
Once configured, dummy players will automatically use AI-generated defense statements during day discussions. No additional configuration is needed in the bot itself.

## Troubleshooting

### API Key Not Found
- Verify the registry key exists: `HKEY_LOCAL_MACHINE\SOFTWARE\Werewolf\OpenAIAPIKey`
- Ensure the key value is correct (starts with `sk-`)
- Check that the application has read access to the registry

### API Errors
- Check OpenAI account status and billing
- Verify API key has sufficient credits
- Review bot logs for specific error messages

### Rate Limiting
- OpenAI has rate limits; the bot includes error handling for this
- If rate limited, falls back to hardcoded statements
- Consider upgrading OpenAI plan for higher limits if needed

## Security Notes
- Store API keys securely in the registry
- Never commit API keys to version control
- Regularly rotate API keys for security
- Monitor OpenAI usage and costs