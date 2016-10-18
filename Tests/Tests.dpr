program Tests;

{$R *.dres}
{$DEFINE LEAKCHECK}

uses
{$IFDEF LEAKCHECK}
  LeakCheck,
  LeakCheck.DUnit,
  TestFramework in '..\..\LeakCheck\External\DUnit\TestFramework.pas',
  Graphics,
  SysUtils,
{$ENDIF}

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

begin
{$IFDEF LEAKCHECK}
  // init some global instances so LeakCheck does not report them
  TPicture.Create.Free;
  TEncoding.IsStandardEncoding(nil);
{$ENDIF}
  RunRegisteredTests();
end.

