{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Zip;

interface

//code taken from
//http://www.tmssoftware.com/site/blog.asp?post=146
//and FIXED with the help of Delphi-Praxis
//http://www.delphipraxis.net/988492-post9.html
//apparently you can't use a string as namespace directly but have to convert it to OLEVariant
function ShellUnzip(AZipFile, ATargetFolder: string; AFilter: string = ''): boolean;
//procedure DecompressFiles(const Filename, DestDirectory : String);

implementation

uses
  ZLib,
  Classes,
  SysUtils,
  Comobj,
  Windows,
  Tlhelp32;

const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_AUTORENAME = 8;
  SHCONTCH_RESPONDYESTOALL = 16;
  SHCONTF_INCLUDEHIDDEN = 128;
  SHCONTF_FOLDERS = 32;
  SHCONTF_NONFOLDERS = 64;

function ShellUnzip(AZipFile, ATargetFolder: string; AFilter: string = ''): boolean;
var
  LShellObject: Variant;
  LSourceFolder, LTargetFolder: Variant;
  LShellFolderItems: Variant;
begin
  try
    LShellObject := CreateOleObject('Shell.Application');

    LSourceFolder := LShellObject.NameSpace(OLEVariant(AZipFile));
    LTargetFolder := LShellObject.NameSpace(OLEVariant(ATargetFolder));

    LShellFolderItems := LSourceFolder.Items;
    if (AFilter <> '') then
      LShellFolderItems.Filter(SHCONTF_INCLUDEHIDDEN or SHCONTF_NONFOLDERS or SHCONTF_FOLDERS, AFilter);

    LTargetFolder.CopyHere(LShellFolderItems, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
    Result := True;
  except
    Result := False;
  end;
end;

end.
