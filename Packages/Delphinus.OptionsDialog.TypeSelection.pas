unit Delphinus.OptionsDialog.TypeSelection;

interface

uses
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  DN.PackageSource.Intf;

type
  TIsNameValid = reference to function(const AName: string): Boolean;

  TTypeSelectionDialog = class(TForm)
    cbSourceType: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edSourceName: TEdit;
    procedure btnOKClick(Sender: TObject);
  private
    FOnValidateName: TIsNameValid;
    FSources: TArray<IDNPackageSource>;
    function GetSelectedSource: IDNPackageSource;
    function GetSourceName: string;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(const ASources: TArray<IDNPackageSource>); reintroduce;
    property SelectedSource: IDNPackageSource read GetSelectedSource;
    property SourceName: string read GetSourceName;
    property OnValidateName: TIsNameValid read FOnValidateName write FOnValidateName;
  end;

var
  TypeSelectionDialog: TTypeSelectionDialog;

implementation

{$R *.dfm}

procedure TTypeSelectionDialog.btnOKClick(Sender: TObject);
var
  LName: string;
begin
  if cbSourceType.ItemIndex < 0 then
  begin
    MessageDlg('You must select a sourcetype!', mtInformation, [mbOK], 0);
    Exit;
  end;

  LName := SourceName;
  if LName = '' then
  begin
    MessageDlg('Name can not be empty!', mtInformation, [mbOK], 0);
    Exit;
  end;

  if not FOnValidateName(LName) then
  begin
    MessageDlg('Name is already in use!', mtInformation, [mbOK], 0);
    Exit;
  end;
  ModalResult := mrOk;
end;

constructor TTypeSelectionDialog.Create(
  const ASources: TArray<IDNPackageSource>);
var
  LSource: IDNPackageSource;
begin
  inherited Create(nil);
  FSources := ASources;
  for LSource in FSources do
    cbSourceType.Items.Add(LSource.Name);
end;

function TTypeSelectionDialog.GetSelectedSource: IDNPackageSource;
begin
  Result := FSources[cbSourceType.ItemIndex];
end;

function TTypeSelectionDialog.GetSourceName: string;
begin
  Result := Trim(edSourceName.Text);
end;

end.
