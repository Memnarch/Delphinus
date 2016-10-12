unit DN.Setup.Dependency;

interface

uses
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Setup.Dependency.Intf;

type
  TDNSetupDependency = class(TInterfacedObject, IDNSetupDependency)
  private
    FAction: TDependencyAction;
    FInstalledVersion: IDNPackageVersion;
    FVersion: IDNPackageVersion;
    FPackage: IDNPackage;
    FID: TGUID;
    function GetAction: TDependencyAction;
    function GetInstalledVersion: IDNPackageVersion;
    function GetPackage: IDNPackage;
    function GetVersion: IDNPackageVersion;
    procedure SetInstalledVersion(const Value: IDNPackageVersion);
    procedure SetPackage(const Value: IDNPackage);
    procedure SetVersion(const Value: IDNPackageVersion);
    procedure SetAction(const Value: TDependencyAction);
    function GetID: TGUID;
    procedure SetID(const Value: TGUID);
  public
    property ID: TGUID read GetID write SetID;
    property Package: IDNPackage read GetPackage write SetPackage;
    property Action: TDependencyAction read GetAction write SetAction;
    property Version: IDNPackageVersion read GetVersion write SetVersion;
    property InstalledVersion: IDNPackageVersion read GetInstalledVersion write SetInstalledVersion;
  end;

implementation

{ TDNSetupDependency }

function TDNSetupDependency.GetAction: TDependencyAction;
begin
  Result := FAction;
end;

function TDNSetupDependency.GetID: TGUID;
begin
  Result := FID;
end;

function TDNSetupDependency.GetInstalledVersion: IDNPackageVersion;
begin
  Result := FInstalledVersion;
end;

function TDNSetupDependency.GetPackage: IDNPackage;
begin
  Result := FPackage;
end;

function TDNSetupDependency.GetVersion: IDNPackageVersion;
begin
  Result := FVersion;
end;

procedure TDNSetupDependency.SetAction(const Value: TDependencyAction);
begin
  FAction := Value;
end;

procedure TDNSetupDependency.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TDNSetupDependency.SetInstalledVersion(
  const Value: IDNPackageVersion);
begin
  FInstalledVersion := Value;
end;

procedure TDNSetupDependency.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
end;

procedure TDNSetupDependency.SetVersion(const Value: IDNPackageVersion);
begin
  FVersion := Value;
end;

end.
