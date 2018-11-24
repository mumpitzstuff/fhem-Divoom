#!/usr/bin/perl
require "./divoom.pl";

# load calendar picture
my $pic = convertImageTB('timebox/skull.png', 11);

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  sendPlain('4500', 5);
  # set calendar entry 0A0A = 10.10, 0805 = 08:05 Uhr
  sendPlain('5400010A0A080501006100620063006400650066006700680069006a006b006c006d006e006f0000', 0);
  sendPlain('550001000A'.$pic, 5, 0);
  # clear calendar entry again
  sendPlain('54000002010C00000000000000000000000000000000000000000000000000000000000000000000', 5);  
  disconnectDivoom();
}