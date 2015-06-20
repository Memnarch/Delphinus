object PackageDetailView: TPackageDetailView
  Left = 0
  Top = 0
  Width = 213
  Height = 320
  TabOrder = 0
  object lbName: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 207
    Height = 23
    Align = alTop
    Caption = 'lbName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 64
  end
  object lbAuthor: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 32
    Width = 207
    Height = 23
    Align = alTop
    Caption = 'lbName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 64
  end
  object mDescription: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 192
    Width = 207
    Height = 125
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 0
    ExplicitWidth = 285
  end
  object btnInstall: TButton
    Left = 3
    Top = 161
    Width = 75
    Height = 25
    Caption = 'Install'
    TabOrder = 1
  end
  object btnUninstall: TButton
    Left = 135
    Top = 161
    Width = 75
    Height = 25
    Caption = 'Uninstall'
    Enabled = False
    TabOrder = 2
  end
end
