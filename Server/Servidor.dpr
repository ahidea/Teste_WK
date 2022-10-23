program Servidor;

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uServidor in 'uServidor.pas' {frmServer},
  uServerMethods in 'uServerMethods.pas' {ServerMethods1: TDSServerModule},
  uDMServerContainer in 'uDMServerContainer.pas' {ServerContainer1: TDataModule},
  uDMConexao in 'uDMConexao.pas' {DataModule1: TDataModule},
  uPessoa in 'uPessoa.pas' {DMPessoa: TDSServerModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerContainer1, ServerContainer1);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TfrmServer, frmServer);
  Application.CreateForm(TDMPessoa, DMPessoa);
  Application.Run;
end.

