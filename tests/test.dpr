
{$i deltics.inc}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Datetime in '..\src\Deltics.Datetime.pas',
  Datetime.Tests in 'Datetime.Tests.pas';

begin
  TestRun.Test(DatetimeTests);
end.
