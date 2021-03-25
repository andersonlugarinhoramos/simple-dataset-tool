unit Simple.DataSet.Tool.Interfaces;

interface

uses
  Data.DB;

type
  ISimpleDataSetToolParameter = interface
    ['{FAB5B11F-4752-4C99-A59F-3A4CB8B0C865}']
    function name : String;
    function paramType : TFieldType;
    function value : Variant;
    function isNull : Boolean;
  end;

  ISimpleDataSetToolParameterBuilder = interface
    ['{A9007843-A0BE-4522-82C9-18677A02D37F}']
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
    function add(name : string; value : Variant): ISimpleDataSetToolParameterBuilder; overload;

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

end.
