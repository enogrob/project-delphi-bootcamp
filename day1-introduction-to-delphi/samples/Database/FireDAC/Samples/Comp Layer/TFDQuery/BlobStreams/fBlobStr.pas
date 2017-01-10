//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit fBlobStr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.StdCtrls, Vcl.DBCtrls, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf,
    FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.ExprFuncs,
    FireDAC.Stan.Param, FireDAC.DApt.Intf,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.DApt, FireDAC.DatS,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.ADSDef, FireDAC.Phys.FBDef, FireDAC.Phys.PGDef,
    FireDAC.Phys.OracleDef, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.SQLite, FireDAC.Phys.Oracle,
    FireDAC.Phys.PG, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Phys.IB,
    FireDAC.Phys.IBDef, FireDAC.Phys.ADS, FireDAC.Phys.ODBCBase,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmBlobStr = class(TForm)
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDPhysADSDriverLink1: TFDPhysADSDriverLink;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDConnection1: TFDConnection;
    qInsert: TFDQuery;
    qSelect: TFDQuery;
    DataSource1: TDataSource;
    DBMemo1: TDBMemo;
    btnInsertExternal: TButton;
    btnInsertInternal: TButton;
    btnPrepare: TButton;
    procedure btnInsertExternalClick(Sender: TObject);
    procedure btnInsertInternalClick(Sender: TObject);
    procedure btnPrepareClick(Sender: TObject);
  private
    procedure ShowData;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBlobStr: TfrmBlobStr;

implementation

{$R *.dfm}

const
  C_File = '.\test_data.bin';

// "Real BLOB Streaming" feature allows to read / write BLOBs without copying
// a BLOB value through client side memory. Real BLOB Streaming works directly
// with DBMS BLOB API and streams:
// - external streams are provided from Delphi application to FireDAC;
// - intenal streams are provided from FireDAC to Delphi application and
// are the thin wrappers of DBMS BLOB API.
//
// All Real BLOB Streaming operations must be performed inside of a transaction.
// ODBC-based, InterBase and Firebird drivers require to call TFDQuery.CloseStreams
// after using the streams. For other drivers this call is optional.
//
// Internal stream reading / writing for most drivers is unidirectional and
// stream.Size / Position provides no information / does nothing.
//
// The following drivers support Real BLOB Streaming:
// - Advantage
// - DB2
// - Informix
// - InterBase / IBLite / FireBird
// - MSAccess
// - MSSQL (for FileStreams see FireDAC\Samples\DBMS Specific\MSSQL\FileStream)
// - MySQL (only external streams)
// - ODBC
// - Oracle
// - PostgreSQL (OID BLOB internal streams)
// - SQLite (only external streams)
// - SQL Anywhere
// - TeraData

{-------------------------------------------------------------------------------}
procedure TfrmBlobStr.btnPrepareClick(Sender: TObject);
const
  C_Data: AnsiString = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, ' +
    'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
var
  oFS: TFileStream;
  s: AnsiString;
  i: Integer;
begin
  DeleteFile(C_File);
  oFS := TFileStream.Create(C_File, fmCreate);
  try
    for i := 1 to 50000 do begin
      s := IntToStr(i) + C_Data;
      oFS.Write(s[1], Length(s) * SizeOf(AnsiChar));
    end;
  finally
    oFS.Free;
  end;
  if FDConnection1.RDBMSKind = TFDRDBMSKinds.PostgreSQL then
    FDConnection1.ExecSQL('delete from {id FDQA_LO}')
  else
    FDConnection1.ExecSQL('delete from {id FDQA_Blob}');
  qInsert.Disconnect;
  qSelect.Disconnect;
end;

{-------------------------------------------------------------------------------}
procedure TfrmBlobStr.ShowData;
begin
  qSelect.Disconnect;
  if FDConnection1.RDBMSKind = TFDRDBMSKinds.PostgreSQL then
    qSelect.Open('select * from {id FDQA_LO}')
  else
    qSelect.Open('select * from {id FDQA_Blob}');
end;

{-------------------------------------------------------------------------------}
procedure TfrmBlobStr.btnInsertExternalClick(Sender: TObject);
begin
  // All Real BLOB Streaming operations must be performed in a transaction.
  FDConnection1.StartTransaction;
  try
    case FDConnection1.RDBMSKind of
    TFDRDBMSKinds.PostgreSQL:
      qInsert.SQL.Text := 'insert into {id FDQA_LO} (blobdata) values (:blobdata)';
    else
      qInsert.SQL.Text := 'insert into {id FDQA_Blob} (blobdata) values (:blobdata)';
    end;
    // Set parameter data type to one of the BLOB types.
    // The external stream will copied into an internal stream.
    // The external stream will be used as-is without any conversion (eg, character set).
    qInsert.Params[0].DataType := ftOraBlob;
    // Assign external stream before ExecSQL.
    qInsert.Params[0].AsStream := TFileStream.Create(C_File, fmOpenRead);
    qInsert.ExecSQL;

    ShowData;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

{-------------------------------------------------------------------------------}
procedure TfrmBlobStr.btnInsertInternalClick(Sender: TObject);
var
  oFS: TFileStream;
begin
  // All Real BLOB Streaming operations must be performed in a transaction.
  FDConnection1.StartTransaction;
  try
    case FDConnection1.RDBMSKind of
    TFDRDBMSKinds.PostgreSQL:
      qInsert.SQL.Text := 'insert into {id FDQA_LO} (blobdata) values (:blobdata)';
    TFDRDBMSKinds.Oracle:
      qInsert.SQL.Text := 'insert into {id FDQA_Blob} (blobdata) values (EMPTY_BLOB()) returning blobdata into :blobdata';
    else
      qInsert.SQL.Text := 'insert into {id FDQA_Blob} (blobdata) values (:blobdata)';
    end;
    // Set parameter data type ftStream and do not assign stream reference.
    // The internal stream reference will be returned after ExecSQL.
    // The internal stream does not perform any conversion (eg, character set).
    qInsert.Params[0].DataType := ftStream;
    qInsert.Params[0].StreamMode := smOpenWrite;
    qInsert.ExecSQL;

    oFS := TFileStream.Create(C_File, fmOpenRead);
    try
      // Write to internal stream. The stream is available after ExecSQL.
      qInsert.Params[0].AsStream.CopyFrom(oFS, -1);
    finally
      oFS.Free;
    end;
    // Flush / close the streams. Mandatory for ODBC-based, InterBase and
    // Firebird drivers. Optional for other drivers (does nothing).
    qInsert.CloseStreams;

    ShowData;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

end.
