package LCP::Agent;

use 5.008008;

use strict;
use warnings;
use Carp;
use LWP;
use LWP::UserAgent;
use LCP::Query;
use LCP::SimpleParser;
use LCP::Session;
use LCP::XMLWriter;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


sub new{
    my $class=shift;
    my $host=shift;
    my $options=shift;
    unless(defined $host){
	carp "No host defined\n";
	return 0;
    }
    # creating self hash with LWP Agent and hostname
    my $self={
        'agent' => $options->{'useragent'} || LWP::UserAgent->new(),
        'host' => $host,
    };
    
    if (defined $options->{'protocol'} and $options->{'protocol'}){
        if ($options->{'protocol'}=~/^(http|https)$/i){
            $self->{'protocol'}=$options->{'protocol'};
        }
        else{
        carp "\"$options->{'protocol'}\"is not a valid protocol please use http or https\n";
        return 0;
        }
        
    }
    else{
        $self->{'protocol'}='https';
    }
    
    if (defined $options->{'port'} and $options->{'port'}){
        if ($options->{'port'}=~/^\d+$/){
            $self->{'port'}=$options->{'port'};
        }
        else{
            carp "\"$options->{'port'}\" is not a valid port number";
            return 0;
        }
        
    }
    else{
        if ($self->{'protocol'}=~/^http$/i){
            $self->{'port'}=5988;
            
        }
        elsif ($self->{'protocol'}=~/^https$/i){
           $self->{'port'}=5989; 
        }
    }
    # adding authentication info
    if ($options->{'username'} and $options->{'password'}){
        $self->{'username'}=$options->{'username'};
	$self->{'password'}=$options->{'password'};
    }
    
    if ($LWP::VERSION >='6.00'){
	$self->{'digest_auth_capable'}=1;
    }
    #if(exists LWP::Authen::Digest::new){
	#
    #}
    $self->{'uri'}=$self->{'protocol'} . '://' . $self->{'host'} . ':' . $self->{port} . '/cimom';
    if (defined $options->{'Method'} and $options->{'Method'}){
	if ($options->{'Method'}=~/^(AUTO|POST|M-POST)$/i){
	    $self->{'Method'}=$options->{'Method'};
	}
	else{
	    carp ("Invalid posting method \"$options->{'Method'}\" Please choose AUTO, POST or MPOST");
	}
    }
    else {
	$self->{'Method'}='AUTO';
    }
    if (defined $options->{'Timeout'} and $options->{'Timeout'}=~/^\d+$/){
	$self->{'Timeout'}=$options->{'Timeout'};
    }
    else{
	$self->{'Timeout'}='60';
    }
    if (defined $options->{'Interop'} and $options->{'Interop'}=~/\w+(\/\w+)*/){
	$self->{'Interop'}=$options->{'Interop'};
    }
    elsif(defined $options->{'Interop'}){
	carp "WARNING: \"$options->{'Interop'}\" does not match the patern for CIM namespace setting the namespace to root/interop instead\n";
	warn "ERROR: Overriding the Interop namespace speccified for this agent because it failed the format validation check\n";
	$self->{'Interop'}='root/interop';
    }
    else{
	$self->{'Interop'}='root/interop';
    }
    bless ($self, $class);
    return $self;
}


1;


__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::Agent - Lib CIM (Common Information Model) Perl

=head1 SYNOPSIS

  use LCP;
  # setting the options for the agent
  my $options={
	'username'=>'someuser',
	'password'=>'somepassword',
	'protocol'=>'http',
	'Method'=>'POST'
  };
  # initializing the agent
  my $agent=LCP::Agent->new('localhost',$options);
  #Creating a session
  my $session=LCP::Session->new($agent);
  # creating a new query
  my $query=LCP::Query->new();
  # Constructing a simple Enumerate classes query against root/cimv2
  $query->EnumerateClasses('root/cimv2');
  # Posting the query
  my $post=LCP::Post->new($session,$query);
  my $tree;
  # Parse if the query executed properly
  if (defined $post and $post->success){
    print "post executed\n";
    #Parsing the query
    my $parser=LCP::SimpleParser->new($post->get_raw_xml);
    # returning a multi dimentional hash of the results
    my $tree=$parser->buildtree;
  }

=head1 DESCRIPTION

LCP::Agent is a class to configure a basic user agent with a set of default options for connecting to a WBEM server. 

=head2 EXPORT

This is an OO Class and as such exports nothing.

=head1 Methods

=item new

=over 4

$agent=LCP::Agent->new('hostname',%{ 'protocol' =>'https', 'port' => 5989, 'Method'=>'M-POST', username=>'someuser', 'password'=>'somepassword', 'Timeout'=>180, 'useragent' => $optionalUserAgent  });

This class only has one method however its important to set the default information for several of the other classes.
There is one required paramiter the hostname or IP address of the WBEM server.
there are 5 optional peramiters defined in a hash that are as follows

1) protocol
Protocol is defined as http or https the default if not specified is https

2) port
The port number the wbem server is listening on. the default if not specified it 5989 for https and 5988 for http.

3) Method
The post method used may be POST, M-POST, or AUTO. if it is not specified the default is AUTO.
POST is the standard http post uesd by web servers and most API's that utilize http and https
M-POST or Method POST is the DMTF prefered method for Common Information Model it utilizes different headers than the standard POST method however it is not supported by all WBEM servers yet and can be buggy in some others.
AUTO attempts to utilizes M-POST first then fails back to POST if the WBEM server reports it is not supported or if ther is a null responce.

Unfortunatly the fail back for AUTO has not been implemented yet; however it will be in the future so users are encuraged to use it in the mean time for future API compatibliity.
The safest choice is POST. Currently not every WBEM server supports M-POST and even some of the ones that do ocasionally malfunction and as a result cause the AIP to hang for a few seconds befor returning an error or more often a null responce.

4) username
The username to use for authenticarion to the wbem server

5) password
The password to use for authenticarion to the wbem server

6) Timeout
How long to wait in seconds for a query to return results befor timing out.

=back

=head1 Advanced Tuning Notes

LCP::Agent uses LWP::UserAgent for a large part of its non CIM specific functionality. The LWP::UserAgent instance can be accessed via the Agent hashref key of the accessor created by the new method.
Advanced developers who are familiar with LWP may utilize this to further tune their settings however this is not advisable for most, and eventually may go away as this module evolves.

If you wish to pass in a mock user agent for testing or for other reasons, the options key to use is 'useragent'.

=head1 SEE ALSO

LCP::Session
LCP::Query
LCP::Post
LCP::SimpleParser
LWP::UserAgent

=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
