unit DN.HttpClient.Intf;

interface

uses
  Classes;

const
  HTTPErrorOk = 200;

type
  IDNHttpClient = interface
    ['{C8768468-6054-438A-81AB-7B5B1691FF94}']
    function Get(const AUrl: string; AResponse: TStream): Integer;
    function GetText(const AUrl: string; out AResponse: string): Integer;
    function Download(const AUrl, ATargetFile: string): Integer;
  end;

implementation

end.
