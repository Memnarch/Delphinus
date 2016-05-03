unit DN.DPM;

interface

type
  TDPM = class
  private
    function GetCommandLine: string;
  public
    procedure Run;
  end;

implementation

uses
  SysUtils,
  DN.Command.Argument.Parser,
  DN.Command.Argument.Parser.Intf,
  DN.Command.Argument,
  DN.Command.Argument.Intf;

{ TDPM }

function TDPM.GetCommandLine: string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to ParamCount do
    Result := Result + ' "' + ParamStr(i) + '"';
end;

procedure TDPM.Run;
var
  LLine: string;
  LParser: IDNCommandArgumentParser;
  LCommand: IDNCommandArgument;
  LSwitch: IDNCommandSwitchArgument;
  i: Integer;
begin
  LLine := GetCommandLine();
  LParser := TDNCommandArgumentParser.Create();
  LCommand := LParser.FromText(LLine);

  WriteLn('Name: ' + LCommand.Name);
  for i := 0 to High(LCommand.Parameters) do
    WriteLn('P' + IntToStr(i) + ': ' + LCommand.Parameters[i]);

  for LSwitch in LCommand.Switches do
  begin
    WriteLn('Name: ' + LSwitch.Name);
    for i := 0 to High(LSwitch.Parameters) do
      WriteLn('P' + IntToStr(i) + ': ' + LSwitch.Parameters[i]);
  end;
end;

end.
