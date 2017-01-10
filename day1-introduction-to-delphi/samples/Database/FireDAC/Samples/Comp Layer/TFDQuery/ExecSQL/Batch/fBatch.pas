//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit fBatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fMainCompBase, ComCtrls, StdCtrls, ExtCtrls, Buttons, DB, Grids, DBGrids,
  fMainQueryBase,
  FireDAC.Stan.Intf, FireDAC.DatS, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.VCLUI.ResourceOptions, FireDAC.VCLUI.FetchOptions,
    FireDAC.VCLUI.FormatOptions, FireDAC.VCLUI.UpdateOptions,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.VCLUI.Controls, FireDAC.Stan.Error;

type
  TfrmBatch = class(TfrmMainQueryBase)
    qryBatch: TFDQuery;
    cbxInsertBlob: TCheckBox;
    cbxBatchExec: TCheckBox;
    edtArraySize: TLabeledEdit;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    btnExecSQL: TButton;
    btnDisconnect: TButton;
    qrySelect: TFDQuery;
    pnlControlButtons: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure cbxInsertBlobClick(Sender: TObject);
    procedure cbDBClick(Sender: TObject);
    procedure btnExecSQLClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBatch: TfrmBatch;

implementation

uses dmMainComp, fMainBase;

{$R *.dfm}

procedure TfrmBatch.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  RegisterDS(qryBatch);
end;

procedure TfrmBatch.cbDBClick(Sender: TObject);
begin
  inherited cbDBClick(Sender);

  cbxInsertBlobClick(nil);
  btnExecSQL.Enabled := True;
  btnDisconnect.Enabled := True;
  cbDB.Enabled := False;
end;

procedure TfrmBatch.cbxInsertBlobClick(Sender: TObject);
begin
  if cbxInsertBlob.Checked then
    qryBatch.SQL.Text := 'insert into {id FDQA_Batch_test}(tint, tstring, tblob) values(:f1, :f2, :f3)'
  else
    qryBatch.SQL.Text := 'insert into {id FDQA_Batch_test}(tint, tstring) values(:f1, :f2)';
end;

procedure TfrmBatch.btnExecSQLClick(Sender: TObject);
var
  i: Integer;
  iTm: LongWord;
begin
  qrySelect.Open;
  qrySelect.ServerDeleteAll(True);
  qrySelect.Close;
  with qryBatch do
    if cbxBatchExec.Checked then begin
      Params.ArraySize := StrToInt(edtArraySize.Text);
      iTm := GetTickCount;
      for i := 0 to Params.ArraySize - 1 do begin
        Params[0].AsIntegers[i] := i;
        Params[1].AsStrings[i] := 'string' + IntToStr(i);
        Params[1].Size := 20;
        if cbxInsertBlob.Checked then
          Params[2].AsBlobs[i] := 'blob' + IntToStr(i);
      end;
      Execute(Params.ArraySize);
      iTm := GetTickCount - iTm;
    end
    else begin
      Params.ArraySize := 1;
      iTm := GetTickCount;
      for i := 0 to StrToInt(edtArraySize.Text) - 1 do begin
        Params[0].AsInteger := i;
        Params[1].AsString := 'string' + IntToStr(i);
        Params[1].Size := 20;
        if cbxInsertBlob.Checked then
          Params[2].AsBlob := 'blob' + IntToStr(i);
        ExecSQL;
      end;
      iTm := GetTickCount - iTm;
    end;
  StatusBar1.SimpleText := 'Time executing is ' + FloatToStr(iTm / 1000.0) + ' sec.';
  qrySelect.Open;
end;

procedure TfrmBatch.btnDisconnectClick(Sender: TObject);
begin
  if qrySelect.Active then
    qrySelect.Active := False;
  cbDB.Enabled := True;
end;

end.
