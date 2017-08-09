program Sudoku;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  SudokuGameEngine in 'SudokuGameEngine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
