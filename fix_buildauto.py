import re

file_path = "Werewolf for Telegram/BuildAutomation/BuildAutomation.csproj"
with open(file_path, "r") as f:
    content = f.read()

# Microsoft.CodeDom.Providers.DotNetCompilerPlatform and Microsoft.Net.Compilers hook into the MSBuild pipeline and inject legacy csc.exe which breaks modern dotnet build
content = re.sub(r'<PackageReference Include="Microsoft\.CodeDom\.Providers\.DotNetCompilerPlatform"[^>]*/>', '', content)
content = re.sub(r'<PackageReference Include="Microsoft\.Net\.Compilers"[^>]*/>', '', content)

with open(file_path, "w") as f:
    f.write(content)
