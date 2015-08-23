{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package.Github;

interface

uses
  Classes,
  Types,
  DN.Package,
  DN.PackageProvider.Intf;

type
  TDNGitHubPackage = class(TDNPackage)
  private
    FDefaultBranch: string;
  public
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
  end;

implementation

uses
  DN.PackageProvider.Github;

{ TDNGitHubPackage }

end.

