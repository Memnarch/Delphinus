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
  TDNCompilerTarget = (ctBuild, ctCompile);
  TDNCompilerConfig = (ccRelease, ccDebug);
  TDNCompilerPlatform = (cpWin32, cpWin64, cpOSX32, cpAndroid, cpIOSDevice32, cpIOSDevice64, cpLinux64);
  TDNCompilerPlatforms = set of TDNCompilerPlatform;

const
  CSourceSubDir = 'Source';
  CMacPackageExtension = '.dylib';
  CMacPackagePrefix = 'bpl';
  CInstallFile = 'Delphinus.Install.json';
  CUninstallFile = 'Delphinus.Uninstall.json';
  CInfoFile = 'Delphinus.Info.json';
  CCacheFile = 'Delphinus.Cache.json';

  CInstallFileFilter = 'InstallationFile|' + CInstallFile;
  CUninstallFileFilter = 'UninstallFile|' + CUninstallFile;


implementation

end.
