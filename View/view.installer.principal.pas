unit view.installer.principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.ScrollBox, FMX.Memo;

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
    Label4: TLabel;
    label50: TLabel;
    StyleBook1: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInstaller: TfrmInstaller;

implementation

{$R *.fmx}

end.
