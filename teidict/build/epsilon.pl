#!/usr/bin/perl


sub phonetics {
  my $pron = $_[0];
  $pron =~ s/([^AaeE][EIei])l([\"%]?[^\"%aeiouyAEIOUY])/$1 . "L" . $2/eg;
  $pron =~ s/@@@//eg;
  $pron =~ s/l_0/K/eg;
  return "$pron";
}

sub conversion {
  my $data = `cat dict8.xml`;
  $data =~s/(<pron>[^<]*)/&phonetics( $1 . "@@@" )/eg;
  print $data;
}

&conversion;

# END OF FILE
