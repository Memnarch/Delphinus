unit DN.PackageSource.Folder;

interface

uses
  DN.PackageSource,
  DN.PackageSource.ConfigPage.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageProvider.Intf;

type
  TDNFolderPackageSource = class(TDNPackageSource)
  public
    function GetName: string; override;
    function NewConfigPage: IDNPackageSourceConfigPage; override;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider; override;
    function NewSettings: IDNPackageSourceSettings; override;
  end;

implementation

uses
  DN.PackageProvider.Folder,
  DN.PackageSource.Settings.Folder,
  DN.PackageSource.ConfigPage.Folder;

{ TDNFolderPackageSource }

function TDNFolderPackageSource.GetName: string;
begin
  Result := 'Folder';
end;

function TDNFolderPackageSource.NewConfigPage: IDNPackageSourceConfigPage;
begin
  Result := TDNFolderConfigPage.Create(nil);
end;

function TDNFolderPackageSource.NewProvider(
  const ASettings: IDNPackageSourceSettings): IDNPackageProvider;
begin
  Result := TDNFolderPackageProvider.Create(ASettings[TDNFolderSourceSettings.Path].Value.ToString);
end;

function TDNFolderPackageSource.NewSettings: IDNPackageSourceSettings;
begin
  Result := TDNFolderSourceSettings.Create(GetName());
end;

end.
