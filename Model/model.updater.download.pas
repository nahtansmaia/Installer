unit Model.Updater.Download;

interface

uses
  System.Net.HttpClientComponent, System.Classes, System.SysUtils, FMX.Dialogs,
  System.Notification, Winapi.ShellAPI, Winapi.Windows, System.Net.HttpClient,
  FMX.Forms, Winapi.ShlObj, Winapi.ActiveX, System.Win.ComObj, Registry;

type
  TDownload = class
    constructor Create;
    destructor Destroy; override;
  private
    NotificationCenter: TNotificationCenter;
    procedure CriarAtalho;
    procedure CopiarInstaller;
  public
    procedure Download(NetHTTPClient: TNetHTTPClient; sURL, sFile: String);
    procedure Notificacao(sName, sTitle, sbody: string);
    procedure NotificationCenterReceiveLocalNotification(Sender: TObject;
      ANotification: TNotification);
    procedure Instalar;
    function GetBuildInfo(Prog: string): string;
  end;

implementation

{ TDownload }

procedure TDownload.CopiarInstaller;
var
  lCaminho: String;
begin
  lCaminho := GetCurrentDir + '\Installer.exe';
  CopyFile(PWideChar(lCaminho), 'C:\Elegance\Installer.exe', True)
end;

constructor TDownload.Create;
begin
  NotificationCenter := TNotificationCenter.Create(nil);
  NotificationCenter.OnReceiveLocalNotification :=
    NotificationCenterReceiveLocalNotification;
end;

procedure TDownload.CriarAtalho;
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile;
  Directory: String;
  FileName: String;
  InitialDir: String;
  ShortcutName: String;
  Parameters: PWideChar;
  WFileName: WideString;
  MyReg: TRegIniFile;
begin
  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink;
  MyPFile := MyObject as IPersistFile;
  with MySLink do
  begin
    SetArguments('Elegance');
    SetPath(PChar('C:\Elegance\Elegance.exe'));
    SetWorkingDirectory(PChar('C:\Elegance\Elegance.exe'));
  end;
  MyReg := TRegIniFile.Create
    ('Software\\MicroSoft\\Windows\\CurrentVersion\\Explorer');
  Directory := MyReg.ReadString('Shell Folders', 'Desktop', '');
  WFileName := Directory + '\\' + 'Elegance' + '.lnk';
  MyPFile.Save(PWChar(WFileName), False);
  MyReg.Free;
end;

destructor TDownload.Destroy;
begin
  freeandnil(NotificationCenter);
  inherited;
end;

procedure TDownload.Download(NetHTTPClient: TNetHTTPClient;
  sURL, sFile: String);
var
  lFile: TFileStream;
begin
  lFile := TFileStream.Create('C:\Elegance\' + sFile, fmCreate);

  TThread.CreateAnonymousThread(
    procedure()
    begin
      try
        NetHTTPClient.Get(sURL, lFile);
      finally
        lFile.Free;
      end;

      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        Begin
          Notificacao('update', 'Atualização do Elegance disponível',
            'Clique aqui para instalar agora');
        end);
    end).Start;
end;

procedure TDownload.Instalar;
begin
  TThread.CreateAnonymousThread(
    procedure()
    begin
      RenameFile('C:\Elegance\Elegance.exe', 'C:\Elegance\Elegance_Old.exe');
      if RenameFile('C:\Elegance\Elegance_new.exe', 'C:\Elegance\Elegance.exe')
      then
      Begin
        deletefile('C:\Elegance\Elegance_Old.exe');
        ShellExecute(0, nil, PChar('C:\Elegance\Elegance.exe'), '', nil,
          SW_SHOWNORMAL);
        CriarAtalho;
        CopiarInstaller;
      End;

      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        Begin
          Application.terminate;
        end);
    end).Start;
end;

procedure TDownload.Notificacao(sName, sTitle, sbody: string);
var
  Notifica: TNotification;
begin
  if NotificationCenter.Supported then
  Begin
    Notifica := NotificationCenter.CreateNotification;
    with Notifica do
    Begin
      Name := sName;
      Title := sTitle;
      AlertBody := sbody;
      FireDate := now;
    End;
    NotificationCenter.PresentNotification(Notifica);
  End;
end;

procedure TDownload.NotificationCenterReceiveLocalNotification(Sender: TObject;
ANotification: TNotification);
begin
  if ANotification.Name = 'update' then
  Begin
    Instalar;
  End;
end;

function TDownload.GetBuildInfo(Prog: string): string;
var
 VerInfoSize: DWORD;
 VerInfo: Pointer;
 VerValueSize: DWORD;
 VerValue: PVSFixedFileInfo;
 Dummy: DWORD;
 V1, V2, V3, V4: Word;
begin
 try
   VerInfoSize := GetFileVersionInfoSize(PChar(Prog), Dummy);
   GetMem(VerInfo, VerInfoSize);
   GetFileVersionInfo(PChar(prog), 0, VerInfoSize, VerInfo);
   VerQueryValue(VerInfo, '', Pointer(VerValue), VerValueSize);
   with (VerValue^) do
   begin
     V1 := dwFileVersionMS shr 16;
     V2 := dwFileVersionMS and $FFFF;
     V3 := dwFileVersionLS shr 16;
     V4 := dwFileVersionLS and $FFFF;
   end;
   FreeMem(VerInfo, VerInfoSize);
   Result := Format('%d.%d.%d.%d', [v1, v2, v3, v4]);
 except
   Result := '1.0.0';
 end;
end;

end.
