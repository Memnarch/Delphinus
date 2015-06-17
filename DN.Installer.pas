unit DN.Installer;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.Installer.Intf,
  DN.Compiler.Intf,
  JSon,
  DBXJSon;

type
  TDNInstaller = class(TInterfacedObject, IDNInstaller)
  private
    FCompiler: IDNCompiler;
    FCompilerVersion: Integer;
    procedure AddSearchPath(const ASearchPath: string); virtual;
    procedure CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False); virtual;
    procedure ProcessSearchPathes(AObject: TJSONObject; const ARootDirectory: string);
    procedure ProcessSourceFolders(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string);
    procedure ProcessProjects(AObect: TJSONObject);
    function IsSupported(AObject: TJSonObject): Boolean;
    function FileMatchesFilter(const AFile: string; const AFilter: TStringDynArray): Boolean;
  public
    constructor Create(const ACompiler: IDNCompiler; const ACompilerVersion: Integer);
    destructor Destroy(); override;
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean;
  end;

implementation

uses
  IOUtils,
  StrUtils,
  Masks;

{ TDNInstaller }

procedure TDNInstaller.AddSearchPath(const ASearchPath: string);
begin

end;

procedure TDNInstaller.CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False);
var
  LDirectories, LFiles: TStringDynArray;
  LDirectory, LFile, LFileName: string;
  LForcedDirectory: Boolean;
begin
  LForcedDirectory := False;
  if ARecursive then
  begin
    LDirectories := TDirectory.GetDirectories(ASource);
    for LDirectory in LDirectories do
    begin
      CopyDirectory(LDirectory, TPath.Combine(ATarget, ExtractFileName(LDirectory)), AFileFilters, ARecursive);
    end;
  end;

  LFiles := TDirectory.GetFiles(ASource);
  for LFile in LFiles do
  begin
    LFileName := ExtractFileName(LFile);
    if FileMatchesFilter(LFileName, AFileFilters) then
    begin
      //lazy directory creation, so directories with no matching files are not created in the target path!
      if not LForcedDirectory then
      begin
        LForcedDirectory := True;
        ForceDirectories(ATarget);
      end;
      TFile.Copy(LFile, TPath.Combine(ATarget, LFileName), True);
    end;
  end;
end;

constructor TDNInstaller.Create(const ACompiler: IDNCompiler; const ACompilerVersion: Integer);
begin
  inherited Create();
  FCompiler := ACompiler;
  FCompilerVersion := ACompilerVersion;
end;

destructor TDNInstaller.Destroy;
begin
  inherited;
end;

function TDNInstaller.FileMatchesFilter(const AFile: string;
  const AFilter: TStringDynArray): Boolean;
var
  LFilter: string;
begin
  Result := Length(AFilter) = 0;
  if not Result then
  begin
    for LFilter in AFilter do
    begin
      Result := MatchesMask(AFile, LFilter);
      if Result then
        Break;
    end;
  end;
end;

function TDNInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LInfo: TJSONObject;
  LInstallerFile: string;
  LStream: TStringStream;
begin
  Result := False;
  LInstallerFile := TPath.Combine(ASourceDirectory, 'install.json');
  if TFile.Exists(LInstallerFile) then
  begin
    LStream := TStringStream.Create();
    try
      LStream.LoadFromFile(LInstallerFile);
      LInfo := TJSONObject.ParseJSONValue(LStream.DataString) as TJSonObject;
      if Assigned(LInfo) then
      begin
        try
          ProcessSearchPathes(LInfo, ATargetDirectory);
          ProcessSourceFolders(LInfo, ASourceDirectory, TPath.Combine(ATargetDirectory, 'source'));
          ProcessProjects(LInfo);
          Result := True;
        finally
          LInfo.Free;
        end;
      end;
    finally
      LStream.Free;
    end;
  end;
end;

function TDNInstaller.IsSupported(AObject: TJSonObject): Boolean;
var
  LMin, LMax: TJSonValue;
begin
  Result := True;
  LMin := AObject.GetValue('compiler_min');
  LMax := AObject.GetValue('compiler_max');
  if Assigned(LMin) then
    Result := Result and (FCompilerVersion >= StrToIntDef(LMin.Value, 0));

  if Assigned(LMax) then
    Result := Result and (FCompilerVersion <= STrToIntDef(LMax.Value, 1000));
end;

procedure TDNInstaller.ProcessProjects(AObect: TJSONObject);
begin

end;

procedure TDNInstaller.ProcessSearchPathes(AObject: TJSONObject; const ARootDirectory: string);
var
  LPathes: TStringDynArray;
  LPathArray: TJSONArray;
  LPath: TJSonObject;
  LRelPath: string;
  i: Integer;
begin
  LPathArray := TJSonArray(AObject.GetValue('search_pathes'));
  if Assigned(LPathArray) then
  begin
    for i := 0 to LPathArray.Count - 1 do
    begin
      LPath := LPathArray.Items[i] as TJSonObject;
      if IsSupported(LPath) then
      begin
        LPathes := SplitString(LPath.GetValue('pathes').Value, ';');
        for LRelPath in LPathes do
        begin
          AddSearchPath(TPath.Combine(ARootDirectory, LRelPath));
        end;
      end;
    end;
  end;
end;

procedure TDNInstaller.ProcessSourceFolders(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string);
var
  LFolders: TJSONArray;
  LFolder: TJSonObject;
  LValue: TJSONValue;
  LRecursive: Boolean;
  LFilter: TStringDynArray;
  LRelPath: string;
  i: Integer;
begin
  LFolders := TJSonArray(AObject.GetValue('source_folders'));
  if Assigned(LFolders) then
  begin
    for i := 0 to LFolders.Count - 1 do
    begin
      LFolder := LFolders.Items[i] as TJSonObject;
      if IsSupported(LFolder) then
      begin
        LRelPath := LFolder.GetValue('folder').Value;
        LValue := LFolder.GetValue('recursive');
        if Assigned(LValue) then
          LRecursive := StrToBoolDef(LValue.Value, False)
        else
          LRecursive := False;

        LValue := LFolder.GetValue('filter');
        if Assigned(LValue) then
          LFilter := SplitString(LValue.Value, ';')
        else
          SetLength(LFilter, 0);

        CopyDirectory(TPath.Combine(ASourceDirectory, LRelPath), TPath.Combine(ATargetDirectory, LRelPath), LFilter, LRecursive);
      end;
    end;
  end;
end;

end.
