#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes;
use Net::Bluetooth;
use IO::Select;
use Imager;
use GD;

sub listDevices();
sub connectDivoom($;$);
sub disconnectDivoom();
sub sendRaw($$;$);
sub sendPlain($$;$);
sub convertRawToPlain($);
sub convertImageTB($;$);
sub convertImageTBEVO($;$);
sub convertImageAB($;$);
sub readAnimatedGif($);
sub resizePicture($$$$);


my $socket;
my $TIMEBOX;
# 0 = disable escape sequences (use it for devices like timebox evo) 
# 1 = enable escape sequences (use it for devices like aurabox, timebox or timebox mini)
my $escaped = 1;

GD::Image->trueColor(1);


sub listDevices()
{
  print "Search for devices...\n\n";  

  my $device_ref = get_remote_devices();
  
  foreach my $addr (keys %$device_ref) 
  {
    print "Address: $addr Name: $device_ref->{$addr}\n";
  }

  print "done\n\n";
}

# the optional port parameter must be set to 1 for new devices like timebox evo
# default: port 4 for aurabox, timebox and timebox mini will be used
sub connectDivoom($;$)
{
  my $device = shift;
  my $port = shift;
  my $ret;
  my $success = 0;

  $port = 4 if (!defined($port));
  
  print "Create RFCOMM client ($device with port $port)...\n";
  
  $socket = Net::Bluetooth->newsocket("RFCOMM");
  return $success unless(defined($socket));
  
  if (0 != $socket->connect($device, $port))
  {
    $socket->close();
    return $success;
  }

  $TIMEBOX = $socket->perlfh();
  
  # timebox evo do not send anything on connect
  if (4 == $port)
  {
    sysread($TIMEBOX, $ret, 256);
    if (defined($ret))
    {
      $ret =~ s/[^[:print:]]//g;
      print "Device answer: $ret";

      if ('HELLO' eq $ret)
      {
        $success = 1;
      }
      else
      {
        close($TIMEBOX);
        $socket->close();
      }
    }
  }
  else
  {
    $success = 1;
  }
  
  print "\ndone\n\n";

  return $success;
}

sub disconnectDivoom()
{
  close($TIMEBOX);
  $socket->close();
}

sub sendRaw($$;$)
{
  my $data = shift;
  my $timeout = shift;
  my $response = shift;
  my $ret;
  my $retry = 0;
  my $select = IO::Select->new($TIMEBOX);
  
  print "Send raw command: $data\n";

  $response = 1 if (!defined($response));
  
  # needs rework
  if (0 != $escaped)
  {
    # remove prefix and postfix
    #$data = substr($data, 2, -2);
  
    # escape data if needed
    #$data =~ s/(01|02|03)(?{ if (0 == ($-[0] & 1)) {'030'.(3+$1)} else {$1} })/$^R/g;

    # add prefix and postfix
    #$data = '01'.$data.'02';
  }

  $data =~ s/((?:[0-9a-fA-F]{2})+)/pack('H*', $1)/ge;
  
  do
  {
    syswrite($TIMEBOX, $data);

    if ($select->can_read(0.1))
    {
      sysread($TIMEBOX, $ret, 256);
      if (defined($ret))
      {
        $ret = unpack('(H2)*', $ret);
        $ret =~ s/[^[:print:]]+//g;
        print "Device answer: $ret\n";
      }
    }
    else
    {
      print "No answer from device!\n";
    }

    $retry++;
  } while (($response) && ($retry <= 3) && (!defined($ret) || '01' ne $ret));

  if ($retry > 3)
  {
    print "Failed!\n";
  }
  else
  {
    Time::HiRes::sleep($timeout);
  }

  print "done\n\n";
}

sub sendPlain($$;$)
{
  my $data = shift;
  my $timeout = shift;
  my $response = shift;
  my $crc = 0;
  my $ret;
  my $retry = 0;

  print "Send plain command: $data\n";

  # add length (length of data + length of checksum)
  $_ = (length($data) + 4) / 2;
  $data = sprintf("%02X", ($_ & 0xFF)).sprintf("%02X", (($_ >> 8) & 0xFF)).$data;

  # calculate crc
  while ($data =~ /(..)/g)
  {
    $crc += hex($1);
  }

  # add crc
  $data .= sprintf("%02X", ($crc & 0xFF)).sprintf("%02X", (($crc >> 8) & 0xFF));  

  if (0 != $escaped)
  {
    # escape data
    $data =~ s/(01|02|03)(?{ if (0 == ($-[0] & 1)) {'030'.(3+$1)} else {$1} })/$^R/g;
  }
    
  # add prefix and postfix
  $data = '01'.$data.'02';

  print "Generated raw command: $data\n";

  sendRaw($data, $timeout, $response);
}

sub convertRawToPlain($)
{
  my $data = shift;

  print $data."\n";

  # remove prefix and postfix
  $data = substr($data, 2, -2);

  if (0 != $escaped)
  {
    # unescape data
    $data =~ s/(03(04|05|06))(?{ if (0 == ($-[0] & 1)) {'0'.($2-3)} else {$1} })/$^R/g;
  }
  
  #remove length
  $data = substr($data, 4);

  # remove checksum
  $data = substr($data, 0, -4);

  print $data."\n";

  return $data;
}

sub convertImageTB($;$)
{
  my $file = shift;
  my $size = shift;
  my @imgData = (0);
  my $image = GD::Image->new($file) or die "Can't read image $file\n";
  
  $size = 11 if (!defined($size));
  
  if (defined($image))
  {
    my $index;
    my ($r, $g, $b, $a);
    my $flicflac = 0;    
        
    print "Image: ".$file." (".$image->height."x".$image->width.")\n";
    
    if (($size != $image->height) || ($size != $image->width))
    {
      my $k_h = $size / $image->height;
      my $k_w = $size / $image->width;
      my $k   = ($k_h < $k_w ? $k_h : $k_w);
      my $height = int($image->height * $k);
      my $width  = int($image->width * $k);
      my $newimage = GD::Image->new($width, $height);
      
      $newimage->alphaBlending(0);
      $newimage->saveAlpha(1);
      $newimage->copyResampled($image, 0, 0, 0, 0, $width, $height, $image->width, $image->height);
      
      $image = $newimage;
    }

    for (my $y = 0; $y < $size; $y++)
    {
      for (my $x = 0; $x < $size; $x++)
      {
        $index = $image->getPixel($x, $y);
        ($r, $g, $b) = $image->rgb($index);
        $a = $image->alpha($index);
        
        if (0 == $flicflac)
        {
          if ($a > 32)
          {
            $imgData[-1] = (($r & 0xF0) >> 4) + ($g & 0xF0);
            push(@imgData, (($b & 0xF0) >> 4));
          }
          else
          {
            $imgData[-1] = 0;
            push(@imgData, 0);
          }

          $flicflac = 1;
        }
        else
        {
          if ($a > 32)
          {
            $imgData[-1] += ($r & 0xF0); 
            push(@imgData, (($g & 0xF0) >> 4) + ($b & 0xF0));
          }
          else
          {
            $imgData[-1] += 0;
            push(@imgData, 0);
          }
          push(@imgData, 0);

          $flicflac = 0;
        }
      }
    }
  }
  else
  {
    print "Error: Loading image failed!\n";
  }

  $_ = '';
  foreach my $byte (@imgData)
  {
    $_ .= sprintf("%02X", ($byte & 0xFF));
  }

  return $_;
}


sub convertImageTBEVO($;$)
{
  my $file = shift;
  my $size = shift;
  my %colors = ();
  my $imgData = '';
  my $bits;
  my $counter = 0;
  my $image = GD::Image->new($file) or die "Can't read image $file\n";
  
  @_ = ();
  
  $size = 16 if (!defined($size));
    
  if (defined($image))
  {
    my $index;
    my ($r, $g, $b, $a);

    print "Image: ".$file." (".$image->height."x".$image->width.")\n";
    
    if (($size != $image->height) || ($size != $image->width))
    {
      my $k_h = $size / $image->height;
      my $k_w = $size / $image->width;
      my $k   = ($k_h < $k_w ? $k_h : $k_w);
      my $height = int($image->height * $k);
      my $width  = int($image->width * $k);
      my $newimage = GD::Image->new($width, $height);
      
      $newimage->alphaBlending(0);
      $newimage->saveAlpha(1);
      $newimage->copyResampled($image, 0, 0, 0, 0, $width, $height, $image->width, $image->height);
      
      $image = $newimage;
    }
    
    for (my $y = 0; $y < $size; $y++)
    {
      for (my $x = 0; $x < $size; $x++)
      {
        $index = $image->getPixel($x, $y);
        ($r, $g, $b) = $image->rgb($index);
        #$_ = sprintf("%02X%02X%02X", $r, $g, $b);
        $_ = ($r << 16) + ($g << 8) + $b;
        
        if (!exists($colors{$_}))
        {
          # store color within hash
          $colors{$_} = $counter;
          
          # store pixel as color index
          push(@_, $counter);
          
          $counter++; 
        }
        else
        {
          # store pixel as color index
          push(@_, $colors{$_});
        }
      }
    }
  }
  else
  {
    print "Error: Loading image failed!\n";
  }

  $_ = log($counter) / log(2);
  $bits = ($_ == int($_)) ? $_ : int($_ + 1);
  $bits = 1 if (0 == $bits);
  
  foreach (@_)
  {
    $imgData .= substr(unpack('b*', pack('C*', $_)), 0, $bits);
  }

  # number of colors
  $_ = sprintf("%02X", $counter);
  # color codes
  foreach my $color (sort { $colors{$a} <=> $colors{$b} } keys %colors) 
  {
    #$_ .= $color;
    $_ .= sprintf("%06X", $color);
  }
  # RLE encoded image data
  $_ .= unpack('H*', pack('b*', $imgData));
  
  return $_;
}


sub convertImageAB($;$)
{
  my $file = shift;
  my $size = shift;
  my @imgData = ();
  my $image = Imager->new;
  my @color = (0, 1, 2, 11, 4, 5, 2, 15, 8, 1, 2, 3, 4, 13, 6, 7); 

  $size = 10;
  $image->read(file=>$file) or die "Can't read image ".$file." (".$image->errstr.")\n";

  if ('paletted' eq $image->type)
  {
    print "Image: ".$image->getheight()."x".$image->getwidth()." (maxcolors: ".$image->maxcolors.", usedcolors: ".$image->getcolorcount().")\n";
  }
  else
  {
    print "Image: ".$image->getheight()."x".$image->getwidth()." (maxcolors: no palette found, usedcolors: ".$image->getcolorcount().")\n";
  }

  if (defined($image))
  {
    my $flicflac = 0;

    for (my $y = 0; $y < $size; $y++)
    {
      for (my $x = 0; $x < $size; $x++)
      {
        my $index = $image->findcolor(color=>$image->getpixel(x=>$x, y=>$y));
        print "Warning: palette index (".$index.") outside of allowed range at x=".$x." y=".$y."\n" if ($index > 15);
        $index = $index % 16;
                
        if (0 == $flicflac)
        { 
          push(@imgData, $color[$index]);

          $flicflac = 1;
        }
        else
        {
          $imgData[-1] += ($color[$index] << 4); 

          $flicflac = 0;
        }
      }
    }
  }
  else
  {
    print "Error: Loading image failed!\n";
  }

  $_ = '';
  foreach my $byte (@imgData)
  {
    $_ .= sprintf("%02X", ($byte & 0xFF));
  }

  return $_;
}


sub readAnimatedGif($)
{
  my $file = shift;
  my @images = Imager->read_multi(file=>$file) or die "Can't read image ".$file." (".Imager->errstr.")\n"; 
  my @png = () x scalar(@images);
  
  for (my $i = 0; $i < scalar(@images); $i++)
  {
    print "Frame ".$i.": ".$images[$i]->getheight()."x".$images[$i]->getwidth()."\n";
    $images[$i]->write(data=>\$png[$i], type=>'png');  
  }
  
  return @png;
}


sub resizePicture($$$$)
{
  my ($inputfile, $width, $height, $outputfile) = @_;
  my $gdo = GD::Image->new($inputfile);
  my $k_h = $height / $gdo->height;
  my $k_w = $width / $gdo->width;
  my $k   = ($k_h < $k_w ? $k_h : $k_w);
  $height = int($gdo->height * $k);
  $width  = int($gdo->width * $k);
  my $image = GD::Image->new($width, $height);
  $image->alphaBlending(0);
  $image->saveAlpha(1);
  $image->copyResampled($gdo, 0, 0, 0, 0, $width, $height, $gdo->width, $gdo->height);

  open my $FH, '>', $outputfile;
  binmode $FH;
  print {$FH} $image->png;
  close $FH;
}

1;
