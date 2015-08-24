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
  DN.Package.Version.Intf;

type
  IDNPackage = interface
  ['{A2BECB05-D5A2-4E59-A7F0-E16A6ACCC555}']
    function GetID: TGUID;
    procedure SetID(const Value: TGUID);
    function GetCompilerMax: TCompilerVersion;
    function GetCompilerMin: TCompilerVersion;
    procedure SetCompilerMax(const Value: TCompilerVersion);
    procedure SetCompilerMin(const Value: TCompilerVersion);
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
    property ID: TGUID read GetID write SetID;
    property CompilerMin: TCompilerVersion read GetCompilerMin write SetCompilerMin;
    property CompilerMax: TCompilerVersion read GetCompilerMax write SetCompilerMax;
    property Author: string read GetAuthor write SetAuthor;
    property Name: string read GetName write SetName;
    property Description: string read GetDescription write SetDescription;
    property Picture: TPicture read GetPicture;
    property DownloadLoaction: string read GetDownloadLocation write SetDownloadLocation;
    property LastUpdated: string read GetLastUpdated write SetLastUpdated;
    property Versions: TList<IDNPackageVersion> read GetVersions;
  end;

implementation

end.
