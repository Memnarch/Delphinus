unit DN.Utils;

interface

uses
  DN.Types;

function GetDelphiName(const ACompilerVersion: TCompilerVersion): string;
function GenerateSupportsString(const AMin, AMax: TCompilerVersion): string;
function GeneratePlatformString(APlatforms: TDNCompilerPlatforms; const ASeperator: string = ', '): string;

const
  TDNCompilerTargetName: array[Low(TDNCompilerTarget)..High(TDNCompilerTarget)] of string = ('Build', 'Compile');
  TDNCompilerConfigName: array[Low(TDNCompilerConfig)..High(TDNCompilerConfig)] of string = ('Release', 'Debug');
  TDNCompilerPlatformName: array[Low(TDNCompilerPlatform)..High(TDNCompilerPlatform)] of string = ('Win32', 'Win64', 'OSX32', 'Android', 'IOSDevice32', 'IOSDevice64', 'Linux64');

function TryPlatformNameToCompilerPlatform(const AName: string; out APlatform: TDNCompilerPlatform): Boolean;


implementation

uses
  SysUtils;

const
  CDelphiNames: array[9..33] of string =
  ('2', '3', '3', '4', '5', '6', '7', '8', '2005', '2006', '2007', '2009', '2010',
   'XE', 'XE2', 'XE3', 'XE4', 'XE5', 'XE6', 'XE7', 'XE8', 'Seattle', 'Berlin', 'Tokyo', 'Rio');

function GetDelphiName(const ACompilerVersion: TCompilerVersion): string;
var
  LVersion: Integer;
begin
  LVersion := Trunc(ACompilerVersion);
  if (LVersion >= Low(CDelphiNames)) and (LVersion <= High(CDelphiNames)) then
  begin
    Result := CDelphiNames[LVersion];
  end
  else
  begin
    Result := 'Compiler ' + IntToStr(LVersion);
  end;
end;

function GenerateSupportsString(const AMin, AMax: TCompilerVersion): string;
begin
  if AMin > 0 then
  begin
    if (AMax - AMin) =  0 then
      Result := 'Delphi ' + GetDelphiName(AMin)
    else if (AMax < AMin) then
      Result := 'Delphi ' + GetDelphiName(AMin) + ' and newer'
    else
      Result := 'Delphi ' + GetDelphiName(AMin) + ' to ' + GetDelphiName(AMax);
  end
  else
  begin
    Result := 'Unspecified';
  end;
end;

function GeneratePlatformString(APlatforms: TDNCompilerPlatforms; const ASeperator: string = ', '): string;
var
  LPlatform: TDNCompilerPlatform;
  LRequiresSeperator: Boolean;
begin
  Result := '';
  LRequiresSeperator := False;
  for LPlatform in APlatforms do
  begin
    if LRequiresSeperator then
      Result := Result + ASeperator;

    Result := Result + TDNCompilerPlatformName[LPlatform];
    LRequiresSeperator := True;
  end;
end;

function TryPlatformNameToCompilerPlatform(const AName: string; out APlatform: TDNCompilerPlatform): Boolean;
var
  LPlatform: TDNCompilerPlatform;
begin
  for LPlatform := Low(TDNCompilerPlatformName) to High(TDNCompilerPlatformName) do
    if SameText(TDNCompilerPlatformName[LPlatform], AName) then
    begin
      APlatform := LPlatform;
      Exit(True);
    end;

  Result := False;
end;

end.
