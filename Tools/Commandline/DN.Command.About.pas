unit DN.Command.About;

interface

uses
  DN.Command;

type
  TDNCommandAbout = class(TDNCommand)
  public
    procedure Execute; override;
    class function Name: string; override;
    class function Description: string; override;
  end;

implementation

uses
  DN.Version;

{ TDNCommandAbout }

class function TDNCommandAbout.Description: string;
begin
  Result := 'Displays information about this tool';
end;

procedure TDNCommandAbout.Execute;
begin
  inherited;
  Writeln('');
  Writeln('Delphinus Package Manager Commandline');
  Writeln('');
  Writeln('Author:       Alexander Benikowski');
  Writeln('Projectpage:  https://github.com/Memnarch/Delphinus');
  Writeln('Blog:         http://memnarch.bplaced.net/');
  Writeln('');
  Writeln('This project is currently in Beta. Please provide feedback to improve the project');
  Writeln('');
  Writeln('Special thanks to Icons8.com for providing the icons');
end;

class function TDNCommandAbout.Name: string;
begin
  Result := 'About';
end;

end.
