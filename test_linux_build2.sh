#!/bin/bash
dotnet publish "Werewolf for Telegram/Werewolf Control/WerewolfControl.csproj" -c Release -r linux-x64 --self-contained false -o "publish/linux-x64/Werewolf Control"
dotnet publish "Werewolf for Telegram/Werewolf Node/WerewolfNode.csproj" -c Release -r linux-x64 --self-contained false -o "publish/linux-x64/Werewolf Node"
