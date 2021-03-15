unit Delphinus.Theming;

interface

uses
  SysUtils,
  Graphics,
  Windows;

const
  CBlendPrimary = 0.87;
  CBlendSecondary = 0.54;
  CBlendDisabled = 0.38;
  CBlendDivider = 0.12;

  CPrimaryColor: TColor = $fe4f30; //$304ffe;
  CAccentColor: TColor = $5b18c2;//$c2185b;

function BlendColor(ABackground, AForeground: TColor; AForegroundAlpha: Single): TColor;

implementation

type
  TColorRec = packed record
    R, G, B, A: Byte;
  end;

function BlendColor(ABackground, AForeground: TColor; AForegroundAlpha: Single): TColor;
var
  LBackgroundAlpha: Single;
  LBackground, LForeground: TColorRec;
begin
  LBackgroundAlpha := 1 - AForegroundAlpha;
  LBackground := TColorRec(ColorToRGB(ABackground));
  LForeground := TColorRec(ColorToRGB(AForeground));
  TColorRec(Result).R := Round(LBackground.R * LBackgroundAlpha + LForeground.R * AForegroundAlpha);
  TColorRec(Result).G := Round(LBackground.G * LBackgroundAlpha + LForeground.G * AForegroundAlpha);
  TColorRec(Result).B := Round(LBackground.B * LBackgroundAlpha + LForeground.B * AForegroundAlpha);
  TColorRec(Result).A := Round(LBackground.A * LBackgroundAlpha + LForeground.A * AForegroundAlpha);
end;

end.
