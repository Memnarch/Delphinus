unit Delphinus.ProgressDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ComCtrls,
  DN.ComCtrls.Helper;

type
  TProgressDialog = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
  private
    function GetTask: string;
    procedure SetTask(const Value: string);
    function GetProgress: Integer;
    procedure SetProgress(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    property Task: string read GetTask write SetTask;
    property Progress: Integer read GetProgress write SetProgress;
  end;

var
  ProgressDialog: TProgressDialog;

implementation

{$R *.dfm}

{ TProgressDialog }

function TProgressDialog.GetProgress: Integer;
begin
  Result := ProgressBar1.Position;
end;

function TProgressDialog.GetTask: string;
begin
  Result := Label1.Caption;
end;

procedure TProgressDialog.SetProgress(const Value: Integer);
begin
  ProgressBar1.Position := Value;
  if Value < 0 then
    ProgressBar1.Style := pbstMarquee
  else
    ProgressBar1.Style := pbstNormal;
end;

procedure TProgressDialog.SetTask(const Value: string);
begin
  Label1.Caption := Value;
end;

end.
