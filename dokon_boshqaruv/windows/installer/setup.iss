#ifndef AppVersion
  #define AppVersion "0.3.1"
#endif
#ifndef ReleaseDir
  #define ReleaseDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\..\dist"
#endif
[Setup]
AppId={{A8BD345F-B813-41BD-B018-768E60B3DC50}
AppName=e-dukon
AppVersion={#AppVersion}
AppPublisher=DEALS
DefaultDirName={localappdata}\Programs\e-dukon
DefaultGroupName=e-dukon
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
OutputDir={#OutputDir}
OutputBaseFilename=e-dukon-Setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\e-dukon.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: unchecked
[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\e-dukon"; Filename: "{app}\e-dukon.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\e-dukon"; Filename: "{app}\e-dukon.exe"; WorkingDir: "{app}"; Tasks: desktopicon
[Run]
Filename: "{app}\e-dukon.exe"; Description: "Launch e-dukon"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent
