unit view.installer.principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.ScrollBox, FMX.Memo,
  model.updater.download, Winapi.Windows, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Winapi.ShellAPI,
  model.updater.firebase, System.JSON;

type
  TfrmInstaller = class(TForm)
    layPrincipal: TLayout;
    layTop: TLayout;
    layBot: TLayout;
    layDescricao: TLayout;
    layClient: TLayout;
    layBtn: TLayout;
    layImg: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    btnDownload: TSpeedButton;
    BtnMinimizar: TSpeedButton;
    Label3: TLabel;
    ProgressBar1: TProgressBar;
    lblVersaoElegance: TLabel;
    label50: TLabel;
    StyleBook1: TStyleBook;
    NetHTTPClient1: TNetHTTPClient;
    lblVersaoInstaller: TLabel;
    procedure BtnMinimizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure NetHTTPClient1ReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var Abort: Boolean);
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
  private
    lLink: String;
    lVersao: String;
    ldownload: Tdownload;
    FConexao: Tcomunicacao;
    procedure ObterDados;
  public
    { Public declarations }
  end;

var
  frmInstaller: TfrmInstaller;

implementation

{$R *.fmx}

function BytesToStr(iBytes: integer): String;
var
  iKb: integer;
begin
  iKb := Round(iBytes / 1024);
  if iKb > 1000 then
    Result := Format('%.2f MB', [iKb / 1024])
  else
    Result := Format('%d KB', [iKb]);
end;

procedure TfrmInstaller.btnDownloadClick(Sender: TObject);
begin
  if btnDownload.Text = 'Instalar' then
  Begin
    btnDownload.TextSettings.Font.Size := 12;
    btnDownload.Text := 'Instalando';
    btnDownload.Enabled := False;
    ldownload.instalar;
  End
  Else
    try
      if not DirectoryExists('C:\Elegance\') then
      Begin
        ForceDirectories('C:\Elegance\');
        WinExec(PAnsiChar('cacls "C:\Elegance" /E /P Todos:F'), SW_HIDE);
        WinExec(PAnsiChar('cacls "C:\Elegance" /E /P Todos:F'), SW_HIDE);
      end;
    finally
      btnDownload.Text := 'Buscando';
      btnDownload.Enabled := False;
      ldownload.download(NetHTTPClient1, lLink, 'Elegance_new.exe');
    end;
end;

procedure TfrmInstaller.BtnMinimizarClick(Sender: TObject);
begin
  if BtnMinimizar.StyleLookup = 'cleareditbutton' then
    self.Close
  else
    self.WindowState := TWindowState.wsMinimized;
end;

procedure TfrmInstaller.FormCreate(Sender: TObject);
begin
  FConexao := Tcomunicacao.Create('https://elegance-software.firebaseio.com/');
  ldownload := Tdownload.Create;

  btnDownload.Enabled := False;
  btnDownload.Text := 'Buscando';

  lblVersaoInstaller.Text := 'Versão Installer: ' + ldownload.GetBuildInfo
    ('C:\Elegance\Installer.exe');
  ObterDados;
  lVersao := ldownload.GetBuildInfo('C:\Elegance\Elegance.exe');
  if lVersao = StringReplace(FConexao.ObtemDados('Versao', True), '"', '',
    [rfReplaceAll]) then
  Begin
    btnDownload.TextSettings.Font.Size := 14;
    btnDownload.Text := 'Atualizado';
    btnDownload.Enabled := False;
    BtnMinimizar.StyleLookup := 'cleareditbutton';
  End;
end;

procedure TfrmInstaller.FormDestroy(Sender: TObject);
begin
  ldownload.Free;
  FConexao.Free;
end;

procedure TfrmInstaller.NetHTTPClient1ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var Abort: Boolean);
var
  i: integer;
begin
  btnDownload.Text := 'Baixando';
  btnDownload.Enabled := False;
  Label3.Visible := True;
  Label3.Text := BytesToStr(AReadCount) + ' / ' + BytesToStr(AContentLength);
  ProgressBar1.Max := AContentLength;
  if AReadCount < AContentLength then
  begin
    ProgressBar1.value := AReadCount;
  end;
end;

procedure TfrmInstaller.NetHTTPClient1RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  btnDownload.Text := 'Instalar';
  btnDownload.Enabled := True;
end;

procedure TfrmInstaller.ObterDados;
var
  jsonObj: TJSONObject;
begin
  if FConexao.ObtemDados('Versao') = True then
  Begin
    lblVersaoElegance.Text := 'Versão Elegance disponível: ' +
      StringReplace(FConexao.ObtemDados('Versao', True), '"', '',
      [rfReplaceAll]);
  End;
  if FConexao.ObtemDados('Link') = True then
  Begin
    lLink := StringReplace(FConexao.ObtemDados('Link', True), '"', '',
      [rfReplaceAll]);
    btnDownload.Text := 'Baixar';
    btnDownload.Enabled := True;
  End;
end;

end.
