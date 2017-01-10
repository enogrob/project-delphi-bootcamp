inherited frmMain: TfrmMain
  Left = 419
  Top = 175
  Width = 435
  Height = 513
  Caption = 'TFDEventAlerter'
  Font.Name = 'MS Sans Serif'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlTitle: TPanel
    Width = 427
    inherited bvlTitle: TBevel
      Width = 379
    end
    inherited imgAnyDAC: TImage
      Left = 379
      Width = 48
    end
    inherited lblTitle: TLabel
      Width = 253
      Caption = 'Working with DB events'
    end
  end
  inherited pnlMain: TPanel
    Width = 427
    Height = 370
    inherited pnlConnection: TPanel
      Width = 427
      inherited lblUseConnectionDef: TLabel
        Width = 126
      end
    end
    object Memo1: TMemo
      Left = 6
      Top = 131
      Width = 412
      Height = 228
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
    end
    object btnRegister: TButton
      Left = 6
      Top = 102
      Width = 130
      Height = 23
      Caption = '1.) Register events'
      Enabled = False
      TabOrder = 2
      OnClick = btnRegisterClick
    end
    object btnFire: TButton
      Left = 147
      Top = 102
      Width = 130
      Height = 23
      Caption = '2.) Fire events !'
      Enabled = False
      TabOrder = 3
      OnClick = btnFireClick
    end
    object btnUnregister: TButton
      Left = 288
      Top = 102
      Width = 130
      Height = 23
      Caption = '3.) Unregister events'
      Enabled = False
      TabOrder = 4
      OnClick = btnUnregisterClick
    end
  end
  inherited pnlButtons: TPanel
    Top = 423
    Width = 427
    inherited bvlButtons: TBevel
      Width = 427
    end
    inherited btnClose: TButton
      Left = 343
      Top = 6
    end
  end
  inherited StatusBar1: TStatusBar
    Top = 460
    Width = 427
  end
  object rgEventKinds: TRadioGroup
    Left = 8
    Top = 99
    Width = 412
    Height = 47
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Supported event kinds:'
    TabOrder = 4
    OnClick = rgEventKindsClick
  end
  object qryFireEvents: TFDQuery
    Connection = dmlMainComp.dbMain
    Left = 180
    Top = 264
  end
  object FDEventAlerter1: TFDEventAlerter
    Connection = dmlMainComp.dbMain
    Options.Timeout = 1000
    OnAlert = FDEventAlerter1Alert
    OnTimeout = FDEventAlerter1Timeout
    Left = 176
    Top = 208
  end
end
