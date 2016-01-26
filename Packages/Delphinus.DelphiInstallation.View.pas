unit Delphinus.DelphiInstallation.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Generics.Collections, ComCtrls, DN.DelphiInstallation.Intf, Vcl.StdCtrls,
  Vcl.CheckLst;

type
  TDelphiInstallationView = class(TFrame)
    View: TCheckListBox;
    procedure ViewDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FInstallations: TList<IDNDelphiInstallation>;
    function GetInstallations: TList<IDNDelphiInstallation>;
    procedure HandleInstallationsChanged(Sender: TObject; const Item: IDNDelphiInstallation; Action: TCollectionNotification);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Installations: TList<IDNDelphiInstallation> read GetInstallations;
  end;

implementation

const
  CImageDimension = 32;

{$R *.dfm}

{ TDelphiInstallationView }

constructor TDelphiInstallationView.Create(AOwner: TComponent);
begin
  inherited;
  FInstallations := TList<IDNDelphiInstallation>.Create();
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
  if (odSelected in State) or (odFocused in State) then
    View.Canvas.DrawFocusRect(Rect);
end;

end.
