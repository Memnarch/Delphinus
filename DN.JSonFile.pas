{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile;

interface

uses
  DN.JSon;

type
  TJSonFile = class
  protected
    procedure Load(const ARoot: TJSONObject); virtual;
    procedure Save(const ARoot: TJSONObject); virtual;
    procedure WriteString(AParent: TJSONObject; const AProperty, AContent: string);
    procedure WritePath(AParent: TJSonObject; const AProperty: string; const AContent: string);
    procedure WriteInteger(AParent: TJSONObject; const AProperty: string; AContent: Integer);
    procedure WriteBoolean(AParent: TJSONObject; const AProperty: string; AValue: Boolean);
    procedure WriteFloat(AParent: TJSonObject; const AProperty: string; AValue: Single);
    function WriteArray(AParent: TJSONObject; const AArrayName: string): TJSONArray;
    function WriteObject(AParent: TJSONObject; const AObjectName: string): TJSONObject;
    function WriteArrayObject(AParent: TJSONArray): TJSONObject;
    function ReadString(AParent: TJSONObject; const AProperty: string; const ADefault: string = ''): string;
    function ReadInteger(AParent: TJSONObject; const AProperty: string; const ADefault: Integer = 0): Integer;
    function ReadFloat(AParent: TJSonObject; const AProperty: string; const ADefault: Single = 0): Single;
    function ReadBoolean(AParent: TJSonObject; const AProperty: string; ADefault: Boolean = False): Boolean;
    function ReadObject(AParent: TJSONObject; const AProperty: string; var AObject: TJSonObject): Boolean;
    function ReadArray(AParent: TJSonObject; const AProperty: string; var AArray: TJSONArray): Boolean;
    function ReadJSOnValue(AParent: TJSOnObject; const AProperty: string; var AValue: TJSonValue): Boolean;
    function EscapeQuotes(const AString: string): string;
    function UnescapeQuotes(const AString: string): string;
  public
    function LoadFromFile(const AFileName: string): Boolean;
    procedure SaveToFile(const AFileName: string);
    function LoadFromString(const AText: string): Boolean;
    function ToString: string; override;
  end;

implementation

uses
  Classes,
  SysUtils;

var
  GJSonFormatSettings: TFormatSettings;

{ TJSonFile }

function TJSonFile.EscapeQuotes(const AString: string): string;
begin
  Result := StringReplace(AString, '"', '\"', [rfReplaceAll]);
end;

procedure TJSonFile.Load(const ARoot: TJSONObject);
begin

end;

function TJSonFile.LoadFromFile(const AFileName: string): Boolean;
var
  LData: TStringStream;
begin
  LData := TStringStream.Create();
  try
    LData.LoadFromFile(AFileName);
    Result := LoadFromString(LData.DataString);
  finally
    LData.Free;
  end;
end;

function TJSonFile.LoadFromString(const AText: string): Boolean;
var
  LRoot: TJSONObject;
begin
  LRoot := TJSONObject.ParseJSONValue(AText) as TJSonObject;
  Result := Assigned(LRoot);
  if Result then
  begin
    try
      Load(LRoot);
    finally
      LRoot.Free;
    end;
  end;
end;

function TJSonFile.ReadArray(AParent: TJSonObject; const AProperty: string;
  var AArray: TJSONArray): Boolean;
var
  LValue: TJSONValue;
begin
  Result := ReadJSOnValue(AParent, AProperty, LValue) and (LValue is TJSONArray);
  AArray := TJSONArray(LValue);
end;

function TJSonFile.ReadBoolean(AParent: TJSonObject; const AProperty: string;
  ADefault: Boolean): Boolean;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if ReadJSOnValue(AParent, AProperty, LValue) then
    if LValue is TJSONTrue then
      Result := True
    else if LValue is TJSONFalse then
      Result := False;
end;

function TJSonFile.ReadFloat(AParent: TJSonObject; const AProperty: string;
  const ADefault: Single): Single;
begin
  if not TryStrToFloat(ReadString(AParent, AProperty), Result, GJSonFormatSettings) then
  Result := ADefault;
end;

function TJSonFile.ReadInteger(AParent: TJSONObject; const AProperty: string;
  const ADefault: Integer): Integer;
begin
  Result := StrToInt(ReadString(AParent, AProperty, IntToStr(ADefault)));
end;

function TJSonFile.ReadJSOnValue(AParent: TJSOnObject; const AProperty: string;
  var AValue: TJSonValue): Boolean;
begin
  AValue := AParent.GetValue(AProperty);
  Result := Assigned(AValue);
end;

function TJSonFile.ReadObject(AParent: TJSONObject; const AProperty: string;
  var AObject: TJSonObject): Boolean;
var
  LValue: TJSONValue;
begin
  Result := ReadJSOnValue(AParent, AProperty, LValue) and (LValue is TJSonObject);
  AObject := TJSONObject(LValue);
end;

function TJSonFile.ReadString(AParent: TJSONObject; const AProperty,
  ADefault: string): string;
var
  LValue: TJSONValue;
begin
  if ReadJSOnValue(AParent, AProperty, LValue) then
    Result := LValue.Value
  else
    Result := ADefault;

  {$if CompilerVersion < 23}
  Result := UnescapeQuotes(Result);
  {$IfEnd}
end;

procedure TJSonFile.Save(const ARoot: TJSONObject);
begin

end;

procedure TJSonFile.SaveToFile(const AFileName: string);
var
  LData: TStringStream;
begin
  LData := TStringStream.Create();
  try
    LData.WriteString(ToString);
    LData.SaveToFile(AFileName);
  finally
    LData.Free;
  end;
end;

function TJSonFile.ToString: string;
var
  LRoot: TJSONObject;
begin
  LRoot := TJSONObject.Create();
  try
    Save(LRoot);
    Result := LRoot.ToString;
  finally
    LRoot.Free;
  end;
end;

function TJSonFile.UnescapeQuotes(const AString: string): string;
begin
  Result := StringReplace(AString, '\"', '"', [rfReplaceAll]);
end;

function TJSonFile.WriteArray(AParent: TJSONObject;
  const AArrayName: string): TJSONArray;
begin
  Result := TJSONArray.Create();
  AParent.AddPair(AArrayName, Result);
end;

function TJSonFile.WriteArrayObject(AParent: TJSONArray): TJSONObject;
begin
  Result := TJSONObject.Create();
  AParent.AddElement(Result);
end;

procedure TJSonFile.WriteBoolean(AParent: TJSONObject; const AProperty: string;
  AValue: Boolean);
begin
  if AValue then
    AParent.AddPair(AProperty, TJSONTrue.Create())
  else
    AParent.AddPair(AProperty, TJSONFalse.Create())
end;

procedure TJSonFile.WriteFloat(AParent: TJSonObject; const AProperty: string;
  AValue: Single);
begin
  WriteString(AParent, AProperty, FloatToStr(AValue));
end;

procedure TJSonFile.WriteInteger(AParent: TJSONObject; const AProperty: string;
  AContent: Integer);
begin
  WriteString(AParent, AProperty, IntToStr(AContent));
end;

function TJSonFile.WriteObject(AParent: TJSONObject;
  const AObjectName: string): TJSONObject;
begin
  Result := TJSONObject.Create();
  AParent.AddPair(AObjectName, Result);
end;

procedure TJSonFile.WritePath(AParent: TJSonObject; const AProperty,
  AContent: string);
begin
  //Before 10.3 Tokyo, escaping strings doesn't seem to work properly
  {$if CompilerVersion < 33}
    WriteString(AParent, AProperty, StringReplace(AContent, '\', '\\', [rfReplaceAll]));
  {$Else}
    WriteString(AParent, AProperty, AContent);
  {$IfEnd}
end;

procedure TJSonFile.WriteString(AParent: TJSONObject; const AProperty,
  AContent: string);
begin
  {$if CompilerVersion < 23}
  AParent.AddPair(AProperty, EscapeQuotes(AContent));
  {$Else}
  AParent.AddPair(AProperty, TJSONString.Create(AContent));
  {$IfEnd}
end;

initialization
  GJSonFormatSettings := TFormatSettings.Create();
  GJSonFormatSettings.DecimalSeparator := '.';

end.
