{
  * MIT LICENSE *

  Copyright � 2008 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Direnko-Smith
  e-mail          : jsmith@deltics.co.nz
  github          : deltics/deltics.rtl
}

{$i deltics.datetime.inc}

{$ifdef debug_DelticsDateUtils}
  {$debuginfo ON}
  {$undefine InlineMethods}
{$endif}

  unit Deltics.DateUtils;


interface

  uses
  {$ifdef DELPHI2006_OR_2007}
    Controls, // Contains TDate and TTime declarations in Delphi 2006/2007 only
  {$endif}
    Windows;

  type
  {$ifdef DELPHI2006_OR_2007}               // Alias the TDate and TTime types from Controls
    TDate = Controls.TDate;
    TTime = Controls.TTime;
  {$else}
    {$ifdef __DELPHI7}                      // Up to Delphi 7 TDate or TTime are not declared at all
      TDate = type TDateTime;
      TTime = type TDateTime;
    {$else}
      // TDate and TTime are declared in System
    {$endif}
  {$endif}

    TDateTimePart   = (dtDate, dtTime);
    TDateTimeParts  = set of TDateTimePart;

    TDateTimeUnit = (
                      dtYear,
                      dtMonth,
                      dtWeek,
                      dtDay,
                      dtHour,
                      dtMinute,
                      dtSecond,
                      dtMillisecond
                    );

    TDayOfWeek = (
                  dwMonday = 1,
                  dwTuesday,
                  dwWednesday,
                  dwThursday,
                  dwFriday,
                  dwSaturday,
                  dwSunday
                 );

  const
    dtYears         = dtYear;
    dtMonths        = dtMonth;
    dtWeeks         = dtWeek;
    dtDays          = dtDay;
    dtHours         = dtHour;
    dtMinutes       = dtMinute;
    dtSeconds       = dtSecond;
    dtMilliseconds  = dtMillisecond;


  type
    Date = class
      class function Diff(const aDateA, aDateB: TDateTime; aUnits: TDateTimeUnit = dtDay): Integer;
    end;


  function DateDiff(const aEarlier, aLater: TDateTime): Double;
  function DateDiffInMilliseconds(const aEarlier, aLater: TDateTime): Int64;

  function DateTimeToISO8601(const aDateTime: TDateTime; const aParts: TDateTimeParts = [dtDate, dtTime]): String;
  function DateTimeFromISO8601(const aDateTime: String; const aParts: TDateTimeParts = [dtDate, dtTime]): TDateTime;

  function DateTimeOn(const aDate: TDate; aTime: TTime): TDateTime;
  function DateTimeToday(const aTime: TTime): TDateTime;
  function DateTimePlus(const aDateTime: TDateTime;
                        const aAmount: Integer;
                        const aUnits: TDateTimeUnit): TDateTime;

  function DayOfTheWeek(const aDateTime: TDateTime): TDayOfWeek;
  function DayOfTheMonth(const aDateTime: TDateTime): Integer;
  function DayOfTheYear(const aDateTime: TDateTime): Integer;


  function Now: TDateTime;


  type
    TDateTimeFn = function: TDateTime;

  procedure ClearBasisTimeFn;
  procedure SetBasisTime(const aDateTime: TDateTime);
  procedure SetBasisTimeFn(const aDateTimeFn: TDateTimeFn);

  function CustomBasisTime: TDateTime;

{$ifdef MSWINDOWS}
  function UtcNow: TDateTime;
  function LocalToUtc(const aDateTime: TDateTime): TDateTime;
  function UtcToLocal(const aDateTime: TDateTime): TDateTime;

  // Additional Windows API's not imported by the VCL Windows unit

  function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation;
                                           var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
    external kernel32 name 'TzSpecificLocalTimeToSystemTime';
{$endif}


implementation

  uses
    DateUtils,
    Math,
    SysUtils,
    TypInfo,
    Deltics.Exceptions;



(*
  function StrIsDate(const aString, aFormat: String): Boolean;
  var
    parts: TStringArray;
    y, m, d: Word;
  begin
    STR.Split(aString, '-', parts);

    y := StrToInt(parts[2]);
    m := StrToIntDef(parts[1], 0);
    d := StrToInt(parts[0]);

    if y < 100 then
      y := y + 2000;

    if m = 0 then
      m := STR.IndexOfText(parts[1], ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']) + 1;

    try
      EncodeDate(y, m, d);
      result := TRUE;

    except
      result := FALSE;
    end;
  end;


  function StrToDate(const aString, aFormat: String): TDate;
  var
    parts: TStringArray;
    y, m, d: Word;
  begin
    STR.Split(aString, '-', parts);

    y := StrToInt(parts[2]);
    m := StrToIntDef(parts[1], 0);
    d := StrToInt(parts[0]);

    if y < 100 then
      y := y + 2000;

    if m = 0 then
      m := STR.IndexOfText(parts[1], ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']) + 1;

    result := EncodeDate(y, m, d);
  end;
*)

  var
    _BasisTime: TDateTime;
    _BasisTimeFn: TDateTimeFn = SysUtils.Now;


  procedure ClearBasisTimeFn;
  begin
    _BasisTimeFn := SysUtils.Now;
  end;


  procedure SetBasisTime(const aDateTime: TDateTime);
  begin
    _BasisTime := aDateTime;
  end;


  procedure SetBasisTimeFn(const aDateTimeFn: TDateTimeFn);
  begin
    _BasisTimeFn := aDateTimeFn;

    if NOT Assigned(_BasisTimeFn) then
      _BasisTimeFn := SysUtils.Now;
  end;


  function CustomBasisTime: TDateTime;
  begin
    result := _BasisTime;
  end;


  function Now: TDateTime;
  begin
    result := _BasisTimeFn;
  end;





  function DateDiff(const aEarlier, aLater: TDateTime): Double;
  begin
    result := aLater - aEarlier;
  end;


  function DateDiffInMilliseconds(const aEarlier, aLater: TDateTime): Int64;
  begin
    result := Trunc(DateDiff(aEarlier, aLater) * MSecsPerDay);
  end;


  function DateTimeToISO8601(const aDateTime: TDateTime;
                             const aParts: TDateTimeParts): String;
  const
    DATEFORMAT = '%.4d%.2d%.2d';
    TIMEFORMAT = '%.2d%.2d%.2d.%.3d0';
  var
    parts: TDateTimeParts;
    year, month, day: Word;
    hour, min, sec, msec: Word;
  begin
    parts := aParts;
    if parts = [] then
      parts := [dtDate, dtTime];

    DecodeDate(aDateTime, year, month, day);
    DecodeTime(aDateTime, hour, min, sec, msec);

    if (dtDate in parts) then
    begin
      result := Format(DATEFORMAT, [year, month, day]);
      if (dtTime in aParts) then
        result := result + ' ';
    end
    else
      result := '';

    if (dtTime in parts) then
      result := result + Format(TIMEFORMAT, [hour, min, sec, msec]);
  end;


  function DateTimeFromISO8601(const aDateTime: String;
                               const aParts: TDateTimeParts): TDateTime;

    function Pop(var S: String; const aLen: Integer): Word;
    begin
      result := StrToInt(Copy(S, 1, aLen));
      Delete(S, 1, aLen);
    end;

  const
    TIME_LENGTH = 11;   // hhmmss.nnnn
    DATE_LENGTH = 8;    // yyyymmdd
    DATETIME_LENGTH = DATE_LENGTH + 1 + TIME_LENGTH;   // single space separates the two values
  var
    parts: TDateTimeParts;
    s: String;
    year, month, day: Word;
    hour, min, sec, msec: Word;
  begin
    parts := aParts;
    if parts = [] then
      parts := [dtDate, dtTime];

    s := aDateTime;

    year  := 1899;
    month := 12;
    day   := 31;
    hour  := 0;
    min   := 0;
    sec   := 0;
    msec  := 0;

    if (Length(s) = DATE_LENGTH)
     or (Length(s) = DATETIME_LENGTH) then
    begin
      year  := Pop(s, 4);
      month := Pop(s, 2);
      day   := Pop(s, 2);

      Delete(s, 1, 1);
    end;

    if (Length(s) = TIME_LENGTH) then
    begin
      hour  := Pop(s, 2);
      min   := Pop(s, 2);
      sec   := Pop(s, 2);

      Delete(s, 1, 1);

      msec  := Pop(s, 4) div 10;
    end;

    result  := 0;

    if (dtDate in parts) then
      result := EncodeDate(year, month, day);

    if (dtTime in parts) then
      result := result + EncodeTime(hour, min, sec, msec);
  end;



  function DateTimeOn(const aDate: TDate; aTime: TTime): TDateTime;
  begin
    result := Trunc(aDate) + (aTime - Trunc(aTime));
  end;


  function DateTimeToday(const aTime: TTime): TDateTime;
  begin
    result := DateTimeOn(Now, aTime);
  end;


  function DateTimePlus(const aDateTime: TDateTime;
                        const aAmount: Integer;
                        const aUnits: TDateTimeUnit): TDateTime;
  var
    y, m, d: Word;
    h, mi, s, ms: Word;
  begin
    if aAmount = 0 then
    begin
      result := aDateTime;
      EXIT;
    end;

    DecodeDate(aDateTime, y, m, d);
    DecodeTime(aDateTime, h, mi, s, ms);

    case aUnits of
      dtYear    : begin
                    y := y + aAmount;

                    if (m = 2) and (d > 28) then
                      d := Min(d, DaysInAMonth(y, m));

                    result := DateTimeOn(EncodeDate(y, m, d), aDateTime);
                  end;

      dtMonth   : begin
                    if (aAmount > 0) then
                      y := y + ((m + aAmount + 1) div 12)
                    else
                      y := y + ((m - 12 + aAmount) div 12);

                    m := ((12 + (((m - 1) + aAmount) mod 12)) + 1) mod 12;

                    if (d > 30) or ((m = 2) and (d > 28)) then
                      d := Min(d, DaysInAMonth(y, m));

                    result := DateTimeOn(EncodeDate(y, m, d), aDateTime);
                  end;
      dtWeek    : result := DateTimeOn(Trunc(aDateTime) + (aAmount * 7), aDateTime);
      dtDay     : result := DateTimeOn(Trunc(aDateTime) + aAmount, aDateTime);
      dtHour    : result := aDateTime + (aAmount * (1 / HoursPerDay));
      dtMinute  : result := aDateTime + (aAmount * (1 / MinsPerDay));
      dtSecond  : result := aDateTime + (aAmount * (1 / SecsPerDay));
    else
      result := aDateTime;
    end;
  end;


  function DayOfTheWeek(const aDateTime: TDateTime): TDayOfWeek;
  begin
    result := TDayOfWeek(DateUtils.DayOfTheWeek(aDateTime));
  end;


  function DayOfTheMonth(const aDateTime: TDateTime): Integer;
  begin
    result := DateUtils.DayOfTheMonth(aDateTime);
  end;


  function DayOfTheYear(const aDateTime: TDateTime): Integer;
  begin
    result := DateUtils.DayOfTheYear(aDateTime);
  end;



{$ifdef MSWINDOWS}
  function UtcNow: TDateTime;
  begin
    result := LocalToUtc(Now);
  end;


  function LocalToUtc(const aDateTime: TDateTime): TDateTime;
  var
    local: TSystemTime;
    UTC: TSystemTime;
  begin
    DateTimeToSystemTime(aDateTime, local);

    Win32Check(TzSpecificLocalTimeToSystemTime(NIL, local, UTC));

    result := SystemTimeToDateTime(UTC);
  end;


  function UtcToLocal(const aDateTime: TDateTime): TDateTime;
  var
    UTC: TSystemTime;
    local: TSystemTime;
  begin
    DateTimeToSystemTime(aDateTime, UTC);

    Win32Check(SystemTimeToTzSpecificLocalTime(NIL, UTC, local));

    result := SystemTimeToDateTime(local);
  end;
{$endif}



{ Date }

  class function Date.Diff(const aDateA, aDateB: TDateTime; aUnits: TDateTimeUnit): Integer;
  var
    diff: Double;
  begin
    if aUnits > dtDay then
      diff := aDateB - aDateA
    else
      diff := Trunc(aDateB) - Trunc(aDateA);

    case aUnits of
      dtYears       : raise ENotImplemented.Create;
      dtMonths      : raise ENotImplemented.Create;
      dtWeeks       : result := Trunc(diff / 7);
      dtDays        : result := Trunc(diff);
      dtHours       : result := Trunc(diff * 24);
      dtMinutes     : result := Trunc(diff * 24 * 60);
      dtSeconds     : result := Trunc(diff * 24 * 60 * 60);
      dtMilliseconds: result := Trunc(diff * 24 * 60 * 60 * 1000);
    else
      raise ENotImplemented.CreateFmt('%s units are not supported by DateDiff',
                                      [GetEnumName(TypeInfo(TDateTimeUnit), Ord(aUnits))]);
    end;
  end;




end.
