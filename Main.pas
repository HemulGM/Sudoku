unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, SudokuGameEngine, ExtCtrls, StdCtrls;

type
  TFormMain = class(TForm)
    XPManifest: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  SGE:TGameByHemulGM;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
 Color:=clBlack;
 try
  SGE:=TSudokuGame.Create(Canvas);
 except
  Ahtung;
 end;
 TSudokuGame(SGE).CreateField(35);
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if TSudokuGame(SGE).Edit then
  case Key of
   '1'..'9':with TSudokuGame(SGE) do
    if not GraphicEngine.QuestKey then Field[SelectedCell.Y, SelectedCell.X].SetFull(StrToInt(Key))
    else Field[SelectedCell.Y, SelectedCell.X].SetQuest(StrToInt(Key));
   Char(8):with TSudokuGame(SGE) do
    begin
     Field[SelectedCell.Y, SelectedCell.X].Delete;
     GraphicEngine.ShowKeyboard:=False;
    end;
   ' ':with TSudokuGame(SGE) do GraphicEngine.QuestKey:=not GraphicEngine.QuestKey;
  Char(27):with TSudokuGame(SGE) do Edit:=False;
  end
 else
 case Key of
  '1'..'9':with TSudokuGame(SGE) do CreateField(StrToInt(Key) * 10);
  ' ':TSudokuGame(SGE).CreateField(TSudokuGame(SGE).Difficult);
  #13:TSudokuGame(SGE).ShowCheckInfo;
  'C', 'c', 'ñ', 'Ñ':TSudokuGame(SGE).Clear;
  'F', 'À', 'f', 'à':TSudokuGame(SGE).Fill_v1;
  'D', 'Â', 'd', 'â':TSudokuGame(SGE).Fill_v2;
  'G', 'Ï', 'g', 'ï':TSudokuGame(SGE).Fill_v3;
  Char(27):if ClientHeight <= 380 then ClientHeight:=455 else ClientHeight:=380;
  'Q', 'q', 'é', 'É':TSudokuGame(SGE).Processing:=False;
  'Z', 'z', 'ÿ', 'ß':TSudokuGame(SGE).Fix;
  Char(8):TSudokuGame(SGE).ClearFull;
 end;
 //ShowMessage(IntToStr(Ord(Key)));
end;

procedure TFormMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 TSudokuGame(SGE).MouseUp(Button, Shift, X, Y);
end;

procedure TFormMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 TSudokuGame(SGE).MouseMove(Shift, X, Y);
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 TSudokuGame(SGE).MouseDown(Button, Shift, X, Y);
end;

end.
