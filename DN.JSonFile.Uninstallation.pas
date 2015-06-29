unit DN.JSonFile.Uninstallation;

interface

uses
  JSon,
  DBXJSon,
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
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property SearchPathes: string read FSearchPathes write FSearchPathes;
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
  WriteString(ARoot, 'search_pathes', StringReplace(FSearchPathes, '\', '\\', [rfReplaceAll]));
  LPackages := WriteArray(ARoot, 'packages');
  for LPackage in FPackages do
  begin
    LJPackage := WriteArrayObject(LPackages);
    WriteString(LJPackage, 'bpl_file', StringReplace(LPackage.BPLFile, '\', '\\', [rfReplaceAll]));
    WriteString(LJPackage, 'dcp_file', StringReplace(LPackage.DCPFile, '\', '\\', [rfReplaceAll]));
    WriteBoolean(LJPackage, 'installed', LPackage.Installed);
  end;
end;

end.
