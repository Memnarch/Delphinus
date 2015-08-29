{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.CacheInfo;

interface

uses
  Types,
  DN.JSonFile,
  DN.JSon;

type
  TCacheInfo = class(TJSonFile)
  private
    FCacheID: string;
    FDescription: string;
    FDefaultBranch: string;
    FVersions: TStringDynArray;
    FDownloadLocation: string;
    FRepositoryName: string;
    FProjectUrl: string;
    FReportUrl: string;
    FHomepageUrl: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property CacheID: string read FCacheID write FCacheID;
    property Description: string read FDescription write FDescription;
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
    property RepositoryName: string read FRepositoryName write FRepositoryName;
    property DownloadLocation: string read FDownloadLocation write FDownloadLocation;
    property Versions: TStringDynArray read FVersions write FVersions;
    property ProjectUrl: string read FProjectUrl write FProjectUrl;
    property HomepageUrl: string read FHomepageUrl write FHomepageUrl;
    property ReportUrl: string read FReportUrl write FReportUrl;
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
  FRepositoryName := ReadString(ARoot, 'repository_name');
  FDownloadLocation := ReadString(ARoot, 'download_location');
  FProjectUrl := ReadString(ARoot, 'project_url');
  FHomepageUrl := ReadString(ARoot, 'homepage_url');
  FReportUrl := ReadString(ARoot, 'report_url');
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
  WriteString(ARoot, 'repository_name', FRepositoryName);
  WriteString(ARoot, 'download_location', FDownloadLocation);
  WriteString(ARoot, 'project_url', FProjectUrl);
  WriteString(ARoot, 'homepage_url', FHomepageUrl);
  WriteString(ARoot, 'report_url',FReportUrl);
  LArray := WriteArray(ARoot, 'versions');
  for LVersion in FVersions do
  begin
    LArray.Add(LVersion);
  end;
end;

end.
