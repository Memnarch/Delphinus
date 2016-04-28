program VerScheme;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  DN.Version in '..\..\DN.Version.pas';


procedure PrintVersion(const AVersion: TDNVersion);
begin
  WriteLn('Major: ' + IntToStr(AVersion.Major));
  WriteLn('Minor: ' + IntToStr(AVersion.Minor));
  WriteLn('Patch: ' + IntToStr(AVersion.Patch));
  WriteLn('PreReleaseLabel: ' + AVersion.PreReleaseLabel);
  WriteLn('Stable: ' + BoolToStr(AVersion.IsStable, True));
  WriteLn('Cleaned: ' + AVersion.ToString);
end;

function GetOperator(AResult: Integer): string;
begin
  if AResult = 0 then
    Result := '='
  else if AResult < 0 then
    Result := '<'
  else
    Result := '>';
end;

var
  GLeft, GRight: TDNVersion;

begin
  try
    if ParamCount > 2 then
    begin
      Writeln('Expected a maximum of 2 parameters!');
      Exit;
    end;

    GLeft := TDNVersion.Parse(ParamStr(1));
    PrintVersion(GLeft);
    if ParamCount = 2 then
    begin
      WriteLn('');
      GRight := TDNVersion.Parse(ParamStr(2));
      PrintVersion(GRight);
      Writeln('');
      Writeln(GLeft.ToString + ' ' + GetOperator(GLeft.Compare(GRight)) + ' ' + GRight.ToString);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
