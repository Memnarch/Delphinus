unit DN.Preview;

interface

uses
  Classes,
  Types,
  Windows,
  System.UITypes,
  Controls,
  Graphics,
  DN.Package.Intf,
  DN.Controls,
  DN.Controls.Button;

type
  TNotifyEvent = reference to procedure(Sender: TObject);

  TPreview = class(TCustomControl)
  private
    FPackage: IDNPackage;
    FSelected: Boolean;
    FBGSelectedStart: TColor;
    FBGSelectedEnd: TColor;
    FBGStart: TColor;
    FBGEnd: TColor;
    FGUI: TDNControlsController;
    FButton: TDNButton;
    FUpdateButton: TDNButton;
    FInstalled: Boolean;
    FHasUpdate: Boolean;
    FOnUpdate: TNotifyEvent;
    FOnInstall: TNotifyEvent;
    FOnUninstall: TNotifyEvent;
    procedure SetSelected(const Value: Boolean);
    procedure SetPackage(const Value: IDNPackage);
    procedure SetInstalled(const Value: Boolean);
    procedure SetHasUpdate(const Value: Boolean);
    procedure DoInstall();
    procedure DoUninstall();
    procedure DoUpdate();
    procedure HandleButtonClick(Sender: TObject);
  protected
    procedure Paint; override;
    procedure SetupControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write SetPackage;
    property Selected: Boolean read FSelected write SetSelected;
    property Installed: Boolean read FInstalled write SetInstalled;
    property HasUpdate: Boolean read FHasUpdate write SetHasUpdate;
    property OnClick;
    property OnInstall: TNotifyEvent read FOnInstall write FOnInstall;
    property OnUninstall: TNotifyEvent read FOnUninstall write FOnUninstall;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

implementation

uses
  DN.Graphics;

{ TPreview }

constructor TPreview.Create(AOwner: TComponent);
begin
  inherited;
  Width := 128;
  Height := Width + 40 + 25;

  FBGSelectedStart := RGBToColor(250, 134, 30);
  FBGSelectedEnd := AlterColor(FBGSelectedStart, -5);
  FBGStart := AlterColor(clWhite, -30);
  FBGEnd := AlterColor(FBGStart, -5);
  FGUI := TDNControlsController.Create();
  FGUI.Parent := Self;
  SetupControls();
end;

destructor TPreview.Destroy;
begin
  FGUI.Free;
  inherited;
end;

procedure TPreview.DoInstall;
begin
  if Assigned(FOnInstall) then
    FOnInstall(Self);
end;

procedure TPreview.DoUninstall;
begin
  if Assigned(FOnUninstall) then
    FOnUninstall(Self);
end;

procedure TPreview.DoUpdate;
begin
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
end;

procedure TPreview.HandleButtonClick(Sender: TObject);
begin
  if Sender = FButton then
  begin
    if Installed then
    begin
      DoUninstall();
    end
    else
    begin
      DoInstall();
    end;
  end
  else
  begin
    if Sender = FUpdateButton then
      DoUpdate();
  end;
end;

procedure TPreview.Paint;
var
  LLeft, LTop: Integer;
begin
  inherited;
  if Assigned(FPackage) then
  begin
    Canvas.Brush.Style := bsClear;
//    if Selected then
//      GradientFillRectVertical(Canvas, FBGSelectedStart, FBGSelectedEnd, Rect(0, 128, Width, Height-25))
//    else
    GradientFillRectVertical(Canvas, FBGStart, FBGEnd, Rect(0, 128, Width, Height-25));



    if Assigned(FPackage.Picture.Graphic) then
    begin
      LLeft := (Width - 128) div 2;
      LTop := 0;
      Canvas.StretchDraw(Rect(LLeft, LTop, LLeft + 128, LTop + 128), FPackage.Picture.Graphic);
    end;
    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.TextOut(5, Width, FPackage.Name);
    Canvas.Font.Style := [];
    Canvas.TextOut(5, Width + 20, FPackage.Author);

    Canvas.Pen.Color := clBtnShadow; //cl3DLight;
    Canvas.Rectangle(0, 0, Width, Height-24);
    FGui.PaintTo(Canvas);
  end;
end;

procedure TPreview.SetHasUpdate(const Value: Boolean);
begin
  FHasUpdate := Value;
  FUpdateButton.Visible := FHasUpdate;
  if FHasUpdate then
  begin
    FButton.Width := Width div 2;
    FButton.Left := Width div 2;
  end
  else
  begin
    FButton.Left := 0;
    FButton.Width := Width;
  end;
end;

procedure TPreview.SetInstalled(const Value: Boolean);
begin
  FInstalled := Value;
  if FInstalled then
  begin
    FButton.Caption := 'Uninstall';
    FButton.HoverColor := RGBToColor(224, 25, 51); //clRed;
  end
  else
  begin
    FButton.Caption := 'Install';
    FButton.HoverColor := RGBToColor(151, 224, 25) //clGreen;
  end;
end;

procedure TPreview.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
end;

procedure TPreview.SetSelected(const Value: Boolean);
begin
  if FSelected <> Value then
  begin
    FSelected := Value;
    Invalidate;
  end;
end;

procedure TPreview.SetupControls;
begin
  FButton := TDNButton.Create();
  FButton.Left := 0;
  FButton.Top := Height - 25;
  FButton.Width := Width;
  FButton.Height := 25;
  FButton.Color := clSilver;
  FButton.OnClick := HandleButtonClick;
  FGUI.Controls.Add(FButton);
  FUpdateButton := TDNButton.Create();
  FUpdateButton.Left := 0;
  FUpdateButton.Top := Height - 25;
  FUpdateButton.Width := Width div 2;
  FUpdateButton.Height := 25;
  FUpdateButton.Color := clSilver;
  FUpdateButton.HoverColor := RGBToColor(153, 242, 222);
  FUpdateButton.Visible := False;
  FUpdateButton.Caption := 'Update';
  FUpdateButton.OnClick := HandleButtonClick;
  FGUI.Controls.Add(FUpdateButton);
end;

end.
