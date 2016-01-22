unit DN.HttpClient.Intf;

interface

uses
  Classes;

const
  HTTPErrorOk = 200;
  HTTPErrorNotModified = 304;

type
  TProgressEvent = procedure (Progress, Max: Int64) of object;
  TResponseSource = (rsServer, rsCache);

  IDNHttpClient = interface
    ['{C8768468-6054-438A-81AB-7B5B1691FF94}']
    //getter and setter
    function GetAuthentication: string;
    procedure SetAuthentication(const Value: string);
    function GetOnProgress: TProgressEvent;
    procedure SetOnProgress(const Value: TProgressEvent);
    function GetAccept: string;
    procedure SetAccept(const Value: string);
    function GetLastResponseSoure: TResponseSource;
    function GetIgnoreCacheExpiration: Boolean;
    procedure SetIgnoreCacheExpiration(const Value: Boolean);
    //publlic
    function Get(const AUrl: string; AResponse: TStream): Integer;
    function GetText(const AUrl: string; out AResponse: string): Integer;
    function Download(const AUrl, ATargetFile: string): Integer;
    procedure BeginWork;
    procedure EndWork;
    property Authentication: string read GetAuthentication write SetAuthentication;
    property Accept: string read GetAccept write SetAccept;
    property LastResponseSource: TResponseSource read GetLastResponseSoure;
    property IgnoreCacheExpiration: Boolean read GetIgnoreCacheExpiration write SetIgnoreCacheExpiration;
    property OnProgress: TProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

end.
