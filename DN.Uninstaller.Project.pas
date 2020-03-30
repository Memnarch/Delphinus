unit DN.Uninstaller.Project;

interface

uses
  DN.JSonFile.Uninstallation,
  DN.EnvironmentOptions.Intf,
  DN.Uninstaller.IDE;

type
  TDNIDEProjectUninstaller = class(TDNIDEUninstaller)
  protected
    function ProcessExperts(const AExperts: TArray<TInstalledExpert>): Boolean; override;
    function ProcessPackages(const APackages: TArray<TPackage>): Boolean; override;
  public
    constructor Create(const AEnvironmentOptionsService: IDNEnvironmentOptionsService);
  end;

implementation

{ TDNIDEProjectUninstaller }

constructor TDNIDEProjectUninstaller.Create(
  const AEnvironmentOptionsService: IDNEnvironmentOptionsService);
begin
  inherited Create(AEnvironmentOptionsService, nil);
end;

function TDNIDEProjectUninstaller.ProcessExperts(
  const AExperts: TArray<TInstalledExpert>): Boolean;
begin
  Result := True;
end;

function TDNIDEProjectUninstaller.ProcessPackages(
  const APackages: TArray<TPackage>): Boolean;
begin
  Result := True;
end;

end.
