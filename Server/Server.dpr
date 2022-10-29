program Server;
{$APPTYPE GUI}

{$R *.dres}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uServer in 'uServer.pas' {frmServer},
  uServerMethods in 'uServerMethods.pas',
  uWebModule in 'uWebModule.pas' {WebModule1: TWebModule},
  uDMConexao in 'uDMConexao.pas' {DataModule1: TDataModule},
  uPessoa in 'uPessoa.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfrmServer, frmServer);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
