import xml.etree.ElementTree as ET
import glob

def fix_windows_targeting(csproj_path):
    tree = ET.parse(csproj_path)
    root = tree.getroot()
    changed = False

    # We want to strictly use <TargetFramework>net8.0</TargetFramework> everywhere except BuildAutomation where we don't care because the instructions explicitly said skip website, but we should make sure that node/control/clearupdates are fully net8.0
    for pg in root.findall('PropertyGroup'):
        tfs = pg.findall('TargetFramework')
        if len(tfs) > 1:
            for tf in tfs[1:]:
                pg.remove(tf)
                changed = True
        elif len(tfs) == 1:
            if tfs[0].text == 'net8.0-windows':
                tfs[0].text = 'net8.0'
                changed = True

    if changed:
        xml_str = ET.tostring(root, encoding='utf-8', xml_declaration=True).decode('utf-8')
        with open(csproj_path, 'w', encoding='utf-8') as f:
            f.write(xml_str)

for f in glob.glob("Werewolf for Telegram/**/*.csproj", recursive=True):
    fix_windows_targeting(f)

with open("Werewolf for Telegram/ClearUpdates/Program.cs", "r") as f:
    content = f.read()

content = content.replace('var apikey = key.GetValue("QueueAPI").ToString();', 'var apikey = Environment.GetEnvironmentVariable("WEREWOLF_QUEUE_API") ?? "";')

with open("Werewolf for Telegram/ClearUpdates/Program.cs", "w") as f:
    f.write(content)
with open("Werewolf for Telegram/BuildAutomation/BuildAutomation.csproj", "r") as f:
    content = f.read()

# Microsoft.Net.Compilers includes a Windows exe which breaks build on linux
content = content.replace('<PackageReference Include="Microsoft.Net.Compilers" Version="1.0.0" />', '')

with open("Werewolf for Telegram/BuildAutomation/BuildAutomation.csproj", "w") as f:
    f.write(content)
