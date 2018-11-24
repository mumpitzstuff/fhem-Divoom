#!/usr/bin/perl
require "./divoom.pl";

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  # set clock
  sendPlain('450001FF0000', 5);
  # set temperature
  sendPlain('45010000FF00', 5);
  # set animation (hardcoded)
  sendPlain('450301', 5);
  # set equalizer
  sendPlain('4504000000FFFF0000', 5);
  # set animation (loaded by app)
  sendPlain('4505', 5);
  # set stopwatch
  sendPlain('4506', 5);
  # set scoreboard
  sendPlain('450700010001', 5);
  disconnectDivoom();
}