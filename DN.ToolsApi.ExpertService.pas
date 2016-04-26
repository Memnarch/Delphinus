unit DN.ToolsApi.ExpertService;

interface

uses
  DN.ToolsApi.ExpertService.Intf;

type
  TDNExpertService = class(TInterfacedObject, IDNExpertService)
  private
    FRootKey: string;
  public
    constructor Create(const ARootKey: string);
    function RegisterExpert(const AExpert: string; ALoad: Boolean = False): Boolean;
    function UnregisterExpert(const AExpert: string; AUnload: Boolean = False): Boolean;
  end;

procedure LoadExpert(const AExpert: string);
procedure UnloadExpert(const AExpert: string);

implementation

uses
  Classes,
  Types,
  Windows,
  SysUtils,
  StrUtils,
  RTTI,
  IniFiles,
  Registry;

function TryGetExpertService(out AService: TObject): Boolean;
var
  LLibName: string;
  LContext: TRttiContext;
  LPackage: TRttiPackage;
  LService: ^TObject;
const
  CExpertServiceSymbol = '@Exptmain@ExpertServices';
begin
  Result := False;
  for LPackage in LContext.GetPackages() do
  begin
    LLibName := ExtractFileName(LPackage.Name);
    if StartsText('CoreIDE', LLibName) and EndsText('.bpl', LLibName) then
    begin
      LService := GetProcAddress(LPackage.Handle, CExpertServiceSymbol);
      if Assigned(LService) then
      begin
        AService := LService^;
        Exit(True);
      end;
    end;
  end;
end;

function TryGetExtertLibName(AExpert: TObject; out ALibName: string): Boolean;
var
  LContext: TRttiContext;
  LType: TRTTIType;
  LField: TRttiField;
begin
  Result := False;
  LType := LContext.GetType(AExpert.ClassType);
  LField := LType.GetField('LibHandle');
  if Assigned(LField) then
  begin
    ALibName := GetModuleName(NativeUInt(LField.GetValue(AExpert).AsInt64));
    Result := True;
  end;
end;

procedure LoadExpert(const AExpert: string);
var
  LService: TObject;
  LRTTI: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
const
  CLoadExpertLib = 'LoadExpertLib';
begin
  if TryGetExpertService(LService) then
  begin
    LType := LRTTI.GetType(LService.ClassType);
    LMethod := LType.GetMethod(CLoadExpertLib);
    if Assigned(LMethod) then
    begin
      try
        LMethod.Invoke(LService, [AExpert]);
      except

      end;
    end;
  end;
end;

procedure UnloadExpert(const AExpert: string);
var
  LService: TObject;
  LRTTI: TRttiContext;
  LType: TRttiType;
  LList: TList;
  LUnload: TRttiMethod;
  LField: TRttiField;
  LExpert: Pointer;
  LExpertLib: string;
const
  CLibList = 'LibList';
  CUnloadExpertLib = 'UnloadExpertLib';
begin
  if TryGetExpertService(LService) then
  begin
    LType := LRTTI.GetType(LService.ClassType);
    LField := LType.GetField(CLibList);
    LUnload := LType.GetMethod(CUnloadExpertLib);
    if Assigned(LField) then
    begin
      LList := TList(LField.GetValue(LService).AsObject);
      if Assigned(LList) then
      begin
        for LExpert in LList do
        begin
          if TryGetExtertLibName(TObject(LExpert), LExpertLib) and SameText(AExpert, LExpertLib) then
          begin
            try
              LUnload.Invoke(LService, [TObject(LExpert)]);
            except

            end;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

{ TDNExpertService }

constructor TDNExpertService.Create(const ARootKey: string);
var
  LService: TObject;
begin
  inherited Create();
  FRootKey := ARootKey;
  TryGetExpertService(LService);
end;

function TDNExpertService.RegisterExpert(const AExpert: string;
  ALoad: Boolean): Boolean;
var
  LRegistry: TRegistry;
begin
  Result := False;
  LRegistry := TRegistry.Create();
  try
    if LRegistry.OpenKey(FRootKey, False) then
    begin
      if LRegistry.OpenKey('Experts', True) then
      begin
        LRegistry.WriteString(ExtractFileName(AExpert), AExpert);
        if ALoad then
          LoadExpert(AExpert);
        Result := True;
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

function TDNExpertService.UnregisterExpert(const AExpert: string;
  AUnload: Boolean): Boolean;
var
  LRegistry: TRegistry;
begin
  Result := False;
  LRegistry := TRegistry.Create();
  try
    if LRegistry.OpenKey(FRootKey, False) then
    begin
      if LRegistry.OpenKey('Experts', True) then
      begin
        Result := LRegistry.DeleteValue(ExtractFileName(AExpert));
        if AUnload then
          UnloadExpert(AExpert);
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
