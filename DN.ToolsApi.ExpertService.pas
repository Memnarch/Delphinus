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
procedure UnloadExpert(AIndex: Integer);

implementation

uses
  Classes,
  Types,
  Windows,
  SysUtils,
  RTTI,
  IniFiles,
  Registry;

procedure LoadExpert(const AExpert: string);
var
  LHandle: THandle;
  LService: ^TObject;
  LRTTI: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
//  LIni: TMemIniFile;
begin
  LHandle := LoadLibrary('coreide200.bpl');
  if LHandle <> INVALID_HANDLE_VALUE then
  begin
    LService := GetProcAddress(LHandle, '@Exptmain@ExpertServices');
    LType := LRTTI.GetType(LService.ClassType);
    LMethod := LType.GetMethod('LoadExpertLib');
    LMethod.Invoke(LService^, [AExpert]);
//    LIni := TMemIniFile.Create('');
//    LIni.WriteString('\Software\Embarcadero\BDS\14.0\Experts', 'GExperts', AExpert);
//    LMethod := LType.GetMethod('LoadExperts');
//    LMethod.Invoke(LService^, [LIni]);
    FreeLibrary(LHandle);
  end;
end;

type
  TUnload = procedure(ALib: TObject) of object;

procedure TerminateWizard;
begin

end;

procedure UnloadExpert(AIndex: Integer);
var
  LHandle: THandle;
  LService: ^TObject;
  LRTTI: TRttiContext;
  LType: TRttiType;
  LList, LExpertList: TList;
  LWizardList: IInterfaceList;
  LExpert: TObject;
//  LUnload: TUnload;
  LMethod: TRttiMethod;
//  LWizardCount: Integer;
//  LTerminate: TWizardTerminateProc;
begin
  LHandle := LoadLibrary('coreide200.bpl');
  if LHandle <> INVALID_HANDLE_VALUE then
  begin
    LService := GetProcAddress(LHandle, '@Exptmain@ExpertServices');
    LType := LRTTI.GetType(LService.ClassType);
    LList := TList(LType.GetField('LibList').GetValue(LService^).AsObject);
//    LExpertList := TList(LType.GetField('ExpertList').GetValue(LService^).AsObject);
    LWizardList := LType.GetField('WizardList').GetValue(LService^).AsInterface as IInterfaceList;
//    TMethod(LUnload).Code := LType.GetMethod('UnloadExpertLib').CodeAddress;
//    TMethod(LUnload).Data := LService^;
    LExpert := TObject(LList[AIndex]);
//    LWizardCount := LRTTI.GetType(LExpert.ClassType).GetProperty('WizardCount').GetValue(LExpert).AsInteger;
//    LUnload(LExpert);
    LMethod := LType.GetMethod('UnloadExpertLib');
    LMethod.Invoke(LService^, [LExpert]);
    FreeLibrary(LHandle);
  end;
end;

{ TDNExpertService }

constructor TDNExpertService.Create(const ARootKey: string);
begin
  inherited Create();
  FRootKey := ARootKey;
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
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
