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
  DN.Command.Help in '..\DN.Command.Help.pas',
  DN.Command.Install in '..\DN.Command.Install.pas',
  DN.Command.Environment.Intf in '..\DN.Command.Environment.Intf.pas',
  DN.Command.Environment in '..\DN.Command.Environment.pas',
  DN.Command.Default in '..\DN.Command.Default.pas',
  DN.Command.Exit in '..\DN.Command.Exit.pas',
  DN.Command.List in '..\DN.Command.List.pas',
  DN.Command.Switch.Delphi in '..\DN.Command.Switch.Delphi.pas',
  DN.EnvironmentOptions.Registry in '..\..\..\DN.EnvironmentOptions.Registry.pas',
  DN.EnvironmentOptions in '..\..\..\DN.EnvironmentOptions.pas',
  DN.BPLService.Registry in '..\..\..\DN.BPLService.Registry.pas',
  DN.Command.Uninstall in '..\DN.Command.Uninstall.pas',
  DN.VariableResolver.Compiler.Factory in '..\..\..\DN.VariableResolver.Compiler.Factory.pas',
  DN.Package.Finder.Intf in '..\..\..\DN.Package.Finder.Intf.pas',
  DN.Package.Finder in '..\..\..\DN.Package.Finder.pas',
  DN.Package.Version.Finder.Intf in '..\..\..\DN.Package.Version.Finder.Intf.pas',
  DN.Package.Version.Finder in '..\..\..\DN.Package.Version.Finder.pas',
  DN.Command.Info in '..\DN.Command.Info.pas',
  DN.Command.Switch.Versions in '..\DN.Command.Switch.Versions.pas',
  DN.Command.Switch.License in '..\DN.Command.Switch.License.pas',
  DN.Command.Update in '..\DN.Command.Update.pas',
  DN.TextTable in '..\..\..\DN.TextTable.pas',
  DN.TextTable.Intf in '..\..\..\DN.TextTable.Intf.pas';

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
