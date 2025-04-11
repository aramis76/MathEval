{*****************************************************************************}
{* Name    : sfunc                                                           *}
{* Date    : 26/09/2024                                                      *}
{* Author  : Dirk Van den Bossche                                            *}
{* Version : 1.0                                                             *}
{* Comment : Various string manipulation functions                           *}
{*                                                                           *}
{* Changelog :                                                               *}
{*      Date        Change                                                   *}
{*      26/09/2024  initial creation of the unit.                            *}
{*****************************************************************************}


unit sfunc;

interface

function upper(const s:string):string;
function lower(const s:string):string;
function lowercase(const s:string):string;
function RepeatStr(const s:string;number : byte):string;
function replaceStr(const s,search,replace : string) : string;
function trim(const s:string):string;
function rtrim(const s:string):string;
function ltrim(const s:string):string;
function comparestring(s1,s2 : string;casesensitive:boolean):shortint;
function iif(booleanexpr : Boolean;const truevalue,falsevalue:string):string;

implementation

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Convert a string into uppercase                                 *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 26/09/2024 Converting a string into uppercasel                             *}
{*****************************************************************************}

function upper(const s:string):string;
var
   i : byte;
   result : string;

begin;
    result[0]:=s[0];
    for i:=1 to length(s) do result[i]:=upcase(s[i]);
    upper:=result;
end;

function lower(const s:string):string;

const
   UpperToLowerMask = 1 shl 5;     {Changing the 5th bit to a 1 changes a character to a lowercase}

var
   i : byte;
   result:string;

begin;
    result[0]:=s[0];
    for i:=1 to length(s) do
    begin;
          if (s[i]>='A') and (s[i]<='Z') then
            result[i]:=chr(ord(s[i]) or UpperToLowerMask)
          else
            result[i]:=s[i];
    end;
    lower:=result;
end;

function RepeatStr(const s:string;number : byte):string;

var
   i : byte;
   len, totalLen : byte;
   result : string;

begin;
    len:=length(s);
    totallen:=len*number;
    result[0]:=chr(totallen);
    for i:=0 to number - 1 do move(s[1], Result[i * len  + 1], Len);
    repeatstr:=result;
end;

function replaceStr(const s,search,replace : string) : string;

var
   i : byte;
   result: string;

begin;
    result:=s;
    i:=pos(search,result);
    while i<>0 do
    begin;
        delete(result,i,length(search));
        insert(replace,result,i);
        inc(i,length(replace));
        if i<=length(result) then
          i:=pos(search,copy(result,i,length(result)))
        else
          i:=0;
    end;
    replacestr:=result;
end;


function rtrim(const s:string):string;
var
    i : byte;

begin;
    i:=length(s);
    while (i>=1) and (s[i]=' ') do dec(i);
    rtrim:=copy(s,1,i);
end;

function ltrim(const s:string):string;
var
    i: byte;

begin;
    i:=1;
    while (i <= length(s)) and (s[i] = ' ') do inc(i);
    ltrim:=copy(s,i,length(s) - i + 1);
end;

function trim(const s: string):string;
begin;
    trim:=ltrim(rtrim(s));
end;

function comparestring(s1,s2 : string;casesensitive:boolean):shortint;

begin;
      if not casesensitive then
      begin;
            s1:=Upper(S1);
            s2:=Upper(S2);
      end;
      if s1<s2 then comparestring:=-1
      else if s1>s2 then comparestring:=1
      else comparestring:=0;
end;

function iif(booleanexpr : Boolean;const truevalue, falsevalue:string):string;
begin;
      if booleanexpr then iif:=truevalue
      else iif:=falsevalue;
end;

function lowercase(const s:string):string;
begin;
      lowercase:=lower(s);
end;

end.