unit DN.Preview;

interface

uses
  Classes,
  Types,
  System.UITypes,
  Controls,
  Graphics,
  DN.Package.Intf;

type
  TPreview = class(TCustomControl)
  private
    FPackage: IDNPackage;
    FSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write FPackage;
    property Selected: Boolean read FSelected write SetSelected;
    property OnClick;
  end;

implementation

{ TPreview }

constructor TPreview.Create(AOwner: TComponent);
begin
  inherited;
  Width := 138;
  Height := Width+40;
end;

destructor TPreview.Destroy;
begin

  inherited;
end;

procedure TPreview.Paint;
var
  LLeft, LTop: Integer;
begin
  inherited;
  if Assigned(FPackage) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Canvas.ClipRect);
    if Assigned(FPackage.Picture.Graphic) then
    begin
      LLeft := (Width - 128) div 2;
      LTop := 5;
      Canvas.StretchDraw(Rect(LLeft, LTop, LLeft + 128, LTop + 128), FPackage.Picture.Graphic);
    end;
    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.TextOut(5, Width, FPackage.Name);
    Canvas.Font.Style := [];
    Canvas.TextOut(5, Width + 20, FPackage.Author);
    Canvas.Brush.Style := bsClear;
    if Selected then
    begin
      Canvas.Pen.Color := clBlue;
      Canvas.Pen.Width := 1;
    end
    else
    begin
      Canvas.Pen.Color := clNone;
      Canvas.Pen.Width := 1;
    end;
    Canvas.Rectangle(0, 0, Width, Height);
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

end.
