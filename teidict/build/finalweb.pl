#!/usr/bin/perl


sub gobblespace {
  my $data = `cat dict/entries.raw`;
  $data =~s/[ \n\r\t]+/" "/eg;
  $data =~s/&#339;/oe/eg;
  $data =~s/&#375;/"ÿ"/eg;
  $data =~s/<raw><\/raw>[ ]*/'
'/eg;
  print $data;
  print "

";
}

&gobblespace;

# END OF FILE
