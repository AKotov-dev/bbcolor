unit mrcbbcolorunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ComCtrls, StdCtrls, ExtCtrls, Menus, RichMemo, RichMemoHelpers,
  LCLIntf, LCLType, LazUTF8, ClipBrd, XMLPropStorage, Spin, LCLTranslator,
  DefaultTranslator, IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    AnchorColorReset: TSpeedButton;
    AnchorMemo: TMemo;
    Bevel2: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    AnchorBoldBtn: TSpeedButton;
    ColorDialog1: TColorDialog;
    ColorButton1: TColorButton;
    ColorButton2: TColorButton;
    Editor: TRichMemo;
    AnchorColorBtn: TSpeedButton;
    AboutButton: TSpeedButton;
    IniPropStorage1: TIniPropStorage;
    RandomButton: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    BBTextMemo: TMemo;
    BBURLMemo: TMemo;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    CopyTextBtn: TSpeedButton;
    CopyURLBtn: TSpeedButton;
    SpinEdit1: TSpinEdit;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    URLClearBtn: TSpeedButton;
    AnchorClearBtn: TSpeedButton;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    BoldButton: TSpeedButton;
    ItalicButton: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    GradientButton: TSpeedButton;
    FontColorButton: TSpeedButton;
    TextClearBtn: TSpeedButton;
    UnderlineButton: TSpeedButton;
    StrikeOutButton: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    URLMemo: TMemo;
    procedure AboutButtonClick(Sender: TObject);
    procedure AnchorBoldBtnClick(Sender: TObject);
    procedure AnchorColorResetClick(Sender: TObject);
    procedure AnchorMemoExit(Sender: TObject);
    procedure CopyTextBtnClick(Sender: TObject);
    procedure BoldButtonClick(Sender: TObject);
    procedure CopyURLBtnClick(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure AnchorColorBtnClick(Sender: TObject);
    procedure FontColorButtonlick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ItalicButtonClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure PageControl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure RandomButtonClick(Sender: TObject);
    procedure GradientButtonClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1KeyPress(Sender: TObject; var Key: char);
    procedure TextClearBtnClick(Sender: TObject);
    procedure URLClearBtnClick(Sender: TObject);
    procedure AnchorClearBtnClick(Sender: TObject);
    procedure StrikeOutButtonClick(Sender: TObject);
    procedure UnderlineButtonClick(Sender: TObject);
    procedure URLMemoExit(Sender: TObject);
  private
    EditorModified, Focus: boolean;
    DefaultColor: TColor;

    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses aboutunit;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.URLMemoExit(Sender: TObject);
begin
  Focus := False;
end;

function ColorToHex(Color: TColor): string;
begin
  Result :=
    IntToHex(GetRValue(Color), 2) + IntToHex(GetGValue(Color), 2) +
    IntToHex(GetBValue(Color), 2);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Windows/Linux
  {$IFDEF linux}
  Editor.PopupMenu := nil;
  IniPropStorage1.IniFileName := GetUserDir + '.bbcolor';
  {$ELSE}
  IniPropStorage1.IniFileName := ExtractFilePath(ParamStr(0)) + 'bbcolor';
  {$ENDIF}
end;

procedure TMainForm.CopyTextBtnClick(Sender: TObject);
var
  n: integer; //Указатель номера символа, размер шрифта
  b, i, u, s: boolean; //Флаги стиля
  StrBB, SymBB, c: string;
  //Строка-результат-BB, символ-результат-BB, цвет
begin
  Screen.Cursor := crHourGlass;
  //Убираем мерцание
  Editor.Lines.BeginUpdate;

  //Номер символа в начало
  n := 0;
  StrBB := '';

  //Анализ текста посимвольно
  while n < UTF8Length(Editor.Text) do
  begin
    //Выделяем текущий символ
    Editor.SelStart := n;
    Editor.SelLength := 1;
    SymBB := Editor.SelText;

    //Запоминаем атрибуты текущего символа
    b := fsBold in Editor.SelAttributes.Style;
    i := fsItalic in Editor.SelAttributes.Style;
    u := fsUnderline in Editor.SelAttributes.Style;
    s := fsStrikeOut in Editor.SelAttributes.Style;
    c := ColorToHex(Editor.SelAttributes.Color);

    //-------- Сравниваем стиль предыдущего символа с текущим
    Editor.SelStart := n - 1;
    Editor.SelLength := 1;

    if (b and not (fsBold in Editor.SelAttributes.Style)) or (b and (n = 0)) then
      SymBB := '[b]' + SymBB;

    if (i and not (fsItalic in Editor.SelAttributes.Style)) or (i and (n = 0)) then
      SymBB := '[i]' + SymBB;

    if (u and not (fsUnderline in Editor.SelAttributes.Style)) or
      (u and (n = 0)) then
      SymBB := '[u]' + SymBB;

    if (s and not (fsStrikeOut in Editor.SelAttributes.Style)) or
      (s and (n = 0)) then
      SymBB := '[s]' + SymBB;

    //if c <> ColorToHex(DefaultColor) then
    //Не ставить теги, если DefaulColor
    if (c <> ColorToHex(Editor.SelAttributes.Color)) or
      ((c = ColorToHex(Editor.SelAttributes.Color)) and (n = 0)) then
      SymBB := '[color=#' + c + ']' + SymBB;


    //-------- Сравниваем стиль последующего символа с текущим
    Editor.SelStart := n + 1;
    Editor.SelLength := 1;

    if (b and not (fsBold in Editor.SelAttributes.Style)) or
      (b and (n = Length(Editor.Text) - 1)) then
      SymBB := SymBB + '[/b]';

    if (i and not (fsItalic in Editor.SelAttributes.Style)) or
      (i and (n = Length(Editor.Text) - 1)) then
      SymBB := SymBB + '[/i]';

    if (u and not (fsUnderline in Editor.SelAttributes.Style)) or
      (u and (n = Length(Editor.Text) - 1)) then
      SymBB := SymBB + '[/u]';

    if (s and not (fsStrikeOut in Editor.SelAttributes.Style)) or
      (s and (n = Length(Editor.Text) - 1)) then
      SymBB := SymBB + '[/s]';

    //if c <> ColorToHex(DefaultColor) then
    //Не ставить теги, если DefaulColor
    if (c <> ColorToHex(Editor.SelAttributes.Color)) or
      ((c = ColorToHex(Editor.SelAttributes.Color)) and
      (n = UTF8Length(Editor.Text) - 1)) then
      SymBB := SymBB + '[/color]';

    StrBB := StrBB + SymBB;

    //Следующий символ
    Inc(n);
  end;

  //Копируем результат в буфер
  BBTextMemo.Text := StrBB;

  ClipBoard.AsText := StrBB;
  Editor.SelStart := 0;
  Editor.SetFocus;

  //Убираем мерцание
  Editor.Lines.EndUpdate;
  Screen.Cursor := crDefault;
end;

procedure TMainForm.AnchorBoldBtnClick(Sender: TObject);
begin
  if fsBold in AnchorMemo.Font.Style then
    AnchorMemo.Font.Style := AnchorMemo.Font.Style - [fsBold]
  else
    AnchorMemo.Font.Style := AnchorMemo.Font.Style + [fsBold];
  AnchorMemo.SetFocus;
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  AboutForm.Show;
end;

procedure TMainForm.AnchorColorResetClick(Sender: TObject);
begin
  AnchorMemo.Font.Color := BBURLMemo.Font.Color;
  AnchorMemo.SetFocus;
end;

procedure TMainForm.AnchorMemoExit(Sender: TObject);
begin
  Focus := True;
end;

procedure TMainForm.BoldButtonClick(Sender: TObject);
begin
  if fsBold in Editor.SelAttributes.Style then
    Editor.SelAttributes.Style := Editor.SelAttributes.Style - [fsBold]
  else
    Editor.SelAttributes.Style := Editor.SelAttributes.Style + [fsBold];
end;

procedure TMainForm.CopyURLBtnClick(Sender: TObject);
var
  AnchorBBCode, ResBBCode: string;
begin
  ResBBCode := '';
  AnchorBBCode := '';

  //Компоновка
  URLMemo.Text := Trim(URLMemo.Text);
  AnchorMemo.Text := Trim(AnchorMemo.Text);

  //Если URL не пустой
  if URLMemo.Text <> '' then
  begin
    //Цветной анкор
    if AnchorMemo.Font.Color <> DefaultColor then
      AnchorBBCode := '[color=#' + ColorToHex(AnchorMemo.Font.Color) +
        ']' + AnchorMemo.Text + '[/color]'
    else
      AnchorBBCode := AnchorMemo.Text;
    //Жирный анкор
    if fsBold in AnchorMemo.Font.Style then
      AnchorBBCode := '[b]' + AnchorBBCode + '[/b]';

    //E-Mail или нет
    if Pos('@', URLMemo.Text) > 0 then
      if AnchorMemo.Text = '' then //Нет описания
        ResBBCode := '[email]' + URLMemo.Text + '[/email]'
      else
        ResBBCode := '[email=' + URLMemo.Text + ']' + AnchorBBCode + '[/email]'
    else
    if AnchorMemo.Text = '' then
      ResBBCode := '[url]' + URLMemo.Text + '[/url]'
    else
      ResBBCode := '[url=' + URLMemo.Text + ']' + AnchorBBCode + '[/url]';
  end;

  //Копируем результат в буфер
  BBURLMemo.Text := ResBBCode;
  ClipBoard.AsText := ResBBCode;

  //Возвращаем фокус
  if not Focus then
    URLMemo.SetFocus
  else
    AnchorMemo.SetFocus;
end;

procedure TMainForm.EditorChange(Sender: TObject);
begin
  EditorModified := True;
end;

procedure TMainForm.AnchorColorBtnClick(Sender: TObject);
begin
  ColorDialog1.Color := AnchorMemo.Font.Color;

  if ColorDialog1.Execute then
    AnchorMemo.Font.Color := Colordialog1.Color;

  AnchorMemo.SetFocus;
end;

procedure TMainForm.FontColorButtonlick(Sender: TObject);
begin
  ColorDialog1.Color := Editor.SelAttributes.Color;

  if ColorDialog1.Execute then
  begin
    Editor.SelAttributes.Color := Colordialog1.Color;
    Editor.Repaint;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  //Plasma DPi
  IniPropStorage1.Restore;

  MainForm.Caption := Application.Title;
  DefaultColor := BBTextMemo.Font.Color;
  EditorModified := False;

  Editor.Font.Size := SpinEdit1.Value;
  PageControl1.ActivePageIndex := 0;
  Editor.SetFocus;
end;

procedure TMainForm.ItalicButtonClick(Sender: TObject);
begin
  if fsItalic in Editor.SelAttributes.Style then
    Editor.SelAttributes.Style := Editor.SelAttributes.Style - [fsItalic]
  else
    Editor.SelAttributes.Style := Editor.SelAttributes.Style + [fsItalic];
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TMainForm.MenuItem2Click(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TMainForm.MenuItem4Click(Sender: TObject);
begin
  Editor.PasteFromClipboard;
end;

procedure TMainForm.PageControl1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if PageControl1.PageIndex = 0 then
    Editor.SetFocus
  else
  if not Focus then
    URLMemo.SetFocus
  else
    AnchorMemo.SetFocus;
end;

procedure TMainForm.RandomButtonClick(Sender: TObject);
var
  i: integer;
begin
  Screen.Cursor := crHourGlass;
  Editor.Lines.BeginUpdate;
  for i := 0 to UTF8Length(Editor.Text) - 1 do
  begin
    Editor.SelStart := i;
    Editor.SelLength := 1;
    Editor.SelAttributes.Color := Random(65535);
  end;
  Editor.Lines.EndUpdate;
  Editor.SelStart := 0;
  Editor.SetFocus;
  Screen.Cursor := crDefault;
end;

procedure TMainForm.GradientButtonClick(Sender: TObject);
var
  StartC, EndC: TColor; //начальный и конечный цвета
  StartRGB, EndRGB: array[0..2] of byte; //разложенный цвет
  i: integer;
begin
  //цвета
  StartC := ColorToRGB(ColorButton1.ButtonColor);
  EndC := ColorToRGB(ColorButton2.ButtonColor);

  //массив с исходными цветами (1)
  StartRGB[0] := GetRValue(StartC);
  StartRGB[1] := GetGValue(StartC);
  StartRGB[2] := GetBValue(StartC);

  //массив с исходными цветами (2)
  EndRGB[0] := GetRValue(EndC);
  EndRGB[1] := GetGValue(EndC);
  EndRGB[2] := GetBValue(EndC);

  Screen.Cursor := crHourGlass;
  CopyTextBtn.Enabled := False;
  //Убираем мерцание
  Editor.Lines.BeginUpdate;

  for i := 0 to UTF8Length(Editor.Text) do
  begin
    Editor.SelStart := i;
    Editor.SelLength := 1;

    Editor.SelAttributes.Color :=
      RGB((StartRGB[0] + MulDiv(i, EndRGB[0] - StartRGB[0], UTF8Length(Editor.Text))),
      (StartRGB[1] + MulDiv(i, EndRGB[1] - StartRGB[1], UTF8Length(Editor.Text))),
      (StartRGB[2] + MulDiv(i, EndRGB[2] - StartRGB[2], UTF8Length(Editor.Text))));
  end;

  Editor.Lines.EndUpdate;
  CopyTextBtn.Enabled := True;
  Editor.SelStart := 0;
  Editor.SetFocus;
  Screen.Cursor := crDefault;
end;

procedure TMainForm.SpinEdit1Change(Sender: TObject);
begin
  with Editor do
  begin
    SelectAll;
    SelAttributes.Size := SpinEdit1.Value;
    //Windows/Linux
    {$IFDEF linux}
    Editor.Font.Size := SpinEdit1.Value;
    {$ENDIF}
    SelStart := 0;
    SetFocus;
  end;
end;

procedure TMainForm.SpinEdit1KeyPress(Sender: TObject; var Key: char);
begin
  Key := #0;
end;

procedure TMainForm.TextClearBtnClick(Sender: TObject);
begin
  Editor.Lines.Clear;
  BBTextMemo.Lines.Clear;
  Editor.SetFocus;
end;

procedure TMainForm.URLClearBtnClick(Sender: TObject);
begin
  URLMemo.Lines.Clear;
  BBURLMemo.Lines.Clear;
  URLMemo.SetFocus;
end;

procedure TMainForm.AnchorClearBtnClick(Sender: TObject);
begin
  AnchorMemo.Lines.Clear;
  BBURLMemo.Lines.Clear;
  AnchorMemo.SetFocus;
end;

procedure TMainForm.StrikeOutButtonClick(Sender: TObject);
begin
  if fsStrikeOut in Editor.SelAttributes.Style then
    Editor.SelAttributes.Style := Editor.SelAttributes.Style - [fsStrikeOut]
  else
    Editor.SelAttributes.Style := Editor.SelAttributes.Style + [fsStrikeOut];
end;

procedure TMainForm.UnderlineButtonClick(Sender: TObject);
begin
  if fsUnderLine in Editor.SelAttributes.Style then
    Editor.SelAttributes.Style := Editor.SelAttributes.Style - [fsUnderline]
  else
    Editor.SelAttributes.Style := Editor.SelAttributes.Style + [fsUnderline];
end;

end.
