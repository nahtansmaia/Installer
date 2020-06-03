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
  public
    procedure Download(NetHTTPClient: TNetHTTPClient; sURL, sFile: String);
    procedure Notificacao(sName, sTitle, sbody: string);
    procedure NotificationCenterReceiveLocalNotification(Sender: TObject;
      ANotification: TNotification);
    procedure Instalar;
    procedure CriarAtalho;
  end;

implementation

{ TDownload }

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
  RenameFile('C:\Elegance\Elegance.exe', 'C:\Elegance\Elegance_Old.exe');
  if RenameFile('C:\Elegance\Elegance_new.exe', 'C:\Elegance\Elegance.exe') then
    deletefile('C:\Elegance\Elegance_Old.exe');
  ShellExecute(0, nil, PChar('C:\Elegance\Elegance.exe'), '', nil,
    SW_SHOWNORMAL);
  CriarAtalho;
  Application.terminate;
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

end.
