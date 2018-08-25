{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package.Intf;

interface

uses
  Types,
  Graphics,
  Generics.Collections,
  DN.Types,
  DN.Package.Version.Intf,
  DN.Compiler.Intf;

type
  IDNPackage = interface
  ['{A2BECB05-D5A2-4E59-A7F0-E16A6ACCC555}']
    function GetID: TGUID;
    procedure SetID(const Value: TGUID);
    function GetCompilerMax: TCompilerVersion;
    function GetCompilerMin: TCompilerVersion;
    procedure SetCompilerMax(const Value: TCompilerVersion);
    procedure SetCompilerMin(const Value: TCompilerVersion);
    function GetPlatforms: TDNCompilerPlatforms;
    procedure SetPlatforms(const Value: TDNCompilerPlatforms);
    function GetDownloadLocation: string;
    procedure SetDownloadLocation(const Value: string);
    function GetAuthor: string;
    function GetDescription: string;
    function GetName: string;
    function GetPicture: TPicture;
    procedure SetAuthor(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    function GetLastUpdated: string;
    procedure SetLastUpdated(const Value: string);
    function GetVersions: TList<IDNPackageVersion>;
    function GetLicense: TList<TDNLicense>;
    function GetLicenseText(const ALicense: TDNLicense): string;
    function GetLicenseTypes: string;
    function GetHomepageUrl: string;
    function GetProjectUrl: string;
    function GetReportUrl: string;
    procedure SetProjectUrl(const Value: string);
    procedure SetReportUrl(const Value: string);
    procedure SetHomepageUrl(const Value: string);
    procedure SetLicenseText(const ALicense: TDNLicense; const Value: string);
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
    property Licenses: TList<TDNLicense> read GetLicense;
    property LicenseText[const ALicense: TDNLicense]: string read GetLicenseText write SetLicenseText;
    property LicenseTypes: string read GetLicenseTypes;
    property ProjectUrl: string read GetProjectUrl write SetProjectUrl;
    property HomepageUrl: string read GetHomepageUrl write SetHomepageUrl;
    property ReportUrl: string read GetReportUrl write SetReportUrl;
  end;

implementation

end.
