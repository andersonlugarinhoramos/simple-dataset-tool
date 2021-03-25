unit Simple.DataSet.Tool.Helpers;

interface

uses
  Simple.Simple.DataSet.Tool,
  System.SysUtils,
  Data.DB;

type
  TSimpleDataSetToolHelper = class Helper for TDataSet
    procedure forEach(procedimento : TProc; Filter : string = '');
    function inEditMode : Boolean;
    function isInserting : Boolean;
    function isEditing : Boolean;
    procedure postIfInEditMode;
    procedure cancelIfInEditMode;
  end;

implementation

{ TSimpleDataSetToolHelper }

procedure TSimpleDataSetToolHelper.cancelIfInEditMode;
begin
  if inEditMode then
    Cancel;
end;

procedure TSimpleDataSetToolHelper.forEach(procedimento : TProc; filter : string = '');
begin
  TSimpleDataSetTool.forEach(Self, procedimento, filter);
end;

function TSimpleDataSetToolHelper.inEditMode: Boolean;
begin
  Result := State in dsEditModes;
end;

function TSimpleDataSetToolHelper.isEditing: Boolean;
begin
  Result := State = dsEdit;
end;

function TSimpleDataSetToolHelper.isInserting: Boolean;
begin
  Result := State = dsInsert;
end;

procedure TSimpleDataSetToolHelper.postIfInEditMode;
begin
  if inEditMode then
    Post;
end;

end.
