#!/usr/bin/perl

# PHONETICS
 
%sampa_UTF = (
      # Stress
      '"',  '&#712;',  # Primary stress
      '%',  '&#716;',   # Secondary stess
      # Vowel
      'A',  '&#593;',     # Card. 5, script a
      'O',  '&#596;',     # Card. 6, turned c
      '3',  '&#604;',     # reversed epsilon
      'E',  '&#603;',     # epsilon
      # Consonant
      'D',  '&#240;',     # Voiced dental fricative (theta)
      'T',  '&#952;',     # Voiceless dental fricative (theta)
      'X',  '&#967;',         # Voiceless uvular fricative (chi)
      'N',  '&#331;',         # (eng)
      'W',  '&#653;',        # Voiceless w (reversed w)
      'K',  '&#620;',        # Fricative voiceless l
      # Modified consonants 
      'L',   'l&#801;',        # Palatal l (with hook) -- WARNING, NOT IN X-SAMPA
      'l_0', 'l&#805;',       # Voiceless l
      'r_0', '&#633;&#805;',       # Voiceless r
      'w_0', 'w&#805;',       # Voiceless w
      'r=',  'r&#809;',      # Syllabic r
      'l=',  'l&#809;',      # Syllabic l
      'n=',  'n&#809;',      # Syllabic n
      # Syllabic marks
      '.',  '.',   # Syllabic break
      # Length mark
      ':/', '&#721;',    # Half Length mark
      ':',  '&#720;'     # Length mark
   );

sub sampa2utf {
  my $parm = $_[0];

  if ($sampa_UTF{$parm}) {
    return "$sampa_UTF{$parm}";
  } else {
    return "$parm";
  }
}

sub phonetics {
  my $pron = $_[0];
  $pron =~ s/((.\/)|(.=)|(._0)|(_.)|(.[`])|(.))/sampa2utf( $1 )/eg;
  return "$pron";
}

sub conversion {
  my $data = `cat dict8.xml`;
  $data =~s/(<pron>[^<]*)/&phonetics( $1 )/eg;
  print $data;
}

&conversion;

# END OF FILE
