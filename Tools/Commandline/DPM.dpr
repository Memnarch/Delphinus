program DPM;

{$APPTYPE CONSOLE}

{$R 'DPM.res' 'DPM.rc'}
{$R *.dres}

uses
  SysUtils,
  DN.DPM in 'DN.DPM.pas',
  DN.Command.Argument.Parser in 'DN.Command.Argument.Parser.pas',
  DN.Command.Argument.Parser.Intf in 'DN.Command.Argument.Parser.Intf.pas',
  DN.Command.Argument in 'DN.Command.Argument.pas',
  DN.Command.Argument.Intf in 'DN.Command.Argument.Intf.pas',
  DN.Command in 'DN.Command.pas',
  DN.Command.Switch in 'DN.Command.Switch.pas',
  DN.Command.Dispatcher in 'DN.Command.Dispatcher.pas',
  DN.Command.Dispatcher.Intf in 'DN.Command.Dispatcher.Intf.pas',
  DN.Command.Help in 'DN.Command.Help.pas',
  DN.Command.Install in 'DN.Command.Install.pas',
  DN.Command.Environment.Intf in 'DN.Command.Environment.Intf.pas',
  DN.Command.Environment in 'DN.Command.Environment.pas',
  DN.Command.Default in 'DN.Command.Default.pas',
  DN.Command.Exit in 'DN.Command.Exit.pas',
  DN.Command.List in 'DN.Command.List.pas',
  DN.Command.Switch.Delphi in 'DN.Command.Switch.Delphi.pas',
  DN.Command.Uninstall in 'DN.Command.Uninstall.pas',
  DN.Command.Info in 'DN.Command.Info.pas',
  DN.Command.Switch.Versions in 'DN.Command.Switch.Versions.pas',
  DN.Command.Switch.License in 'DN.Command.Switch.License.pas',
  DN.Command.Update in 'DN.Command.Update.pas',
  DN.Command.DelphiBlock in 'DN.Command.DelphiBlock.pas',
  DN.Command.About in 'DN.Command.About.pas',
  DN.Command.Delphis in 'DN.Command.Delphis.pas',
  DN.Command.Switch.PanicOnError in 'DN.Command.Switch.PanicOnError.pas',
  DN.Command.Types in 'DN.Command.Types.pas',
  DN.Command.Switch.Types in 'DN.Command.Switch.Types.pas';

var
  GDPM: TDPM;

begin
  try
    GDPM := TDPM.Create();
    try
      ExitCode := GDPM.Run();
    finally
      GDPM.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
