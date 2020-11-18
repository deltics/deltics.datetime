
{$i deltics.inc}

  program test;

uses
  Deltics.Smoketest,
  Deltics.DateUtils in '..\src\Deltics.DateUtils.pas',
  DateUtils.Tests in 'DateUtils.Tests.pas';

begin
  TestRun.Test(DateUtilsTests);
end.
