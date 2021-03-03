object DNGithubSourceConfigPage: TDNGithubSourceConfigPage
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    320
    240)
  object Label1: TLabel
    Left = 3
    Top = 3
    Width = 75
    Height = 16
    Caption = 'OAuthToken:'
  end
  object lbResponse: TLabel
    Left = 3
    Top = 54
    Width = 314
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  object edOAuthToken: TEdit
    Left = 3
    Top = 24
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '*'
    TabOrder = 0
  end
  object btnTest: TButton
    Left = 242
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Test'
    TabOrder = 1
    OnClick = btnTestClick
  end
end
