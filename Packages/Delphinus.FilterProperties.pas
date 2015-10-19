unit Delphinus.FilterProperties;

interface

uses
  DN.Compiler.Intf;

type
  TFilterProperties = class
  private
    FPlatforms: TDNCompilerPlatforms;
    FCaption: string;
  public
    property Caption: string read FCaption write FCaption;
    property Platforms: TDNCompilerPlatforms read FPlatforms write FPlatforms;
  end;

implementation

end.
