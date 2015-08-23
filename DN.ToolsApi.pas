{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.ToolsApi;
{#################################
  ToolsApi Hacks written by Alexander Benikowski
  original unit: DN.ToolsApi
  Homepage: memnarch.bplaced.net
  On Github: https://github.com/Memnarch

  if you reuse this code in your own projects, please copy this header, too
##################################
}
interface

uses
  IniFiles;

//function ReloadEnvironmentOptions(): Boolean;
//function SaveEnvironmentOptions(): Boolean;
function GetEnvironmentOptionObject(): TObject;
function GetRegistryOptionsMemIni(const ARegOption: TObject): TMemIniFile;
function GetRegistryOptionsObject(const AEnvironmentOptions: TObject; const APath: string): TObject;

implementation

uses
  Classes,
  RTTI,
  SysUtils,
  ToolsAPi;

const
  CFEnvOptions = 'FEnvOptions';
  CLoadOptions = 'LoadOptions';
  CSaveOptions = 'SaveOptions';

function GetEnvironmentOptionObject(): TObject;
var
  LService: IOTAServices;
  LEnvironmentOptions: IOTAEnvironmentOptions;
  LOTAEnvironmentOptions: TObject;
  LContext: TRttiContext;
  LTypeA: TRttiType;
  LField: TRttiField;
begin
  Result := nil;
  LService := BorlandIDEServices as IOTAServices;
  LEnvironmentOptions := LService.GetEnvironmentOptions();
  LOTAEnvironmentOptions := LEnvironmentOptions as TObject;
  LTypeA := LContext.GetType(LOTAEnvironmentOptions.ClassType);
  if Assigned(LTypeA) then
  begin
    LField := LTypeA.GetField(CFEnvOptions);
    if Assigned(LField) then
    begin
      Result := LField.GetValue(LOTAEnvironmentOptions).AsObject;
    end;
  end;
end;

function GetRegistryOptionsObject(const AEnvironmentOptions: TObject; const APath: string): TObject;
var
  LContext: TRttiContext;
  LType, LTypeB: TRttiType;
  i, LCount: Integer;
  LOption: TObject;
begin
  Result := nil;
  if not Assigned(AEnvironmentOptions) then Exit;
  LType := LContext.GetType(AEnvironmentOptions.ClassType);
  if Assigned(LType) then
  begin
    LCount := LType.GetProperty('OptionCount').GetValue(AEnvironmentOptions).AsInteger;
    for i := 0 to LCount - 1 do
    begin
      LOption := LType.GetMethod('GetOptionComponent').Invoke(AEnvironmentOptions, [i]).AsObject;
      if LOption.ClassNameIs('TRegistryPropSet') then
      begin
        LTypeB := LContext.GetType(LOption.ClassType);
        if Assigned(LTypeB) then
        begin
          if APath = LTypeB.GetProperty('CurrentPath').GetValue(LOption).AsString then
          begin
            Result := LOption;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

function GetRegistryOptionsMemIni(const ARegOption: TObject): TMemIniFile;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMemIni: TObject;
begin
  Result := nil;

  LType := LContext.GetType(ARegOption.ClassType);
  if Assigned(LType) then
  begin
    LMemIni := LType.GetProperty('Values').GetValue(ARegOption).AsObject;
    if LMemIni is TMemIniFile then
    begin
      Result := TMemIniFile(LMemIni);
    end;
  end;
end;

function ReloadEnvironmentOptions(): Boolean;
var
  LService: IOTAServices;
  LEnvironmentOptions: IOTAEnvironmentOptions;
  LOTAEnvironmentOptions: TObject;
  LFEnvOptions: TObject;
  LContext: TRttiContext;
  LTypeA, LTypeB: TRttiType;
  LField: TRttiField;
  LLoadOptions: TRttiMethod;
begin
  Result := False;
  LService := BorlandIDEServices as IOTAServices;
  LEnvironmentOptions := LService.GetEnvironmentOptions();
  LOTAEnvironmentOptions := LEnvironmentOptions as TObject;
  LTypeA := LContext.GetType(LOTAEnvironmentOptions.ClassType);
  if Assigned(LTypeA) then
  begin
    LField := LTypeA.GetField(CFEnvOptions);
    if Assigned(LField) then
    begin
      LFEnvOptions := LField.GetValue(LOTAEnvironmentOptions).AsObject;
      if Assigned(LFEnvOptions) then
      begin
        LTypeB := LContext.GetType(LFEnvOptions.ClassType);
        if Assigned(LTypeB) then
        begin
          LLoadOptions := LTypeB.GetMethod(CLoadOptions);
          if Assigned(LLoadOptions) then
          begin
            LLoadOptions.Invoke(LFEnvOptions, []);
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

function SaveEnvironmentOptions(): Boolean;
var
  LService: IOTAServices;
  LEnvironmentOptions: IOTAEnvironmentOptions;
  LOTAEnvironmentOptions: TObject;
  LFEnvOptions: TObject;
  LContext: TRttiContext;
  LTypeA, LTypeB: TRttiType;
  LField: TRttiField;
  LSaveOptions: TRttiMethod;
begin
  Result := False;
  LService := BorlandIDEServices as IOTAServices;
  LEnvironmentOptions := LService.GetEnvironmentOptions();
  LOTAEnvironmentOptions := LEnvironmentOptions as TObject;
  LTypeA := LContext.GetType(LOTAEnvironmentOptions.ClassType);
  if Assigned(LTypeA) then
  begin
    LField := LTypeA.GetField(CFEnvOptions);
    if Assigned(LField) then
    begin
      LFEnvOptions := LField.GetValue(LOTAEnvironmentOptions).AsObject;
      if Assigned(LFEnvOptions) then
      begin
        LTypeB := LContext.GetType(LFEnvOptions.ClassType);
        if Assigned(LTypeB) then
        begin
          LSaveOptions := LTypeB.GetMethod(CSaveOptions);
          if Assigned(LSaveOptions) then
          begin
            LSaveOptions.Invoke(LFEnvOptions, []);
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

end.
