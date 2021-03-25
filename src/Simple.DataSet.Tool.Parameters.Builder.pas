unit Simple.DataSet.Tool.Parameters.Builder;

interface

uses
  Simple.DataSet.Tool.Interfaces,
  Simple.DataSet.Tool.Parameters,
  System.Generics.Collections,
  Data.DB;

type
  TSimpleDataSetToolParameterBuilder = class(TInterfacedObject, ISimpleDataSetToolParameterBuilder)
  private
    FLista : TList<ISimpleDataSetToolParameter>;
  public
    constructor Create;
    destructor Destroy; override;

    class function New: ISimpleDataSetToolParameterBuilder;

    function add(name : string): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : string): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : Integer): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : Double): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : Extended): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : Currency): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : TDate): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : TTime): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value : TDateTime): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; field : TField): ISimpleDataSetToolParameterBuilder; overload;
    function add(name : string; value: Variant): ISimpleDataSetToolParameterBuilder; overload;

    function addNullIf(name : string; value : string; nullIf : string): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : Integer; nullIf : Integer): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : Double; nullIf : Double): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : Extended; nullIf : Extended): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : Currency; nullIf : Currency): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : TDate; nullIf : TDate): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : TTime; nullIf : TTime): ISimpleDataSetToolParameterBuilder; overload;
    function addNullIf(name : string; value : TDateTime; nullIf : TDateTime): ISimpleDataSetToolParameterBuilder; overload;

    function build : TArray<ISimpleDataSetToolParameter>;
  end;

implementation

{ TSimpleDataSetToolParameterBuilder }

function TSimpleDataSetToolParameterBuilder.add(name: string; value: Integer): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string;
  value: Extended): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name, value: string): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: String; value: Variant): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string;
  value: Currency): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string;
  value: TDateTime): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string; value: Double): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string; value: TTime): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string; value: TDate): ISimpleDataSetToolParameterBuilder;
begin
  FLista.Add(TSimpleDataSetToolParameter.new(name, Value));
  Result := Self;
end;

function TSimpleDataSetToolParameterBuilder.build: TArray<ISimpleDataSetToolParameter>;
begin
  Result := FLista.ToArray;
end;

constructor TSimpleDataSetToolParameterBuilder.Create;
begin
  FLista := TList<ISimpleDataSetToolParameter>.Create;
end;

destructor TSimpleDataSetToolParameterBuilder.Destroy;
begin
  FLista.Free;
  inherited;
end;

class function TSimpleDataSetToolParameterBuilder.New: ISimpleDataSetToolParameterBuilder;
begin
  Result := TSimpleDataSetToolParameterBuilder.Create;
end;

function TSimpleDataSetToolParameterBuilder.add(name: string; field: TField): ISimpleDataSetToolParameterBuilder;
begin
  if field.IsNull then
    Result := add(name)
  else
    case field.DataType of
      ftSmallint,
      ftInteger,
      ftAutoInc,
      ftLongWord,
      ftShortint: Result := add(name, field.AsInteger);

      ftLargeint : Result := add(name, field.AsLargeInt);

      ftFloat,
      ftCurrency,
      ftBCD,
      ftFMTBcd,
      ftExtended,
      ftSingle : Result := add(name, field.AsFloat);
      ftDate: Result := add(name, TDate(field.AsDateTime));
      ftTime: Result := add(name, TTime(field.AsDateTime));
      ftDateTime,
      ftTimeStamp: Result := add(name, field.AsDateTime);
    else
      Result := add(name, field.AsString);
    end;
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: Extended): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: Double): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: Integer): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name, value,
  nullIf: string): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: TDateTime): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: TTime): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: TDate): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

function TSimpleDataSetToolParameterBuilder.addNullIf(name: string; value,
  nullIf: Currency): ISimpleDataSetToolParameterBuilder;
begin
  if value = nullIf then
    Result := add(name)
  else
    Result := add(name, value);
end;

end.
