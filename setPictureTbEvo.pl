#!/usr/bin/perl
require "./divoom.pl";

# load picture
my $pic = convertImageTBEVO('timebox/tb_evo.png', 16);

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  # set clock
  sendPlain('4500', 5);
  # set picture
  sendPlain('44000A0A04AA2D00000000'.$pic, 10, 0);
  disconnectDivoom();
}