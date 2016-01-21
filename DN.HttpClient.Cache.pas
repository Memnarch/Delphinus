unit DN.HttpClient.Cache;

interface

uses
  Classes,
  Windows,
  SysUtils,
  SyncObjs,
  Generics.Collections,
  DN.HttpClient.Cache.Intf;

type
  TDNHttpCache = class(TInterfacedObject, IDNHttpCache)
  private
    FEntries: TDictionary<string, IDNHttpCacheEntry>;
    FDirectory: string;
    FKey: string;
    FMutex: TMutex;
    FLockCount: Integer;
    procedure LoadCache;
    procedure SaveCache;
  public
    constructor Create(const ADirectory: string);
    destructor Destroy; override;
    procedure OpenCache;
    procedure CloseCache;
    procedure AddCache(const AUrl: string; AData: TStream; const ACacheControl: string; const AETag: string);
    function TryGetCache(const AUrl: string; out AEntry: IDNHttpCacheEntry): Boolean;
  end;

  TDNHttpCacheEntry = class(TInterfacedObject, IDNHttpCacheEntry)
  private
    FID: string;
    FETag: string;
    FUrl: string;
    FDirectory: string;
    FMaxAge: Integer;
    FLastModified: TDateTime;
    function GetETag: string;
    function GetID: string;
    procedure SetETag(const Value: string);
    procedure SetID(const Value: string);
    function GetUrl: string;
    procedure SetUrl(const Value: string);
    function GetLastModified: TDateTime;
    function GetMaxAge: Integer;
    procedure SetLastModified(const Value: TDateTime);
    procedure SetMaxAge(const Value: Integer);
  public
    constructor Create(const ADirectory: string);
    procedure Store(const ASource: TStream);
    procedure Load(const ATarget: TStream);
    function IsExpired: Boolean;
    property ID: string read GetID write SetID;
    property ETag: string read GetETag write SetETag;
    property Url: string read GetUrl write SetUrl;
    property MaxAge: Integer read GetMaxAge write SetMaxAge;
    property LastModified: TDateTime read GetLastModified write SetLastModified;
  end;

implementation

uses
  IOUtils,
  DateUtils,
  IniFiles;

const
  CCacheIni = 'Cache.ini';

{ TDNHttpCache }

procedure TDNHttpCache.AddCache(const AUrl: string; AData: TStream;
  const ACacheControl, AETag: string);
var
  LEntry: IDNHttpCacheEntry;
  LControl: TStringList;
  LMaxAge: Integer;
begin
  if not FEntries.TryGetValue(AUrl, LEntry) then
  begin
    LEntry := TDNHttpCacheEntry.Create(FDirectory);
    LEntry.ID := TGuid.NewGuid.ToString();
    LEntry.Url := AUrl;
    FEntries.Add(LEntry.Url, LEntry);
  end;
  LEntry.ETag := AETag;
  if ACacheControl <> '' then
  begin
    LControl := TStringList.Create();
    try
      LControl.CommaText := ACacheControl;
      if TryStrToInt(LControl.Values['max-age'], LMaxAge) then
        LEntry.MaxAge := LMaxAge;
    finally
      LControl.Free;
    end;
  end;
  LEntry.Store(AData);
end;

procedure TDNHttpCache.CloseCache;
begin
  Dec(FLockCount);
  if FLockCount = 0 then
  begin
    SaveCache();
    FMutex.Release();
  end;
end;

constructor TDNHttpCache.Create(const ADirectory: string);
begin
  inherited Create();
  FEntries := TDictionary<string, IDNHttpCacheEntry>.Create();
  FDirectory := ADirectory;
  ForceDirectories(FDirectory);
  FKey := StringReplace(ADirectory, '\', '/', [rfReplaceAll]);
  FMutex := TMutex.Create(nil, False, FKey);
end;

destructor TDNHttpCache.Destroy;
begin
  //If we are still locked, release ownership
  if FLockCount > 0 then
  begin
    SaveCache();
    FMutex.Release();
  end;
  FMutex.Free;
  FEntries.Free;
  inherited;
end;

procedure TDNHttpCache.LoadCache;
var
  LIni: TMemIniFile;
  LSections: TStringList;
  LSection, LIniFile: string;
  LEntry: IDNHttpCacheEntry;
begin
  LIniFile := TPath.Combine(FDirectory, CCacheIni);
  if not TFile.Exists(LIniFile) then
    Exit;

  LIni := TMemIniFile.Create(LIniFile);
  try
    LSections := TStringList.Create();
    try
      LIni.ReadSections(LSections);
      for LSection in LSections do
      begin
        LEntry := TDNHttpCacheEntry.Create(FDirectory);
        LEntry.ID := LSection;
        LEntry.Url := LIni.ReadString(LSection, 'url', '');
        LEntry.ETag := LIni.ReadString(LSection, 'ETag', '');
        LEntry.MaxAge := LIni.ReadInteger(LSection, 'MaxAge', 0);
        LEntry.LastModified := LIni.ReadDateTime(LSection, 'LastModified', 0);
        FEntries.AddOrSetValue(LEntry.Url, LEntry);
      end;
    finally
      LSections.Free;
    end;
  finally
    LIni.Free;
  end;
end;

procedure TDNHttpCache.OpenCache;
begin
  if FLockCount = 0 then
  begin
    FMutex.Acquire();
    LoadCache();
  end;
  Inc(FLockCount);
end;

procedure TDNHttpCache.SaveCache;
var
  LIni: TMemIniFile;
  LEntry: IDNHttpCacheEntry;
begin
  LIni := TMemIniFile.Create(TPath.Combine(FDirectory, CCacheIni));
  try
    for LEntry in FEntries.Values do
    begin
      LIni.WriteString(LEntry.ID, 'url', LEntry.Url);
      LIni.WriteString(LEntry.ID, 'ETag', LEntry.ETag);
      LIni.WriteInteger(LEntry.ID, 'MaxAge', LEntry.MaxAge);
      LIni.WriteDateTime(LEntry.ID, 'LastModified', LEntry.LastModified);
    end;
    LIni.UpdateFile();
  finally
    LIni.Free;
  end;
end;

function TDNHttpCache.TryGetCache(const AUrl: string;
  out AEntry: IDNHttpCacheEntry): Boolean;
begin
  Result := FEntries.TryGetValue(AUrl, AEntry);
end;

{ TDNHttpCacheEntry }

constructor TDNHttpCacheEntry.Create(const ADirectory: string);
begin
  inherited Create();
  FDirectory := ADirectory;
end;

function TDNHttpCacheEntry.GetETag: string;
begin
  Result := FETag;
end;

function TDNHttpCacheEntry.GetLastModified: TDateTime;
begin
  Result := FLastModified;
end;

function TDNHttpCacheEntry.GetID: string;
begin
  Result := FID;
end;

function TDNHttpCacheEntry.GetMaxAge: Integer;
begin
  Result := FMaxAge;
end;

function TDNHttpCacheEntry.GetUrl: string;
begin
  Result := FUrl;
end;

function TDNHttpCacheEntry.IsExpired: Boolean;
begin
  Result := SecondsBetween(FLastModified, Now) >= FMaxAge;
end;

procedure TDNHttpCacheEntry.Load(const ATarget: TStream);
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(TPath.Combine(FDirectory, FID), fmOpenRead);
  try
    ATarget.CopyFrom(LFile, LFile.Size);
  finally
    LFile.Free;
  end;
end;

procedure TDNHttpCacheEntry.SetETag(const Value: string);
begin
  FETag := Value;
end;

procedure TDNHttpCacheEntry.SetLastModified(const Value: TDateTime);
begin
  FLastModified := Value;
end;

procedure TDNHttpCacheEntry.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TDNHttpCacheEntry.SetMaxAge(const Value: Integer);
begin
  FMaxAge := Value;
end;

procedure TDNHttpCacheEntry.SetUrl(const Value: string);
begin
  FUrl := Value;
end;

procedure TDNHttpCacheEntry.Store(const ASource: TStream);
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(TPath.Combine(FDirectory, FID), fmCreate or fmOpenWrite);
  try
    LFile.CopyFrom(ASource, 0);
    FLastModified := Now();
  finally
    LFile.Free;
  end;
end;

end.
