{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Types;

interface

type
  TMessageType = (mtNotification, mtWarning, mtError);
  TMessageEvent = procedure(AMessageType: TMessageType; const AMessage: string) of object;
  TPathType = (tpSearchPath, tpBrowsingPath);
  TCompilerVersion = Single;

const
  CSourceSubDir = 'Source';
  CMacPackageExtension = '.dylib';
  CMacPackagePrefix = 'bpl';
  CInstallFile = 'install.json';
  CUninstallFile = 'uninstall.json';
  CInfoFile = 'info.json';
  CCacheFile = 'cache.json';


implementation

end.
