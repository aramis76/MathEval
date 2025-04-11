{*****************************************************************************}
{* Name    : Matheval                                                        *}
{* Date    : 07/04/2025                                                      *}
{* Author  : Dirk Van den Bossche                                            *}
{* Version : 1.0                                                             *}
{* Comment : A Math expression evaluator                                     *}
{*           Possible error codes :                                          *}
{*             1 : Illegal constant registration (ans is used as an internal *}
{*                 constant and will contain the last evaluation result)     *}
{*             3 : Unknown Function (Argument=name)                          *}
{*             4 : Invalid number (Argument=number)                          *}
{*             5 : Unexpected Character (Argument=Character)                 *}
{*             6 : Expected )                                                *}
{*             7 : Expected Function call (Argument=Function name)           *}
{*             8 : Unexpected token in primary                               *}
{*             9 : Unexpected character after end of expression              *}
{*                                                                           *}
{* License : GNU General Public License                                      *}
{*                                                                           *}
{* Changelog :                                                               *}
{*      Date        Change                                                   *}
{*      07/04/2025  Initial creation                                         *}
{*      09/04/2025  Addition of constant/function support through            *}
{*                  a linked list registry                                   *}
{*      10/04/2025  Addition of x unknown implemented as a constant.         *}
{*****************************************************************************}

{$F+}
unit MathEval;

interface

uses Math;

type
  TFunction = Function(Arg: Float): Float;

const
     ERR_ILLEGAL_CONSTANT=1;
     ERR_OUT_OF_MEMORY=2;
     ERR_UNKNOWN_FUNCTION=3;
     ERR_INVALID_NUMBER=4;
     ERR_UNEXPECTED_CHARACTER=5;
     ERR_EXPECTED_CLOSE=6;
     ERR_EXPECTED_FUNCTION=7;
     ERR_UNEXPECTED_TOKEN=8;
     ERR_UNEXPECTED_CHARACTER_EOF=9;
     ERR_COORDINATE_LIST_NOT_EMPTY=10;

var
  error:byte;
  errorargument:string;
  errorpos:integer;

Type
  PCoordinatesLinkedList = ^TCoordinatesLinkedList;
  TCoordinatesLinkedList = record
                         x:float;
                         y:float;
                         next:PCoordinatesLinkedList;
                        end;

Procedure RemoveFunction(Const Name : String);
Procedure RemoveConstant(Const Name : String);
Procedure RegisterFunction(const Name: string;Func: TFunction);
Procedure RegisterConstant(const Name: String;Value : Float);
Function PrintFunctions : longint;
Function PrintConstants : longint;
Function Evaluate(Const S: string): Float;
Procedure EvaluateRange(Const S:String;min:float;max:float;interval:float;var list:PCoordinatesLinkedList);

Implementation

uses
  SysUtils,SFunc;

type

  PConstantRegistry = ^TConstantRecord;
  PFunctionRegistry = ^TFunctionRecord;

  TFunctionRecord = record
    Name: string[20];
    Func: TFunction;
    Next: PFunctionRegistry;
  end;

  TConstantRecord = Record
    Name  : String[20];
    Value : Float;
    Next  : PConstantRegistry;
  end;

  TTokenKind = (tkNone, tkNumber, tkPlus, tkMinus, tkMul, tkDiv, tkPower,
                tkLParen, tkRParen, tkIdentifier, tkEOF);

  TToken = record
    Kind  : TTokenKind;
    Text  : string[20];
    Value : Float;
  end;

var
  Expr         : string;
  Pos          : Integer;
  CurrentToken : TToken;
  Functions    : PFunctionRegistry;
  Constants    : PConstantRegistry;

procedure RegisterFunction(Const Name: string;Func: TFunction);

var
  FunctionFound    : PFunctionRegistry;
  PreviousFunction : PFunctionRegistry;
  LName            : String;

begin
  LName:=LowerCase(Name);
  PreviousFunction:=nil;
  FunctionFound:=Functions;
  while FunctionFound<>nil do
  begin;
      if FunctionFound^.name=LName then
      begin;
          FunctionFound^.Func:=Func;
          Exit;
      end
      else
      begin;
          PreviousFunction:=FunctionFound;
          FunctionFound:=FunctionFound^.next;
      end;
  end;
  if memavail<SizeOf(FunctionFound^) then
  begin;
      error:=ERR_OUT_OF_MEMORY; {OutOfMemory}
      errorargument:='';
      errorpos:=pos;
      exit;
  end;
  new(functionFound);
  FunctionFound^.Name := LowerCase(Name);
  FunctionFound^.Func := Func;
  FunctionFound^.Next := nil;

  if PreviousFunction = nil then Functions:=FunctionFound
  else PreviousFunction^.Next:=FunctionFound;
end;

Procedure RegisterConstantInternal(const Name : String; Value : Float);

var
   ConstantFound    : PConstantRegistry;
   PreviousConstant : PConstantRegistry;
   LName            : String;

begin;
    LName:=Lowercase(name);
    PreviousConstant:=nil;
    ConstantFound:=Constants;
    while ConstantFound<>nil do
    begin;
        if ConstantFound^.name=lname then
        begin;
            ConstantFound^.Value:=Value;
            Exit;
        end
        else
        begin;
            PreviousConstant:=ConstantFound;
            ConstantFound:=ConstantFound^.next;
        end;
    end;
    if memavail<SizeOf(ConstantFound^) then
    begin;
        error:=ERR_OUT_OF_MEMORY; {Out of memory}
        errorargument:='';
        errorpos:=pos;
        exit;
    end;
    new(ConstantFound);
    ConstantFound^.Name:=LName;
    ConstantFound^.Value:=Value;
    ConstantFound^.Next:=nil;

    if PreviousConstant=nil then Constants:=ConstantFound
    else PreviousConstant^.next:=ConstantFound;
end;

Procedure RegisterConstant(Const Name : String;Value:Float);
var
    LName : String;
begin;
    Lname:=LowerCase(Name);
    if (LName<>'ans') and (LName<>'x') then RegisterConstantInternal(LName,Value)
    else
    begin;
        error:=ERR_ILLEGAL_CONSTANT;  {Illegal constant registration}
        errorargument:='';
        errorpos:=-1;
    end;
end;

Procedure FindConstant(const Name: string;Var value: Float;Var Found:Boolean);
var
   PosConst:PConstantRegistry;
   LName : String;

Begin;
    Lname:=Lowercase(name);
    PosConst:=Constants;
    While (PosConst^.Name<>LName) do
    begin;
        PosConst:=PosConst^.next;
        if PosConst=nil then break;
    end;
    Found:=not (PosConst = nil);
    if Found then value:=PosConst^.Value;
end;

procedure FindFunction(const Name: string;Var Func: TFunction);

var
  PosFunction : PFunctionRegistry;
  LName       : String;
begin
  PosFunction:=Functions;
  LName:=LowerCase(name);
  While PosFunction<>Nil do
  begin;
      if PosFunction^.Name = LName then
      begin;
          Func:=PosFunction^.Func;
          exit;
      end;
      PosFunction:=PosFunction^.next;
  end;
  Error:=ERR_UNKNOWN_FUNCTION; {'Unknown function'}
  ErrorArgument:=Name;
  ErrorPos:=Pos;
end;

procedure NextToken;

  function IsIdentifierChar(C: Char): Boolean;
  begin
    IsIdentifierChar := C in ['a'..'z', 'A'..'Z', '_'];
  end;

  function IsDigitOrDot(C: Char): Boolean;
  begin
    IsDigitOrDot := C in ['0'..'9', '.'];
  end;

var
  StartPos      : Integer;
  S             : string;
  Code          : Integer;
  ConstantFound : Boolean;

begin
  while (Pos <= Length(Expr)) and (Expr[Pos] = ' ') do Inc(Pos);

  if Pos > Length(Expr) then
  begin
    CurrentToken.Kind := tkEOF;
    Exit;
  end;

  case Expr[Pos] of
    '+': begin CurrentToken.Kind := tkPlus; Inc(Pos); end;
    '-': begin CurrentToken.Kind := tkMinus; Inc(Pos); end;
    '*': begin CurrentToken.Kind := tkMul; Inc(Pos); end;
    '/': begin CurrentToken.Kind := tkDiv; Inc(Pos); end;
    '^': begin CurrentToken.Kind := tkPower; Inc(Pos); end;
    '(': begin CurrentToken.Kind := tkLParen; Inc(Pos); end;
    ')': begin CurrentToken.Kind := tkRParen; Inc(Pos); end;
    '0'..'9', '.':
      begin
        StartPos := Pos;
        while (Pos <= Length(Expr)) and IsDigitOrDot(Expr[Pos]) do Inc(Pos);
        S := Copy(Expr, StartPos, Pos - StartPos);
        Val(S, CurrentToken.Value, Code);
        if Code <> 0 then
        begin;
            Error:=ERR_INVALID_NUMBER; {'Invalid number: '}
            ErrorArgument:=S;
            ErrorPos:=Pos;
        end;
        CurrentToken.Kind := tkNumber;
        CurrentToken.Text := S;
      end;
    'a'..'z', 'A'..'Z', '_':
      begin
        StartPos := Pos;
        while (Pos <= Length(Expr)) and IsIdentifierChar(Expr[Pos]) do Inc(Pos);
        CurrentToken.Text := Copy(Expr, StartPos, Pos - StartPos);
        FindConstant(CurrentToken.Text, CurrentToken.Value, ConstantFound);
        if ConstantFound then CurrentToken.Kind:=tkNumber
        else CurrentToken.Kind := tkIdentifier;
      end;
  else
      Error:=ERR_UNEXPECTED_CHARACTER; {'Unexpected character: '}
      ErrorArgument:=Expr[Pos];
      ErrorPos:=Pos;
  end;
end;

function ParseFactor: Float; Forward;

function ParsePrimary: Float;
var
  FuncName : string;
  Arg      : Float;
  F        : TFunction;

begin
  if CurrentToken.Kind = tkNumber then
  begin
    ParsePrimary := CurrentToken.Value;
    NextToken;
  end
  else if CurrentToken.Kind = tkIdentifier then
  begin
    FuncName := CurrentToken.Text;
    NextToken;
    if CurrentToken.Kind = tkLParen then
    begin
      NextToken;
      Arg := ParseFactor;
      if CurrentToken.Kind <> tkRParen then
      begin;
          Error:=ERR_EXPECTED_CLOSE; {'Expected ")"'};
          ErrorPos:=Pos;
      end;
      NextToken;
      FindFunction(FuncName, F);
      ParsePrimary := F(Arg);
    end
    else
    begin;
       Error:=ERR_EXPECTED_FUNCTION; {'Expected function call: ' + FuncName);}
       ErrorArgument:=FuncName;
       ErrorPos:=Pos;
    end;
  end
  else if CurrentToken.Kind = tkLParen then
  begin
    NextToken;
    ParsePrimary := ParseFactor;
    if CurrentToken.Kind <> tkRParen then
    begin;
        Error:=ERR_EXPECTED_CLOSE; {'Expected ")"'}
        ErrorArgument:='';
        ErrorPos:=Pos;
    end;
    NextToken;
  end
  else if CurrentToken.Kind = tkMinus then
  begin
    NextToken;
    ParsePrimary := -ParsePrimary;
  end
  else
  begin;
    Error:=ERR_UNEXPECTED_TOKEN; {'Unexpected token in primary'}
    ErrorArgument:='';
    ErrorPos:=Pos;
  end;
end;

function ParsePower: Float;
var
  Base, Exponent: Float;

begin
  Base := ParsePrimary;
  while CurrentToken.Kind = tkPower do
  begin
    NextToken;
    Exponent := ParsePrimary;
    Base := Power(Base, Exponent);
  end;
  ParsePower := Base;
end;

function ParseTerm: Float;
var
  Value: Float;
  test: Float;

begin
  Value := ParsePower;
  while (CurrentToken.Kind = tkMul) or (CurrentToken.Kind = tkDiv) do
  begin
    if CurrentToken.Kind = tkMul then
    begin
      NextToken;
      Value := Value * ParsePower;
    end
    else
    begin
      NextToken;
      test:=ParsePower;
      if (test<>0.0) then Value := Value / Test
      else
      begin;
          if Value>0.0 then Value:=inf
          else if Value<0.0 then Value:=-inf
          else value:=Nan;
      end;
    end;
  end;
  ParseTerm := Value;
end;

function ParseFactor: Float;
var
  Value: Float;
begin
  Value := ParseTerm;
  while (CurrentToken.Kind = tkPlus) or (CurrentToken.Kind = tkMinus) do
  begin
    if CurrentToken.Kind = tkPlus then
    begin
      NextToken;
      Value := Value + ParseTerm;
    end
    else
    begin
      NextToken;
      Value := Value - ParseTerm;
    end;
  end;
  ParseFactor := Value;
end;

function Evaluate(Const S: string): Float;
var
   Result: Float;

begin
  Error := 0;
  Expr := S;
  Pos := 1;
  NextToken;
  Result:=ParseFactor;
  RegisterConstantInternal('ans',Result);
  Evaluate:=Result;
  if CurrentToken.Kind <> tkEOF then
  begin;
    Error:=ERR_UNEXPECTED_CHARACTER_EOF; {'Unexpected characters after end of expression'}
    ErrorArgument:='';
    ErrorPos:=Pos;
  end;
end;

Procedure RemoveFunction(Const Name : String);

var
   PreviousFunction : PFunctionRegistry;
   RemoveFunction   : PFunctionRegistry;
   LName            : String;

begin;
    PreviousFunction:=Nil;
    RemoveFunction:=Functions;
    LName:=LowerCase(Name);
    While RemoveFunction<>nil do
    begin;
        if RemoveFunction^.Name=LName then
        begin;
            if PreviousFunction=nil then Functions:=RemoveFunction^.next
            else PreviousFunction^.next:=RemoveFunction^.next;
            dispose(RemoveFunction);
            exit;
        end
        else
        begin;
            PreviousFunction:=RemoveFunction;
            RemoveFunction:=RemoveFunction^.Next;
        end;
    end;
end;

Procedure RemoveConstant(Const Name : String);
var
   PreviousConstant: PConstantRegistry;
   RemoveConstant: PConstantRegistry;
   LName : String;

begin;
    PreviousConstant:=nil;
    RemoveConstant:=Constants;
    LName:=LowerCase(Name);
    While RemoveConstant<>nil do
    begin;
        if RemoveConstant^.Name=LName then
        begin;
            if PreviousConstant=nil then Constants:=RemoveConstant^.next
            else PreviousConstant^.next:=RemoveConstant^.Next;
            dispose(RemoveConstant);
            exit;
        end
        else
        begin;
            PreviousConstant:=RemoveConstant;
            RemoveConstant:=RemoveConstant^.Next;
        end;
    end;
end;

Function PrintFunctions : longint;
Var
   PosFunction   : PFunctionRegistry;
   FunctionCount : Word;
   MemoryUsage   : Longint;

begin;
    PosFunction:=Functions;
    FunctionCount:=0;
    Writeln('Registered functions :');
    while PosFunction<>nil do
    begin;
        inc(FunctionCount);
        Writeln('  ',PosFunction^.Name);
        PosFunction:=PosFunction^.next;
    end;
    MemoryUsage:=SizeOf(PosFunction^)*FunctionCount;
    Writeln;
    Writeln('Memory used for ',FunctionCount, ' functions : ',MemoryUsage);
    PrintFunctions:=MemoryUsage;
end;

Function PrintConstants : Longint;

Var
   PosConstant : PConstantRegistry;
   ConstantCount : Word;
   MemoryUsage : Longint;

begin;
    PosConstant:=Constants;
    ConstantCount:=0;
    Writeln('Registered constant :');
    while PosConstant<>nil do
    begin;
        inc(ConstantCount);
        Writeln('  ',PosConstant^.Name);
        PosConstant:=PosConstant^.next;
    end;
    MemoryUsage:=SizeOf(PosConstant^)*ConstantCount;
    Writeln;
    Writeln('Memory used for ', ConstantCount, ' Constants : ',MemoryUsage);
    PrintConstants:=MemoryUsage;
end;

Procedure EvaluateRange(Const S:String;min:float;max:float;interval:float;var list:PCoordinatesLinkedList);
var
   x : Float;
   currentcoordinate,previouscoordinate:PCoordinatesLinkedList;

begin;
    if list<>nil then
    begin;
        Error:=ERR_COORDINATE_LIST_NOT_EMPTY;
        exit;
    end;
    CurrentCoordinate:=nil;
    x:=min;
    while x<max do
    begin;
        PreviousCoordinate:=CurrentCoordinate;
        New(CurrentCoordinate);
        CurrentCoordinate^.X:=x;
        RegisterConstantInternal('x',x);
        CurrentCoordinate^.Y:=evaluate(S);
        if PreviousCoordinate=nil then list:=CurrentCoordinate
        else PreviousCoordinate^.Next:=CurrentCoordinate;
        x:=x+interval;
    end;
    if currentCoordinate<>nil then CurrentCoordinate^.next:=nil;
    error:=0;
end;

{ === Custom Functions === }

function MySin(X:Float):Float;
begin
  MySin := Sin(X);
end;

Function MyCos(X:Float):Float;
begin;
    MyCos:=Cos(X);
end;

Function MyArcTan(X:Float):Float;
begin;
      MyArcTan:=Arctan(x);
end;

Function MyExp(X:Float):Float;
begin;
      MyExp:=Exp(x);
end;

Function MyLn(X:Float):Float;
begin;
      MyLn:=ln(x);
end;

Function MySqrt(x:float):Float;
begin;
      MySqrt:=Sqrt(X);
end;

begin
     Functions := nil;
     Constants := nil;
     RegisterFunction('arctan',MyArcTan);
     RegisterFunction('cos', MyCos);
     RegisterFunction('exp', MyExp);
     RegisterFunction('ln',MyLn);
     RegisterFunction('sin', MySin);
     RegisterFunction('sqrt',MySqrt);
     RegisterFunction('arccos',arccos);
     RegisterFunction('arccosh',ArcCosH);
     RegisterFunction('arcsin',ArcSin);
     RegisterFunction('arcsinh',ArcSinH);
     RegisterFunction('arccotan',Arccotan);
     RegisterFunction('arctanh',ArcTanH);
     RegisterFunction('cosecant',cosecant);
     RegisterFunction('cosh',cosh);
     RegisterFunction('cotan',cotan);
     RegisterFunction('cotanh',cotanh);
     RegisterFunction('log',log10);
     RegisterFunction('binlog',log2);
     RegisterFunction('secant',Secant);
     RegisterFunction('sinh',sinh);
     RegisterFunction('tan',tan);
     RegisterFunction('tanh',tanh);
     RegisterConstantInternal('ans',0);
     RegisterConstantInternal('pi',pi);
     RegisterConstantInternal('e',exp(1));
     RegisterConstantInternal('x',0);
end.
