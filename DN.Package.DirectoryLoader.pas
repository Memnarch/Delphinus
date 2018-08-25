unit DN.Package.DirectoryLoader;

interface

uses
  DN.Package.DirectoryLoader.Intf,
  DN.Package.Intf;

type
  TDNPackageDirectoryLoader = class(TInterfacedObject, IDNPackageDirectoryLoader)
  private
    function LoadLicenceText(const AFile: string): string;
  public
    function Load(const ADirectory: string; const APackage: IDNPackage): Boolean;
  end;

implementation

uses
  Classes,
  SysUtils,
  IOUtils,
  DN.Types,
  DN.JsonFile.Info,
  DN.JsonFile.InstalledInfo,
  DN.Package.Version,
  DN.Package.Version.Intf,
  DN.Graphics.Loader,
  DN.Package.Dependency,
  DN.Package.Dependency.Intf;

{ TDNPackageLoaderDirectory }

function TDNPackageDirectoryLoader.Load(const ADirectory: string; const APackage: IDNPackage): Boolean;
var
  LInfoFile: string;
  LImageFile: string;
  LInfo: TInstalledInfoFile;
  LVersion: IDNPackageVersion;
  LDependency: IDNPackageDependency;
  LInfoDependency: TInfoDependency;
  LLicense: TDNLicense;
begin
  Result := False;
  LInfoFile := TPath.Combine(ADirectory, CInfoFile);
  APackage.Versions.Add(TDNPackageVersion.Create() as IDNPackageVersion);
  APackage.Name := ExtractFileName(ExcludeTrailingPathDelimiter(ADirectory));
  if TFile.Exists(LInfoFile) then
  begin
    LInfo := TInstalledInfoFile.Create();
    try
      if LInfo.LoadFromFile(LInfoFile) then
      begin
        if LInfo.Name <> '' then
          APackage.Name := LInfo.Name;

        APackage.Author := LInfo.Author;
        APackage.Description := LInfo.Description;
        APackage.ID := LInfo.ID;
        APackage.CompilerMin := LInfo.CompilerMin;
        APackage.CompilerMax := LInfo.CompilerMax;
        APackage.Platforms := LInfo.Platforms;
        APackage.Licenses.AddRange(LInfo.Licenses);
        for LLicense in APackage.Licenses do
          APackage.LicenseText[LLicense] := LoadLicenceText(TPath.Combine(ADirectory, LLicense.LicenseFile));
        APackage.ProjectUrl := LInfo.ProjectUrl;
        APackage.HomepageUrl := LInfo.HomepageUrl;
        APackage.ReportUrl := LInfo.ReportUrl;
        LVersion := APackage.Versions.First;
        LVersion.Name := LInfo.Version.ToString;
        LVersion.Value := LInfo.Version;

        LVersion.CompilerMin := LInfo.CompilerMin;
        LVersion.CompilerMax := LInfo.CompilerMax;
        for LInfoDependency in LInfo.Dependencies do
        begin
          LDependency := TDNPackageDependency.Create(LInfoDependency.ID, LInfoDependency.Version);
          LVersion.Dependencies.Add(LDependency);
        end;
        APackage.Versions.Add(LVersion);
        if LInfo.Picture <> '' then
        begin
          LImageFile := TPath.Combine(ADirectory, LInfo.Picture);
          TGraphicLoader.TryLoadPictureFromFile(LImageFile, APackage.Picture);
        end;
        Result := True;
      end;
    finally
      LInfo.Free;
    end;
  end;
end;

function TDNPackageDirectoryLoader.LoadLicenceText(const AFile: string): string;
var
  LFile: TStringStream;
begin
  Result := '';
  if TFile.Exists(AFile) then
  begin
    LFile := TStringStream.Create();
    try
      LFile.LoadFromFile(AFile);
      Result := LFile.DataString;
    finally
      LFile.Free;
    end;
  end;
end;

end.
