unit DN.JSon;

interface

{$if CompilerVersion >= 27}
  {$Define DelphiXe6_Up}
{$IfEnd}

uses
  {$IfDef DelphiXe6_Up }
  JSon;
  {$Else}
  DBXJSon;
  {$EndIf}

type
  {$IfDef DelphiXe6_Up}
  TJSONAncestor = JSon.TJSonAncestor;
  TJSONByteReader = JSon.TJSONByteReader;
  EJSONException = JSon.EJSONException;
  TJSONPair = JSon.TJSONPair;
  TJSONValue = JSon.TJSONValue;
  TJSONTrue = JSon.TJSONTrue;
  TJSONFalse = JSon.TJSONFalse;
  TJSONString = JSon.TJSONString;
  TJSONNumber = JSon.TJSONNumber;
  TJSONObject = JSon.TJSONObject;
  TJSONNull = JSon.TJSONNull;
  TJSONArray = JSon.TJSONArray;
  {$Else}
  TJSONAncestor = DBXJSon.TJSonAncestor;
  TJSONByteReader = DBXJSon.TJSONByteReader;
  EJSONException = DBXJSon.TJSONException;
  TJSONPair = DBXJSon.TJSONPair;
  TJSONValue = DBXJSon.TJSONValue;
  TJSONTrue = DBXJSon.TJSONTrue;
  TJSONFalse = DBXJSon.TJSONFalse;
  TJSONString = DBXJSon.TJSONString;
  TJSONNumber = DBXJSon.TJSONNumber;
  TJSONObject = DBXJSon.TJSONObject;
  TJSONNull = DBXJSon.TJSONNull;
  TJSONArray = DBXJSon.TJSONArray;
  {$EndIf}

  {$IFNDEF DelphiXe6_Up}
  TJSonObjectHelper = class helper for TJSonObject
    function GetValue(const AName: string): TJSONValue;
  end;

  TJSonArrayHelper = class helper for TJSonArray
  private
    function GetCount: Integer;
    function GetItems(const AIndex: Integer): TJSonValue;
  public
    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: TJSonValue read GetItems;
  end;
  {$EndIf}

implementation

{$IFNDEF DelphiXe6_Up}
{ TJSonObjectHelper }

function TJSonObjectHelper.GetValue(const AName: string): TJSONValue;
var
  LPair: TJSONPair;
begin
  Result := nil;
  LPair := Get(AName);
  if Assigned(LPair) then
    Result := LPair.JsonValue;
end;

{ TJSonArrayHelper }

function TJSonArrayHelper.GetCount: Integer;
begin
  Result := Size;
end;

function TJSonArrayHelper.GetItems(const AIndex: Integer): TJSonValue;
begin
  Result := Get(AIndex);
end;
{$ENDIF}

end.
