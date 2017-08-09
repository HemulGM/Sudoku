unit SudokuGameEngine;

interface

 uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage;

 type
  TGameByHemulGM = class;
  TSudokuElement = class;
  TSudokuGame    = class;
  TGraphicEngine = class;
  TExPoint       = record
   X, Y:Extended;
  end;

  TSudokuElementState = (esEmpty, esFull, esNumber, esQuest);

  TGameByHemulGM = class(TObject)
   private
    FCanvas:TCanvas;
    FGameName:string;
    FAutor:string;
    FDateStart:string;
   public
    property GameName:string read FGameName;
    property Autor:string read FAutor;
    property DateStart:string read FDateStart;
    constructor Create(AGameName:string; HCanvas:TCanvas);
  end;

  TSudokuElement = class
   private
    FOwner:TSudokuGame;
    FID:Integer;
    FNumber:Byte;
    FState:TSudokuElementState;
    FPos:TPoint;
   public
    procedure SetNumber(Value:Byte);
    procedure SetFull(Value:Byte);
    procedure SetQuest(Value:Byte);
    procedure SetState(Value:TSudokuElementState);
    procedure Delete;
    property Position:TPoint read FPos;
    property Owner:TSudokuGame read FOwner;
    property ID:Integer read FID write FID;
    property Number:Byte read FNumber write SetNumber;
    property State:TSudokuElementState read FState write SetState;
    constructor Create(AOwner:TSudokuGame; MPos:TPoint);
  end;

  TMtCell = record
   Mistake:Boolean;
  end;

  TField = array[1..9, 1..9] of TSudokuElement;
  TMtField = array[1..9, 1..9] of TMtCell;

  TSudokuGame = class(TGameByHemulGM)
   private
    FEdit:Boolean;
    FEditCell:TPoint;
    FField:TField;
    MTField:TMtField;
    OldSelectedCell:TPoint;
    DrawCurPos:TExPoint;
    OldCurPos:TExPoint;
    CurPos:TExPoint;
    NewCurPos:TExPoint;
    MoveTimer:TTimer;
    FProcessing:Boolean;
    HideInfo:TTimer;
    function GetCellFieldPos(Cell:TPoint):TPoint;
    procedure FillField;
    function FieldIsFull:Boolean;
    function SetFieldDif(Dif:Byte):Byte;
    procedure HideInfoTime(Sender:TObject);
   public
    Difficult:Byte;
    SelectedCell:TPoint;
    GraphicEngine:TGraphicEngine;
    procedure Fill_v1;
    procedure Fill_v2;
    procedure Fill_v3;
    procedure Fix;
    procedure Clear;
    procedure ShowInfo(Cap, Text:string);
    function CheckCell(AR, AC, ANum:Byte):Boolean;
    function CheckField:Byte;
    procedure ClearFull;
    procedure MoveCur(NX, NY:Integer);
    procedure CreateField(Dif:Byte);
    procedure ShowCheckInfo;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MoveTimerTime(Sender:TObject);
    property Field:TField read FField write FField;
    property Processing:Boolean read FProcessing write FProcessing;
    property Edit:Boolean read FEdit write FEdit;
    property EditCell:TPoint read FEditCell write FEditCell;
    constructor Create(HCanvas:TCanvas);
  end;

  TGraphicEngine = class
   private
    BGStep:Byte;
    InfoPage1:string;
    InfoPage2:string;
    InfoPNG:TPNGObject;
    PenPNG:TPNGObject;
    EditQPNG:TPNGObject;
    EditPNG:TPNGObject;
    PNGField:TPNGObject;
    MtPNG:TPNGObject;
    BGBMP:TBitmap;
    CurPNG:TPNGObject;
    NumPadPNG:TPNGObject;
    SelNumPNG:TPNGObject;
    BottomPNG:TPNGObject;
    FGame:TGameByHemulGM;
    HCanvas:TCanvas;
    ShiftT:Integer;
    ShiftL:Integer;
    SelectedAns:TPoint;
    KeyboardRect:TRect;
    KeyboardPos:TPoint;
    KeyWidth:Word;
    FieldRect:TRect;
    CellWidth:Word;
    FTimer:TTimer;
    BackGroundDraw:TBitmap;
    BackGroundOne:TBitmap;
    BackGroundTwo:TBitmap;
    TimerDraw:TTimer;
    procedure FTimerTime(Sender:TObject);
    procedure TimerBGTime(Sender: TObject);
   public
    QuestKey:Boolean;
    ShowKeyboard:Boolean;
    procedure Redraw;
    property Timer:TTimer read FTimer;
    property Game:TGameByHemulGM read FGame write FGame;
    constructor Create(ACanvas:TCanvas);
  end;


procedure Ahtung;


implementation
 uses Main, Math;

procedure Ahtung;
begin
 MessageBox(Application.Handle, 'Возникла ошибка при инициализации приложения.'#13#10'Программа будет закрыта.', 'Внимание', MB_OK);
 Application.Terminate;
end;

function ExPoint(X, Y:Extended):TExPoint;
begin
 Result.X:=X;
 Result.Y:=Y;
end;

constructor TSudokuElement.Create(AOwner:TSudokuGame; MPos:TPoint);
begin
 FNumber:=0;
 FState:=esEmpty;
 FOwner:=AOwner;
 FPos:=MPos;
end;

constructor TGraphicEngine.Create(ACanvas:TCanvas);
begin
 FTimer:=TTimer.Create(nil);
 with FTimer do
  begin
   Name:='FTimer';
   OnTimer:=FTimerTime;
   Interval:=40;
   Enabled:=True;
  end;
 TimerDraw:=TTimer.Create(nil);
 with TimerDraw do
  begin
   OnTimer:=TimerBGTime;
   Name:='TimerDraw';
   Enabled:=True;
   Interval:=45;
  end;
 BackGroundDraw:=TBitmap.Create;
 BackGroundDraw.Width:=400;
 BackGroundDraw.Height:=500;
 BackGroundDraw.PixelFormat:=pf24bit;
 BackGroundOne:=TBitmap.Create;
 BackGroundOne.Width:=400;
 BackGroundOne.Height:=500;
 BackGroundOne.PixelFormat:=pf24bit;
 BackGroundTwo:=TBitmap.Create;
 BackGroundTwo.Width:=400;
 BackGroundTwo.Height:=500;
 BackGroundTwo.PixelFormat:=pf24bit;
 BackGroundDraw.Canvas.Brush.Color:=clBlack;
 BackGroundDraw.Canvas.Rectangle(BackGroundDraw.Canvas.ClipRect);
 BackGroundOne.Canvas.Brush.Color:=clBlack;
 BackGroundOne.Canvas.Rectangle(BackGroundOne.Canvas.ClipRect);
 BackGroundTwo.Canvas.Brush.Color:=clBlack;
 BackGroundTwo.Canvas.Rectangle(BackGroundTwo.Canvas.ClipRect);
 HCanvas:=ACanvas;
 ShiftT:=50;
 ShiftL:=50;
 CellWidth:=30;
 KeyWidth:=20;
 FieldRect:=Rect(ShiftL, ShiftT, ShiftL + (CellWidth * 9), ShiftT + (CellWidth * 9));
 try
   BGBMP:=TBitmap.Create;
   BGBMP.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\BG.bmp');
   CurPNG:=TPNGObject.Create;
   CurPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Cursor.png');
   NumPadPNG:=TPNGObject.Create;
   NumPadPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\NumPad.png');
   SelNumPNG:=TPNGObject.Create;
   SelNumPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\SelNum.png');
   BottomPNG:=TPNGObject.Create;
   BottomPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Bottom.png');
   PNGField:=TPNGObject.Create;
   PNGField.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\F1.png');
   MtPNG:=TPNGObject.Create;
   MtPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Mt.png');
   InfoPNG:=TPNGObject.Create;
   InfoPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Info.png');
   EditPNG:=TPNGObject.Create;
   EditPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Edt.png');
   PenPNG:=TPNGObject.Create;
   PenPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\Pen.png');
   EditQPNG:=TPNGObject.Create;
   EditQPNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'Data\EdtQ.png');
 except
  begin
   //Ahtung;
   Application.Terminate;
  end;
 end;       
end;

procedure TGraphicEngine.FTimerTime(Sender:TObject);
begin
 Redraw;
 //Рисуем на Холсте 2 главный холст
 BackGroundTwo.Canvas.Draw(0, 0, BackGroundDraw);
 //Рисуем на экране главный холст
 HCanvas.Draw(0, 0, BackGroundDraw);
 //Прозрачность - 50%
 BGStep:=50;
end;

procedure TGraphicEngine.Redraw;
var R, C, Count:Byte;
    X, Y, SL, ST:Integer;
    GM:TSudokuGame;
begin
 with BackGroundOne.Canvas do
  begin
   GM:=TSudokuGame(Game);
   Draw(0, 0, BGBMP);
   Count:=9;
   SL:=ShiftL;
   ST:=ShiftT;
   Draw(SL - 1, ST - 1, PNGField);
   Font.Name:='Segoe Script';
   Font.Size:=19;
   Brush.Style:=bsClear;
   for R:=1 to Count do
    for C:=1 to Count do
     begin
      X:=(C - 1) * CellWidth + SL;
      Y:=(R - 1) * CellWidth + ST;
      case GM.Field[R, C].State of
       esNumber:Font.Color:=clMaroon;
       esFull:  Font.Color:=clGreen;
       esQuest: Font.Color:=clGray;
      else Continue;
      end;
      TextOut(X + 6, Y - 4, IntToStr(GM.Field[R, C].Number));
      if GM.MTField[R, C].Mistake then Draw(X , Y, MtPNG);
     end;
   Draw(Round(GM.DrawCurPos.X) - 1, Round(GM.DrawCurPos.Y) - 1, CurPNG);
   if ShowKeyboard then
    begin
     Draw(KeyboardPos.X, KeyboardPos.Y, NumPadPNG);
     C:=((SelectedAns.Y - 1) * 3) + SelectedAns.X;
     X:=(KeyboardPos.X) + ((C - 1) mod 3) * KeyWidth;
     Y:=(KeyboardPos.Y) + ((C - 1) div 3) * KeyWidth;
     Draw(X + 2, Y + 2, SelNumPNG);
     X:=(KeyboardPos.X) + ((10 - 1) mod 3) * KeyWidth;
     Y:=(KeyboardPos.Y) + ((10 - 1) div 3) * KeyWidth;
     if QuestKey then Draw(X + 2, Y + 2, SelNumPNG);
    end;
   if GM.Edit then
    begin
     if QuestKey then Draw(Round(GM.EditCell.X * CellWidth + 20), Round(GM.EditCell.Y * CellWidth + 20), EditQPNG)
     else Draw(Round(GM.EditCell.X * CellWidth + 20), Round(GM.EditCell.Y * CellWidth + 20), EditPNG);
     Draw(Round(GM.EditCell.X * CellWidth - 15), Round(GM.EditCell.Y * CellWidth - 15), PenPNG);
    end;
   Brush.Style:=bsClear;
   Font.Color:=clBlack;
   Font.Size:=16;
   Font.Name:='Courier New';
   TextOut(150, 10, 'Судоку');
   Font.Size:=8;
   Brush.Style:=bsSolid;
   Brush.Color:=clGray;
   Draw(0, 380, BottomPNG);
   Brush.Style:=bsClear;
   TextOut(3, 380, '"1..9"   - Генерация головоломки сложности от 1 до 9');
   TextOut(3, 390, '"Пробел" - Генерация головоломки сложности '+IntToStr(GM.Difficult div 10));
   TextOut(3, 400, '"А,В,П"  - Решить головоломку');
   TextOut(3, 410, '"ВВОД"   - Проверить решение "Я" - зафиксировать');
   TextOut(3, 420, '"С"      - Очистить поле');
   TextOut(3, 430, '"Й"      - Остановить обработку');
   TextOut(3, 440, '"Bckspc" - Очистить поле от поставленных цифр');
   if GM.Processing then TextOut(5, 1, 'Подождите. Идёт обработка...');
   TextOut(245, 1, 'Esc, Сложность: '+IntToStr(GM.Difficult div 10));
   if InfoPage1 <> '' then
    begin
     Draw(30, 90, InfoPNG);
     Font.Size:=25;
     TextOut(30 + InfoPNG.Width div 2 - TextWidth(InfoPage1) div 2, 90 + 20, InfoPage1);
     Font.Size:=10;
     TextOut(30 + InfoPNG.Width div 2 - TextWidth(InfoPage2) div 2, 90 + 60, InfoPage2);
    end;
  end;
end;

procedure TSudokuGame.ShowCheckInfo;
begin
 case CheckField of
  0:ShowInfo('Информация', 'Головоломка не решена!');
  1:ShowInfo('Информация', 'Головоломка решена ВЕРНО!');
  2:ShowInfo('Информация', 'Головоломка решена НЕВЕРНО!');
 end;
end;

constructor TSudokuGame.Create;
var R, C:Byte;
begin
 inherited Create('Судоку', HCanvas);
 Difficult:=10;
 try
  GraphicEngine:=TGraphicEngine.Create(HCanvas);
 except
  Ahtung;
 end;
 GraphicEngine.Game:=Self;
 for R:=1 to 9 do
  for C:=1 to 9 do FField[R, C]:=TSudokuElement.Create(Self, Point(R, C));
 SelectedCell:=Point(1, 1);
 MoveTimer:=TTimer.Create(nil);
 with MoveTimer do
  begin
   OnTimer:=MoveTimerTime;
   Name:='MoveTimer';
   Enabled:=True;
   Interval:=4;
  end;
 HideInfo:=TTimer.Create(nil);
 with HideInfo do
  begin
   OnTimer:=HideInfoTime;
   Name:='HideInfo';
   Enabled:=True;
   Interval:=7000;
  end;
end;

procedure TSudokuGame.HideInfoTime(Sender:TObject);
begin
 GraphicEngine.InfoPage1:='';
end;

procedure TSudokuGame.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if PtInRect(GraphicEngine.FieldRect, Point(X, Y)) or PtInRect(GraphicEngine.KeyboardRect, Point(X, Y)) then
  begin
   if Button = mbRight then
    begin
     if (Field[SelectedCell.Y, SelectedCell.X].State <> esNumber) then
      if (not GraphicEngine.ShowKeyboard) then
       begin
        GraphicEngine.ShowKeyboard:=True;
        GraphicEngine.KeyboardRect:=Rect(X, Y, X + GraphicEngine.KeyWidth * 3, Y + GraphicEngine.KeyWidth * 4);
        GraphicEngine.KeyboardPos:=Point(X, Y);
        Edit:=False;
        Exit;
       end;
    end;
   if Button = mbLeft then
    begin
     if (Field[SelectedCell.Y, SelectedCell.X].State <> esNumber) then
      if (not GraphicEngine.ShowKeyboard) then
       begin
        Edit:=True;
        EditCell:=SelectedCell;
        Exit;
       end;
     if PtInRect(GraphicEngine.KeyboardRect, Point(X, Y)) then
      case ((GraphicEngine.SelectedAns.Y - 1) * 3) + GraphicEngine.SelectedAns.X of
       1..9:
        begin
         if not GraphicEngine.QuestKey then Field[SelectedCell.Y, SelectedCell.X].SetFull(((GraphicEngine.SelectedAns.Y - 1) * 3) + GraphicEngine.SelectedAns.X)
         else Field[SelectedCell.Y, SelectedCell.X].SetQuest(((GraphicEngine.SelectedAns.Y - 1) * 3) + GraphicEngine.SelectedAns.X);
         GraphicEngine.ShowKeyboard:=False;
         GraphicEngine.QuestKey:=False;
        end;
       10:GraphicEngine.QuestKey:=not GraphicEngine.QuestKey;
       11:
        begin
         Field[SelectedCell.Y, SelectedCell.X].Delete;
         GraphicEngine.ShowKeyboard:=False;
        end;
       12:
        begin
         GraphicEngine.ShowKeyboard:=False;
         GraphicEngine.QuestKey:=False;
        end;
      end
     else GraphicEngine.ShowKeyboard:=False;
     Edit:=False;
    end;
  end;
end;

procedure TSudokuGame.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
 if PtInRect(GraphicEngine.FieldRect, Point(X, Y)) then
  if not GraphicEngine.ShowKeyboard then
   begin
    SelectedCell:=Point((X - GraphicEngine.ShiftL) div GraphicEngine.CellWidth + 1, (Y - GraphicEngine.ShiftT) div GraphicEngine.CellWidth + 1);
   end;
 if PtInRect(GraphicEngine.KeyboardRect, Point(X, Y)) and (GraphicEngine.ShowKeyboard) then
  with GraphicEngine do
   begin
    SelectedAns:=Point((X - KeyboardPos.X) div KeyWidth + 1, (Y - KeyboardPos.Y) div KeyWidth + 1);
   end;
end;

procedure TGraphicEngine.TimerBGTime(Sender: TObject);
const Count = 100;
var X, Y:Word;
    P1, P2, P0:PByteArray;
begin
 //Увлеичиваем шаг смены фона
 Inc(BGStep);
 //Если последний шаг
 if BGStep >= Count then Exit;
 //Идем по палитре рисунка
 for Y:= 0 to BackGroundDraw.Height - 1 do
  begin
   //Палитра фонового рисунка
   P0:=BackGroundDraw.ScanLine[Y];
   //Палитра первого рисунка
   P1:=BackgroundOne.ScanLine[Y];
   //Палитра второго рисунка
   P2:=BackgroundTwo.ScanLine[Y];
   //Делаем перемешку "линий" первого и второго рисунка в фоновый в зависимости от шага BGStep
   for x:=0 to (BackgroundDraw.Width * 3) - 1 do P0^[X]:=Round((P1^[X] * (Count - BGStep) + P2^[x] * BGStep) / Count);
  end;
end;

procedure TSudokuGame.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TSudokuElement.Delete;
begin
 FNumber:=0;
 FState:=esEmpty;
end;

procedure TSudokuElement.SetNumber(Value:Byte);
begin
 FNumber:=Value;
 FState:=esNumber;
end;

procedure TSudokuElement.SetFull(Value:Byte);
begin
 FNumber:=Value;
 FState:=esFull;   
 if Owner.FieldIsFull then Owner.ShowCheckInfo;
 Owner.MTField[Position.X, Position.Y].Mistake:=not Owner.CheckCell(Position.X, Position.Y, Value);
end;

procedure TSudokuElement.SetQuest(Value:Byte);
begin
 FNumber:=Value;
 FState:=esQuest;
 if Owner.FieldIsFull then Owner.ShowCheckInfo;
 Owner.MTField[Position.X, Position.Y].Mistake:=not Owner.CheckCell(Position.X, Position.Y, Value);
end;

constructor TGameByHemulGM.Create(AGameName:string; HCanvas:TCanvas);
begin
 FGameName:=AGameName;
 FAutor:='Геннадий Малинин';
 FDateStart:='19.07.2013 17:47';
 FCanvas:=HCanvas;
end;

procedure TSudokuElement.SetState(Value:TSudokuElementState);
begin
 case Value of
  esEmpty:FNumber:=0;
 end;
 FState:=Value;
end;

function TSudokuGame.GetCellFieldPos(Cell:TPoint):TPoint;
var Count:Byte;
begin
 Count:=3;
 Result:=Point((Cell.X - 1) div Count + 1, (Cell.Y - 1) div Count + 1);
end;

procedure TSudokuGame.MoveTimerTime(Sender:TObject);
var Spd:Byte;
    b, c:Extended;
begin
 if (SelectedCell.X <> OldSelectedCell.X) or (SelectedCell.Y <> OldSelectedCell.Y) then
  begin
   NewCurPos.X:=GraphicEngine.ShiftL + GraphicEngine.CellWidth * (SelectedCell.X - 1) - 5;
   NewCurPos.Y:=GraphicEngine.ShiftT + GraphicEngine.CellWidth * (SelectedCell.Y - 1) - 5;
   OldCurPos:=DrawCurPos;
   OldSelectedCell:=SelectedCell;
  end;
 b:=Abs(OldCurPos.X - NewCurPos.X);
 c:=Sqrt(Sqr(OldCurPos.X - NewCurPos.X) + Sqr(OldCurPos.Y - NewCurPos.Y));
 Spd:=Round((7/100) * ((c/100) * Sqrt(Sqr(DrawCurPos.X - NewCurPos.X) + Sqr(DrawCurPos.Y - NewCurPos.Y)))) + 1;
 if (DrawCurPos.X >= NewCurPos.X - Spd) and (DrawCurPos.X <= NewCurPos.X + Spd) and
  (DrawCurPos.Y >= NewCurPos.Y - Spd) and (DrawCurPos.Y <= NewCurPos.Y + Spd)
 then
  begin
   DrawCurPos:=NewCurPos;
   Exit;
  end;
 if OldCurPos.X < NewCurPos.X then
  DrawCurPos.X:=DrawCurPos.X + (b/c) * Spd
 else DrawCurPos.X:=DrawCurPos.X - (b/c) * Spd;

 if OldCurPos.Y < NewCurPos.Y then
  DrawCurPos.Y:=DrawCurPos.Y + Sin(ArcCos(b/c)) * Spd
 else DrawCurPos.Y:=DrawCurPos.Y - Sin(ArcCos(b/c)) * Spd;
end;

procedure TSudokuGame.MoveCur(NX, NY:Integer);
begin
 OldCurPos:=NewCurPos;
 DrawCurPos:=OldCurPos;
 NewCurPos:=ExPoint(NX, NY);
 CurPos:=ExPoint(NX, NY);
end;

function TSudokuGame.CheckField:Byte;
var R, C:Byte;
begin
 Result:=0;
 for R:=1 to 9 do
  for C:=1 to 9 do
   begin
    if not CheckCell(R, C, Field[R, C].Number) then
     begin
      Result:=2;
      Exit;
     end;
   end;
 if FieldIsFull then Result:=1;
end;

procedure TSudokuGame.Fill_v1;
var
  NumSet:array[1..9] of set of byte;
  StrSet:array[1..9] of set of byte;
  CelSet:array[1..9] of set of byte;
  i, j, Num, c, R:Byte;
  FPos:TPoint;

function GetNumOfCell(x, y:Byte):Byte;
begin
 Result:=3 * (((x - 1) div 3 + 1) - 1) + (y - 1) div 3 + 1;
end;

procedure Clr;
var n1, n2:Byte;
begin
 for n1:=1 to 9 do
  for n2:=1 to 9 do if Field[n1, n2].State = esFull then Field[n1, n2].Delete;
end;
begin
 Randomize;
 Processing:=True;
 repeat
  for i:=1 to 9 do
   begin
    NumSet[i]:=[];
    StrSet[i]:=[];
    CelSet[i]:=[];
   end;
  Clr;
  for i:=1 to 3 do
   for j:=1 to 3 do
    begin
     FPos:=GetCellFieldPos(Point(j * 3, i * 3));
     FPos.X:=(FPos.X - 1) * 3 + 1;
     FPos.Y:=(FPos.Y - 1) * 3 + 1;
     for R:=FPos.Y to FPos.Y + 2 do
      for C:=FPos.X to FPos.X + 2 do
       begin
        if Field[R, C].State = esEmpty then Continue;
        Include(CelSet[(i - 1) * 3 + j], Field[R, C].Number);
       end;
    end;
  for i:=1 to 9 do
   for j:=1 to 9 do
    begin
     if Field[i, j].State = esEmpty then Continue;
     Include(StrSet[i], Field[i, j].Number);
    end;
  for j:=1 to 9 do
   for i:=1 to 9 do
    begin
     if Field[i, j].State = esEmpty then Continue;
     Include(NumSet[j], Field[i, j].Number);
    end;
  Application.ProcessMessages;
  if not Processing then Exit;
  for i:=1 to 9 do
   begin
    for j:=1 to 9 do
     begin
      SelectedCell:=Point(j ,i);
      c:=0;
      if Field[i, j].State <> esEmpty then Continue;
      repeat
       Inc(c);
       Num:=Random(9) + 1;
      until ((not (Num in NumSet[j])) and (not (Num in StrSet[i])) and (not (Num in CelSet[GetNumOfCell(i, j)]))) or (c >= 20);
      if c >= 20 then Break;
      Include(NumSet[j], Num);
      Include(StrSet[i], Num);
      Include(CelSet[GetNumOfCell(i, j)], Num);
      Field[i, j].SetFull(Num);
      Application.ProcessMessages;
      if not Processing then Exit;
      //Sleep(20);
     end;
    if c >= 20 then Break;
   end;
  if c < 20 then Break;
 until False;
 Processing:=False;
end;

procedure TSudokuGame.Fill_v2;
var i, j, Number, CountPoss:Byte;
    Nums:array[1..9, 1..9, 1..9, 1..2] of Byte;
    WasInsert, Level:Byte;
    LastInsertQ:array[1..81] of TPoint;
    WasLvl:Boolean;
label
  Step1, Step2;

procedure Undo;
var x:Byte;
begin
 for x:=1 to 81 do
  begin
   if LastInsertQ[x].X > 0 then
    Field[LastInsertQ[x].X, LastInsertQ[x].Y].Delete;
   LastInsertQ[x].X:=0;
  end;
end;

procedure Add(Nm:TPoint);
var x:Byte;
begin
 for x:=1 to 81 do
  if LastInsertQ[x].X = 0 then
   begin
    LastInsertQ[x]:=Nm;
    Break;
   end;
end;

procedure Clr;
var x:Byte;
begin
 for x:=1 to 81 do LastInsertQ[x].X:=0;
end;
begin
 if CheckField = 1 then Exit;
 Processing:=True;
 Clr;
 //Первый шаг: Вставка единственного возможного
Step1:
 repeat
  WasInsert:=0;
  for i:=1 to 9 do
   for j:=1 to 9 do
    begin
     SelectedCell:=Point(j ,i);
     if Field[i, j].State <> esEmpty then Continue;
     CountPoss:=0;
     for Number:=1 to 9 do
      begin
       Nums[i, j, Number, 1]:=Number;
       Nums[i, j, Number, 2]:=0;
       if CheckCell(i, j, Number) then
        begin
         Nums[i, j, Number, 2]:=1;
         Inc(CountPoss);
        end;
      end;
     if CountPoss = 0 then
      begin
       Undo;
       goto Step2;
      end;
     if CountPoss = 1 then
      for Number:=1 to 9 do
       begin
        if Nums[i, j, Number, 2] = 1 then
         begin
          Field[i, j].SetFull(Nums[i, j, Number, 1]);
          Add(Point(i, j));
          Inc(WasInsert);
          Break;
         end;
       end;
     Application.ProcessMessages;
     if not Processing then Exit;
    end;
 until WasInsert = 0;
 if CheckField = 1 then
  begin
   Processing:=False;
   Exit;
  end;
Step2:
 //Второй шаг: вставка наиболее вероятного
 WasLvl:=False;
 for Level:=2 to 9 do
 repeat
  for i:=1 to 9 do
   for j:=1 to 9 do
    begin
     SelectedCell:=Point(j, i);
     if Field[i, j].State <> esEmpty then Continue;
     CountPoss:=0;
     for Number:=1 to 9 do Inc(CountPoss, Nums[i, j, Number, 2]);
     if CountPoss = Level then
      begin
       for Number:=1 to 9 do
        begin
         if Nums[i, j, Number, 2] = 1 then
          begin
           Field[i, j].SetQuest(Nums[i, j, Number, 1]);
           Nums[i, j, Number, 2]:=0;
           Add(Point(i, j));
           goto Step1;
           Break;
          end;
        end;
       WasLvl:=True;
      end;
     Application.ProcessMessages;
     if not Processing then Exit;
    end;
 until not WasLvl;
 Processing:=False;
end;

procedure TSudokuGame.Fill_v3;
var i, j, Number, CountPoss:Byte;
    Nums:array[1..9, 1..9, 1..9, 1..2] of Byte;
    WasInsert:Byte;
    NumSet:array[1..9] of set of byte;
    StrSet:array[1..9] of set of byte;
    CelSet:array[1..9] of set of byte;
    Num, c, R:Byte;
    FPos:TPoint;

function GetNumOfCell(x, y:Byte):Byte;
begin
 Result:=3 * (((x - 1) div 3 + 1) - 1) + (y - 1) div 3 + 1;
end;

procedure Clr;
var n1, n2:Byte;
begin
 for n1:=1 to 9 do
  for n2:=1 to 9 do if Field[n1, n2].State = esFull then Field[n1, n2].Delete;
end;

begin
 if CheckField = 1 then Exit;
 Processing:=True;
 //Первый шаг: Вставка единственного возможного
 repeat
  WasInsert:=0;
  for i:=1 to 9 do
   for j:=1 to 9 do
    begin
     SelectedCell:=Point(j ,i);
     if Field[i, j].State <> esEmpty then Continue;
     CountPoss:=0;
     for Number:=1 to 9 do
      begin
       Nums[i, j, Number, 1]:=Number;
       Nums[i, j, Number, 2]:=0;
       if CheckCell(i, j, Number) then
        begin
         Nums[i, j, Number, 2]:=1;
         Inc(CountPoss);
        end;
      end;
     if CountPoss = 1 then
      for Number:=1 to 9 do
       begin
        if Nums[i, j, Number, 2] = 1 then
         begin
          Field[i, j].SetFull(Nums[i, j, Number, 1]);
          Inc(WasInsert);
          Break;
         end;
       end;
     Application.ProcessMessages;
     if not Processing then Exit;
    end;
 until WasInsert = 0;
 if CheckField = 1 then
  begin
   Processing:=False;
   Exit;
  end;
 for i:=1 to 9 do
  for j:=1 to 9 do if Field[i, j].State = esFull then Field[i, j].State:=esNumber;
  repeat
  for i:=1 to 9 do
   begin
    NumSet[i]:=[];
    StrSet[i]:=[];
    CelSet[i]:=[];
   end;
  Clr;
  for i:=1 to 3 do
   for j:=1 to 3 do
    begin
     FPos:=GetCellFieldPos(Point(j * 3, i * 3));
     FPos.X:=(FPos.X - 1) * 3 + 1;
     FPos.Y:=(FPos.Y - 1) * 3 + 1;
     for R:=FPos.Y to FPos.Y + 2 do
      for C:=FPos.X to FPos.X + 2 do
       begin
        if Field[R, C].State = esEmpty then Continue;
        Include(CelSet[(i - 1) * 3 + j], Field[R, C].Number);
       end;
    end;
  for i:=1 to 9 do
   for j:=1 to 9 do
    begin
     if Field[i, j].State = esEmpty then Continue;
     Include(StrSet[i], Field[i, j].Number);
    end;
  for j:=1 to 9 do
   for i:=1 to 9 do
    begin
     if Field[i, j].State = esEmpty then Continue;
     Include(NumSet[j], Field[i, j].Number);
    end;

  for i:=1 to 9 do
   begin
    for j:=1 to 9 do
     begin
      c:=0;
      if Field[i, j].State <> esEmpty then Continue;
      repeat
       Inc(c);
       Num:=Random(9) + 1;
      until ((not (Num in NumSet[j])) and (not (Num in StrSet[i])) and (not (Num in CelSet[GetNumOfCell(i, j)]))) or (c >= 20);
      if c >= 20 then Break;
      Include(NumSet[j], Num);
      Include(StrSet[i], Num);
      Include(CelSet[GetNumOfCell(i, j)], Num);
      Field[i, j].SetFull(Num);
      Application.ProcessMessages;
      if not Processing then Exit;
     end;
    if c >= 20 then Break;
   end;
  if c < 20 then Break;
 until False;
 Processing:=False;
end;

procedure TSudokuGame.ShowInfo(Cap, Text:string);
begin
 GraphicEngine.InfoPage2:=Text;
 GraphicEngine.InfoPage1:=Cap;
end;

//Проверить клетку на верность правилу
function TSudokuGame.CheckCell(AR, AC, ANum:Byte):Boolean;
var R, C, Count:Byte;
    FPos:TPoint;
begin
 Result:=False;
 Count:=9;
 FPos:=GetCellFieldPos(Point(AC, AR));
 FPos.X:=(FPos.X - 1) * (Count div 3) + 1;
 FPos.Y:=(FPos.Y - 1) * (Count div 3) + 1;

 for R:=FPos.Y to FPos.Y + ((Count div 3) - 1) do
  for C:=FPos.X to FPos.X + ((Count div 3) - 1) do
   begin
    if (R = AR) and (C = AC) then Continue;
    if Field[R, C].State = esEmpty then Continue;
    if ANum = Field[R, C].Number then Exit;
   end;

 for R:=1 to Count do
  begin
   if R = AR then Continue;
   if Field[R, AC].State = esEmpty then Continue;
   if ANum = Field[R, AC].Number then Exit;
  end;

 for C:=1 to Count do
  begin
   if C = AC then Continue;
   if Field[AR, C].State = esEmpty then Continue;
   if ANum = Field[AR, C].Number then Exit;
  end;
 Result:=True;
end;

function TSudokuGame.FieldIsFull:Boolean;
var R, C, Count:Byte;
begin
 Result:=False;
 Count:=9;
 for R:=1 to Count do
  for C:=1 to Count do if Field[R, C].State = esEmpty then Exit;
 Result:=True;
end;

//Заполнение поля по правилу "Судоку"
procedure TSudokuGame.FillField;
var
  NumSet:array[1..9] of set of byte;
  StrSet:array[1..9] of set of byte;
  CelSet:array[1..9] of set of byte;
  i, j, Num, c:Byte;

function GetNumOfCell(x, y:Byte):Byte;
begin
 Result:=3 * (((x - 1) div 3 + 1) - 1) + (y - 1) div 3 + 1;
end;
begin
 Randomize;
 repeat
  for i:=1 to 9 do
   begin
    NumSet[i]:=[];
    StrSet[i]:=[];
    CelSet[i]:=[];
   end;
  for i:=1 to 9 do
   begin
    for j:=1 to 9 do
     begin
      c:=0;
      repeat
       Inc(c);
       Num:=Random(9) + 1;
      until ((not (Num in NumSet[j])) and (not (Num in StrSet[i])) and (not (Num in CelSet[GetNumOfCell(i, j)]))) or (c >= 20);
      if c >= 20 then Break;
      Include(NumSet[j], Num);
      Include(StrSet[i], Num);
      Include(CelSet[GetNumOfCell(i, j)], Num);
      Field[i, j].SetNumber(Num);
     end;
    if c >= 20 then Break;
   end;
  if c < 20 then Break;
 until False;
end;

procedure TSudokuGame.Fix;
var n1, n2:Byte;
begin
 for n1:=1 to 9 do
  for n2:=1 to 9 do if Field[n1, n2].State <> esEmpty then Field[n1, n2].State:=esNumber;
end;

//Установка сложности (1-10)
function TSudokuGame.SetFieldDif(Dif:Byte):Byte;
var Empty, Count, WasDo, x, y:integer;
begin
 //1 - 10 = 10% - 80%
 if (Dif < 10) or (Dif > 90) then Dif:=10;
 Count:=81;
 Empty:=Round((Count / 100) * Dif);
 WasDo:=0;
 Count:=Round(Sqrt(Count));
 repeat
  repeat
   x:=Random(Count) + 1;
   y:=Random(Count) + 1;
  until (Field[x, y].State <> esEmpty);
  Inc(WasDo);
  Field[x, y].Delete;
 until Empty = WasDo;
 Result:=Dif;
end;

procedure TSudokuGame.Clear;
var R, C:Byte;
begin
 for R:=1 to 9 do
  for C:=1 to 9 do
   begin
    MTField[R, C].Mistake:=False;
    Field[R, C].Delete;
   end;
end;

procedure TSudokuGame.ClearFull;
var n1, n2:Byte;
begin
 for n1:=1 to 9 do
  for n2:=1 to 9 do
   begin
    if Field[n1, n2].State <> esNumber then Field[n1, n2].Delete;
    MTField[n1, n2].Mistake:=False;
   end;
end;

//Создание игрового поля "Судоку"
procedure TSudokuGame.CreateField(Dif:Byte);
begin
 //ShowMessage(FloatToStr(RadToDeg(ArcCos(4/Sqrt(32)))));
 Clear;
 //Заполним поле случайным образом, но в соответствии с правилом "Судоку"
 FillField;
 //Установим сложность
 Difficult:=SetFieldDif(Dif);
end;

end.
