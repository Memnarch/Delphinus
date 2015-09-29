{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package;

interface

uses
  Types,
  Graphics,
  Generics.Collections,
  DN.Types,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Compiler.Intf;

type
  TDNPackage = class(TInterfacedObject, IDNPackage)
  private
    FID: TGUID;
    FCompilerMin: TCompilerVersion;
    FCompilerMax: TCompilerVersion;
    FName: string;
    FAuthor: string;
    FDescription: string;
    FPicture: TPicture;
    FDownloadLocation: string;
    FLastUpdated: string;
    FVersions: TList<IDNPackageVersion>;
    FLicenseType: string;
    FLicenseText: string;
    FProjectUrl: string;
    FHomepageUrl: string;
    FReportUrl: string;
    FPlatforms: TDNCompilerPlatforms;
  protected
    function GetID: TGUID; virtual;
    procedure SetID(const Value: TGUID); virtual;
    function GetCompilerMax: TCompilerVersion; virtual;
    function GetCompilerMin: TCompilerVersion; virtual;
    procedure SetCompilerMax(const Value: TCompilerVersion); virtual;
    procedure SetCompilerMin(const Value: TCompilerVersion); virtual;
    function GetPlatforms: TDNCompilerPlatforms; virtual;
    procedure SetPlatforms(const Value: TDNCompilerPlatforms); virtual;
    function GetDownloadLocation: string; virtual;
    procedure SetDownloadLocation(const Value: string); virtual;
    function GetAuthor: string; virtual;
    function GetDescription: string; virtual;
    function GetName: string; virtual;
    function GetPicture: TPicture; virtual;
    procedure SetAuthor(const Value: string); virtual;
    procedure SetDescription(const Value: string); virtual;
    procedure SetName(const Value: string); virtual;
    function GetLastUpdated: string; virtual;
    procedure SetLastUpdated(const Value: string); virtual;
    function GetVersions: TList<IDNPackageVersion>; virtual;
    function GetLicenseText: string; virtual;
    function GetLicenseType: string; virtual;
    procedure SetLicenseText(const Value: string); virtual;
    procedure SetLicenseType(const Value: string); virtual;
    function GetHomepageUrl: string; virtual;
    function GetProjectUrl: string; virtual;
    function GetReportUrl: string; virtual;
    procedure SetProjectUrl(const Value: string); virtual;
    procedure SetReportUrl(const Value: string); virtual;
    procedure SetHomepageUrl(const Value: string); virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    property ID: TGUID read GetID write SetID;
    property CompilerMin: TCompilerVersion read GetCompilerMin write SetCompilerMin;
    property CompilerMax: TCompilerVersion read GetCompilerMax write SetCompilerMax;
    property Platforms: TDNCompilerPlatforms read GetPlatforms write SetPlatforms;
    property Author: string read GetAuthor write SetAuthor;
    property Name: string read GetName write SetName;
    property Description: string read GetDescription write SetDescription;
    property Picture: TPicture read GetPicture;
    property DownloadLoaction: string read GetDownloadLocation write SetDownloadLocation;
    property LastUpdated: string read GetLastUpdated write SetLastUpdated;
    property Versions: TList<IDNPackageVersion> read GetVersions;
    property LicenseType: string read GetLicenseType write SetLicenseType;
    property LicenseText: string read GetLicenseText write SetLicenseText;
    property ProjectUrl: string read GetProjectUrl write SetProjectUrl;
    property HomepageUrl: string read GetHomepageUrl write SetHomepageUrl;
    property ReportUrl: string read GetReportUrl write SetReportUrl;
  end;

implementation

{ TDCPMPackage }

constructor TDNPackage.Create;
begin
  inherited;
  FPicture := TPicture.Create();
  FVersions := TList<IDNPackageVersion>.Create();
end;

destructor TDNPackage.Destroy;
begin
  FVersions.Free;
  FPicture.Free;
  inherited;
end;

function TDNPackage.GetAuthor: string;
begin
  Result := FAuthor;
end;

function TDNPackage.GetCompilerMax: TCompilerVersion;
begin
  Result := FCompilerMax;
end;

function TDNPackage.GetCompilerMin: TCompilerVersion;
begin
  Result := FCompilerMin;
end;

function TDNPackage.GetDescription: string;
begin
  Result := FDescription;
end;

function TDNPackage.GetDownloadLocation: string;
begin
  Result := FDownloadLocation;
end;

function TDNPackage.GetHomepageUrl: string;
begin
  Result := FHomepageUrl;
end;

function TDNPackage.GetID: TGUID;
begin
  Result := FID;
end;

function TDNPackage.GetLastUpdated: string;
begin
  Result := FLastUpdated;
end;

function TDNPackage.GetLicenseText: string;
begin
  Result := FLicenseText;
end;

function TDNPackage.GetLicenseType: string;
begin
  Result := FLicenseType;
end;

function TDNPackage.GetName: string;
begin
  Result := FName;
end;

function TDNPackage.GetPicture: TPicture;
begin
  Result := FPicture;
end;

function TDNPackage.GetPlatforms: TDNCompilerPlatforms;
begin
  Result := FPlatforms;
end;

function TDNPackage.GetProjectUrl: string;
begin
  Result := FProjectUrl;
end;

function TDNPackage.GetReportUrl: string;
begin
  Result := FReportUrl;
end;

function TDNPackage.GetVersions: TList<IDNPackageVersion>;
begin
  Result := FVersions;
end;

procedure TDNPackage.SetAuthor(const Value: string);
begin
  FAuthor := Value;
end;

procedure TDNPackage.SetCompilerMax(const Value: TCompilerVersion);
begin
  FCompilerMax := Value;
end;

procedure TDNPackage.SetCompilerMin(const Value: TCompilerVersion);
begin
  FCompilerMin := Value;
end;

procedure TDNPackage.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TDNPackage.SetDownloadLocation(const Value: string);
begin
  FDownloadLocation := Value;
end;

procedure TDNPackage.SetHomepageUrl(const Value: string);
begin
  FHomepageUrl := Value;
end;

procedure TDNPackage.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TDNPackage.SetLastUpdated(const Value: string);
begin
  FLastUpdated := Value;
end;

procedure TDNPackage.SetLicenseText(const Value: string);
begin
  FLicenseText := Value;
end;

procedure TDNPackage.SetLicenseType(const Value: string);
begin
  FLicenseType := Value;
end;

procedure TDNPackage.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TDNPackage.SetPlatforms(const Value: TDNCompilerPlatforms);
begin
  FPlatforms := Value;
end;

procedure TDNPackage.SetProjectUrl(const Value: string);
begin
  FProjectUrl := Value;
end;

procedure TDNPackage.SetReportUrl(const Value: string);
begin
  FReportUrl := Value;
end;

end.
