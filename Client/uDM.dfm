object DM: TDM
  Height = 444
  Width = 350
  object RESTpessoa: TRESTClient
    BaseURL = 'http://localhost:9000'
    Params = <>
    SynchronizedEvents = False
    Left = 64
    Top = 24
  end
  object RESTRequestGET: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTpessoa
    Params = <>
    Resource = 'pessoa/31'
    Response = RESTResponseGET
    SynchronizedEvents = False
    Left = 64
    Top = 96
  end
  object RESTResponseGET: TRESTResponse
    Left = 168
    Top = 96
  end
  object RESTRequestGET_ping: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTpessoa
    Params = <>
    Resource = 'ping'
    Response = RESTResponseGET_ping
    SynchronizedEvents = False
    Left = 64
    Top = 352
  end
  object RESTResponseGET_ping: TRESTResponse
    Left = 200
    Top = 352
  end
  object RESTRequestPOST: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTpessoa
    Method = rmPOST
    Params = <
      item
        Kind = pkREQUESTBODY
        Name = 'body8627DF54B8DC40158975D27A39FE11A1'
        Value = 
          '{'#13#10'    "flnatureza": 1,'#13#10'    "dsdocumento": "000.000.0031-23",'#13#10 +
          '    "nmprimeiro": "Allan",'#13#10'    "nmsegundo": "Silva",'#13#10'    "cep"' +
          ': "07092-090"'#13#10'}'#13#10#13#10
        ContentTypeStr = 'application/json'
      end>
    Resource = 'pessoa'
    Response = RESTResponsePOST
    SynchronizedEvents = False
    Left = 64
    Top = 160
  end
  object RESTResponsePOST: TRESTResponse
    Left = 176
    Top = 160
  end
  object RESTRequestPUT: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTpessoa
    Method = rmPUT
    Params = <
      item
        Kind = pkREQUESTBODY
        Name = 'bodyFB9C0610E65F4EDCAF37C47E05141BD6'
        Value = 
          '{"idpessoa":32,"flnatureza":1,"dsdocumento":"000.000.0031-23","n' +
          'mprimeiro":"Allan","nmsegundo":"Silvano","cep":"07092-090"}'
        ContentTypeStr = 'application/json'
      end>
    Resource = 'pessoa'
    Response = RESTResponsePUT
    SynchronizedEvents = False
    Left = 64
    Top = 224
  end
  object RESTResponsePUT: TRESTResponse
    Left = 176
    Top = 224
  end
  object RESTRequestDELETE: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTpessoa
    Method = rmDELETE
    Params = <
      item
        Kind = pkREQUESTBODY
        Name = 'body9CE5BE882D1F4B52A0A6A724822C5859'
        Value = 
          '{"idpessoa":32,"flnatureza":1,"dsdocumento":"000.000.0031-23","n' +
          'mprimeiro":"Allan","nmsegundo":"Silvano","cep":"07092-090"}'
        ContentTypeStr = 'application/json'
      end>
    Resource = 'pessoa/33'
    Response = RESTResponseDELETE
    SynchronizedEvents = False
    Left = 64
    Top = 288
  end
  object RESTResponseDELETE: TRESTResponse
    Left = 192
    Top = 288
  end
end
