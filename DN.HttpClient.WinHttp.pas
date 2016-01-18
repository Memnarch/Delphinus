unit DN.HttpClient.WinHttp;

interface

uses
  Classes,
  SysUtils,
  DN.HttpClient,
  DN.Import.WinHttp,
  DN.HttpClient.Cache.Intf;

type
  TDNWinHttpClient = class(TDNHttpClient)
  private
    FRequest: IWinHttpRequest;
    FLastThreadID: Cardinal;
    FCache: IDNHttpCache;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const AUrl: string; AResponse: TStream): Integer; override;
  end;

implementation

uses
  ActiveX,
  Windows,
  IOUtils,
  DN.Environment,
  DN.HttpClient.Intf,
  DN.HttpClient.Cache;

{ TDNWinHttpClient }

constructor TDNWinHttpClient.Create;
begin
  FCache := TDNHttpCache.Create(TPath.Combine(GetDelphinusTempFolder(), 'HttpCache'));
  inherited;
end;

destructor TDNWinHttpClient.Destroy;
begin
  FCache := nil;
  FRequest := nil;
  inherited;
end;

function TDNWinHttpClient.Get(const AUrl: string; AResponse: TStream): Integer;
var
  LResponse: IStream;
  LAdapter: IStream;
  LRead, LWritten: Int64;
  LEntry: IDNHttpCacheEntry;
  LETag, LCacheControl: WideString;
begin
  if (not Assigned(FRequest)) or (FLastThreadID <> GetCurrentThreadId())  then
  begin
    FRequest := CoWinHttpRequest.Create();
    FLastThreadID := GetCurrentThreadId();
  end;

  FRequest.Open('Get', AUrl, False);

  if Authentication <> '' then
    FRequest.SetRequestHeader('Authorization', Authentication);

  if FCache.TryGetCache(AUrl, LEntry) then
  begin
    if not LEntry.IsExpired then
    begin
      LEntry.Load(AResponse);
      Exit(HTTPErrorOk);
    end
    else
    begin
      FRequest.SetRequestHeader('If-None-Match', LEntry.ETag);
    end;
  end;

  FRequest.Send('');
  Result := FRequest.Status;

  if (Result = HTTPErrorNotModified) and Assigned(LEntry) then
  begin
    LEntry.Load(AResponse);
    Exit(HTTPErrorOk);
  end;

  if Result = HTTPErrorOk then
  begin
    LResponse := IUnknown(FRequest.ResponseStream) as IStream;
    LAdapter := TStreamAdapter.Create(AResponse);
    LResponse.CopyTo(LAdapter, High(Int64), LRead, LWritten);
    if FRequest.GetResponseHeader('ETag', LETag) = S_OK then
    begin
      if not FRequest.GetResponseHeader('cache-control', LCacheControl) = S_OK then
        LCacheControl := '';
      FCache.AddCache(AUrl, AResponse, LCacheControl, LETag);
    end;
  end;
end;

end.
