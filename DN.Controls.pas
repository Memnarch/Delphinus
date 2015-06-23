unit DN.Controls;

interface

uses
  Classes,
  Types,
  Windows,
  Controls,
  Graphics,
  Generics.Collections;

type
  TDNControlState = (dnsMouseIn, dnsMouseLeft);
  TDNControlStates = set of TDNControlState;
  TDNControlsController = class;

  TDNControl = class
  private
    FWidth: Integer;
    FTop: Integer;
    FHeight: Integer;
    FLeft: Integer;
    FState: TDNControlStates;
    FOnClick: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  protected
    procedure MouseEnter; virtual;
    procedure MouseLeave; virtual;
    procedure Click; virtual;
    procedure Changed; virtual;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  public
    constructor Create();
    procedure UpdateMousePos(const APos: TPoint);
    procedure MouseDown(AButton: TMouseButton); virtual;
    procedure MouseUp(AButton: TMouseButton); virtual;
    procedure PaintTo(ACanvas: TCanvas); virtual;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property State: TDNControlStates read FState;
    property Visible: Boolean read FVisible write SetVisible;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TDNControlsController = class
  private
    FControls: TObjectList<TDNControl>;
    FParent: TWinControl;
    procedure SetParent(const Value: TWinControl);
    procedure HandleMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure HandleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HandleMouseLeave(Sender: TObject);
    procedure HandleControlsChanged(Sender: TObject; const Item: TDNControl;
      Action: TCollectionNotification);
    procedure HandleControlChanged(Sender: TObject);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure PaintTo(ACanvas: TCanvas);
    property Parent: TWinControl read FParent write SetParent;
    property Controls: TObjectList<TDNControl> read FControls;
  end;

implementation

uses
  Math;
{ TDNControl }

procedure TDNControl.Changed;
begin
  if Visible and Assigned(FOnChanged) then
  begin
    FOnChanged(Self);
  end;
end;

procedure TDNControl.Click;
begin
  if Visible and Assigned(FOnClick) then
    FOnClick(Self);
end;

constructor TDNControl.Create;
begin
  inherited;
  FVisible := True;
end;

procedure TDNControl.MouseDown(AButton: TMouseButton);
begin
  if (dnsMouseIn in FState) and (mbLeft = AButton) then
  begin
    Include(FState, dnsMouseLeft);
    Changed();
  end;
end;

procedure TDNControl.MouseEnter;
begin

end;

procedure TDNControl.MouseLeave;
begin

end;

procedure TDNControl.MouseUp(AButton: TMouseButton);
begin
  if (dnsMouseLeft in FState) and (mbLeft = AButton) then
  begin
    Exclude(FState, dnsMouseLeft);
    if dnsMouseIn in FState then
      Click();

    Changed();
  end;
end;

procedure TDNControl.PaintTo(ACanvas: TCanvas);
begin

end;

procedure TDNControl.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  Changed();
end;

procedure TDNControl.UpdateMousePos(const APos: TPoint);
var
  LIsInRect: Boolean;
begin
  LIsInRect := PtInRect(Rect(Left, Top, Left+Width, Top+Height), APos);
  if LIsInRect then
  begin
    if not (dnsMouseIn in FState) then
    begin
      Include(FState, dnsMouseIn);
      MouseEnter();
      Changed();
    end;
  end
  else
  begin
    if (dnsMouseIn in FState) then
    begin
      Exclude(FState, dnsMouseIn);
      MouseLeave();
      Changed();
    end;
  end;
end;

{ TDNControlsController }

constructor TDNControlsController.Create;
begin
  inherited;
  FControls := TObjectList<TDNControl>.Create();
  FControls.OnNotify := HandleControlsChanged;
end;

destructor TDNControlsController.Destroy;
begin
  Parent := nil;
  FControls.Free;
  inherited;
end;

procedure TDNControlsController.HandleControlChanged(Sender: TObject);
var
  LRect: TRect;
begin
  if Assigned(FParent) and FParent.HandleAllocated then
  begin
    LRect.Left := TDNControl(Sender).Left;
    LRect.Top := TDNControl(Sender).Top;
    LRect.Right := TDNControl(Sender).Left + TDNControl(Sender).Width;
    LRect.Bottom := TDNControl(Sender).Top + TDNControl(Sender).Height;
    InvalidateRect(FParent.Handle, @LRect, False);
  end;
end;

procedure TDNControlsController.HandleControlsChanged(Sender: TObject;
  const Item: TDNControl; Action: TCollectionNotification);
begin
  case Action of
    cnAdded: Item.OnChanged := HandleControlChanged;
    cnRemoved, cnExtracted: Item.OnChanged := nil;
  end;
end;

procedure TDNControlsController.HandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LControl: TDNControl;
begin
  for LControl in FControls do
  begin
    LControl.MouseDown(Button);
  end;
end;

procedure TDNControlsController.HandleMouseLeave(Sender: TObject);
begin
  HandleMouseMove(Sender, [], -1, -1);
end;

procedure TDNControlsController.HandleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LControl: TDNControl;
begin
  for LControl in FControls do
  begin
    LControl.UpdateMousePos(Point(X, Y));
  end;
end;

procedure TDNControlsController.HandleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LControl: TDNControl;
begin
  for LControl in FControls do
  begin
    LControl.MouseUp(Button);
  end;
end;

procedure TDNControlsController.PaintTo(ACanvas: TCanvas);
var
  LControl: TDNControl;
begin
  for LControl in FControls do
  begin
    if LControl.Visible then
      LControl.PaintTo(ACanvas);
  end;
end;

type
  TOverride = class(TWinControl);

procedure TDNControlsController.SetParent(const Value: TWinControl);
begin
  if Assigned(FParent) then
  begin
    TOverride(FParent).OnMouseMove := nil;
    TOverride(FParent).OnMouseUp := nil;
    TOverride(FParent).OnMouseDown := nil;
    TOverride(FParent).OnMouseLeave := nil;
  end;
  FParent := Value;
  if Assigned(FParent) then
  begin
    TOverride(FParent).OnMouseMove := HandleMouseMove;
    TOverride(FParent).OnMouseUp := HandleMouseUp;
    TOverride(FParent).OnMouseDown := HandleMouseDown;
    TOverride(FParent).OnMouseLeave := HandleMouseLeave;
  end;
end;

end.
