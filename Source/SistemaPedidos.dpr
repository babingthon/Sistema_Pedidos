program SistemaPedidos;

uses
  Vcl.Forms,
  uView.Pedido in 'View\uView.Pedido.pas' {ViewPedido},
  uModel.Cliente in 'Model\uModel.Cliente.pas',
  uModel.Produto in 'Model\uModel.Produto.pas',
  uController.Pedido in 'Controller\uController.Pedido.pas',
  uModel.Pedido in 'Model\uModel.Pedido.pas',
  uInterfaces in 'uInterfaces.pas',
  uDataModule.DB in 'Shared\uDataModule.DB.pas' {DM_DB: TDataModule};

{$R *.res}

var
  LDataModule: TDM_DB;
  LController: TControllerPedido;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TViewPedido, ViewPedido);

  LDataModule := TDM_DB.Create(nil);
  LController := TControllerPedido.Create(LDataModule, LDataModule, LDataModule);

  ViewPedido.SetController(LController);

  Application.Run;

  LController.Free;
  LDataModule.Free;
end.

