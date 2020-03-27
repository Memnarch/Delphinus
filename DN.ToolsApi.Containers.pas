unit DN.ToolsApi.Containers;

interface

uses
  Classes,
  DN.ToolsApi;

type
  TContainer = class(TInterfacedObject)
  private
    function GetModelContainer: IModelContainer;
    function GetParent: IGraphLocation;
    function GetProject: ICustomProjectGroupProject;
    function GetImageIndex: Integer;
    procedure SetImageIndex(const Value: Integer);
    function GetNodeDataInterfaceA: IInterface;
    function GetNodeDataInterfaceB: IInterface;
    function GetDisplayName: string;
    function GetChildren: IInterfaceList;
  public
    class function CreateCategory(const AParent: TContainer; const ACaption, AIdent: string): TContainer;
    property ModelContainer: IModelContainer read GetModelContainer;
    property Parent: IGraphLocation read GetParent;
    property Project: ICustomProjectGroupProject read GetProject;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    property DisplayName: string read GetDisplayName;
    property Children: IInterfaceList read GetChildren;
    property NodeDataInterfaceA: IInterface read GetNodeDataInterfaceA;
    property NodeDataInterfaceB: IInterface read GetNodeDataInterfaceB;
  end;

  TProjectContainer = class(TContainer);
  TBuildConfigurationContainer = class(TContainer);
  TTargetPlatformContainer = class(TContainer);
  TDelphinusPackagesContainer = class(TContainer);
  TDelphinusPackageContainer = class(TContainer);

implementation

uses
  RTTI;

const
  CCategoryContainerClass = 'Containers.TStdContainerCategory';
  CProjectInterfaceType = 'CodeMgr.ICustomProjectGroupProject';
  CModelContainerInterfaceType = 'ProjectIntf.IModelContainer';
  CCgraphLocationInterfaceType = 'IDEModel.IGraphLocation';

{ TContainer }

class function TContainer.CreateCategory(const AParent: TContainer; const ACaption, AIdent: string): TContainer;
var
  LRTTI: TRttiContext;
  LCategoryType: TRttiInstanceType;
  LMethod: TRttiMethod;
  LParams: TArray<TRttiParameter>;
  LModel, LProject, LParent: TValue;
  LTempIntf: IInterface;
begin
  Result := nil;
  LCategoryType := LRTTI.FindType(CCategoryContainerClass).AsInstance;
  for LMethod in LCategoryType.GetMethods() do
  begin
    if LMethod.IsConstructor then
    begin
      LParams := LMethod.GetParameters;
      LTempIntf := AParent.ModelContainer;
      TValue.Make(@LTempIntf, LParams[0].ParamType.Handle, LModel);
      LTempIntf := AParent.Project;
      TValue.Make(@LTempIntf, LParams[1].ParamType.Handle, LProject);
      LTempIntf := TInterfacedObject(AParent) as IGraphLocation;
      TValue.Make(@LTempIntf, LParams[2].ParamType.Handle, LParent);
      Result := TContainer(LMethod.Invoke(LCategoryType.MetaclassType, [LModel, LProject, LParent, ACaption, AIdent, '']).AsObject);
      Break;
    end;
  end;
end;

function TContainer.GetChildren: IInterfaceList;
var
  LContext: TRttiContext;
begin
  Result := LContext.GetType(ClassType).GetField('FChildren').GetValue(Self).AsType<IInterfaceList>();
end;

function TContainer.GetDisplayName: string;
var
  LContext: TRttiContext;
begin
  Result := LContext.GetType(ClassType).GetField('FDisplayName').GetValue(Self).AsString;
end;

function TContainer.GetImageIndex: Integer;
var
  LContext: TRttiContext;
begin
  Result := LContext.GetType(ClassType).GetField('FImageIndex').GetValue(Self).AsInteger;
end;

function TContainer.GetModelContainer: IModelContainer;
var
  LRTTI: TRttiContext;
  LType: TRttiInstanceType;
begin
  LType := LRTTI.GetType(ClassType).AsInstance;
  Result := IModelContainer(LType.GetField('FModelContainer').GetValue(Self).AsInterface());
end;

function TContainer.GetNodeDataInterfaceA: IInterface;
begin
  Result := IInterface(NativeUInt(Self) + $B4);
end;

function TContainer.GetNodeDataInterfaceB: IInterface;
begin
  Result := IInterface(NativeUInt(Self) + $34);
end;

function TContainer.GetParent: IGraphLocation;
var
  LRTTI: TRttiContext;
begin
  Result := IGraphLocation(LRTTI.GetType(ClassType).GetField('FGraphParent').GetValue(Self).AsInterface());
end;

function TContainer.GetProject: ICustomProjectGroupProject;
var
  LRTTI: TRttiContext;
begin
  Result := ICustomProjectGroupProject(LRTTI.GetType(ClassType).GetField('FProject').GetValue(Self).AsInterface());
end;

procedure TContainer.SetImageIndex(const Value: Integer);
var
  LContext: TRttiContext;
begin
  LContext.GetType(ClassType).GetField('FImageIndex').SetValue(Self, Value);
end;

end.
