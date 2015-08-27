object SetupDialog: TSetupDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Setup'
  ClientHeight = 300
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcSteps: TPageControl
    Left = 0
    Top = 0
    Width = 564
    Height = 300
    ActivePage = tsMainPage
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 0
    object tsMainPage: TTabSheet
      Caption = 'tsMainPage'
      TabVisible = False
      DesignSize = (
        556
        290)
      object Image1: TImage
        Left = 3
        Top = 51
        Width = 128
        Height = 128
        Stretch = True
      end
      object lbActionInstallUpdate: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 550
        Height = 35
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'lbActionInstallUpdate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 19
        ExplicitTop = -21
      end
      object lbNameInstallUpdate: TLabel
        AlignWithMargins = True
        Left = 137
        Top = 51
        Width = 416
        Height = 35
        AutoSize = False
        Caption = 'lbActionInstallUpdate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Shape1: TShape
        AlignWithMargins = True
        Left = 3
        Top = 185
        Width = 550
        Height = 1
        Anchors = [akLeft, akRight]
      end
      object Shape2: TShape
        AlignWithMargins = True
        Left = 3
        Top = 44
        Width = 550
        Height = 1
        Align = alTop
        ExplicitLeft = 0
        ExplicitTop = 37
        ExplicitWidth = 556
      end
      object lbDescriptionInstallUpdate: TLabel
        Left = 137
        Top = 92
        Width = 416
        Height = 37
        AutoSize = False
        Caption = 'lbDescriptionInstallUpdate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label1: TLabel
        Left = 137
        Top = 139
        Width = 39
        Height = 13
        Caption = 'Version:'
      end
      object lbLicenseAnotation: TLabel
        Left = 3
        Top = 192
        Width = 550
        Height = 13
        AutoSize = False
        Caption = 
          'By clicking OK, you accept the License provided within the packa' +
          'ge'
      end
      object Label3: TLabel
        Left = 137
        Top = 120
        Width = 39
        Height = 13
        Caption = 'License:'
      end
      object lbLicenseType: TLabel
        Left = 182
        Top = 120
        Width = 39
        Height = 13
        Caption = 'License:'
      end
      object btnOK: TButton
        Left = 397
        Top = 262
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'OK'
        TabOrder = 0
        OnClick = HandleOK
      end
      object btnCancel: TButton
        Left = 478
        Top = 262
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
      object cbVersion: TComboBox
        Left = 137
        Top = 158
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 2
      end
      object btnLicense: TButton
        Left = 288
        Top = 154
        Width = 75
        Height = 25
        Caption = 'Show License'
        TabOrder = 3
        OnClick = btnLicenseClick
      end
    end
    object tsLog: TTabSheet
      Caption = 'tsLog'
      ImageIndex = 2
      TabVisible = False
      object mLog: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 550
        Height = 284
        Align = alClient
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
end
