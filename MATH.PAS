unit math;

interface

type
   {$ifdef UseDouble}
   float = double;
   {$else}
       {$ifdef UseSingle}
   float = single;
       {$else}
   float = Extended;
       {$endif}
   {$endif}

const
   pi   : float = 3.1415926535897932384626433832795;
   e    : float = 2.7182818284590452353602874713527;
   ln10 : float = 2.3025850929940456840179914546844;
   ln2  : float = 0.6931471805599453094172321214581;
   {$ifdef UseDouble}
   NaNarray: array[0..7] of byte=($00, $00, $00, $00, $00, $09, $F8, $7F); {Nan representation for double}
   INFarray: array[0..7] of byte=($00, $00, $00, $00, $00, $00, $F0, $7F); {Inf representation for double}
   {$else}
       {$ifdef UseSingle}
   NaNarray: array[0..3] of byte=($00, $48, $C0, $7F); {NaN representation for single}
   INFarray: array[0..3] of byte=($00, $00, $80, $7F); {INF representation for single}
       {$else}
   NaNArray: array[0..9] of byte=($00, $00, $00, $00, $00, $00, $48, $C0, $FF, $7F); {NaN representation for extended}
   INFArray: array[0..9] of byte=($00, $00, $00, $00, $00, $00, $00, $00, $FF, $7F); {INF representation for extended}
       {$endif}
   {$endif}


var
   INF : float absolute INFArray;
   NAN : float absolute NANArray;

function ArcCos(X:Float) : Float;
function ArcCosH(X:Float) : Float;
function ArcSin(X:Float) : Float;
function ArcSinH(X:Float) : Float;
function ArcTan2(Y,X:Float) : Float;
function Arccotan(x:float) : float;
function ArcTanH(X:Float) : Float;
function ceil(x:float) : longint;
function floor(x:float) : longint;
function cosecant(x:float) : float;
function cosh(x:float) : float;
function cotan(x:float) : float;
function cotanh(x:float) : float;
function CycleToRad(x:float) : float;
function DegNormalize(x:float) : float;
function DegToGrad(x:float) : float;
function DegToRad(x:float) : float;
function EnsureRange(const AValue, AMin, AMax : float):float;
function FMod(const a,b : Float) : Float;
procedure Frexp(X:float;var Mantissa:Float;var Exponent:longint);
function GradToDeg(X:Float):float;
function GradToRad(x:Float):float;
function hypot(x,y : float):float;
function ifthen(val:boolean;const iftrue:Float; const iffalse:float):float;
function InRange(const AVal, AMin, AMax : Float) : boolean;
function ldexp(x:float;const p:integer) : float;
function intpower(base:float;const exponent:longint) : float;
function log10(x:float) : float;
function log2(x:float) : float;
function logn(n,x:float) : float;
function Power(base,exponent:float) : float;
function RadtoCycle(rad :float) : float;
function RadtoDeg(rad : float) : float;
function RadToGrad(rad : float) : float;
function RandG(mean, stddev : float) : float;
function RoundTo(const AValue: Float;const digits:byte) : Extended;
function Secant(X:float): float;
function sign(X:Float) : shortint;
function sinh(x:float) : float;
function tan(x:float) : float;
function tanh(x:float) : float;
function DegToDMS(x:float) : string;
function factorial(n:float) : float;
function gcd(a,b : Longint):Longint;

implementation

uses sysutils;

function ArcCos(X:float) : float;
begin;
      if abs(X)=1.0 then
       if x<0.0 then
        ArcCos:=Pi
       else
        ArcCos:=0
      else
       arccos:=arctan2(sqrt((1.0-x)*(1.0+x)),x);
end;

function ArcTan2(Y,X:Float) : Float;
var
   result : Float;

begin;
    if x=0 then
    begin;
        if y=0 then arctan2:=0.0
        else if y>0 then result:=pi / 2
        else if y<0 then result:=-pi / 2;
    end
    else result:=ArcTan(y/x);
    if x<0.0 then result:=result+pi;
    if result>pi then result:=result-2*pi;
    arctan2:=result;
end;

function ArcCosH(X:Float):Float;
begin;
    ArcCosH:=ln(x+sqrt((x-1.0)*(x+1.0)));
end;

function ArcSin(X:Float) : Float;
begin;
    ArcSin:=Arctan2(x,sqrt((1.0-x)*(1.0+x)));
end;


function ArcSinH(X:Float) : Float;
var
   z: float;

begin;
    z:=abs(x);
    z:=ln(z+sqrt(1+z*z));
    if x<0 then arcSinH:=-abs(z)
    else arcSinH:=abs(z);
end;

function lnxp1(x:float) : float;
begin;
    lnxp1:=ln(1+x);
end;

function ArcTanH(X:Float) : Float;
begin;
      arctanh:=(lnxp1(x)-lnxp1(-x))*0.5;
end;

function ceil(x:float) : longint;
begin;
      ceil:=Trunc(x)+ord(frac(x)>0);
end;

function floor(x:float) : longint;
begin;
      floor:=Trunc(x)-ord(Frac(x)<0);
end;

function cosecant(x:float) : float;
begin;
    if sin(x)<>0.0 then cosecant:=1/sin(x)
    else cosecant:=NaN;
end;

function cosh(x:float) : float;
var
   temp : float;

begin;
    temp:=exp(x);
    cosh:=0.5*(temp+1.0/temp);
end;

function cotan(x:float) : float;
begin;
    if sin(x)<>0.0 then cotan:=cos(x)/sin(x)
    else cotan:=Nan;
end;

function cycletorad(x:float) : float;
begin;
      cycletorad:=2*pi*x;
end;

function degNormalize(x:float) : float;

var
    result: float;

begin;
    result:=x-int(x/360)*360;
    if result<0 then result:=result+360;
    degNormalize:=result;
end;


function DegToGrad(x:float) : float;
begin;
      degtograd:=x*(200.0/180.0);
end;

function DegToRad(x:float) : float;
begin;
      degtorad:=x*(pi/180.0);
end;

function EnsureRange(const AValue, AMin, AMax : float):float;

begin;
      if AValue<AMin then EnsureRange:=AMin
      else if AValue>AMax then EnsureRange:=AMax
      else EnsureRange:=AMax;
end;

function FMod(const a,b : Float) : Float;
begin;
      Fmod:= a-b * int(a/b);
end;

procedure Frexp(X:float;var Mantissa:Float;var Exponent:longint);

begin;
      Exponent:=0;
      if (X<>0) then
      begin;
         if (abs(x)<0.5) then
         begin;
               repeat
                     x:=x*2;
                     dec(exponent);
               until (abs(x)>=0.5);
         end;
      end;
      Mantissa:=X;
end;

function GradToDeg(X:Float):float;
begin;
      GradToDeg:=X*(180.0/200.0);
end;

function GradToRad(x:Float):float;
begin;
      GradToRad:=x*(pi/200.0);
end;

function hypot(x,y:float) : float;
begin;
      x:=abs(x);
      y:=abs(y);
      if (x>y) then hypot:=x*sqrt(1.0+sqr(y/x))
      else if (x>0.0) then hypot:=y*sqrt(1.0+sqr(x/y))
      else hypot:=y;
end;

function ifthen(val:boolean;const iftrue:Float; const iffalse:float):float;

begin;
      if val then ifthen:=iftrue else ifthen:=iffalse;
end;

function InRange(const AVal, AMin, AMax : Float) : boolean;
begin;
      InRange:=(AVal>=AMin) and (AVal<=AMax);
end;

function intpower(base:float;const exponent:longint) : float;
var
   i: longint;
   result:float;

begin;
    if (base = 0.0) and (exponent = 0) then intpower:=1.0
    else
    begin;
          if exponent<0 then base:=1.0/base;
          i:=abs(exponent);
          result:=1.0;
          while i>0 do
          begin;
              while (i and 1)=0 do
              begin;
                  i:=i shr 1;
                  base:=sqr(base);
              end;
              dec(i);
              result:=result*base;
          end;
    end;
    intpower:=result;
end;

function ldexp(x:float;const p:integer) : float;
begin;
      ldexp:=x*intpower(2.0,p);
end;

function log10(x:float):float;
begin;
      log10:=ln(x)/ln10;
end;

function log2(x:float):float;
begin;
      log2:=ln(x)/ln2;
end;

function logn(n,x:float) : float;
begin;
      if n=1.0 then logn:=nan
      else logn:=ln(x)/ln(n);
end;

function power(base, exponent:float) : float;
var
   result : float;

begin;
      if Exponent=0.0 then result:=1.0
      else if (base=0.0) and (exponent>0.0) then result:=0.0
      else if (abs(exponent)<=maxlongint) and (frac(exponent)=0.0) then result:=intpower(base,trunc(exponent))
      else result:=exp(exponent * ln(base));
      power:=Result;
end;

function RadtoCycle(rad : float) : float;
begin;
    RadToCycle:=rad * 0.5 * pi;
end;

function RadToDeg(rad : float) : float;
begin;
      radtodeg:=rad * (180.0/pi);
end;

function RadToGrad(rad : float) : float;
begin;
      RadToGrad:=rad * (200.0/pi);
end;

function RandG(mean, stddev : float) : float;
var U1, S2 : Float;

begin;
      repeat
            u1:=2*random-1;
            s2:=sqr(u1)+sqr(2*random-1);
      until s2<1;
      randg:=sqrt(-2*ln(S2)/S2)*u1*stddev+mean;
end;

function RoundTo(const AValue: Float;const digits:byte) : Extended;

var
   RV : Float;

begin;
    RV:=IntPower(10,Digits);
    RoundTo:=Round(AValue/RV)*RV;
end;

function Secant(X:float): float;
begin;
      if cos(x)=0.0 then secant:=nan
      else secant:=1/cos(x);
end;

function sign(X:Float) : shortint;
begin;
      sign:=ord(X>0.0)-ord(X<0.0);
end;

function sinh(x:float) : float;

var
   temp : float;

begin;
    temp:=exp(x);
    sinh:=0.5*(temp-1.0/temp);
end;

function tan(x:float) : float;

begin;
      if Abs(cos(x))=0.0 then tan:=inf
      else tan:=sin(x)/cos(x);
end;

function tanh(x:float) : float;
const
     MaxTanh = 5678.22249441322;

var
   temp : Float;

begin;
    if x>MaxTanh then tanh:=1.0
    else if x<-MaxTanh then tanh:=-1.0
    else
    begin;
          temp:=exp(-2*x);
          tanh:=(1-temp)/(1+temp)
    end;
end;

function DegToDMS(x:float) : string;
var
   Deg, Min : integer;
   sec : Float;

begin;
      deg:=trunc(x);
      x:=frac(x);
      min:=trunc(x*60);
      sec:=frac(x*60)*60;
      DegToDMS:=IntegerToStr(deg,0)+'ø'+IntegerToStr(min,0)+chr(39)+FloatToStr(sec)+'"';
end;

function Arccotan(x:float) : float;
begin;
      if x=0.0 then arccotan:=nan
      else Arccotan:=arctan(1/x);
end;

function cotanh(x:float) : float;
begin;
      if x=0.0 then cotanh:=nan
      else cotanh:=1/tanh(x);
end;

function factorial(n:float):float;
begin;
      n:=int(n);
      if (n=0) or (n=1) then factorial:=1
      else factorial:=n*factorial(n-1);
end;

function gcd(a,b : Longint):Longint;
begin;
      while b<>0 do
      begin;
            a:=a mod b;
            if a = 0 then break;
            b:=b mod a;
      end;
      if a = 0 then GCD:=b
      else GCD:=a;
end;

end.