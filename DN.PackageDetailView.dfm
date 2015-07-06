object PackageDetailView: TPackageDetailView
  Left = 0
  Top = 0
  Width = 604
  Height = 348
  Color = cl3DLight
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object pnlHeader: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 598
    Height = 128
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlHeader'
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      598
      128)
    object imgRepo: TImage
      Left = 0
      Top = 0
      Width = 128
      Height = 128
    end
    object lbDescription: TLabel
      Left = 134
      Top = 45
      Width = 464
      Height = 83
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'This is the repository Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitWidth = 427
    end
    object lbTitle: TLabel
      AlignWithMargins = True
      Left = 134
      Top = 0
      Width = 459
      Height = 39
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Name of the Repository'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlDetail: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 137
    Width = 598
    Height = 181
    Margins.Bottom = 30
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlDetail'
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      598
      181)
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 128
      Height = 33
      AutoSize = False
      Caption = 'Author:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbAuthor: TLabel
      Left = 134
      Top = 0
      Width = 464
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 0
      Top = 24
      Width = 128
      Height = 33
      AutoSize = False
      Caption = 'Supports:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbSupports: TLabel
      Left = 134
      Top = 24
      Width = 464
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbInstalledCaption: TLabel
      Left = 0
      Top = 48
      Width = 128
      Height = 33
      AutoSize = False
      Caption = 'Installed:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbInstalled: TLabel
      Left = 134
      Top = 48
      Width = 464
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Author'#39's Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
end
