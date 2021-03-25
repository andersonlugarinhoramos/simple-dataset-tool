unit Simple.DataSet.Tool.Parameters;

interface

uses
  System.Variants,
  Simple.DataSet.Tool.Interfaces,
  Data.DB;

type
  TSimpleDataSetToolParameter = class(TInterfacedObject, ISimpleDataSetToolParameter)
  private
    Fname : string;
    FparamType : TFieldType;
    Fvalue : Variant;
    FNull : Boolean;
  public
    constructor Create(name : string; paramType : TFieldType; value : Variant);
    class function new(name : string): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : string): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : Integer): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : Double): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : Extended): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : Currency): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : TDate): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : TTime): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : TDateTime): ISimpleDataSetToolParameter; overload;
    class function new(name : string; value : Variant): ISimpleDataSetToolParameter; overload;
    function name : String;
    function paramType : TFieldType;
    function value : Variant;
    function isNull : Boolean;
  end;

implementation

{ TSimpleDataSetToolParameter }

constructor TSimpleDataSetToolParameter.Create(name: string; paramType: TFieldType;
  value: Variant);
begin
  Fname := name;
  FparamType := paramType;
  Fvalue := value;
  FNull := VarIsNull(value) or VarIsEmpty(value);
end;

function TSimpleDataSetToolParameter.isNull: Boolean;
begin
  Result := FNull;
end;

function TSimpleDataSetToolParameter.name: String;
begin
  Result := Fname;
end;

class function TSimpleDataSetToolParameter.new(name: string; value: Integer): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftInteger, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: Extended): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftFloat, value);
end;

class function TSimpleDataSetToolParameter.new(name: string): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftVariant, Null);
end;

class function TSimpleDataSetToolParameter.new(name, value: string): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftString, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: TDateTime): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftDateTime, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: Double): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftFloat, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: Currency): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftCurrency, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: TTime): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftTime, value);
end;

class function TSimpleDataSetToolParameter.new(name: string; value: TDate): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftDate, value);
end;

function TSimpleDataSetToolParameter.paramType: TFieldType;
begin
  Result := FparamType;
end;

function TSimpleDataSetToolParameter.value: Variant;
begin
  Result := Fvalue;
end;

class function TSimpleDataSetToolParameter.new(name: string; value: Variant): ISimpleDataSetToolParameter;
begin
  Result := TSimpleDataSetToolParameter.Create(name, ftVariant, value);
end;

end.
