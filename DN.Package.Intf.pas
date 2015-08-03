unit DN.Package.Intf;

interface

uses
  Types,
  Graphics,
  Generics.Collections,
  DN.Package.Version.Intf;

type
  IDNPackage = interface
  ['{A2BECB05-D5A2-4E59-A7F0-E16A6ACCC555}']
    function GetID: TGUID;
    procedure SetID(const Value: TGUID);
    function GetCompilerMax: Integer;
    function GetCompilerMin: Integer;
    procedure SetCompilerMax(const Value: Integer);
    procedure SetCompilerMin(const Value: Integer);
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
    property CompilerMin: Integer read GetCompilerMin write SetCompilerMin;
    property CompilerMax: Integer read GetCompilerMax write SetCompilerMax;
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
