unit Simple.DataSet.Tool;

interface

uses
  Simple.DataSet.Tool.Interfaces,
  Simple.DataSet.Tool.Parameters,
  Simple.DataSet.Tool.Parameters.Builder,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Variants,
  Data.DB,
  Datasnap.DBClient,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

type
  TDatasetEvent = reference to procedure(dataset : TDataSet);

  TSimpleDataSetTool = class
  private
  public
    class procedure copyDataSet(origem, destino : TDataSet);
    class procedure copyRecord(origem, destino : TDataSet; autoAppend : Boolean = True);
    class procedure copyField(origem, destino : TField);
    class procedure setParams(query : TFDQuery; origem : TDataSet); overload;
    class procedure setParams(query : TFDQuery; parameters : TArray<ISimpleDataSetToolParameter>); overload;
    class procedure setParams(cds : TClientDataSet; origem : TDataSet); overload;
    class procedure setParams(cds : TClientDataSet; parameters : TArray<ISimpleDataSetToolParameter>); overload;
    class procedure forEach(dataSet : TDataSet; procedimento : TProc; filter : string = '');
    class function execute(connection : TFDConnection; sql : String; Origem: String = ''): Integer; overload;
    class function execute(connection : TFDConnection; sql : String; parameter : ISimpleDataSetToolParameter; Origem: String = ''): Integer; overload;
    class function execute(connection : TFDConnection; sql : String; parameters : TArray<ISimpleDataSetToolParameter>; Origem: String = ''): Integer; overload;
    class function executeDirect(connection : TFDConnection; sql : String; Origem: String = ''): Integer; overload;
    class function open(connection : TFDConnection; sql : String): TDataSet; overload;
    class function open(connection : TFDConnection; sql : String; parameter : ISimpleDataSetToolParameter): TDataSet; overload;
    class function open(connection : TFDConnection; sql : String; parameters : TArray<ISimpleDataSetToolParameter>): TDataSet; overload;

    class function exists(connection : TFDConnection; sql : String): Boolean; overload;
    class function exists(connection : TFDConnection; sql : String; parameter : ISimpleDataSetToolParameter): Boolean; overload;
    class function exists(connection : TFDConnection; sql : String; parameters : TArray<ISimpleDataSetToolParameter>): Boolean; overload;

    class procedure DisableControls(container: TComponent);
    class procedure EnableControls(container: TComponent);

    class procedure copyStruture(origem : TDataSet; destino : TClientDataSet);
    class function firstResult(connection : TFDConnection; sql : String) : Variant; overload;
    class function firstResult(connection : TFDConnection; sql : String; parameter : ISimpleDataSetToolParameter) : Variant; overload;
    class function firstResult(connection : TFDConnection; sql : String; parameters : TArray<ISimpleDataSetToolParameter>) : Variant; overload;
    class procedure recriaClientDataSet(cds : TClientDataSet);
    class procedure closeDataSets(container: TComponent);
    class procedure forceEnableControls(dataset : TDataSet);
    class procedure texto2Blob(campoBlob : TBlobField; texto : String);
    class function blob2Texto(campoBlob : TBlobField) : string;

    class procedure cloneRecord(dataset : TDataSet; fields : TArray<ISimpleDataSetToolParameter>);
    class procedure setFields(dataset : TDataSet; parameters : TArray<ISimpleDataSetToolParameter>);

    class procedure reOpenDataSet(dataset : TDataSet);

    class procedure setConnection(container: TComponent;
      connection: TFDConnection); static;
  end;

implementation

{ TSimpleDataSetTool }

class function TSimpleDataSetTool.blob2Texto(campoBlob: TBlobField): string;
begin
  Result := TEncoding.UTF8.GetString(campoBlob.AsBytes);
end;

class procedure TSimpleDataSetTool.cloneRecord(dataset: TDataSet; fields: TArray<ISimpleDataSetToolParameter>);
var
  FClientDataSet : TClientDataSet;
begin
  FClientDataSet := TClientDataSet.Create(nil);
  dataset.DisableControls;
  try
    copyStruture(dataset, FClientDataSet);
    FClientDataSet.CreateDataSet;
    copyRecord(dataset, FClientDataSet);
    dataset.Append;
    try
      copyRecord(FClientDataSet, dataset, False);
      setFields(dataset, fields);
      dataset.Post;
    except
      if dataset.State in dsEditModes then
        dataset.Cancel;
      raise;
    end;
  finally
    FClientDataSet.Free;
    dataset.EnableControls;
  end;
end;

class procedure TSimpleDataSetTool.closeDataSets(container: TComponent);
var
  i : Integer;
  dst : TDataSet;
begin
  for i := 0 to container.ComponentCount - 1 do
    if container.Components[i] is TDataSet then
    begin
      dst := (container.Components[i] as TDataSet);
      if dst.Active then
      begin
        if dst.State in dsEditModes then
          dst.Cancel;
        dst.Close;
      end;
    end;
end;

class procedure TSimpleDataSetTool.copyDataSet(origem, destino: TDataSet);
var
  bk : TBookmark;
begin
  origem.DisableControls;
  destino.DisableControls;
  bk := origem.GetBookmark;
  try
    origem.First;
    while not origem.Eof do
      begin
        copyRecord(origem, destino);
        origem.Next;
      end;
  finally
    origem.GotoBookmark(bk);
    origem.FreeBookmark(bk);
    origem.EnableControls;
    destino.First;
    destino.EnableControls;
  end;
end;

class procedure TSimpleDataSetTool.copyField(origem, destino: TField);
begin
  if origem.IsNull then
    destino.Clear
  else
    begin
      case destino.DataType of
        ftSmallint,
        ftInteger,
        ftWord,
        ftShortint,
        ftLongWord: destino.AsInteger := origem.AsInteger;

        ftLargeint : destino.AsLargeInt := origem.AsLargeInt;

        ftExtended,
        ftSingle,
        ftFloat,
        ftCurrency,
        ftBCD,
        ftFMTBcd: destino.AsFloat := origem.AsFloat;

        ftDate,
        ftTime,
        ftTimeStamp,
        ftDateTime: destino.AsDateTime := origem.AsDateTime;

        ftFixedChar,
        ftWideString,
        ftFixedWideChar,
        ftString,
        ftMemo,
        ftWideMemo: destino.AsString := origem.AsString;
      else
        destino.Value := origem.Value;
      end;
    end;
end;

class procedure TSimpleDataSetTool.copyRecord(origem, destino: TDataSet; autoAppend : Boolean);
var
  i : Integer;
  fldOrigem, fldDestino : TField;
begin
  if autoAppend then
    destino.Append;

  for i := 0 to origem.FieldCount -1 do
    begin
      fldOrigem := origem.Fields[i];
      fldDestino := destino.Fields.FindField(fldOrigem.FieldName);
      if fldDestino <> nil then
        copyField(fldOrigem, fldDestino);
    end;

  if autoAppend then
    destino.Post;
end;

class procedure TSimpleDataSetTool.copyStruture(origem: TDataSet; destino: TClientDataSet);
var
  i : Integer;
begin
  destino.Close;
  destino.Fields.Clear;
  destino.FieldDefs.Clear;
  for i := 0 to origem.Fields.Count - 1 do
    with origem.Fields[i] do
      destino.FieldDefs.Add(
        FieldName,
        DataType,
        Size
      );
end;

class procedure TSimpleDataSetTool.DisableControls(container: TComponent);
var
  i : Integer;
begin
  for i := 0 to container.ComponentCount - 1 do
    if container.Components[i] is TDataSet then
      (container.Components[i] as TDataSet).DisableControls;
end;

class procedure TSimpleDataSetTool.EnableControls(container: TComponent);
var
  i : Integer;
begin
  for i := 0 to container.ComponentCount - 1 do
    if container.Components[i] is TDataSet then
      (container.Components[i] as TDataSet).EnableControls;
end;

class function TSimpleDataSetTool.execute(connection: TFDConnection; sql: String; parameters: TArray<ISimpleDataSetToolParameter>; Origem: String = ''): Integer;
var
  qry : TFDQuery;
  w_Log: array of String;
  w_ListaLog: TStringList;
  w_I: Integer;
begin
  qry := TFDQuery.Create(Nil);
  w_ListaLog := TStringList.Create;
  try
    qry.Connection := connection;
    qry.SQL.Text := sql;

    w_ListaLog.Text := SQL;
    SetLength(w_Log,w_ListaLog.Count);
    for w_I := 0 to w_ListaLog.Count-1 do
      w_Log[w_I] := w_ListaLog.Strings[w_I];
    setParams(qry, parameters);
    qry.ExecSQL;
    Result := qry.RowsAffected;
  finally
    qry.Free;
    w_ListaLog.Free;
  end;
end;

class function TSimpleDataSetTool.executeDirect(connection: TFDConnection; sql: String; Origem: String = ''): Integer;
var
  qry : TFDQuery;
  w_Log: array of String;
  w_ListaLog: TStringList;
  w_I: Integer;
begin
  qry := TFDQuery.Create(Nil);
  w_ListaLog := TStringList.Create;
  try
    qry.Connection := connection;
    qry.SQL.Text := sql;
    w_ListaLog.Text := SQL;
    SetLength(w_Log,w_ListaLog.Count);
    for w_I := 0 to w_ListaLog.Count-1 do
      w_Log[w_I] := w_ListaLog.Strings[w_I];

    Result := qry.ExecSQL(True);
  finally
    qry.Free;
    w_ListaLog.Free;
  end;
end;

class function TSimpleDataSetTool.execute(connection: TFDConnection; sql: String; parameter: ISimpleDataSetToolParameter; Origem: String = ''): Integer;
begin
  Result := execute(connection, sql, [parameter], Origem);
end;

class function TSimpleDataSetTool.execute(connection: TFDConnection; sql: String; Origem: String = ''): Integer;
begin
  Result := execute(connection, sql, [], Origem);
end;

class function TSimpleDataSetTool.firstResult(connection: TFDConnection; sql: String): Variant;
begin
  Result := firstResult(connection, sql, []);
end;

class function TSimpleDataSetTool.firstResult(connection: TFDConnection; sql: String;
  parameter: ISimpleDataSetToolParameter): Variant;
begin
  Result := firstResult(connection, sql, [parameter]);
end;

class function TSimpleDataSetTool.firstResult(connection: TFDConnection; sql: String;
  parameters: TArray<ISimpleDataSetToolParameter>): Variant;
var
  i : Integer;
begin
  with open(connection, sql, parameters) do
  try
    if IsEmpty then
      Result := Null
    else
    begin
      if FieldCount = 1 then
        Result := Fields[0].Value
      else
      begin
        Result := VarArrayCreate([0, FieldCount - 1], varVariant);
        for i := 0 to FieldCount -1 do
          Result[i] := Fields[i].Value;
      end;
    end;
  finally
    Free;
  end;
end;

class procedure TSimpleDataSetTool.forEach(dataSet : TDataSet; procedimento : TProc; filter : string = '');
var
  bk : TBookmark;
  oldFilter : string;
  filterActive : Boolean;
begin
  if dataSet.Active then
  begin
    bk := dataSet.GetBookmark;
    filterActive := dataSet.Filtered;
    oldFilter := dataSet.Filter;
    dataSet.DisableControls;
    try
      dataSet.Filtered := False;
      dataSet.Filter := filter;
      dataSet.Filtered := not filter.Trim.IsEmpty;
      dataSet.First;
      while not dataSet.Eof do
        begin
          procedimento;
          dataSet.Next;
        end;
    finally
      dataSet.Filter := oldFilter;
      dataSet.Filtered := filterActive;
      try
        dataSet.GotoBookmark(bk);
        dataSet.FreeBookmark(bk);
      except

      end;
      dataSet.EnableControls;
    end;
  end;
end;

class function TSimpleDataSetTool.open(connection: TFDConnection; sql: String;
  parameters: TArray<ISimpleDataSetToolParameter>): TDataSet;
var
  qry : TFDQuery;
  cds : TClientDataSet;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := connection;
    qry.SQL.Text := sql;
    setParams(qry, parameters);
    qry.Open;
    cds := TClientDataSet.Create(Nil);
    try
      copyStruture(qry, cds);
      cds.CreateDataSet;
      copyDataSet(qry, cds);
      cds.First;
      Result := cds;
    except
      cds.Free;
      raise;
    end;
  finally
    qry.Free;
  end;
end;

class procedure TSimpleDataSetTool.recriaClientDataSet(cds: TClientDataSet);
begin
  cds.Close;
  cds.FieldDefs.Clear;
  cds.CreateDataSet;
end;

class procedure TSimpleDataSetTool.reOpenDataSet(dataset: TDataSet);
begin
  dataset.Close;
  dataset.Open;
end;

class function TSimpleDataSetTool.open(connection: TFDConnection; sql: String;
  parameter: ISimpleDataSetToolParameter): TDataSet;
begin
  Result := open(connection, sql, [parameter]);
end;

class function TSimpleDataSetTool.open(connection: TFDConnection;
  sql: String): TDataSet;
begin
  Result := open(connection, sql, []);
end;

class procedure TSimpleDataSetTool.setParams(query: TFDQuery;
  parameters: TArray<ISimpleDataSetToolParameter>);
var
  queryParameter : TFDParam;
  parameter : ISimpleDataSetToolParameter;
begin
  for parameter in parameters do
    begin
      queryParameter := query.Params.FindParam(parameter.name);
      if queryParameter <> Nil then
        begin
          if parameter.isNull then
            begin
              queryParameter.DataType := ftString;
              queryParameter.Clear;
            end
          else
            begin
              queryParameter.DataType := parameter.paramType;
              queryParameter.Value := parameter.value;
            end;
        end;
    end;
end;

class procedure TSimpleDataSetTool.setParams(query: TFDQuery; origem: TDataSet);
var
  i : Integer;
  fld : TField;
  param : TFDParam;
begin
  for i := 0 to query.Params.Count - 1 do
    begin
      param := query.Params[i];
      param.Clear;
      param.DataType := ftInteger;
      fld := origem.FindField(param.Name);
      if fld <> nil then
        begin
          param.DataType := fld.DataType;
          param.Value := fld.Value;
        end;
    end;
end;

class procedure TSimpleDataSetTool.forceEnableControls(dataset: TDataSet);
begin
  while dataset.ControlsDisabled do
    dataset.EnableControls;
end;

class procedure TSimpleDataSetTool.setConnection(container: TComponent;
  connection: TFDConnection);
var
  i : Integer;
begin
  for i := 0 to container.ComponentCount - 1 do
  begin
    if (container.Components[i] is TFDQuery) then
      (container.Components[i] as TFDQuery).Connection := connection
    else if (container.Components[i] is TFDStoredProc) then
      (container.Components[i] as TFDStoredProc).Connection := connection;
  end;
end;

class procedure TSimpleDataSetTool.setFields(dataset: TDataSet;
  parameters: TArray<ISimpleDataSetToolParameter>);
var
  parameter : ISimpleDataSetToolParameter;
  field : TField;
begin
  for parameter in parameters do
    begin
      field := dataset.FindField(parameter.name);
      if field <> Nil then
        begin
          if parameter.isNull then
            begin
              field.Clear;
            end
          else
            begin
              field.Value := parameter.value;
            end;
        end;
    end;
end;

class procedure TSimpleDataSetTool.setParams(cds: TClientDataSet;
  parameters: TArray<ISimpleDataSetToolParameter>);
var
  queryParameter : TParam;
  parameter : ISimpleDataSetToolParameter;
begin
  cds.FetchParams;
  for parameter in parameters do
    begin
      queryParameter := cds.Params.FindParam(parameter.name);
      if queryParameter <> Nil then
        begin
          if parameter.isNull then
            begin
              queryParameter.DataType := ftString;
              queryParameter.Clear;
            end
          else
            begin
              queryParameter.DataType := parameter.paramType;
              queryParameter.Value := parameter.value;
            end;
        end;
    end;
end;

class procedure TSimpleDataSetTool.texto2Blob(campoBlob: TBlobField; texto: String);
begin
  if texto.Trim.IsEmpty then
    campoBlob.Clear
  else
    campoBlob.AsBytes := TEncoding.UTF8.GetBytes(texto);
end;

class procedure TSimpleDataSetTool.setParams(cds: TClientDataSet; origem: TDataSet);
var
  i : Integer;
  fld : TField;
  param : TParam;
begin
  for i := 0 to cds.Params.Count - 1 do
    begin
      param := cds.Params[i];
      param.Clear;
      param.DataType := ftInteger;
      fld := origem.FindField(param.Name);
      if fld <> nil then
        begin
          param.DataType := fld.DataType;
          param.Value := fld.Value;
        end;
    end;
end;

class function TSimpleDataSetTool.exists(connection: TFDConnection; sql: String;
  parameters: TArray<ISimpleDataSetToolParameter>): Boolean;
var
  qry : TFDQuery;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := connection;
    qry.SQL.Text := sql;
    setParams(qry, parameters);
    qry.Open;
    Result := not qry.IsEmpty;
  finally
    qry.Free;
  end;
end;

class function TSimpleDataSetTool.exists(connection: TFDConnection; sql: String;
  parameter: ISimpleDataSetToolParameter): Boolean;
begin
  Result := exists(connection, sql, [parameter]);
end;

class function TSimpleDataSetTool.exists(connection: TFDConnection;
  sql: String): Boolean;
begin
  Result := exists(connection, sql, []);
end;

end.
