object DM: TDM
  Height = 444
  Width = 367
  object RESTRequestGET_ping: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = REST_Pessoa
    Params = <>
    Resource = 'ping'
    Response = RESTResponseGET_ping
    SynchronizedEvents = False
    Left = 80
    Top = 336
  end
  object RESTResponseGET_ping: TRESTResponse
    Left = 224
    Top = 336
  end
  object RESTRequest_PUT: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = REST_Pessoa
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
    Resource = 'Pessoa'
    Response = RESTResponse_PUT
    SynchronizedEvents = False
    Left = 80
    Top = 208
  end
  object RESTResponse_PUT: TRESTResponse
    Left = 192
    Top = 208
  end
  object RESTRequest_GET: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = REST_Pessoa
    Params = <>
    Resource = 'Pessoa/id'
    Response = RESTResponse_GET
    SynchronizedEvents = False
    Left = 80
    Top = 80
  end
  object RESTResponse_GET: TRESTResponse
    Left = 192
    Top = 80
  end
  object REST_Pessoa: TRESTClient
    BaseURL = 'http://localhost:9000/datasnap/rest/TServerMethods'
    Params = <>
    SynchronizedEvents = False
    Left = 80
    Top = 16
  end
  object RESTRequest_POST: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = REST_Pessoa
    Params = <>
    Resource = 'Pessoa'
    Response = RESTResponse_POST
    SynchronizedEvents = False
    Left = 80
    Top = 144
  end
  object RESTResponse_POST: TRESTResponse
    Left = 200
    Top = 144
  end
  object RESTRequest_DELETE: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = REST_Pessoa
    Params = <>
    Resource = 'Pessoa/id'
    Response = RESTResponse_DELETE
    SynchronizedEvents = False
    Left = 80
    Top = 272
  end
  object RESTResponse_DELETE: TRESTResponse
    Left = 208
    Top = 272
  end
end
