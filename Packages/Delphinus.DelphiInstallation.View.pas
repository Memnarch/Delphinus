unit Delphinus.DelphiInstallation.View;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs,
  Generics.Collections, ComCtrls, DN.DelphiInstallation.Intf, StdCtrls,
  CheckLst, ExtCtrls;

type
  TDelphiInstallationView = class(TFrame)
    View: TCheckListBox;
    sLine: TShape;
    cbAll: TCheckBox;
    procedure ViewDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbAllClick(Sender: TObject);
    procedure ViewClickCheck(Sender: TObject);
  private
    { Private declarations }
    FInstallations: TList<IDNDelphiInstallation>;
    FSelectedInstallations: TList<IDNDelphiInstallation>;
    function GetInstallations: TList<IDNDelphiInstallation>;
    procedure HandleInstallationsChanged(Sender: TObject; const Item: IDNDelphiInstallation; Action: TCollectionNotification);
    function GetSelectedInstallations: TList<IDNDelphiInstallation>;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Installations: TList<IDNDelphiInstallation> read GetInstallations;
    property SelectedInstallations: TList<IDNDelphiInstallation> read GetSelectedInstallations;
  end;

implementation

const
  CImageDimension = 32;

{$R *.dfm}

type
  TProtectedCheckBox = class(TCheckBox);

{ TDelphiInstallationView }

procedure TDelphiInstallationView.cbAllClick(Sender: TObject);
begin
  if cbAll.State = cbGrayed then
  begin
    cbAll.State := cbChecked;
  end
  else
  begin
    if cbAll.Checked then
      View.CheckAll(cbChecked)
    else
      View.CheckAll(cbUnchecked);
  end;
end;

constructor TDelphiInstallationView.Create(AOwner: TComponent);
begin
  inherited;
  FInstallations := TList<IDNDelphiInstallation>.Create();
  FSelectedInstallations := TList<IDNDelphiInstallation>.Create();
  FInstallations.OnNotify := HandleInstallationsChanged;
  View.ItemHeight := CImageDimension + cImageMargin*2;
end;

destructor TDelphiInstallationView.Destroy;
begin
  FInstallations.OnNotify := nil;
  FInstallations.Free;
  inherited;
end;

function TDelphiInstallationView.GetInstallations: TList<IDNDelphiInstallation>;
begin
  Result := FInstallations;
end;

function TDelphiInstallationView.GetSelectedInstallations: TList<IDNDelphiInstallation>;
var
  i: Integer;
begin
  FSelectedInstallations.Clear;
  for i := 0 to FInstallations.Count - 1 do
  begin
    if View.Checked[i] then
      FSelectedInstallations.Add(FInstallations[i]);
  end;
  Result := FSelectedInstallations;
end;

procedure TDelphiInstallationView.HandleInstallationsChanged(Sender: TObject;
  const Item: IDNDelphiInstallation; Action: TCollectionNotification);
begin
  case Action of
    cnAdded:
      View.Items.Add('');
    cnRemoved, cnExtracted:
      View.Items.Delete(View.Items.Count - 1);
  end;
end;

procedure TDelphiInstallationView.ViewClickCheck(Sender: TObject);
var
  LCheckedCount: Integer;
  i: Integer;
begin
  LCheckedCount := 0;
  for i := 0 to View.Items.Count - 1 do
    if View.Checked[i] then
      Inc(LCheckedCount);

  TProtectedCheckBox(cbAll).ClicksDisabled := True;
  if (LCheckedCount > 0) and (LCheckedCount < View.Items.Count) then
    cbAll.State := cbGrayed
  else
    cbAll.Checked := LCheckedCount = View.Items.Count;

  TProtectedCheckBox(cbAll).ClicksDisabled := False;
end;

procedure TDelphiInstallationView.ViewDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LInstallation: IDNDelphiInstallation;
  LTextRect: TRect;
  LName: string;
begin
  if Index < FInstallations.Count then
  begin
    LInstallation := FInstallations[Index];
    View.Canvas.Brush.Color := View.Color;
    View.Canvas.FillRect(Rect);
    View.Canvas.Draw(Rect.Left + cImageMargin, Rect.Top + cImageMargin, LInstallation.Icon);
    LTextRect.Left := Rect.Left + CImageDimension + cImageMargin * 2;
    LTextRect.Top := Rect.Top + cImageMargin;
    LTextRect.Right := Rect.Right;
    LTextRect.Bottom := Rect.Bottom;

    View.Canvas.Font.Color := clWindowText;
    View.Canvas.Font.Style := [fsBold];
    LName := LInstallation.Name;
    View.Canvas.TextRect(LTextRect, LName);
    LTextRect.Top := LTextRect.Top + Abs(View.Canvas.Font.Height);
    View.Canvas.Font.Style := [];
    LName := LInstallation.Directory;
    View.Canvas.TextRect(LTextRect, LName);
  end;
  if [odSelected, odFocused] <= State then
    View.Canvas.DrawFocusRect(Rect);
end;

end.
