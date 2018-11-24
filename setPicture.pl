#!/usr/bin/perl
require "./divoom.pl";

# load picture
my $pic = convertImageTB('timebox/skull.png', 11);

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  # set clock
  sendPlain('4500', 5);
  # set picture
  sendPlain('44000A0A04'.$pic, 10, 0);
  disconnectDivoom();
}