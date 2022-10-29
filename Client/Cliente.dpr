program Cliente;

uses
  Vcl.Forms,
  uCliente in 'uCliente.pas' {frmCliente},
  uDM in 'uDM.pas' {DM: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmCliente, frmCliente);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
