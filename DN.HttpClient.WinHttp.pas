unit DN.HttpClient.WinHttp;

interface

uses
  Classes,
  DN.HttpClient,
  DN.Import.WinHttp;

type
  TDNWinHttpClient = class(TDNHttpClient)
  private
    FRequest: IWinHttpRequest;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const AUrl: string; AResponse: TStream): Integer; override;
  end;

implementation

uses
  ActiveX,
  DN.HttpClient.Intf;

{ TDNWinHttpClient }

constructor TDNWinHttpClient.Create;
begin
  inherited;
  FRequest := CoWinHttpRequest.Create();
end;

destructor TDNWinHttpClient.Destroy;
begin
  FRequest := nil;
  inherited;
end;

function TDNWinHttpClient.Get(const AUrl: string; AResponse: TStream): Integer;
var
  LResponse: IStream;
  LAdapter: TStreamAdapter;
  LRead, LWritten: Int64;
begin
  FRequest.Open('Get', AUrl, False);
  FRequest.Send('');
  Result := FRequest.Status;
  if Result = HTTPErrorOk then
  begin
    LResponse := IUnknown(FRequest.ResponseStream) as IStream;
    LAdapter := TStreamAdapter.Create(AResponse);
    try
      LResponse.CopyTo(LAdapter, High(Int64), LRead, LWritten);
    finally
      LAdapter.Free;
    end;
  end;
end;

end.
