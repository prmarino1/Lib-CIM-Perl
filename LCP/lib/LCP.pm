package LCP;

use 5.008008;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;


require LCP::Agent;  # this should load everything you need

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


1;

__END__


=head1 NAME

LCP - Lib CIM (Common Information Model) Perl

=head1 SYNOPSIS

  use LCP;
  use Data::Dumper;
  my $options={
        'username'=>'username',
        'password'=>'passwd',
        'protocol'=>'http',
        'Method'=>'POST'
  };
  my $post_counter=0;
  print "setting up the agent\n";
  my $agent=LCP::Agent->new('localhost',$options);
  print "setting up the session\n";
  my $session=LCP::Session->new($agent);
  print "constructing the query\n";
  my $test=LCP::Query->new();
  $test->EnumerateClasses('root/cimv2');
  print "posting the query\n";
  my $post=LCP::Post->new($session,$test);
  if (defined $post and $post->{'Result'}->is_success){
        print "post executed\n";
        print "@{[$post->{'Result'}->decoded_content]}\n";
        my $parser=LCP::SimpleParser->new($post->get_raw_xml);
        my $tree=$parser->buildtree;
        print Dumper($tree) . "\n";
  }
  


=head1 DESCRIPTION

  LCP (Lib CIM Perl) vendor agnostic near pure Perl API for Commom Information Model. The goal is to become
  a full DSP0200 compliant implemtation of CIM over http(s) by version 1.0 of the suite. As of now most read
  operations are impemented and have been tested against openPegasus but the api is still in an early
  development stage as such the syntax for the LCP::SimpleParser class is expected to change, however most
  of the other classes should not change much if at all with the exeption of new features until the
  release of version 1.0. and the syntax of the LCP::Query will never change aside from implmentation of
  previously unimplemented methods CIM, this is due to the fact that most of the methods are based strictly on a Perl
  style interpretation of DSP0200 from the DMTF.

=head2 EXPORT

None by default.


=head1 SEE ALSO

   DMTF DSP0200
   LWP (Lib WWW Perl)
   XML::Twig

=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
