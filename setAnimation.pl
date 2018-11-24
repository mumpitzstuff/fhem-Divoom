#!/usr/bin/perl
require "./divoom.pl";

# load animation pictures
my $pic1 = convertImageTB('timebox/1.png', 11);
my $pic2 = convertImageTB('timebox/2.png', 11);
my $pic3 = convertImageTB('timebox/3.png', 11);
my $pic4 = convertImageTB('timebox/4.png', 11);
my $pic5 = convertImageTB('timebox/5.png', 11);
my $pic6 = convertImageTB('timebox/6.png', 11);
my $pic7 = convertImageTB('timebox/7.png', 11);
my $pic8 = convertImageTB('timebox/8.png', 11);

if (connectDivoom('11:75:58:4F:A1:CB'))
{
  # set clock
  sendPlain('4500', 5);
  # set animation
  sendPlain('49000A0A040000'.$pic1, 0, 0);
  sendPlain('49000A0A040100'.$pic2, 0, 0);
  sendPlain('49000A0A040200'.$pic3, 0, 0);
  sendPlain('49000A0A040300'.$pic4, 0, 0);
  sendPlain('49000A0A040400'.$pic5, 0, 0);
  sendPlain('49000A0A040500'.$pic6, 0, 0);
  sendPlain('49000A0A040600'.$pic7, 0, 0);
  sendPlain('49000A0A040700'.$pic8, 20, 0);
  disconnectDivoom();
}