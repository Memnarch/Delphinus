unit DN.HttpClient.Cache.Intf;

interface

uses
  Classes;

type
  IDNHttpCacheEntry = interface
    ['{C9CF09BA-9768-4B80-9ED1-3536FD06B30B}']
    function GetETag: string;
    function GetID: string;
    procedure SetETag(const Value: string);
    procedure SetID(const Value: string);
    function GetUrl: string;
    procedure SetUrl(const Value: string);
    function GetLastModified: TDateTime;
    function GetMaxAge: Integer;
    procedure SetLastModified(const Value: TDateTime);
    procedure SetMaxAge(const Value: Integer);

    procedure Store(const ASource: TStream);
    procedure Load(const ATarget: TStream);
    function IsExpired: Boolean;
    property ID: string read GetID write SetID;
    property ETag: string read GetETag write SetETag;
    property Url: string read GetUrl write SetUrl;
    property MaxAge: Integer read GetMaxAge write SetMaxAge;
    property LastModified: TDateTime read GetLastModified write SetLastModified;
  end;

  IDNHttpCache = interface
    ['{133E667C-96D5-4E23-989A-F9CAAA508E6E}']
    procedure AddCache(const AUrl: string; AData: TStream; const CacheControl: string; const AETag: string);
    function TryGetCache(const AUrl: string; out AEntry: IDNHttpCacheEntry): Boolean;
  end;

implementation

end.
