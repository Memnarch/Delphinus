unit DN.Package.Finder;

interface

uses
  DN.Package.Intf,
  DN.Package.Finder.Intf;

type
  TDNPackageFinder = class(TInterfacedObject, IDNPackageFinder)
  private
    FPackages: TArray<IDNPackage>;
  public
    constructor Create(const APackages: TArray<IDNPackage>);
    function TryFind(const ANameOrID: string; out APackage: IDNPackage): Boolean;
    function Find(const ANameOrID: string): IDNPackage;
  end;

implementation

uses
  SysUtils,
  StrUtils;

{ TPackageFinder }

constructor TDNPackageFinder.Create(const APackages: TArray<IDNPackage>);
begin
  inherited Create();
  FPackages := APackages;
end;

function TDNPackageFinder.Find(const ANameOrID: string): IDNPackage;
begin
  if not TryFind(ANameOrID, Result) then
    raise Exception.Create('Could not resolve Package ' + ANameOrID);
end;

function TDNPackageFinder.TryFind(const ANameOrID: string;
  out APackage: IDNPackage): Boolean;
var
  LPackage: IDNPackage;
  LID: TGUID;
begin
  if StartsStr('{', ANameOrID) and EndsStr('}', ANameOrID) then
  begin
    LID := StringToGUID(ANameOrID);
    for LPackage in FPackages do
      if IsEqualGUID(LID, LPackage.ID) then
      begin
        APackage := LPackage;
        Exit(True);
      end;
  end
  else
  begin
    for LPackage in FPackages do
      if SameText(LPackage.Name, ANameOrID) then
      begin
        APackage := LPackage;
        Exit(True);
      end;
  end;
  Result := False;
end;

end.
