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
  DN.Command.Switch.Types in 'DN.Command.Switch.Types.pas',
  DN.Command.Switch.Dependencies in 'DN.Command.Switch.Dependencies.pas',
  DN.Setup.Dependency.Intf in '..\..\DN.Setup.Dependency.Intf.pas',
  DN.Setup.Dependency in '..\..\DN.Setup.Dependency.pas',
  DN.Setup.Dependency.Processor.Intf in '..\..\DN.Setup.Dependency.Processor.Intf.pas',
  DN.Setup.Dependency.Processor in '..\..\DN.Setup.Dependency.Processor.pas',
  DN.Setup.Dependency.Resolver.Install in '..\..\DN.Setup.Dependency.Resolver.Install.pas',
  DN.Setup.Dependency.Resolver.Intf in '..\..\DN.Setup.Dependency.Resolver.Intf.pas',
  DN.Setup.Dependency.Resolver.UnInstall in '..\..\DN.Setup.Dependency.Resolver.UnInstall.pas',
  DN.Command.Switch.IgnoreDependencies in 'DN.Command.Switch.IgnoreDependencies.pas';

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
