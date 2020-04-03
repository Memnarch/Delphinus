unit DN.PackageProvider.Folder;

interface

uses
  DN.Package.Intf,
  DN.PackageProvider;

type
  TDNFolderPackageProvider = class(TDNPackageProvider)
  private
    FPath: string;
    procedure ProcessPackagesOfAuthor(const APath, AAuthor: string);
    procedure ProcessPackage(const APath, AAuthor, APackage: string);
  public
    constructor Create(const APath: string);
    function Reload: Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
  end;

implementation

uses
  IOUtils,
  SysUtils,
  Classes,
  DN.Types,
  DN.Version,
  DN.Package,
  DN.Package.Version,
  DN.Package.Dependency,
  DN.JsonFile.Info;

const
  CNoVersionDir = 'HEAD';

{ TDNFolderPackageProvider }

constructor TDNFolderPackageProvider.Create(const APath: string);
begin
  inherited Create();
  FPath := APath;
end;

function TDNFolderPackageProvider.Download(const APackage: IDNPackage;
  const AVersion, AFolder: string; out AContentFolder: string): Boolean;
var
  LPath: string;
begin
  LPath := TPath.Combine(TPath.Combine(FPath, APackage.Author), APackage.Name);
  if AVersion <> '' then
    LPath := TPath.Combine(LPath, AVersion)
  else
    LPath := TPath.Combine(LPath, CNoVersionDir);

  Result := TDirectory.Exists(LPath);
  if Result then
  begin
    TDirectory.Copy(LPath, AFolder);
    AContentFolder := AFolder;
  end;
end;

procedure TDNFolderPackageProvider.ProcessPackage(const APath, AAuthor,
  APackage: string);
var
  LVersionPath, LVersionText, LInfoPath: string;
  LPackage: TDNPackage;
  LPackageVersion: TDNPackageVersion;
  LVersion, LHighestVersion: TDNVersion;
  LInfo: TInfoFile;
  LDependency: TInfoDependency;
  LPictureFile: string;
  LLicense, LLicenseCopy: TDNLicense;
begin
  LHighestVersion := TDNVersion.Create();
  LPackage := TDNPackage.Create();
  try
    LPackage.Author := AAuthor;
    LPackage.Name := APackage;
    for LVersionPath in TDirectory.GetDirectories(APath) do
    begin
      LVersionText := ExtractFileName(LVersionPath);
      LInfoPath := TPath.Combine(LVersionPath, CInfoFile);
      if TDNVersion.TryParse(LVersionText, LVersion) and TFile.Exists(LInfoPath) then
      begin
        LInfo := TInfoFile.Create();
        try
          LInfo.LoadFromFile(LInfoPath);
          LPackageVersion := TDNPackageVersion.Create();
          try
            LPackageVersion.Name := LVersion.ToString;
            LPackageVersion.Value := LVersion;
            LPackageVersion.CompilerMin := LInfo.CompilerMin;
            LPackageVersion.CompilerMax := LInfo.CompilerMax;
            for LDependency in LInfo.Dependencies do
              LPackageVersion.Dependencies.Add(TDNPackageDependency.Create(LDependency.ID, LDependency.Version));
            if LHighestVersion.IsEmpty or (LVersion > LHighestVersion) then
            begin
              LHighestVersion := LVersion;
              LPackage.ID := LInfo.ID;
              LPackage.CompilerMin := LInfo.CompilerMin;
              LPackage.CompilerMax := LInfo.CompilerMax;
              LPackage.Platforms := LInfo.Platforms;
              for LLicense in LInfo.Licenses do
              begin
                LLicenseCopy := LLicense;
                LLicenseCopy.LicenseFile := TPath.Combine(LVersionPath, LLicense.LicenseFile);
                LPackage.Licenses.Add(LLicenseCopy);
                if TFile.Exists(LLicenseCopy.LicenseFile) then
                  LPackage.LicenseText[LLicenseCopy] := TFile.ReadAllText(LLicenseCopy.LicenseFile);
              end;
              LPictureFile := TPath.Combine(LVersionPath, LInfo.Picture);
            end;
          finally
            LPackage.Versions.Add(LPackageVersion);
          end;
        finally
          LInfo.Free;
        end;
      end;
    end;
    if TFile.Exists(LPictureFile) then
      LPackage.Picture.LoadFromFile(LPictureFile);
  finally
    if LPackage.ID <> TGuid.Empty then
      Packages.Add(LPackage)
    else
      LPackage.Free;
  end;
end;

procedure TDNFolderPackageProvider.ProcessPackagesOfAuthor(const APath,
  AAuthor: string);
var
  LDir: string;
begin
  for LDir in TDirectory.GetDirectories(APath) do
    ProcessPackage(LDir, AAuthor, ExtractFileName(LDir));
end;

function TDNFolderPackageProvider.Reload: Boolean;
var
  LDir: string;
begin
  Result := False;
  Packages.Clear;
  if TDirectory.Exists(FPath) then
  begin
    for LDir in TDirectory.GetDirectories(FPath) do
      ProcessPackagesOfAuthor(LDir, ExtractFileName(LDir));
    Result := True;
  end;
end;

end.
