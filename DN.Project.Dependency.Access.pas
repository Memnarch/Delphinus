unit DN.Project.Dependency.Access;

interface

uses
  Generics.Collections,
  XMLIntf,
  DN.Project.Dependency.Intf,
  DN.Project.Dependency.Access.Intf;

type
  TDNProjectDependencyAccess = class(TInterfacedObject, IDNProjectDependencyAccess)
  private
    function Read(const ADelphinusNode: IXMLNode): TArray<IDNProjectPackageDependency>;
    procedure Write(const ADelphinusNode: IXMLNode; const AValue: TArray<IDNProjectPackageDependency>);
    function GetDependencies: TArray<IDNProjectPackageDependency>;
    procedure SetDependencies(const Value: TArray<IDNProjectPackageDependency>);
  protected
    function GetDelphinusNode: IXMLNode; virtual; abstract;
    function GetReadOnlyDelphinusNode: IXMLNode; virtual; abstract;
  public
    property Dependencies: TArray<IDNProjectPackageDependency> read GetDependencies write SetDependencies;
  end;

implementation

uses
  Variants,
  SysUtils,
  DN.Utils,
  DN.Version,
  DN.Project.Dependency;

const
  CPackagesNode = 'Packages';
  CPackageNode = 'Package';

{ TDNProjectDependencies }

function TDNProjectDependencyAccess.GetDependencies: TArray<IDNProjectPackageDependency>;
begin
  Result := Read(GetReadOnlyDelphinusNode());
end;

function TDNProjectDependencyAccess.Read(
  const ADelphinusNode: IXMLNode): TArray<IDNProjectPackageDependency>;
var
  LPackages, LPackage: IXMLNode;
  LItems: TList<IDNProjectPackageDependency>;
  LName, LVersionText, LIDString: string;
  LID: TGUID;
  LVersion: TDNVersion;
  i: Integer;
begin
  Result := nil;
  if not Assigned(ADelphinusNode) then
    Exit;
  LPackages := ADelphinusNode.ChildNodes.FindNode(CPackagesNode);
  if Assigned(LPackages) then
  begin
    LItems := TList<IDNProjectPackageDependency>.Create();
    try
      for i := 0 to Pred(LPackages.ChildNodes.Count) do
      begin
        LPackage := LPackages.ChildNodes[i];
        LName := VarToStr(LPackage.Attributes['Name']);
        LIDString := VarToStr(LPackage.Attributes['ID']);
        LVersionText := VarToStr(LPackage.Attributes['Version']);
        if not TDNVersion.TryParse(LVersionText, LVersion) then
          LVersion := TDNVersion.Create();
        if TryStrToGuid(LIDString, LID) and (LName <> '') then
          LItems.Add(TDNProjectPackageDependency.Create(LName, LID, LVersion));
      end;
      Result := LItems.ToArray;
    finally
      LItems.Free;
    end;
  end;
end;

procedure TDNProjectDependencyAccess.SetDependencies(
  const Value: TArray<IDNProjectPackageDependency>);
var
  LNode: IXMLNode;
begin
  LNode := GetReadOnlyDelphinusNode();
  if not Assigned(Value) and Assigned(LNode) then
    LNode.ParentNode.ChildNodes.Remove(LNode)
  else
    Write(GetDelphinusNode(), Value);
end;

procedure TDNProjectDependencyAccess.Write(const ADelphinusNode: IXMLNode;
  const AValue: TArray<IDNProjectPackageDependency>);
var
  LPackages, LPackage: IXMLNode;
  LDependency: IDNProjectPackageDependency;
begin
  LPackages := ADelphinusNode.ChildNodes.FindNode(CPackagesNode);
  if Assigned(LPackages) then
    LPackages.ChildNodes.Clear
  else
    LPackages := ADelphinusNode.AddChild(CPackagesNode);

  for LDependency in AValue do
  begin
    LPackage := LPackages.AddChild(CPackageNode);
    LPackage.Attributes['Name'] := LDependency.Name;
    LPackage.Attributes['ID'] := LDependency.ID.ToString;
    if not LDependency.Version.IsEmpty then
      LPackage.Attributes['Version'] := LDependency.Version.ToString;
  end;
end;

end.
