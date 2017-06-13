{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Preview;

interface

uses
  Classes,
  Types,
  Windows,
  Messages,
  Delphinus.UITypes,
  Controls,
  Graphics,
  Math,
  DN.Package.Intf,
  DN.Version,
  ImgList,
  StdCtrls;

type
  TNotifyEvent = reference to procedure(Sender: TObject);

  TPreview = class(TCustomControl)
  private
    FTarget: TBitmap;
    FPackage: IDNPackage;
    FSelected: Boolean;
    FButton: TButton;
    FUpdateButton: TButton;
    FInstalledVersion: TDNVersion;
    FUpdateVersion: TDNVersion;
    FOnUpdate: TNotifyEvent;
    FOnInstall: TNotifyEvent;
    FOnUninstall: TNotifyEvent;
    FOSImages: TImageList;
    FDummyPic: TGraphic;
    procedure SetSelected(const Value: Boolean);
    procedure SetPackage(const Value: IDNPackage);
    procedure SetInstalledVersion(const Value: TDNVersion);
    procedure SetUpdateVersion(const Value: TDNVersion);
    procedure DoInstall();
    procedure DoUninstall();
    procedure DoUpdate();
    procedure HandleButtonClick(Sender: TObject);
    procedure DownSample;
    procedure UpdateControls;
    procedure PaintOsImages;
  protected
    procedure Paint; override;
    procedure SetupControls(AImages: TImageList);
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent; AOsImages: TImageList; AButtonImages: TImageList); reintroduce;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write SetPackage;
    property DummyPic: TGraphic read FDummyPic write FDummyPic;
    property Selected: Boolean read FSelected write SetSelected;
    property InstalledVersion: TDNVersion read FInstalledVersion write SetInstalledVersion;
    property UpdateVersion: TDNVersion read FUpdateVersion write SetUpdateVersion;
    property OnClick;
    property OnInstall: TNotifyEvent read FOnInstall write FOnInstall;
    property OnUninstall: TNotifyEvent read FOnUninstall write FOnUninstall;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

const
  CPreviewWidth = 256;
  CPreviewImageSize = 80;
  CPreviewHeight = CPreviewImageSize;
  CButtonHeight = 21;
  CButtonWidth = 100;
  CPadding = 3;
  CMargin = 3;
  CLeftMargin = CPadding + CMargin*2 + CPreviewImageSize;

implementation

uses
  DN.Graphics,
  DN.Types;

{ TPreview }

constructor TPreview.Create(AOwner: TComponent; AOsImages: TImageList; AButtonImages: TImageList);
begin
  inherited Create(AOwner);
  FOSImages := AOsImages;
  FTarget := TBitmap.Create();
  FTarget.PixelFormat := pf32bit;
  Width := CPreviewWidth;
  Height := CPreviewHeight + CPadding * 2;
  ShowHint := True;
  SetupControls(AButtonImages);
end;

destructor TPreview.Destroy;
begin
  FTarget.Free();
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

procedure TPreview.DownSample;
var
  LTemp: TBitmap;
  LOldMode: Integer;
begin
  LTemp := TBitmap.Create();
  try
    LTemp.PixelFormat := pf32bit;
    if Assigned(FPackage.Picture.Graphic) then
    begin
      LTemp.SetSize(FPackage.Picture.Width, FPackage.Picture.Height);
      LTemp.Canvas.Brush.Color := clWhite;
      LTemp.Canvas.FillRect(LTemp.Canvas.ClipRect);
      LTemp.Canvas.Draw(0, 0, FPackage.Picture.Graphic);
    end
    else if Assigned(FDummyPic) then
    begin
      LTemp.SetSize(FDummyPic.Width, FDummyPic.Height);
      LTemp.Canvas.Brush.Color := clWhite;
      LTemp.Canvas.FillRect(LTemp.Canvas.ClipRect);
      LTemp.Canvas.Draw(0, 0, FDummyPic);
    end;
    FTarget.SetSize(CPreviewImageSize, CPreviewImageSize);
    FTarget.Canvas.FillRect(FTarget.Canvas.ClipRect);

    LOldMode := GetStretchBltMode(FTarget.Handle);
    SetStretchBltMode(FTarget.Canvas.Handle, HALFTONE);
    StretchBlt(FTarget.Canvas.Handle, 0, 0, FTarget.Width, FTarget.Height,
    LTemp.Canvas.Handle, 0, 0, LTemp.Width, LTemp.Height, SRCCOPY);
    SetStretchBltMode(FTarget.Canvas.Handle, LOldMode);
  finally
    LTemp.Free;
  end;
end;

procedure TPreview.HandleButtonClick(Sender: TObject);
begin
  if Sender = FButton then
  begin
    if not InstalledVersion.IsEmpty then
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
      DoUpdate()
  end;
end;

procedure TPreview.Paint;
var
  LVersionString, LDescription, LLicenseType: string;
  LRect: TRect;
begin
  inherited;
  if Assigned(FPackage) then
  begin
    Canvas.Brush.Style := bsSolid;
    if Selected then
      Canvas.Brush.Color := clSkyBlue
    else
      Canvas.Brush.Color := clWindow;
    Canvas.FillRect(Canvas.ClipRect);
    Canvas.Brush.Style := bsClear;

    Canvas.Draw(CPadding, CPadding, FTarget);
    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.Font.Color := clWindowText;
    Canvas.TextOut(CLeftMargin, CMargin, FPackage.Name);
    Canvas.Font.Style := [];
    Canvas.Font.Color := clGrayText;
    Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height)), FPackage.Author);

    if FPackage.LicenseType <> '' then
      LLicenseType := FPackage.LicenseType
    else
      LLicenseType := 'No license';

    Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height))*2, LLicenseType);
    Canvas.Font.Style := [];

    if not InstalledVersion.IsEmpty then
    begin
      LVersionString := InstalledVersion.ToString;
      if not UpdateVersion.IsEmpty then
      begin
        LVersionString := LVersionString + ' -> ' + UpdateVersion.ToString;
      end;
      Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height))*3, LVersionString);
    end;

    LDescription := FPackage.Description;
    LRect.Left := CLeftMargin;
    LRect.Top := (CMargin + Abs(Canvas.Font.Height))*4;
    LRect.Right := Width - CMargin - FOSImages.Width*3 - (Width - FButton.Left);
    LRect.Bottom := Height - CPadding;
    Canvas.TextRect(LRect, LDescription, [tfWordBreak, tfEndEllipsis]);

    Canvas.Pen.Color := clBtnFace;
    Canvas.MoveTo(0, Height - 1);
    Canvas.LineTo(Width, Height - 1);
    PaintOsImages();
  end;
end;

procedure TPreview.PaintOsImages;
var
  LOffset: Integer;
  LTopOffset: Integer;
begin
  LOffset :=  FButton.Left - FOSImages.Width - CMargin;
  LTopOffset := Height - FOSImages.Height - CMargin;

  if cpLinux64 in FPackage.Platforms then
  begin
    FOSImages.Draw(Canvas, LOffset, LTopOffset, 4);
    Dec(LOffset, FOSImages.Width);
  end;

  if ([cpIOSDevice32, cpIOSDevice64] * FPackage.Platforms) <> [] then
  begin
    FOSImages.Draw(Canvas, LOffset, LTopOffset, 3);
    Dec(LOffset, FOSImages.Width);
  end;

  if cpAndroid in FPackage.Platforms then
  begin
    FOSImages.Draw(Canvas, LOffset, LTopOffset, 2);
    Dec(LOffset, FOSImages.Width);
  end;

  if cpOSX32 in FPackage.Platforms then
  begin
    FOSImages.Draw(Canvas, LOffset, LTopOffset, 1);
    Dec(LOffset, FOSImages.Width);
  end;

  if ([cpWin32, cpWin64] * FPackage.Platforms) <> [] then
  begin
    FOSImages.Draw(Canvas, LOffset, LTopOffset, 0);
  end;
end;

procedure TPreview.Resize;
begin
  inherited;
  UpdateControls();
end;

procedure TPreview.SetUpdateVersion(const Value: TDNVersion);
begin
  FUpdateVersion := Value;
  FUpdateButton.Visible := not FUpdateVersion.IsEmpty;
  UpdateControls();
  InvalidateRect(Handle, Rect(Left, Top, Width, Height), False);
end;

procedure TPreview.UpdateControls;
begin
  FButton.Left := Width - FButton.Width - CMargin;
  FUpdateButton.Left := Width - FUpdateButton.Width - CMargin;
end;

procedure TPreview.SetInstalledVersion(const Value: TDNVersion);
begin
  FInstalledVersion := Value;
  if not FInstalledVersion.IsEmpty then
  begin
    FButton.Hint := 'Uninstall';
    FButton.ImageIndex := 1;
  end
  else
  begin
    FButton.Hint := 'Install';
    FButton.ImageIndex := 0;
  end;
end;

procedure TPreview.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
  if Assigned(FPackage) then
    DownSample();
end;

procedure TPreview.SetSelected(const Value: Boolean);
begin
  if FSelected <> Value then
  begin
    FSelected := Value;
    Invalidate;
  end;
end;

procedure TPreview.SetupControls(AImages: TImageList);
begin
  FButton := TButton.Create(Self);
  FButton.Width := 38;
  FButton.Height := 38;
  FButton.Top := Height - FButton.Height - CMargin;
  FButton.OnClick := HandleButtonClick;
  FButton.Images := AImages;
  FButton.Parent := Self;

  FUpdateButton := TButton.Create(Self);
  FUpdateButton.Width := 38;
  FUpdateButton.Height := 38;
  FUpdateButton.Top := Height - FUpdateButton.Height*2 - CMargin*2;
  FUpdateButton.Visible := False;
  FUpdateButton.Hint := 'Update';
  FUpdateButton.Images := AImages;
  FUpdateButton.ImageIndex := 2;
  FUpdateButton.OnClick := HandleButtonClick;
  FUpdateButton.Parent := Self;
end;

end.
