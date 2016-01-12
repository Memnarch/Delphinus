unit DN.HttpClient;

interface

uses
  Classes,
  SysUtils,
  DN.HttpClient.Intf;

type
  TDNHttpClient = class(TInterfacedObject, IDNHttpClient)
  public
    function Get(const AUrl: string; AResponse: TStream): Integer; virtual; abstract;
    function GetText(const AUrl: string; out AResponse: string): Integer; virtual;
    function Download(const AUrl, ATargetFile: string): Integer; virtual;
  end;

implementation

{ TDNHttpClient }

function TDNHttpClient.Download(const AUrl, ATargetFile: string): Integer;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(ATargetFile, fmCreate or fmOpenReadWrite);
  try
    Result := Get(AUrl, LFile);
  finally
    LFile.Free;
  end;
end;

function TDNHttpClient.GetText(const AUrl: string;
  out AResponse: string): Integer;
var
  LText: TStringStream;
begin
  LText := TStringStream.Create();
  try
    Result := Get(AUrl, LText);
    if Result = HTTPErrorOk then
      AResponse := LText.DataString;
  finally
    LText.Free;
  end;
end;

end.
