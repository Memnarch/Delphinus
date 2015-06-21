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

function ReloadEnvironmentOptions(): Boolean;

implementation

uses
  RTTI,
  ToolsAPi;

const
  CFEnvOptions = 'FEnvOptions';
  CLoadOptions = 'LoadOptions';

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

end.
