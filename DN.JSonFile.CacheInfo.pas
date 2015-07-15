unit DN.JSonFile.CacheInfo;

interface

uses
  Types,
  DN.JSonFile,
  DBXJSon,
  JSOn;

type
  TCacheInfo = class(TJSonFile)
  private
    FCacheID: string;
    FDescription: string;
    FDefaultBranch: string;
    FVersions: TStringDynArray;
    FDownloadLocation: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property CacheID: string read FCacheID write FCacheID;
    property Description: string read FDescription write FDescription;
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
    property DownloadLocation: string read FDownloadLocation write FDownloadLocation;
    property Versions: TStringDynArray read FVersions write FVersions;
  end;

implementation

{ TCacheInfo }

procedure TCacheInfo.Load(const ARoot: TJSONObject);
var
  LArray: TJSonArray;
  i: Integer;
begin
  inherited;
  FCacheID := ReadString(ARoot, 'cache_id');
  FDescription := ReadString(ARoot, 'description');
  FDefaultBranch := ReadString(ARoot, 'default_branch');
  FDownloadLocation := ReadString(ARoot, 'download_location');
  if ReadArray(ARoot, 'versions', LArray) then
  begin
    SetLength(FVersions, LArray.Count);
    for i := 0 to LArray.Count - 1 do
    begin
      FVersions[i] := LARray.Items[i].Value;
    end;
  end;
end;

procedure TCacheInfo.Save(const ARoot: TJSONObject);
var
  LVersion: string;
  LArray: TJSONArray;
begin
  inherited;
  WriteString(ARoot, 'cache_id', FCacheID);
  WriteString(ARoot, 'description', FDescription);
  WriteString(ARoot, 'default_branch', FDefaultBranch);
  WriteString(ARoot, 'download_location', FDownloadLocation);
  LArray := WriteArray(ARoot, 'versions');
  for LVersion in FVersions do
  begin
    LArray.Add(LVersion);
  end;
end;

end.
