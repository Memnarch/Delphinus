unit DN.IOUtils;

interface

uses
  IOUtils;

//XE5 or later
{$IF CompilerVersion > 25}
  {$Define SupportsCachePath}
{$IfEnd}

type
  TPath = IOUtils.TPath;

  {$IFNDEF SupportsCachePath}
  TPathHelper = record helper for TPath
    class function GetCachePath: string; static;
  end;
  {$EndIf}


implementation

uses
  Windows, SHFolder;

{ TPathHelper }

{$IFNDEF SupportsCachePath}
class function TPathHelper.GetCachePath: string;
var
  LPath: array[0..MAX_PATH] of Char;
begin
  Result := '';
  ZeroMemory(@LPath[0], Length(LPath)*SizeOf(Char));
  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA , 0, 0, @LPath) = S_OK then
    Result := LPath;
end;
{$EndIf}

end.
