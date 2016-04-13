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

uses
  TestInsight.DUnit,
  Tests.VariableResolver in 'Tests.VariableResolver.pas';

{$R *.RES}

begin
  RunRegisteredTests();
end.

