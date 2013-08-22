package LCP::Post;
use strict;
use warnings;
use Carp;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

my $lastErr;
my $suppressWarnings	= 0;

sub getLastWarning {
    return $lastErr;
}

sub suppressWarnings {
    $suppressWarnings = 1;
}

sub _warn {
    my $warning = shift;

    if ($suppressWarnings) {
        $lastErr = $warning;
    } else {
        carp($warning);
    }
}

sub new {
    my $class = shift;
    my $session= shift;
    my $query= shift;
    my $self = {};

    $self->{'Session'}=$session;
    $self->{'query'}=$query;
        unless(@{$query->{'writer'}->{'query'}} > 1) {
        unless(defined $self->{'query'}->{'last_method'} or $session->{'Method'}=~/^(M-POST|AUTO)$/i){
            &_warn("ERROR: No CIM Method defined for POST operation\n");
            return 0;
        }
    }
    if ($session->{'Method'}=~/^(POST|M-POST)$/i){
        $self->{'method'}=$session->{'Method'};
    }
    elsif($session->{'Method'}=~/^AUTO$/){
        $self->{'method'}='M-POST';
        $self->{'fallback_method'}='POST';
    }
    else {
        &_warn("$session->{'Method'} is not a valid query method please choose AUTO, M-POST or POST");
        return 0;
    }
    $self->{'Request'}=0;
    
    if ($self->{'method'}=~/^POST$/i){
        eval{$self->{'Request'}=HTTP::Request->new('POST' => $self->{'Session'}->{'agent'}->{'uri'});};
        
    }
    else{
        eval{$self->{'Request'}=HTTP::Request->new('M-POST' => $self->{'Session'}->{'agent'}->{'uri'});};
    }
    $self->{'Result'}=0;
    bless ($self, $class);
    if ($self->{'method'}=~/^POST$/i){
        $self->set_post_headers();
    }
    elsif($session->{'Method'}=~/^(M-POST|AUTO)$/i){
        $self->set_mpost_headers();
    }
    unless($self->{'Session'}->{'messageid'}){
        &_warn("couldn't find the session messageid\n");
    }
    $self->{'query'}->{'writer'}->set_query_id($self->{'Session'}->{'messageid'});
    $self->{'Request'}->content($self->{'query'}->{'writer'}->extractxml());
    if ($self->{'Session'}->{'agent'}->{'password'} and ($self->{'Session'}->{'agent'}->{'username'})){
		$self->{'Request'}->authorization_basic($self->{'Session'}->{'agent'}->{'username'}, $self->{'Session'}->{'agent'}->{'password'});
    }
    $self->{'Session'}->{'messageid'}++;
    if (defined $self->{'Session'}->{'Timeout'} and $self->{'Session'}->{'Timeout'}=~/^\d+$/){
	$self->{'Session'}->{'agent'}->{'agent'}->timeout($self->{'Session'}->{'Timeout'});
    }
    $self->{'Result'}=$self->{'Session'}->{'agent'}->{'agent'}->request($self->{'Request'});
    unless($self->{'Result'}->is_success){
        &_warn("The Query Failed\n");
    }
    return $self;
}



# post or m-post
#If the M-POST invocation fails with an HTTP status of "501 Not Implemented" or "510 Not Extended," the client should retry the request using the HTTP method "POST" with the appropriate modifications (described in 6.2.2).
#If the M-POST invocation fails with an HTTP status of "405 Method Not Allowed," the client should fail the request.




sub set_post_headers{
    my $self=shift;
    my $cim_method=shift;
    $self->{'Request'}->content_type('application/xml; charset="utf-8"');
    $self->{'Request'}->header('CIMProtocolVersion' => "1.0");
    $self->{'Request'}->header(CIMOperation => "MethodCall");
    if (@{$self->{'query'}->{'writer'}->{'query'}} > 1){
        $self->{'Request'}->header(CIMBatch => '');
    }
    else{
        $self->{'Request'}->header(CIMMethod => $self->{'query'}->{'last_method'});
        my $modified_namespace=$self->{'query'}->{'last_namespace'};
        $modified_namespace=~s/\//%2F/;
        $self->{'Request'}->header(CIMObject => $modified_namespace);
    }
    $self->{'Request'}->header(Host => "$self->{'Session'}->{'agent'}->{'host'}:$self->{'Session'}->{'agent'}->{port}");
    $self->{'Request'}->header(charset=>"utf-8");
    $self->{'Request'}->remove_header('TE');
    #$self->{'Request'}->remove_header('Connection');
    #print"@{[$self->{'request'}->as_string]}\n";
    return 1;
}

sub set_mpost_headers{
    my $self=shift;
    my $random=int(rand(99));
    $self->{'Request'}->content_type('application/xml; charset="utf-8"');
    $self->{'Request'}->header(Host => "$self->{'Session'}->{'agent'}->{'host'}:$self->{'Session'}->{'agent'}->{port}");
    $self->{'Request'}->header('Man' => "http://www.dmtf.org/cim/mapping/http/v1.0;ns=$random");
    my $protocolversionstring="$random". '-CIMProtocolVersion';
    $self->{'Request'}->header("$protocolversionstring" => "1.0");
    my $operationstring="$random". '-CIMOperation';
    $self->{'Request'}->header("$operationstring" => 'MethodCall');
    if ($self->{'multi'}){
        my $batchstring="$random". '-CIMBatch';
        $self->{'Request'}->header("$batchstring" => '');
    }
    else{
        my $methodstring="$random". '-CIMMethod';
        $self->{'Request'}->header("$methodstring" => $self->{'query'}->{'last_method'});
        my $objectstring="$random". '-CIMObject';
        $self->{'Request'}->header("$objectstring" => $self->{'query'}->{'last_namespace'});
    }
}

sub get_raw_xml{
    my $self=shift;
    return $self->{'Result'}->decoded_content
}

sub success($){
    my $self=shift;
    if ($self->{'Result'}->is_success){
	return 1
    }
    else{
	return 0;
    }
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP - Lib CIM (Common Information Model) Perl Post

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

LCP::Post executs a POST or M-POST of a qurey generated by LCP::Query Class against a WBEM server with the options specified in an instance of the LCP::Session class.


=head2 EXPORT

This is an OO Class and as such exports nothing

=head1 Methods

=item new

=over 4

$post=LCP::Post->new($session,$query);


The new method creates and executes a POST or M-POST of a query against the WBEM server. It requiers 2 paramiters and returns a accessor uppon successful execution of the query.
The first requierd paramiter is the accessor for a instance of LCP::Session
The second required paramiter is the accessor to the instance of LCP::Query with the query you want to execute.

You may reuse the same query to repeatedly agianst multiple instances of LCP::Post, and each time it will execute the query identicaly except the message id number will increment each time.

Uppon successful posting of the query and reception of a responce this method returns an accessor to the results, but its important for the user to know that this class does not validate the content of the responce at this time only if a responce was recived.

=back

=item get_raw_xml

=over 4

$xml=$post->get_raw_xml

get_raw_xml returns the unparsed XML responce from the WBEM server

=back

=item success

=over 4

$post->success

returns a boolian result of a query
Note: at this time this method only returns true it the WBEM server respods with a 200 or 207 code it does not parse the XML for error messages embeded in the responce.

=back

=item suppressWarnings

=over 4

Call suppressWarnings() you would prefer to keep the constuctor from printing to STDOUT if there are errors.

You can get any warings by calling getLastWarning() if suppressWarnings() has been called.

=back

=back

=head1 Advanced Tuning Notes

    LCP::Post utilizes HTTP::Request to execute the POST or M-POST operation. The accessor handle for the instance of HTTP::Request may be used for the time via the 

=head1 SEE ALSO

LWP - Lib WWW Perl

HTTP::Request

DMTF DSP0200 

DMTF DSP0201

DMTF DSP0004



=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.net<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

