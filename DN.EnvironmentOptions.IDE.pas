{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.EnvironmentOptions.IDE;

interface

uses
  Classes,
  Windows,
  Registry,
  IniFiles,
  Generics.Collections,
  ToolsApi,
  DN.Types,
  DN.EnvironmentOptions;

type
  TDNRegistryEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FRegstryKey: string;
    FRegistryOptions: TObject;
    FRegistry: TMemIniFile;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName, AValue: string); override;
    procedure Changed; override;
  public
    constructor Create(APlatform: TDNCompilerPlatform; const ARegistryKey: string; const ARegistryOptions : TObject);
  end;

  TDNOTAEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FOptions: IOTAOptions;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName: string; const AValue: string); override;
  public
    constructor Create(APlatform: TDNCompilerPlatform);
  end;

  TDNIDEEnvironmentOptionsService = class(TDNEnvironmentOptionsService)
  private
    procedure LoadPlatforms();
  public
    constructor Create();
  end;

implementation

uses
  IOUtils,
  DN.ToolsApi,
  RTTI;

const
  CLibraryKey = 'Library';
  //these maybe different than the names used by the Compiler.
  //for example it is Android for the compiler, but Android32 for the registry
  CPlatformKeys: array[cpWin32..cpLinux64] of string = ('Win32', 'Win64', 'OSX32', 'Android32', 'iOSDevice32', 'iOSDevice64', 'Linux64');

{ TDNIDEEnvironmentOptionsService }

constructor TDNIDEEnvironmentOptionsService.Create;
begin
  inherited;
  LoadPlatforms();
end;

procedure TDNIDEEnvironmentOptionsService.LoadPlatforms;
var
  LService: IOTAServices;
  LReg: TRegistry;
  LBase, LLibraryKey, LPlatformKey: string;
  LOptions: TDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LRegistryOptions: TObject;
begin
  LService := BorlandIDEservices as IOTAServices;
  LBase := LService.GetBaseRegistryKey();
  LReg := TRegistry.Create();
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LLibraryKey := TPath.Combine(LBase ,CLibraryKey);
    if LReg.OpenKey(LLibraryKey, False) then
    begin
      //we are on a Win32-Only Delphi
      if CompilerVersion <= 22 then
      begin
        LOptions := TDNOTAEnvironmentOptions.Create(cpWin32);
        AddOption(LOptions);
      end
      else
      begin
        //we are on a multiplatform Delphi
        for LPlatform := Low(CPlatformKeys) to High(CPlatformKeys) do
        begin
          if LReg.KeyExists(CPlatformKeys[LPlatform]) then
          begin
            LPlatformKey := TPath.Combine(LLibraryKey, CPlatformKeys[LPlatform]);

            LRegistryOptions := GetRegistryOptionsObject(GetEnvironmentOptionObject(), LPlatformKey);

            if Assigned(LRegistryOptions) then
            begin
              LOptions := TDNRegistryEnvironmentOptions.Create(LPlatform, LPlatformKey, LRegistryOptions);
              AddOption(LOptions);
            end;
          end;
        end;
      end;
    end;
  finally
    LReg.Free;
  end;
end;

constructor TDNRegistryEnvironmentOptions.Create(APlatform: TDNCompilerPlatform; const ARegistryKey: string; const ARegistryOptions : TObject);
begin
  inherited Create(APlatform);
  FSearchPathName := 'Search Path';
  FBPLOutputName := 'Package DPL Output';
  FBrowsingPathName := 'Browsing Path';
  FDCPOutputName := 'Package DCP Output';
  FRegstryKey := ARegistryKey;
  FRegistryOptions := ARegistryOptions;
  FRegistry := GetRegistryOptionsMemIni(FRegistryOptions);
end;

function TDNRegistryEnvironmentOptions.ReadString(const AName: string): string;
begin
  Result := FRegistry.ReadString(FRegstryKey, AName, '');
end;

procedure TDNRegistryEnvironmentOptions.Changed;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  LType := LContext.GetType(FRegistryOptions.ClassType);
  LType.GetMethod('SavePropValues').Invoke(FRegistryOptions, []);
  inherited;
end;

procedure TDNRegistryEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  FRegistry.WriteString(FRegstryKey, AName, AValue);
  if not IsUpdating then
    Changed();
end;

{ TDNOTAEnvironmentOptions }

constructor TDNOTAEnvironmentOptions.Create(APlatform: TDNCompilerPlatform);
begin
  inherited;
  FSearchPathName := 'LibraryPath';
  FBPLOutputName := 'PackageDPLOutput';
  FBrowsingPathName := 'BrowsingPath';
  FDCPOutputName := 'PackageDCPOutput';
  FOptions := (BorlandIDEServices as IOTAServices).GetEnvironmentOptions;
end;

function TDNOTAEnvironmentOptions.ReadString(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

procedure TDNOTAEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  FOptions.Values[AName] := AValue;
end;

end.
