unit Delphinus.ToolsApi.VSTManager;

interface

uses
  RTTI,
  Controls,
  ImgList;

type
  TNodeData = record
    ProjectManager: IInterface;
    ProjectManagerB: IInterface;
    //Padding: array[0..3] of Byte;
//    case byte of
//      0: (A, B: PChar);
//      1: (C, D: TObject);
    Padding: array[0..11] of Byte;
  end;

// mode to describe a move action
  TNodeAttachMode = (
    amNoWhere,        // just for simplified tests, means to ignore the Add/Insert command
    amInsertBefore,   // insert node just before destination (as sibling of destination)
    amInsertAfter,    // insert node just after destionation (as sibling of destination)
    amAddChildFirst,  // add node as first child of destination
    amAddChildLast    // add node as last child of destination
  );

  PNodeData = ^TNodeData;
  PNode = type Pointer;

  TVSTManager = record
  private
    FContext: TRttiContext;
    FType: TRttiInstanceType;
    FInstance: TControl;
    function GetProperty(const AName: string): TValue;
    function GetRootNode: Pointer;
    function GetNodeDataSize: Integer;
    function InvokePointer(const AName: string; AValue: Pointer): TValue;
    function GetImages: TCustomImageList;
  public
    constructor Create(AInstance: TControl);
    function GetNodeData(ANode: Pointer): PNodeData;
    function GetFirstVisible: Pointer;
    function GetFirst: Pointer;
    function GetVisibleParent(ANode: Pointer): Pointer;
    function GetNextVisible(ANode: Pointer): Pointer;
    function GetNext(ANode: Pointer): Pointer;
    function GetNextSibling(ANode: Pointer): Pointer;
    function GetFirstChild(ANode: Pointer): Pointer;
    function AddChild(AParent: Pointer): Pointer;
    function InsertNode(Node: PNode; Mode: TNodeAttachMode): PNode;
    property RootNode: Pointer read GetRootNode;
    property NodeDataSize: Integer read GetNodeDataSize;
    property Images: TCustomImageList read GetImages;
  end;

implementation

type
  PPointer = ^Pointer;

{ TVSTManager }

function TVSTManager.AddChild(AParent: Pointer): Pointer;
var
  LMethod: TRttiMethod;
  LParam: TValue;
  LParams: TArray<TRttiParameter>;
begin
  LMethod := FType.GetMethod('AddChild');
  if Assigned(LMethod) then
  begin
    LParams := LMethod.GetParameters;
    TValue.Make(@AParent, LParams[0].ParamType.Handle, LParam);
    Result := PPointer(LMethod.Invoke(FInstance, [LParam, TValue.From<Pointer>(nil)]).GetReferenceToRawData())^;
  end
  else
    Result := nil;
end;

constructor TVSTManager.Create(AInstance: TControl);
begin
  FInstance := AInstance;
  FType := FContext.GetType(FInstance.ClassType).AsInstance;
end;

function TVSTManager.GetFirst: Pointer;
var
  LMethod: TRttiMethod;
  LResult: TValue;
begin
  LMethod := FType.GetMethod('GetFirst');
  if Assigned(LMethod) then
  begin
    LResult := LMethod.Invoke(FInstance, []);
    Result := PPointer(LResult.GetReferenceToRawData())^
  end
  else
    Result := nil;
end;

function TVSTManager.GetFirstChild(ANode: Pointer): Pointer;
var
  LMethod: TRttiMethod;
  LResult, LParam: TValue;
  LParams: TArray<TRttiParameter>;
begin
  LMethod := FType.GetMethod('GetFirstChild');
  if Assigned(LMethod) then
  begin
    LParams := LMethod.GetParameters;
    TValue.Make(@ANode, LParams[0].ParamType.Handle, LParam);
    LResult := LMethod.Invoke(FInstance, [LParam]);
    Result := PPointer(LResult.GetReferenceToRawData())^
  end
  else
    Result := nil;
end;

function TVSTManager.GetFirstVisible: Pointer;
var
  LMethod: TRttiMethod;
  LResult: TValue;
begin
  LMethod := FType.GetMethod('GetFirstVisible');
  if Assigned(LMethod) then
  begin
    LResult := LMethod.Invoke(FInstance, []);
    Result := PPointer(LResult.GetReferenceToRawData())^
  end
  else
    Result := nil;
end;

function TVSTManager.GetImages: TCustomImageList;
begin
  Result := GetProperty('Images').AsType<TCustomImageList>();
end;

function TVSTManager.GetNext(ANode: Pointer): Pointer;
begin
  Result := PPointer(InvokePointer('GetNext', ANode).GetReferenceToRawData())^;
end;

function TVSTManager.GetNextSibling(ANode: Pointer): Pointer;
begin
  Result := PPointer(InvokePointer('GetNextSibling', ANode).GetReferenceToRawData())^;
end;

function TVSTManager.GetNextVisible(ANode: Pointer): Pointer;
begin
  Result := PPointer(InvokePointer('GetNextVisible', ANode).GetReferenceToRawData())^;
end;

function TVSTManager.GetNodeData(ANode: Pointer): PNodeData;
var
  LResult: TValue;
begin
  LResult := InvokePointer('GetNodeData', ANode);
  Result := PPointer(LResult.GetReferenceToRawData())^;
end;

function TVSTManager.GetNodeDataSize: Integer;
begin
  Result := GetProperty('NodeDataSize').AsInteger;
end;

function TVSTManager.GetVisibleParent(ANode: Pointer): Pointer;
var
  LMethod: TRttiMethod;
  LParam: TValue;
  LParams: TArray<TRttiParameter>;
begin
  LMethod := FType.GetMethod('GetVisibleParent');
  if Assigned(LMethod) then
  begin
    LParams := LMethod.GetParameters;
    TValue.Make(@ANode, LParams[0].ParamType.Handle, LParam);
    Result := PPointer(LMethod.Invoke(FInstance, [LParam]).GetReferenceToRawData())^;
  end
  else
    Result := nil;
end;

function TVSTManager.GetProperty(const AName: string): TValue;
var
  LProperty: TRttiProperty;
begin
  LProperty := FType.GetProperty(AName);
  if Assigned(LProperty) then
    Result := LProperty.GetValue(FInstance)
  else
    Result := TValue.Empty;
end;

function TVSTManager.GetRootNode: Pointer;
begin
  Result := PPointer(GetProperty('RootNode').GetReferenceToRawData())^;
end;

function TVSTManager.InsertNode(Node: PNode; Mode: TNodeAttachMode): PNode;
var
  LMethod: TRttiMethod;
  LParams: TArray<TRttiParameter>;
  LNode, LMode: TValue;
begin
  LMethod := FType.GetMethod('InsertNode');
  LParams := LMethod.GetParameters;
  TValue.Make(@Node, LParams[0].ParamType.Handle, LNode);
  TValue.Make(@Mode, LParams[1].ParamType.Handle, LMode);
  Result := PPointer(LMethod.Invoke(FInstance, [LNode, LMode, nil]).GetReferenceToRawData())^;
end;

function TVSTManager.InvokePointer(const AName: string;
  AValue: Pointer): TValue;
var
  LMethod: TRttiMethod;
  LParam: TValue;
  LParams: TArray<TRttiParameter>;
begin
  LMethod := FType.GetMethod(AName);
  if Assigned(LMethod) then
  begin
    LParams := LMethod.GetParameters;
    TValue.Make(@AValue, LParams[0].ParamType.Handle, LParam);
    Result := LMethod.Invoke(FInstance, [LParam]);
  end
  else
    Result := TValue.Empty;
end;

end.
