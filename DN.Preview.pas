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
    FInstallColor: TColor;
    FUninstallColor: TColor;
    FUpdateColor: TColor;
    FInfoColor: TColor;
    FGUI: TDNControlsController;
    FButton: TDNButton;
    FUpdateButton: TDNButton;
    FInfoButton: TDNButton;
    FInstalledVersion: string;
    FUpdateVersion: string;
    FOnUpdate: TNotifyEvent;
    FOnInstall: TNotifyEvent;
    FOnUninstall: TNotifyEvent;
    FOnInfo: TNotifyEvent;
    procedure SetSelected(const Value: Boolean);
    procedure SetPackage(const Value: IDNPackage);
    procedure SetInstalledVersion(const Value: string);
    procedure SetUpdateVersion(const Value: string);
    procedure DoInstall();
    procedure DoUninstall();
    procedure DoUpdate();
    procedure DoInfo();
    procedure HandleButtonClick(Sender: TObject);
  protected
    procedure Paint; override;
    procedure SetupControls;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write SetPackage;
    property Selected: Boolean read FSelected write SetSelected;
    property InstalledVersion: string read FInstalledVersion write SetInstalledVersion;
    property UpdateVersion: string read FUpdateVersion write SetUpdateVersion;
    property OnClick;
    property OnInstall: TNotifyEvent read FOnInstall write FOnInstall;
    property OnUninstall: TNotifyEvent read FOnUninstall write FOnUninstall;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnInfo: TNotifyEvent read FOnInfo write FOnInfo;
  end;

const
  CPreviewWidth = 256;
  CPreviewImageSize = 128;//
  CPreviewHeight = CPreviewImageSize;

implementation

uses
  DN.Graphics;

{ TPreview }

procedure TPreview.CMMouseEnter(var Message: TMessage);
begin
  if Message.LParam = 0 then
    FInfoButton.Visible := True;

  inherited;
end;

procedure TPreview.CMMouseLeave(var Message: TMessage);
begin
  if Message.LParam = 0 then
    FInfoButton.Visible := False;

  inherited;
end;

constructor TPreview.Create(AOwner: TComponent);
begin
  inherited;
  Width := CPreviewWidth;
  Height := CPreviewHeight; //Width + 25 + Abs(Canvas.Font.Height*3) + 5;

  FBGSelectedStart := RGB(250, 134, 30);
  FBGSelectedEnd := AlterColor(FBGSelectedStart, -5);
  FBGStart := AlterColor(clWhite, -30);
  FBGEnd := AlterColor(FBGStart, -5);
  FInstallColor := RGB(151, 224, 25);
  FUninstallColor := RGB(224, 25, 51);
  FUpdateColor := RGB(153, 242, 222);
  FInfoColor := RGB(242, 211, 153);
  FGUI := TDNControlsController.Create();
  FGUI.Parent := Self;
  SetupControls();
end;

destructor TPreview.Destroy;
begin
  FGUI.Free;
  inherited;
end;

procedure TPreview.DoInfo;
begin
  if Assigned(FOnInfo) then
    FOnInfo(Self);
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
    if InstalledVersion <> '' then
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
    else if Sender = FInfoButton then
      DoInfo();
  end;
end;

procedure TPreview.Paint;
var
  LVersionString, LDescription, LLicenseType: string;
  LRect: TRect;
const
  CMargin = 3;
  CLeftMargin = CMargin*2 + CPreviewImageSize;
begin
  inherited;
  if Assigned(FPackage) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(Canvas.ClipRect);
    Canvas.Brush.Style := bsClear;



    if Assigned(FPackage.Picture.Graphic) then
    begin
      Canvas.StretchDraw(Rect(0, 0, CPreviewImageSize, CPreviewImageSize), FPackage.Picture.Graphic);
    end;

    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.TextOut(CLeftMargin, CMargin, FPackage.Name);
    Canvas.Font.Style := [];
    Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height)), FPackage.Author);

    if FPackage.LicenseType <> '' then
      LLicenseType := FPackage.LicenseType
    else
      LLicenseType := 'No license';

    Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height))*2, LLicenseType);
    Canvas.Font.Style := [];

    if InstalledVersion <> '' then
    begin
      LVersionString := InstalledVersion;
      if UpdateVersion <> '' then
      begin
        LVersionString := LVersionString + ' -> ' + UpdateVersion;
      end;
      Canvas.TextOut(CLeftMargin, (CMargin + Abs(Canvas.Font.Height))*3, LVersionString);
    end;

    LDescription := FPackage.Description;
    LRect.Left := CLeftMargin;
    LRect.Top := (CMargin + Abs(Canvas.Font.Height))*4;
    LRect.Right := Width - CMargin;
    LRect.Bottom := Height - 25 - CMargin;
    Canvas.TextRect(LRect, LDescription, [tfWordBreak, tfEndEllipsis]);

    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(0, 0, Width, Height);
    FGui.PaintTo(Canvas);
  end;
end;

procedure TPreview.SetUpdateVersion(const Value: string);
begin
  FUpdateVersion := Value;
  FUpdateButton.Visible := FUpdateVersion <> '';
  if FUpdateVersion <> '' then
  begin
    FButton.Width := (Width - CPreviewImageSize) div 2;
    FButton.Left := CPreviewImageSize + FButton.Width;
  end
  else
  begin
    FButton.Left := CPreviewImageSize;
    FButton.Width := Width - CPreviewImageSize;
  end;
  InvalidateRect(Handle, Rect(Left, Top, Width, Height), False);
end;

procedure TPreview.SetInstalledVersion(const Value: string);
begin
  FInstalledVersion := Value;
  if FInstalledVersion <> '' then
  begin
    FButton.Caption := 'Uninstall';
    FButton.HoverColor := FUninstallColor; //clRed;
  end
  else
  begin
    FButton.Caption := 'Install';
    FButton.HoverColor := FInstallColor //clGreen;
  end;
  InvalidateRect(Handle, Rect(Left, Top, Width, Height), False);
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
  FButton.Left := CPreviewImageSize;
  FButton.Top := Height - 25;
  FButton.Width := Width - CPreviewImageSize;
  FButton.Height := 25;
  FButton.Color := clSilver;
  FButton.OnClick := HandleButtonClick;
  FGUI.Controls.Add(FButton);

  FUpdateButton := TDNButton.Create();
  FUpdateButton.Left := CPreviewImageSize;
  FUpdateButton.Top := Height - 25;
  FUpdateButton.Width := (Width - CPreviewImageSize) div 2;
  FUpdateButton.Height := 25;
  FUpdateButton.Color := clSilver;
  FUpdateButton.HoverColor := FUpdateColor;
  FUpdateButton.Visible := False;
  FUpdateButton.Caption := 'Update';
  FUpdateButton.OnClick := HandleButtonClick;
  FGUI.Controls.Add(FUpdateButton);

  FInfoButton := TDNButton.Create();
  FInfoButton.Left := Width - 25;
  FInfoButton.Top := CPreviewImageSize-50;// Height - 50;
  FInfoButton.Width := 25;
  FInfoButton.Height := 25;
  FInfoButton.Color := clSilver;
  FInfoButton.HoverColor := FInfoColor;
  FInfoButton.Caption := 'i';
  FInfoButton.Visible := False;
  FInfoButton.OnClick := HandleButtonClick;
  FGUI.Controls.Add(FInfoButton);
end;

end.
