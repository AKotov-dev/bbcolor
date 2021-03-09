unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, XMLPropStorage;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LangBtn: TSpeedButton;
    AboutFormStorage: TXMLPropStorage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LangBtnClick(Sender: TObject);
  private

  public

  end;

var
  AboutForm: TAboutForm;

implementation

uses mrcbbcolorunit, LCLTranslator, DefaultTranslator;

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.LangBtnClick(Sender: TObject);
begin
  AboutForm.Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  //Windows/Linux
  {$IFDEF linux}
  AboutForm.AboutFormStorage.FileName := GetUserDir + '/.bbsettings';
  {$ELSE}
  AboutForm.AboutFormStorage.FileName := ExtractFilePath(ParamStr(0)) + 'bbsettings';
  {$ENDIF}
end;

procedure TAboutForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MainForm.Editor.SetFocus;
end;

end.
