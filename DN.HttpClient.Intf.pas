unit DN.HttpClient.Intf;

interface

uses
  Classes;

const
  HTTPErrorOk = 200;
  HTTPErrorNotModified = 304;

type
  TProgressEvent = procedure (Progress, Max: Int64) of object;

  IDNHttpClient = interface
    ['{C8768468-6054-438A-81AB-7B5B1691FF94}']
    //getter and setter
    function GetAuthentication: string;
    procedure SetAuthentication(const Value: string);
    function GetOnProgress: TProgressEvent;
    procedure SetOnProgress(const Value: TProgressEvent);
    //publlic
    function Get(const AUrl: string; AResponse: TStream): Integer;
    function GetText(const AUrl: string; out AResponse: string): Integer;
    function Download(const AUrl, ATargetFile: string): Integer;
    property Authentication: string read GetAuthentication write SetAuthentication;
    property OnProgress: TProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

end.
