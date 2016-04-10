{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.Uninstallation;

interface

uses
  DN.JSon,
  DN.JSonFile;

type

  TPackage = record
    BPLFile: string;
    DCPFile: string;
    Installed: Boolean;
  end;

  TInstalledExpert = record
    Expert: string;
    HotReload: Boolean;
  end;

  TUninstallationFile = class(TJSonFile)
  private
    FPackages: TArray<TPackage>;
    FSearchPathes: string;
    FBrowsingPathes: string;
    FRawFiles: TArray<string>;
    FExperts: TArray<TInstalledExpert>;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property SearchPathes: string read FSearchPathes write FSearchPathes;
    property BrowsingPathes: string read FBrowsingPathes write FBrowsingPathes;
    property Packages: TArray<TPackage> read FPackages write FPackages;
    property Experts: TArray<TInstalledExpert> read FExperts write FExperts;
    property RawFiles: TArray<string> read FRawFiles write FRawFiles;
  end;

implementation

uses
  SysUtils;

{ TUninstallation }

procedure TUninstallationFile.Load(const ARoot: TJSONObject);
var
  LPackages, LRawFiles, LExperts: TJSONArray;
  LPackage: TJSONObject;
  i: Integer;
begin
  inherited;
  FSearchPathes := ReadString(ARoot, 'search_pathes');
  FBrowsingPathes := ReadString(ARoot, 'browsing_pathes');
  if ReadArray(ARoot, 'packages', LPackages) then
  begin
    SetLength(FPackages, LPackages.Count);
    for i := 0 to Pred(LPackages.Count) do
    begin
      LPackage := LPackages.Items[i] as TJSONObject;
      FPackages[i].BPLFile := ReadString(LPackage, 'bpl_file');
      FPackages[i].DCPFile := ReadString(LPackage, 'dcp_file');
      FPackages[i].Installed := ReadBoolean(LPackage, 'installed')
    end;
  end;

  if ReadArray(ARoot, 'raw_files', LRawFiles) then
  begin
    SetLength(FRawFiles, LRawFiles.Count);
    for i := 0 to Pred(LRawFiles.Count) do
      FRawFiles[i] := ReadString(LRawFiles.Items[i] as TJSONObject, 'file');
  end;

  if ReadArray(ARoot, 'experts', LExperts) then
  begin
    SetLength(FExperts, LExperts.Count);
    for i := 0 to Pred(LExperts.Count) do
    begin
      FExperts[i].Expert := ReadString(LExperts.Items[i] as TJSONObject, 'expert');
      FExperts[i].HotReload := ReadBoolean(LExperts.Items[i] as TJSONObject, 'hot_reload');
    end;
  end;
end;

procedure TUninstallationFile.Save(const ARoot: TJSONObject);
var
  LPackages, LRawFiles, LExperts: TJSONArray;
  LPackage: TPackage;
  LJPackage, LJRawFile, LJExpert: TJSONObject;
  LRawFile: string;
  LExpert: TInstalledExpert;
begin
  inherited;
  WritePath(ARoot, 'search_pathes', FSearchPathes);
  WritePath(ARoot, 'browsing_pathes', FBrowsingPathes);
  LPackages := WriteArray(ARoot, 'packages');
  for LPackage in FPackages do
  begin
    LJPackage := WriteArrayObject(LPackages);
    WritePath(LJPackage, 'bpl_file', LPackage.BPLFile);
    WritePath(LJPackage, 'dcp_file', LPackage.DCPFile);
    WriteBoolean(LJPackage, 'installed', LPackage.Installed);
  end;

  LRawFiles := WriteArray(ARoot, 'raw_files');
  for LRawFile in FRawFiles do
  begin
    LJRawFile := WriteArrayObject(LRawFiles);
    WritePath(LJRawFile, 'file', LRawFile);
  end;

  LExperts := WriteArray(ARoot, 'experts');
  for LExpert in FExperts do
  begin
    LJExpert := WriteArrayObject(LExperts);
    WritePath(LJExpert, 'expert', LExpert.Expert);
    WriteBoolean(LJExpert, 'hot_reload', LExpert.HotReload);
  end;
end;

end.
