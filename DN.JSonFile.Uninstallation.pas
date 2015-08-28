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

  TUninstallationFile = class(TJSonFile)
  private
    FPackages: TArray<TPackage>;
    FSearchPathes: string;
    FBrowsingPathes: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property SearchPathes: string read FSearchPathes write FSearchPathes;
    property BrowsingPathes: string read FBrowsingPathes write FBrowsingPathes;
    property Packages: TArray<TPackage> read FPackages write FPackages;
  end;

implementation

uses
  SysUtils;

{ TUninstallation }

procedure TUninstallationFile.Load(const ARoot: TJSONObject);
var
  LPackages: TJSONArray;
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
end;

procedure TUninstallationFile.Save(const ARoot: TJSONObject);
var
  LPackages: TJSONArray;
  LPackage: TPackage;
  LJPackage: TJSONObject;
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
end;

end.
