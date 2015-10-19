unit Delphinus.FilterProperties.Dialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls,
  Delphinus.FilterProperties, CheckLst,
  DN.Compiler.Intf;

type
  TIsNameValid = function(const AName: string): Boolean of object;

  TFilterPropertiesDialog = class(TForm)
    Label1: TLabel;
    edName: TEdit;
    clbPlatforms: TCheckListBox;
    Label2: TLabel;
    btnCacnel: TButton;
    btnOk: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FFilterProperties: TFilterProperties;
    FOnIsNameValid: TIsNameValid;
    procedure SetFilterProperties(const Value: TFilterProperties);
    procedure InitPlatforms;
    function IsNameValid(const AName: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property FilterProperties: TFilterProperties read FFilterProperties write SetFilterProperties;
    property OnIsNameValid: TIsNameValid read FOnIsNameValid write FOnIsNameValid;
  end;

var
  FilterPropertiesDialog: TFilterPropertiesDialog;

implementation

{$R *.dfm}

{ TForm1 }

constructor TFilterPropertiesDialog.Create(AOwner: TComponent);
begin
  inherited;
  InitPlatforms;
end;

procedure TFilterPropertiesDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i: Integer;
begin
  if ModalResult = mrOk then
  begin
    CanClose := IsNameValid(edName.Text);
    if CanClose then
    begin
      FFilterProperties.Caption := edName.Text;
      FFilterProperties.Platforms := [];
      for i := 0 to clbPlatforms.Count - 1 do
        if clbPlatforms.Checked[i] then
          FFilterProperties.Platforms := FFilterProperties.Platforms + [TDNCompilerPlatform(i)];

    end
    else
    begin
      ShowMessage('Name is not unique');
    end;
  end;
end;

procedure TFilterPropertiesDialog.InitPlatforms;
var
  LPlatform: TDNCompilerPlatform;
begin
  for LPlatform := Low(TDNCompilerPlatform) to High(TDNCompilerPlatform) do
    clbPlatforms.AddItem(TDNCompilerPlatformName[LPlatform], nil);
end;

function TFilterPropertiesDialog.IsNameValid(const AName: string): Boolean;
begin
  result := not Assigned(FOnIsNameValid) or FOnIsNameValid(AName);
end;

procedure TFilterPropertiesDialog.SetFilterProperties(const Value: TFilterProperties);
var
  LPlatform: TDNCompilerPlatform;
begin
  if FFilterProperties <> Value then
  begin
    FFilterProperties := Value;
    if Assigned(FFilterProperties) then
    begin
      edName.Text := FFilterProperties.Caption;
      for LPlatform in FFilterProperties.Platforms do
        clbPlatforms.Checked[Integer(LPlatform)] := True;
    end;
  end;
end;

end.
