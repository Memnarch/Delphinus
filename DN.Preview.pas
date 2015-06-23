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
  DN.Controls;

type
  TPreview = class(TCustomControl)
  private
    FPackage: IDNPackage;
    FSelected: Boolean;
    FBGSelectedStart: TColor;
    FBGSelectedEnd: TColor;
    FBGStart: TColor;
    FBGEnd: TColor;
    FGUI: TDNControlsController;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Paint; override;
    procedure SetupControls;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write FPackage;
    property Selected: Boolean read FSelected write SetSelected;
    property OnClick;
  end;

implementation

uses
  DN.Graphics,
  DN.Controls.Button;

{ TPreview }

constructor TPreview.Create(AOwner: TComponent);
begin
  inherited;
  Width := 128;
  Height := Width + 40 + 25;

  FBGSelectedStart := RGBToColor(250, 134, 30);
  FBGSelectedEnd := AlterColor(FBGSelectedStart, -5);
  FBGStart := AlterColor(clWhite, 0);
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

procedure TPreview.Paint;
var
  LLeft, LTop: Integer;
begin
  inherited;
  if Assigned(FPackage) then
  begin
    Canvas.Brush.Style := bsClear;
    if Selected then
      GradientFillRectVertical(Canvas, FBGSelectedStart, FBGSelectedEnd, Rect(0, 128, Width, Height))
    else
      GradientFillRectVertical(Canvas, FBGStart, FBGEnd, Rect(0, 128, Width, Height));

    FGui.PaintTo(Canvas);

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
//    Canvas.Brush.Style := bsClear;
//    if Selected then
//    begin
//      Canvas.Pen.Color := clBlue;
//      Canvas.Pen.Width := 1;
//    end
//    else
//    begin
      Canvas.Pen.Color := cl3DLight;
//      Canvas.Pen.Width := 1;
//    end;
    Canvas.Rectangle(0, 0, Width, Height-25);
  end;
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
var
  LButton: TDNButton;
begin
  LButton := TDNButton.Create();
  LButton.Left := 0;
  LButton.Top := Height - 25;
  LButton.Width := Width;
  LButton.Height := 25;
  LButton.Color := clSilver;
  LButton.HoverColor := clGreen;
  LButton.Caption := 'Install';
  FGUI.Controls.Add(LButton);
end;

end.
