#!/usr/bin/perl
require "./divoom.pl";

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  sendPlain('4500', 5);
  # switch to weather view
  sendPlain('450100', 0);
  # set weather
  sendPlain('5F0101', 10, 0);
  sendPlain('5F0202', 10, 0);
  sendPlain('5F0303', 10, 0);
  sendPlain('5F0404', 10, 0);
  sendPlain('5F0505', 10, 0);
  sendPlain('5F0606', 10, 0);
  sendPlain('5F0707', 10, 0);
  sendPlain('5F0808', 10, 0);
  sendPlain('5F0909', 10, 0);
  sendPlain('5F0A0A', 10, 0);
  sendPlain('5F0B0B', 10, 0);
  sendPlain('5F0C0C', 10, 0);
  sendPlain('5F0D0D', 10, 0);
  sendPlain('5F0E0E', 10, 0);
  sendPlain('5F0F0F', 10, 0);
  sendPlain('5F1010', 10, 0);
  sendPlain('5F1111', 10, 0);
  sendPlain('5F1212', 10, 0);
  sendPlain('5F1313', 30, 0);  
  disconnectDivoom();
}