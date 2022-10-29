unit uDM;

interface

uses
  System.SysUtils, System.Classes, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, FireDAC.Stan.Async, FireDAC.DApt;

type
  TDM = class(TDataModule)
    RESTRequestGET_ping: TRESTRequest;
    RESTResponseGET_ping: TRESTResponse;
    RESTRequest_PUT: TRESTRequest;
    RESTResponse_PUT: TRESTResponse;
    RESTRequest_GET: TRESTRequest;
    RESTResponse_GET: TRESTResponse;
    REST_Pessoa: TRESTClient;
    RESTRequest_POST: TRESTRequest;
    RESTResponse_POST: TRESTResponse;
    RESTRequest_DELETE: TRESTRequest;
    RESTResponse_DELETE: TRESTResponse;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
