program Installer;

uses
  System.StartUpCopy,
  FMX.Forms,
  view.installer.principal in 'View\view.installer.principal.pas' {frmInstaller},
  model.updater.download in 'Model\model.updater.download.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmInstaller, frmInstaller);
  Application.Run;
end.
