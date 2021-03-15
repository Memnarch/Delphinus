object DNGitlabSourceConfigPage: TDNGitlabSourceConfigPage
  Left = 0
  Top = 0
  Width = 320
  Height = 214
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    320
    214)
  object lblInfoToken: TLabel
    Left = 3
    Top = 95
    Width = 75
    Height = 16
    Caption = 'OAuthToken:'
  end
  object lbResponse: TLabel
    Left = 3
    Top = 147
    Width = 314
    Height = 58
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    WordWrap = True
  end
  object lblInfoBaseURL: TLabel
    Left = 3
    Top = 10
    Width = 58
    Height = 16
    Caption = 'Base URL:'
  end
  object imgAvatar: TImage
    Left = 242
    Top = 63
    Width = 75
    Height = 78
    Anchors = [akTop, akRight]
    Stretch = True
  end
  object edtOAuthToken: TEdit
    Left = 3
    Top = 117
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '*'
    TabOrder = 0
  end
  object edtBaseURL: TEdit
    Left = 3
    Top = 32
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    TextHint = 'https://gitlab.com'
    OnChange = edtBaseURLChange
  end
  object btnTestURL: TButton
    Left = 242
    Top = 32
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Test'
    TabOrder = 2
    OnClick = btnTestTokenClick
  end
  object btnSetURLGitLabCom: TButton
    Left = 2
    Top = 56
    Width = 103
    Height = 25
    Caption = 'GitLab.com'
    TabOrder = 3
    OnClick = btnSetURLGitLabComClick
  end
end
