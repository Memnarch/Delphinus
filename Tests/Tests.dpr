program Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
  {$IFNDEF TESTINSIGHT}
    {$APPTYPE CONSOLE}
  {$ENDIF}
{$ENDIF}

{$R *.dres}

uses
  TestInsight.DUnit,
  Tests.VariableResolver in 'Tests.VariableResolver.pas',
  Tests.Installer in 'Tests.Installer.pas',
  Tests.Installer.Interceptor in 'Tests.Installer.Interceptor.pas',
  Tests.Mocks.Compiler in 'Tests.Mocks.Compiler.pas',
  Tests.Data in 'Tests.Data.pas',
  Tests.Mocks.Projects in 'Tests.Mocks.Projects.pas',
  Tests.Uninstaller.Interceptor in 'Tests.Uninstaller.Interceptor.pas',
  Tests.Uninstaller in 'Tests.Uninstaller.pas',
  Tests.Version in 'Tests.Version.pas',
  DN.Version in '..\DN.Version.pas',
  Tests.Mocks.VariableResolver in 'Tests.Mocks.VariableResolver.pas',
  Tests.SetupDependencyResolver.Install in 'Tests.SetupDependencyResolver.Install.pas',
  Tests.Mocks.Package in 'Tests.Mocks.Package.pas',
  Tests.SetupDependencyResolver.Uninstall in 'Tests.SetupDependencyResolver.Uninstall.pas';

{$R *.RES}

begin
  RunRegisteredTests();
end.

