object PackageDetailView: TPackageDetailView
  Left = 0
  Top = 0
  Width = 302
  Height = 618
  Color = clBtnFace
  ParentBackground = False
  ParentColor = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object pnlHeader: TPanel
    AlignWithMargins = True
    Left = 1
    Top = 0
    Width = 301
    Height = 128
    Margins.Left = 1
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlHeader'
    Color = clWindow
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      301
      128)
    object imgRepo: TImage
      Left = 0
      Top = 0
      Width = 128
      Height = 128
      Proportional = True
      Stretch = True
    end
    object lbDescription: TLabel
      Left = 134
      Top = -3
      Width = 163
      Height = 128
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'This is the repository Description'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
      ExplicitWidth = 158
    end
  end
  object pnlDetail: TPanel
    AlignWithMargins = True
    Left = 1
    Top = 129
    Width = 301
    Height = 489
    Margins.Left = 1
    Margins.Top = 1
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlDetail'
    Color = clWindow
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      301
      489)
    object Label1: TLabel
      Left = 5
      Top = 0
      Width = 55
      Height = 18
      AutoSize = False
      Caption = 'Author:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbAuthor: TLabel
      Left = 93
      Top = -3
      Width = 204
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 199
    end
    object Label2: TLabel
      Left = 5
      Top = 23
      Width = 72
      Height = 18
      Caption = 'Supports:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbSupports: TLabel
      Left = 93
      Top = 23
      Width = 204
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 199
    end
    object lbInstalledCaption: TLabel
      Left = 5
      Top = 71
      Width = 72
      Height = 18
      Caption = 'Installed:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbInstalled: TLabel
      Left = 93
      Top = 71
      Width = 204
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 199
    end
    object Label3: TLabel
      Left = 5
      Top = 119
      Width = 62
      Height = 18
      Caption = 'License:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbLicense: TLabel
      Left = 93
      Top = 119
      Width = 204
      Height = 49
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Label5: TLabel
      Left = 5
      Top = 95
      Width = 78
      Height = 18
      Caption = 'Platforms:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbPlatforms: TLabel
      Left = 93
      Top = 95
      Width = 204
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 5
      Top = 47
      Width = 62
      Height = 18
      Caption = 'Version:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbVersion: TLabel
      Left = 93
      Top = 47
      Width = 204
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 199
    end
    object btnProject: TButton
      Left = 49
      Top = 443
      Width = 38
      Height = 38
      Hint = 'Visit project'
      Anchors = [akLeft, akBottom]
      ImageIndex = 1
      Images = ilButtons
      TabOrder = 0
      OnClick = btnProjectClick
    end
    object btnReport: TButton
      Left = 93
      Top = 443
      Width = 38
      Height = 38
      Hint = 'Report a Bug to Author'
      Anchors = [akLeft, akBottom]
      ImageIndex = 0
      Images = ilButtons
      TabOrder = 1
      OnClick = btnReportClick
    end
    object btnHome: TButton
      Left = 5
      Top = 443
      Width = 38
      Height = 38
      Anchors = [akLeft, akBottom]
      ImageIndex = 2
      Images = ilButtons
      TabOrder = 2
      OnClick = btnHomeClick
    end
  end
  object btnLicense: TButton
    Left = 3
    Top = 272
    Width = 38
    Height = 38
    Hint = 'Show License'
    Images = ilButtons
    TabOrder = 2
    OnClick = btnLicenseClick
  end
  object ilButtons: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 224
    Top = 240
  end
end
