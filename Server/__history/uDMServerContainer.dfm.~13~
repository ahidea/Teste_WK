object ServerContainer1: TServerContainer1
  Height = 175
  Width = 317
  object DSServer1: TDSServer
    Left = 96
    Top = 11
  end
  object DSHTTPService1: TDSHTTPService
    HttpPort = 8080
    Server = DSServer1
    Filters = <>
    Left = 160
    Top = 63
  end
  object DSServerClass1: TDSServerClass
    OnGetClass = DSServerClass1GetClass
    Server = DSServer1
    Left = 56
    Top = 83
  end
end
