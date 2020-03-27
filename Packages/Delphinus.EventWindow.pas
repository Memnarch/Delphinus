unit Delphinus.EventWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs;

const
  WM_Event = WM_USER + 800;

type
  TEventType = (etSetupDelphinusPackages);

  TOnEvent = procedure(AEvent: TEventType) of object;

  TEventWindow = class(TForm)
  private
    FOnEvent: TOnEvent;
    { Private declarations }
    procedure HandleWMUser(var MSG: TMessage); message WM_Event;
  public
    procedure PostEvent(AEvent: TEventType);
    property OnEvent: TOnEvent read FOnEvent write FOnEvent;
  end;

var
  EventWindow: TEventWindow;

implementation

{$R *.dfm}

{ TEventWindow }

procedure TEventWindow.HandleWMUser(var MSG: TMessage);
begin
  if Assigned(FOnEvent) then
    FOnEvent(TEventType(MSG.WParam))
end;

procedure TEventWindow.PostEvent(AEvent: TEventType);
begin
  PostMessage(Handle, WM_Event, NativeUInt(AEvent), 0);
end;

end.
