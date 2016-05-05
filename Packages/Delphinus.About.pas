unit Delphinus.About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, Delphinus.Forms,
  StdCtrls;

type
  TAboutDialog = class(TForm)
    imgDelphinus: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LinkLabel1: TLinkLabel;
    LinkLabel2: TLinkLabel;
    imgIcons8: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LinkLabel3: TLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure OpenLinkInBrowser(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutDialog: TAboutDialog;

implementation

uses
  Delphinus.Resources.Names,
  ShellApi;

{$R *.dfm}

procedure TAboutDialog.FormCreate(Sender: TObject);
begin
  imgDelphinus.Picture.Icon.LoadFromResourceName(HInstance, Ico_Delphinus32);
  imgIcons8.Picture.Icon.LoadFromResourceName(HInstance, Ico_Icons8);
end;

procedure TAboutDialog.OpenLinkInBrowser(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'Open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

end.
