unit DN.HttpClient.WinHttp;

interface

uses
  Classes,
  SysUtils,
  DN.HttpClient,
  DN.Import.WinHttp;

type
  TDNWinHttpClient = class(TDNHttpClient)
  private
    FRequest: IWinHttpRequest;
    FLastThreadID: Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const AUrl: string; AResponse: TStream): Integer; override;
  end;

implementation

uses
  ActiveX,
  Windows,
  DN.HttpClient.Intf;

{ TDNWinHttpClient }

constructor TDNWinHttpClient.Create;
begin
  inherited;
end;

destructor TDNWinHttpClient.Destroy;
begin
  FRequest := nil;
  inherited;
end;

function TDNWinHttpClient.Get(const AUrl: string; AResponse: TStream): Integer;
var
  LResponse: IStream;
  LAdapter: IStream;
  LRead, LWritten: Int64;
begin

  if (not Assigned(FRequest)) or (FLastThreadID <> GetCurrentThreadId())  then
  begin
    FRequest := CoWinHttpRequest.Create();
    FLastThreadID := GetCurrentThreadId();
  end;
  FRequest.Open('Get', AUrl, False);
  FRequest.SetRequestHeader('Authorization', Authentication);
  FRequest.Send('');
  Result := FRequest.Status;
  if Result = HTTPErrorOk then
  begin
    LResponse := IUnknown(FRequest.ResponseStream) as IStream;
    LAdapter := TStreamAdapter.Create(AResponse);
    LResponse.CopyTo(LAdapter, High(Int64), LRead, LWritten);
  end;
end;

end.
