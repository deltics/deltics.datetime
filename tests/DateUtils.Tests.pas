
  unit DateUtils.Tests;

interface

  uses
    Deltics.Smoketest;


  type
    DateUtilsTests = class(TTest)
      procedure DayOfTheWeekIsCorrect;
      procedure DayOfTheMonthIsCorrect;
      procedure DayOfTheYearIsCorrect;
      procedure DateDiffReturnsCorrectDays;
    end;


implementation

  uses
    SysUtils,
    Deltics.DateUtils;


{ DateUtilsTests }

  procedure DateUtilsTests.DayOfTheWeekIsCorrect;
  var
    dt: TDateTime;
  begin
    dt := EncodeDate(2020, 11, 16);

    Test('DayOfTheWeek(16 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 0))).Equals(Ord(dwMonday));
    Test('DayOfTheWeek(17 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 1))).Equals(Ord(dwTuesday));
    Test('DayOfTheWeek(18 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 2))).Equals(Ord(dwWednesday));
    Test('DayOfTheWeek(19 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 3))).Equals(Ord(dwThursday));
    Test('DayOfTheWeek(20 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 4))).Equals(Ord(dwFriday));
    Test('DayOfTheWeek(21 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 5))).Equals(Ord(dwSaturday));
    Test('DayOfTheWeek(22 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 6))).Equals(Ord(dwSunday));
    Test('DayOfTheWeek(23 Nov 2020)').Assert(Integer(DayOfTheWeek(dt + 7))).Equals(Ord(dwMonday));
  end;


  procedure DateUtilsTests.DayOfTheMonthIsCorrect;
  var
    dt: TDateTime;
  begin
    dt := EncodeDate(2020, 11, 27);

    Test('DayOfTheMonth(27 Nov 2020)').Assert(DayOfTheMonth(dt + 0)).Equals(27);
    Test('DayOfTheMonth(28 Nov 2020)').Assert(DayOfTheMonth(dt + 1)).Equals(28);
    Test('DayOfTheMonth(29 Nov 2020)').Assert(DayOfTheMonth(dt + 2)).Equals(29);
    Test('DayOfTheMonth(30 Nov 2020)').Assert(DayOfTheMonth(dt + 3)).Equals(30);
    Test('DayOfTheMonth( 1 Dec 2020)').Assert(DayOfTheMonth(dt + 4)).Equals(1);
    Test('DayOfTheMonth( 2 Dec 2020)').Assert(DayOfTheMonth(dt + 5)).Equals(2);
    Test('DayOfTheMonth( 3 Dec 2020)').Assert(DayOfTheMonth(dt + 6)).Equals(3);
    Test('DayOfTheMonth( 4 Dec 2020)').Assert(DayOfTheMonth(dt + 7)).Equals(4);
  end;


  procedure DateUtilsTests.DayOfTheYearIsCorrect;
  begin
    Test('DayOfTheYear(1 Jan 2019)').Assert(DayOfTheYear(EncodeDate(2019, 1, 1))).Equals(1);
    Test('DayOfTheYear(1 Mar 2019)').Assert(DayOfTheYear(EncodeDate(2019, 3, 1))).Equals(60);
    Test('DayOfTheYear(31 Jan 2019)').Assert(DayOfTheYear(EncodeDate(2019, 12, 31))).Equals(365);

    Test('DayOfTheYear(1 Jan 2020)').Assert(DayOfTheYear(EncodeDate(2020, 1, 1))).Equals(1);
    Test('DayOfTheYear(1 Mar 2020)').Assert(DayOfTheYear(EncodeDate(2020, 3, 1))).Equals(61);
    Test('DayOfTheYear(31 Jan 2020)').Assert(DayOfTheYear(EncodeDate(2020, 12, 31))).Equals(366);
  end;


  procedure DateUtilsTests.DateDiffReturnsCorrectDays;
  begin
    Test('DateDiff(1 Jan 2020, 1 Jan 2020)').Assert(Date.Diff(EncodeDate(2020, 1, 1), EncodeDate(2020, 1, 1), dtDays)).Equals(0);
    Test('DateDiff(1 Jan 2020, 31 Dec 2019)').Assert(Date.Diff(EncodeDate(2020, 1, 1), EncodeDate(2019, 12, 31), dtDays)).Equals(-1);
    Test('DateDiff(1 Jan 2020, 1 Jan 2020)').Assert(Date.Diff(EncodeDate(2019, 12, 31), EncodeDate(2020, 1, 1), dtDays)).Equals(1);
    Test('DateDiff(1 Jan 2020, 5 Jan 2020)').Assert(Date.Diff(EncodeDate(2020, 1, 1), EncodeDate(2020, 1, 5), dtDays)).Equals(4);
  end;





end.
