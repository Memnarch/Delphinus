unit DN.PackageSource.ConfigPage;

interface

uses
  Controls,
  Forms,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.ConfigPage.Intf;

type
  TDNSourceConfigPage = class(TFrame, IInterface, IDNPackageSourceConfigPage)
  private
    FRefCount: Integer;
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function GetParent: TWinControl;
    procedure SetParent(const AValue: TWinControl); reintroduce;
  public
    procedure Load(const ASettings: IDNPackageSourceSettings); virtual; abstract;
    procedure Save(const ASettings: IDNPackageSourceSettings); virtual; abstract;
  end;

  //Make designer happy
  TFrame = TDNSourceConfigPage;

implementation

uses
  SyncObjs;

{ TDNSourceConfigPage }

function TDNSourceConfigPage.GetParent: TWinControl;
begin
  Result := Parent;
end;

procedure TDNSourceConfigPage.SetParent(const AValue: TWinControl);
begin
  Align := alClient;
  Parent := AValue;
end;

function TDNSourceConfigPage._AddRef: Integer;
begin
  Result := TInterlocked.Increment(FRefCount);
end;

function TDNSourceConfigPage._Release: Integer;
begin
  Result := TInterlocked.Decrement(FRefCount);
  if Result = 0 then
    Self.Free;
end;

end.
