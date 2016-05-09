program DPM;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  DN.DPM in '..\DN.DPM.pas',
  DN.Command.Argument.Parser in '..\DN.Command.Argument.Parser.pas',
  DN.Command.Argument.Parser.Intf in '..\DN.Command.Argument.Parser.Intf.pas',
  DN.Command.Argument in '..\DN.Command.Argument.pas',
  DN.Command.Argument.Intf in '..\DN.Command.Argument.Intf.pas',
  DN.Command in '..\DN.Command.pas',
  DN.Command.Switch in '..\DN.Command.Switch.pas',
  DN.Command.Dispatcher in '..\DN.Command.Dispatcher.pas',
  DN.Command.Dispatcher.Intf in '..\DN.Command.Dispatcher.Intf.pas',
  DN.Command.Help in '..\DN.Command.Help.pas';

var
  GDPM: TDPM;

begin
  try
    GDPM := TDPM.Create();
    try
      GDPM.Run();
    finally
      GDPM.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
