{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Controls.Button;

interface

uses
  Types,
  Delphinus.UITypes,
  Windows,
  Graphics,
  Math,
  DN.Controls;

type
  TDNButton = class(TDNControl)
  private
    FColor: TColor;
    FEndColor: TColor;
    FBorderColor: TColor;
    FHoverColor: TColor;
    FEndHoverColor: TColor;
    FBorderHoverColor: TColor;
    FHoverDownColor: TColor;
    FEndHoverDownColor: TColor;
    FBorderHoverDownColor: TColor;
    FCaption: string;
    procedure SetColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetCaption(const Value: string);
  public
    procedure PaintTo(ACanvas: TCanvas); override;
    property Color: TColor read FColor write SetColor;
    property HoverColor: TColor read FHoverColor write SetHoverColor;
    property Caption: string read FCaption write SetCaption;
  end;

implementation

uses
  DN.Graphics;

const
  CAlterForEnd =  -10;
  CAlterForBorder = -25;
  CAlterDown = +10;
  CAlterEndDown = -20;
  CAlterEndForBorderDown = 0;

{ TDNButton }

procedure TDNButton.PaintTo(ACanvas: TCanvas);
var
  LSize: TSize;
begin
  inherited;
  if dnsMouseIn in State then
  begin
    if dnsMouseLeft in State then
    begin
      GradientFillRectVertical(ACanvas, FHoverDownColor, FEndHoverDownColor, Rect(Left, Top, Left + Width, Top + Height));
      ACanvas.Pen.Color := FBorderHoverDownColor;
      ACanvas.Brush.Style := bsClear;
      ACanvas.Rectangle(Left, Top, Left+Width, Top + Height);
    end
    else
    begin
      GradientFillRectVertical(ACanvas, FHoverColor, FEndHoverColor, Rect(Left, Top, Left + Width, Top + Height));
      ACanvas.Pen.Color := FBorderHoverColor;
      ACanvas.Brush.Style := bsClear;
      ACanvas.Rectangle(Left, Top, Left+Width, Top + Height);
    end;
  end
  else
  begin
    GradientFillRectVertical(ACanvas, FColor, FEndColor, Rect(Left, Top, Left + Width, Top + Height));
    ACanvas.Pen.Color := FBorderColor;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(Left, Top, Left+Width, Top + Height);
  end;
  if Caption <> '' then
  begin
    LSize := ACanvas.TextExtent(Caption);
    ACanvas.TextOut(Left + (Width - LSize.cx) div 2,
      Top + (Height - LSize.cy) div 2, Caption);
  end;
end;

procedure TDNButton.SetCaption(const Value: string);
begin
  FCaption := Value;
  Changed();
end;

procedure TDNButton.SetColor(const Value: TColor);
begin
  FColor := Value;
  FEndColor := AlterColor(FColor, CAlterForEnd);
  FBorderColor := AlterColor(FColor, CAlterForBorder);
end;

procedure TDNButton.SetHoverColor(const Value: TColor);
begin
  FHoverColor := Value;
  FEndHoverColor := AlterColor(FHoverColor, CAlterForEnd);
  FBorderHoverColor := AlterColor(FHoverColor, CAlterForBorder);

//  FHoverDownColor := ALterColor(Value, CAlterDown);
//  FEndHoverDownColor := AlterColor(FHoverDownColor, CAlterEndDown);
//  FBorderHoverDownColor := AlterColor(FEndHoverDownColor, CAlterEndForBorderDown);
  FHoverDownColor := FEndHoverColor;
  FEndHoverDownColor := AlterColor(FHoverColor, CAlterDown);
  FBorderHoverDownColor := FBorderHoverColor;
end;

end.
