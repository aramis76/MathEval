{*****************************************************************************}
{* Name    : SysUtils                                                        *}
{* Date    : 06/12/2024                                                      *}
{* Author  : Dirk Van den Bossche                                            *}
{* Version : 1.0                                                             *}
{* Comment : This unit provided some extended number conversion functions    *}
{*           and some other system functions                                 *}
{*                                                                           *}
{* Changelog :                                                               *}
{*      Date        Change                                                   *}
{*      06/12/2024  Initial unit creation.  Added float conversion functions *}
{*                  Added conversion functions for integers with minimum     *}
{*                  width parameter. (See specific function header for       *}
{*                  details.                                                 *}
{*****************************************************************************}


unit sysutils;

interface

Type
    PtrInt= Longint;
    TMonthNameArray = array[1..12] of string;
    TWeekNameArray = array[1..7] of string;

    TFormatSettings = Record
       CurrencyFormat: Byte;
       NegCurrFormat: Byte;
       ThousandSeparator:Char;
       DecimalSeparator:Char;
       CurrencyDecimals:Byte;
       DateSeparator:Char;
       TimeSeparator:Char;
       ListSeparator:Char;
       CurrencyString:String;
       ShortDateFormat:String;
       LongDateFormat:String;
       TimeAMString:String;
       TimePMString:String;
       ShortTimeFormat:String;
       LongTimeFormat:String;
       ShortMonthNames:TMonthNameArray;
       LongMonthNames:TMonthNameArray;
       ShortDayNames:TWeekNameArray;
       LongDayNames:TWeekNameArray;
       TwoDigitYearCenturyWindow:Word;
    end;
    TFloatFormat = (ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency);
    TPFormatSettings = ^TFormatSettings;
var
   PDefaultFormatSettings : TPFormatSettings;
   PFormatSettings : TPFormatSettings;

Const
   MaxDigits=17;

function FloatToStrF(Value:extended;format:TFloatFormat;Precision, Digits:Integer;var FormatSettings:TFormatSettings):String;
function FloatToStr(Value:extended) : string;
function bytetostr(value:byte;minchar:byte) : string;
function wordtostr(value:word;minchar:byte) : string;
function shortinttostr(value:shortint;minchar:byte) : string;
function integertostr(value:integer;minchar:byte) : string;
function longinttostr(value:longint;minchar:byte) : string;
function generatetempfile(const path:string):string;
function FileExists(const filename:string):boolean;
function StrToFloat(const S: String) : Double;

implementation

uses dos;

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Convert floating point number to string.  You need to specify   *}
{*           the format, digits and precision.                               *}
{*                                                                           *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 06/12/2024 Converts the floating point number value to a string           *}
{*            representation, according to the settings of the parameters    *}
{*            Format, Precision and Digits.                                  *}
{*                                                                           *}
{*            The meaning of the Precision and Digits parameter depends on   *}
{*            the Format parameter. The format is controlled mainly by the   *}
{*            Format parameter. It can have one of the following values:     *}
{*            ffcurrency                                                     *}
{*                Money format. Value is converted to a string using the     *}
{*                global variables CurrencyString, CurrencyFormat            *}
{*                and NegCurrFormat. The Digits parameter specifies the      *}
{*                number of digits following the decimal point and should be *}
{*                in the range -1 to 18. If Digits equals -1,                *}
{*                CurrencyDecimals is assumed. The Precision parameter is    *}
{*                ignored.                                                   *}
{*            ffExponent                                                     *}
{*                Scientific format. Value is converted to a string using    *}
{*                scientific notation: 1 digit before the decimal point,     *}
{*                possibly preceded by a minus sign if Value is negative.    *}
{*                The number of digits after the decimal point is controlled *}
{*                by Precision and must lie in the range 0 to 15.            *}
{*            ffFixed
{*                Fixed point format. Value is converted to a string using   *}
{*                fixed point notation. The result is composed of all digits *}
{*                of the integer part of Value, preceded by a minus sign if  *}
{*                Value is negative. Following the integer part is           *}
{*                DecimalSeparator and then the fractional part of Value,    *}
{*                rounded off to Digits numbers. If the number is too large  *}
{*                then the result will be in scientific notation.            *}
{*            ffGeneral                                                      *}
{*                General number format. The argument is converted to a      *}
{*                string using ffExponent or ffFixed format, depending on    *}
{*                which one gives the shortest string. There will be no      *}
{*                trailing zeroes. If Value is less than 0.00001 or if the   *}
{*                number of decimals left of the decimal point is larger     *}
{*                than Precision then scientific notation is used, and       *}
{*                Digits is the minimum number of digits in the exponent.    *}
{*                Otherwise Digits is ignored.                               *}
{*            ffnumber                                                       *}
{*                Is the same as ffFixed, except that thousand separators    *}
{*                are inserted in the resulting string.                      *}
{*****************************************************************************}

function FloatToStrF(Value:extended;format:TFloatFormat;Precision, Digits:Integer;var FormatSettings:TFormatSettings):string;
var
   ValueS:string;
   P, PE, Q: integer;
   Exponent: integer;
   DS: Char;
   Negative: Boolean;


   Function RemoveLeadingNegativeSign(var AValue:String) : Boolean;
   var
      i:PtrInt;
      TS : Char;
      StartPos:PtrInt;
      Result:Boolean;

   begin;
       Result:=False;
       if Format = ffCurrency then StartPos:=1
       else StartPos:=2;
       TS:=FormatSettings.ThousandSeparator;
       for i:=StartPos to length(AValue) do
       begin;
           Result:=(AValue[I] in ['0', DS, 'E','+',TS]);
           if not result then break;
       end;
       if (Result) and (Format <> ffCurrency) then delete(AValue,1,1);
       RemoveLeadingNegativeSign:=result;
   end;

begin;
   DS:=FormatSettings.DecimalSeparator;
   Case format of
     ffGeneral:
     Begin;
         Str(Value:precision+8,ValueS);
         while valueS[1]=' ' do delete(ValueS, 1, 1);
         P:=Pos('.',ValueS);
         if P<>0 then ValueS[P]:=DS
         Else
         Begin;
               FloatToStrF:=ValueS;
               Exit;
         end;
         PE:=Pos('E',ValueS);
         if PE > 0 then
         Begin;
               Q:=PE+2;
               Exponent:=0;
               While (Q <=length(ValueS)) do
               Begin;
                     Exponent:=Exponent*10 + Ord(ValueS[Q])-Ord('0');
                     Inc(Q);
               end;
               if ValueS[PE+1]='-' then Exponent := -Exponent;
               if (P+Exponent < PE) and (Exponent > -6) then
               begin;
                   ValueS[0]:=chr(PE-1);
                   if Exponent>=0 then
                   Begin;
                         for Q:=0 to exponent-1 do
                         begin;
                               ValueS[P]:=ValueS[P+1];
                               inc(P);
                         end;
                         ValueS[P]:=DS;
                         P:=1;
                         if ValueS[P]='-' then inc(P);
                         While (ValueS[P] ='0') and (P<Length(ValueS)) and (ValueS[P+1] <> DS) do Delete(ValueS,P,1);
                   end
                   else
                   begin;
                         Insert(Copy('000000',1,-Exponent),ValueS,P-1);
                         ValueS[P-Exponent]:=ValueS[P-Exponent-1];
                         ValueS[P]:=DS;
                         if Exponent <> -1 then ValueS[P-Exponent-1]:='0';
                   end;
                   Q:=Length(ValueS);
                   While (Q>0) and (ValueS[Q] = '0') do Dec(Q);
                   if ValueS[Q] = DS then Dec(Q);
                   if (Q=0) or ((Q=1) and (ValueS[1]='-')) then ValueS:='0'
                   else ValueS[0]:=Chr(Q);
               end
               else
               Begin;
                     While ValueS[PE-1] = '0' do
                     begin;
                           Delete(ValueS,PE-1,1);
                           DEC(PE);
                     end;
                     if ValueS[PE+1]='+' then delete(ValueS,PE-1,1)
                     else inc(pe);
                     While ValueS[PE+1]= '0' do delete(ValueS,PE+1,1)
               end;
         end;
     end;
     ffExponent:
     Begin;
         Str(Value:precision+8,ValueS);
         while ValueS[1] = ' ' do delete(ValueS,1,1);
         if (ValueS[1]='-') and (ValueS[3]='.') then ValueS[3]:=DS
         else if ValueS[2]='.' then ValueS[2]:=DS;
         P:=Pos('E',ValueS);
         if P<>0 then
         begin;
               Inc(P,2);
               if Digits > 4 then Digits:=4;
               Digits:=Length(ValueS) - P - Digits + 1;
               if Digits<0 then insert(copy('0000',1,-Digits),ValueS,P)
               else
               while (Digits > 0) and (ValueS[P]='0') do
               begin;
                     Delete(ValueS,P,1);
                     if P > Length(ValueS) then
                     begin;
                           Delete(ValueS,P-2,2);
                           Break;
                     end;
                     dec(Digits);
               end;
         end;
     end;
     ffnumber:
     begin;
         if Digits = -1 then Digits:=2
         else if digits > maxdigits then Digits:=maxdigits;
         Str(Value:0:Digits,ValueS);
         if ValueS[1]=' ' then Delete(ValueS,1,1);
         P:=POS('.',ValueS);
         if P<>0 then ValueS[P]:=DS
         else P:=Length(ValueS)+1;
         Dec(P,3);
         While (P>1) do
         begin;
               if (ValueS[P - 1] <> '-') and (FormatSettings.ThousandSeparator <>#0) then
                 insert(FormatSettings.ThousandSeparator,ValueS,P);
               DEC(P,3);
         end;
     end;
     ffCurrency:
     begin;
           if Digits=-1 then Digits:=FormatSettings.CurrencyDecimals
           else if Digits > 18 then Digits:=18;
           Str(Value:0:Digits,ValueS);
           Negative:=ValueS[1] = '-';
           if Negative then delete(ValueS,1,1);
           P:=Pos('.',ValueS);
           if P<>0 then ValueS[P]:=DS else P:=Length(ValueS)+1;
           Dec(P,3);
           While (P>1) do
           begin;
               if FormatSettings.ThousandSeparator<>#0 then insert(FormatSettings.ThousandSeparator, ValueS,P);
               Dec(P,3);
           end;
           if (length(ValueS) >1) and Negative then Negative:=Not RemoveLeadingNegativeSign(ValueS);
           if not Negative then
           begin;
            case FormatSettings.CurrencyFormat Of
                 0:ValueS:=FormatSettings.CurrencyString + ValueS;
                 1:ValueS:=ValueS + FormatSettings.CurrencySTring;
                 2:ValueS:=FormatSettings.CurrencyString + ' ' + ValueS;
                 3:ValueS:=ValueS+' '+FormatSettings.CurrencyString;
            end
           end
           else
           begin;
            case FormatSettings.NegCurrFormat Of
             0: ValueS:='('+FormatSettings.CurrencyString+ValueS+')';
             1: ValueS:='-'+FormatSettings.CurrencyString+ValueS;
             2: ValueS:=FormatSettings.CurrencyString+'-'+ValueS;
             3: ValueS:=FormatSettings.CurrencyString+ValueS+'-';
             4: ValueS:='('+ValueS+FormatSettings.CurrencyString+')';
             5: ValueS:='-'+ValueS+FormatSettings.CurrencyString;
             6: ValueS:=ValueS+'-'+FormatSettings.CurrencyString;
             7: ValueS:=ValueS+FormatSettings.CurrencyString+'-';
             8: ValueS:='-'+ValueS+' '+FormatSettings.CurrencyString;
             9: ValueS:='-'+FormatSettings.CurrencyString+' '+ValueS;
             10: ValueS:=ValueS+' '+FormatSettings.CurrencyString+'-';
             11: ValueS:=FormatSettings.CurrencyString+' '+ValueS+'-';
             12: ValueS:=FormatSettings.CurrencyString+' -'+ValueS;
             13: ValueS:=ValueS+'- '+FormatSettings.CurrencyString;
             14: ValueS:='('+FormatSettings.CurrencyString+' '+ValueS+')';
             15: ValueS:='('+ValueS+' '+FormatSettings.CurrencyString+')';
            end;
           end;
     end;
   end;
   if not (format in [ffCurrency]) and (length(ValueS)>1) and (ValueS[1]='-') then RemoveLeadingNegativeSign(ValueS);
   FloatToStrF:=ValueS;
end;

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Placeholder for                                                 *}
{*           FloatToStrF(Value, ffGeneral, 15, 0, FormatSettings)            *}
{*                                                                           *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 06/12/2024 Initial creation                                               *}
{*****************************************************************************}

function FloatToStr(Value:extended) : string;
begin;
      FloatToStr:=FloatToStrF(Value,ffGeneral, 15,0, PFormatSettings^);
end;

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Convert byte into a string representation                       *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 06/12/2024 Creation of the function                                       *}
{*****************************************************************************}

function bytetostr(value:byte;minchar:byte) : string;
var
   result : string;

begin;
    str(value,result);

    while length(result)<minchar do insert('0',result,1);
    bytetostr:=result;
end;

function wordtostr(value:word;minchar:byte) : string;
var
   result : string;

begin;
    str(value,result);
    while length(result)<minchar do insert('0',result,1);
    wordtostr:=result;
end;

function shortinttostr(value:shortint;minchar:byte) : string;
var
   result : string;
   position    : byte;

begin;
    str(value,result);
    if value < 0 then position:=2
    else position:=1;
    while length(result)<minchar do insert('0',result,position);
    shortinttostr:=result;
end;

function integertostr(value:integer;minchar:byte) : string;
var
   result : string;
   position    : byte;

begin;
    str(value,result);
    if value < 0 then position:=2
    else position:=1;
    while length(result)<minchar do insert('0',result,position);
    integertostr:=result;
end;

function longinttostr(value:longint;minchar:byte) : string;
var
   result : string;
   position    : byte;

begin;
    str(value,result);
    if value < 0 then position:=2
    else position:=1;
    while length(result)<minchar do insert('0',result,position);
    longinttostr:=result;
end;

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Generates a random filename consisting of only alphabetic       *}
{*           characters.  The filename will have an 8.3 filename.            *}
{*                                                                           *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 06/12/2024 Initial creation                                               *}
{*****************************************************************************}

function GenerateTempFile(const path:string):string;

var
   filename : String;
   i : byte;

begin;
    randomize;
    repeat
        filename:='';
        for i:=1 to 8 do filename:=filename+chr(65+random(26));
        filename:=filename+'.';
        for i:=1 to 3 do filename:=filename+chr(65+random(26));
        filename:=Path+'\'+filename;
    until not FileExists(filename);
    GenerateTempFile:=Filename;
end;

{*****************************************************************************}
{* Function/Procedure                                                        *}
{* ------------------                                                        *}
{*                                                                           *}
{* Purpose : Returns true if the file/directory exist                        *}
{* Changelog :                                                               *}
{*                                                                           *}
{* 06/12/2024 Initial Creation                                               *}
{*****************************************************************************}

function FileExists(const filename:string):boolean;
var
      f: SearchRec;

begin;
      FindFirst(filename,AnyFile,F);
      FileExists:=(DosError=0);
end;

function StrToFloat(Const S: String) : Double;
var
   error : Word;
   res : Double;

begin;
    val(S,Res,error);
    StrToFloat:=Res;
end;

begin;
      new(PDefaultFormatSettings);
      PFormatSettings:=PDefaultFormatSettings;
      with PDefaultFormatSettings^ do
      begin;
            CurrencyFormat:=1;
            NegCurrFormat:=5;
            ThousandSeparator:=',';
            DecimalSeparator:='.';
            CurrencyDecimals:=2;
            DateSeparator:='-';
            TimeSeparator:=':';
            ListSeparator:=',';
            CurrencyString:='$';
            ShortDateFormat:='d/m/y';
            LongDateFormat:='dd" "mmmm" "yyyy';
            TimeAMString:='AM';
            TimePMString:='PM';
            ShortTimeFormat:='hh:nn';
            LongTimeFormat:='hh:nn:ss';
            ShortMonthNames[1]:='Jan';
            ShortMonthNames[2]:='Feb';
            ShortMonthNames[3]:='Mar';
            ShortMonthNames[4]:='Apr';
            ShortMonthNames[5]:='May';
            ShortMonthNames[6]:='Jun';
            ShortMonthNames[7]:='Jul';
            ShortMonthNames[8]:='Aug';
            ShortMonthNames[9]:='Sep';
            ShortMonthNames[10]:='Oct';
            ShortMonthNames[11]:='Nov';
            ShortMonthNames[12]:='Dec';
            LongMonthNames[1]:='January';
            LongMonthNames[2]:='February';
            LongMonthNames[3]:='March';
            LongMonthNames[4]:='April';
            LongMonthNames[5]:='May';
            LongMonthNames[6]:='June';
            LongMonthNames[7]:='July';
            LongMonthNames[8]:='August';
            LongMonthNames[9]:='September';
            LongMonthNames[10]:='October';
            LongMonthNames[11]:='November';
            LongMonthNames[12]:='December';
            ShortDayNames[1]:='Sun';
            ShortDayNames[2]:='Mon';
            ShortDayNames[3]:='Tue';
            ShortDayNames[4]:='Wed';
            ShortDayNames[5]:='Thu';
            ShortDayNames[6]:='Fri';
            ShortDayNames[7]:='Sat';
            LongDayNames[1]:='Sunday';
            LongDayNames[2]:='Monday';
            LongDayNames[3]:='Tuesday';
            LongDayNames[4]:='Wednesday';
            LongDayNames[5]:='Thursday';
            LongDayNames[6]:='Friday';
            LongDayNames[7]:='Saturday';
            TwoDigitYearCenturyWindow:=50;
      end;
end.