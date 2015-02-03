package LCP::Post;
use strict;
use warnings;
use Carp;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# this was user contributed and will change because it doesn't comply to the overall coding standards
# the replacement will probably be a notification super class

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

# end of the contributed code planed for future change.


sub new {
    # getting the class name
    my $class = shift;
    # getting the session handle
    my $session= shift;
    # getting the query handle
    my $query= shift;
    # creating an empty hash reference which will be blessed latter into the instance of the class
    my $self = {};
    # adding the session handle to the instance
    $self->{'Session'}=$session;
    # adding the query handle to the instance 
    $self->{'query'}=$query;
    # checking if the XML for query has been constructed yet which would indicate that the query has been used before and we can skip some checks
    unless(@{$query->{'writer'}->{'query'}} > 1) {
	# ensuring that the post method is defined
        unless(defined $self->{'query'}->{'last_method'} or $session->{'Method'}=~/^(M-POST|AUTO)$/i){
	    # notifying the user
            &_warn("ERROR: No CIM Method defined for POST operation\n");
	    # exiting in failure
            return 0;
        }
    }
    # if the method is set to POST or M-POST take it as is
    if ($session->{'Method'}=~/^(POST|M-POST)$/i){
	# setting the method to use for the query
        $self->{'method'}=$session->{'Method'};
    }
    # otherwise if the method been set to AUTO default to M-POST and define POST as a fail back method unfortunately this doesn't work yet but is planned for the future.
    elsif($session->{'Method'}=~/^AUTO$/){
	# setting the method to M-POST
        $self->{'method'}='M-POST';
	# setting the fall back method to POST
        $self->{'fallback_method'}='POST';
    }
    # otherwise warning the user and exit
    else {
	# notifying the user
        &_warn("$session->{'Method'} is not a valid query method please choose AUTO, M-POST or POST");
	# exiting in failure
        return 0;
    }
    # defining an empty variable which will be used latter in a string context to contain the XML for the request.
    $self->{'Request'}=0;
    
    # this next section is redundant and will go away soon
    # creating the HTTP request handle if the method is POST
    if ($self->{'method'}=~/^POST$/i){
	# creating the HTTP request handle in an eval because the module forces the program to die instead of returning an error which is not always desirable
        eval{$self->{'Request'}=HTTP::Request->new('POST' => $self->{'Session'}->{'agent'}->{'uri'});};
        
    }
    # otherwise creating the HTTP request handle using the method M-POST
    else{
	# creating the HTTP request handle in an eval because the module forces the program to die instead of returning an error which is not always desirable
        eval{$self->{'Request'}=HTTP::Request->new('M-POST' => $self->{'Session'}->{'agent'}->{'uri'});};
    }
    # end of redundant section
    
    # creating an empty variable which will be used latter to contain the response from the WBEM server.
    $self->{'Result'}=0;
    
    # blessing $self as the instance handle for the class
    bless ($self, $class);
    # if the method is POST set the appropriate HTTP headers 
    if ($self->{'method'}=~/^POST$/i){
	# setting the HTTP headers
        $self->set_post_headers();
    }
    # other wise set HTTP the headers for an M-POST request
    elsif($session->{'Method'}=~/^(M-POST|AUTO)$/i){
	# setting the HTTP headers
        $self->set_mpost_headers();
    }
    # checking if message id is set in the session 
    unless($self->{'Session'}->{'messageid'}){
	# if its not notify the user because there is something strange going on but its not a critical error
        &_warn("couldn't find the session messageid\n");
    }
    # setting the message id in the XML writer handle
    $self->{'query'}->{'writer'}->set_query_id($self->{'Session'}->{'messageid'});
    # generating the XML
    $self->{'Request'}->content($self->{'query'}->{'writer'}->extractxml());
    # checking if a user name and password were defined by the user
    if ($self->{'Session'}->{'agent'}->{'password'} and ($self->{'Session'}->{'agent'}->{'username'})){
	# setting the authentication data on the HTTP request handle using basic because of mixed possible support for digest-MD5 in the upstream module depending on the version
	$self->{'Request'}->authorization_basic($self->{'Session'}->{'agent'}->{'username'}, $self->{'Session'}->{'agent'}->{'password'});
    }
    # incrementing the message ID so the next query get a unique ID
    # not all CIM libraries enforce this but its intended to be message sequence number which can be very useful in tracking down issues
    $self->{'Session'}->{'messageid'}++;
    # if the user has defined a valid timeout in seconds set it on the HTTP request handle
    if (defined $self->{'Session'}->{'Timeout'} and $self->{'Session'}->{'Timeout'}=~/^\d+$/){
	# setting the timeout on the HTTP request handle
	$self->{'Session'}->{'agent'}->{'agent'}->timeout($self->{'Session'}->{'Timeout'});
    }
    # executing the request
    $self->{'Result'}=$self->{'Session'}->{'agent'}->{'agent'}->request($self->{'Request'});
    # checking if a response was received from the WBEM server
    # this method returns success even if the HTTP request returns an error code with XML
    unless($self->{'Result'}->is_success){
	# notifying the user if the request failed
        &_warn("The Query Failed\n");
    }
    # returning blessed instance of the class
    return $self;
}



# post or m-post
# there is a fallback to post logic which needs to be added at a later time but we need to add more robust error handling.
#If the M-POST invocation fails with an HTTP status of "501 Not Implemented" or "510 Not Extended," the client should retry the request using the HTTP method "POST" with the appropriate modifications (described in 6.2.2).
#If the M-POST invocation fails with an HTTP status of "405 Method Not Allowed," the client should fail the request.


# this method creates the headers for the POST operations but not M-POST operations
sub set_post_headers{
    # getting the instance handle for the class
    my $self=shift;
    # this is a legacy variable which is no longer needed
    my $cim_method=shift;
    # setting the character set to utf8 in the content type header
    $self->{'Request'}->content_type('application/xml; charset="utf-8"');
    # setting the CIM protocol version to 1.0 in the headers
    # this will change latter once we can support multiple versions of the CIM protocol
    $self->{'Request'}->header('CIMProtocolVersion' => "1.0");
    # setting the CIMOperation header to MethodCall this seems ridiculous based on the current verso on the standard but it is required.
    $self->{'Request'}->header(CIMOperation => "MethodCall");
    # checking of there is more than one operation in the query
    if (@{$self->{'query'}->{'writer'}->{'query'}} > 1){
	# if there are multiple queries.
	# setting the CIMBatch header to a null value indicating that its a batch of queries being posted at once.
        $self->{'Request'}->header(CIMBatch => '');
    }
    else{
	# if its not a batch operation
	# setting the CIMMethod to the operation being used in the query
        $self->{'Request'}->header(CIMMethod => $self->{'query'}->{'last_method'});
	# getting the name space being queried
        my $modified_namespace=$self->{'query'}->{'last_namespace'};
	# encoding the / to %2F this is needed by some WBEM servers but not all
        $modified_namespace=~s/\//%2F/;
	# setting the CIMObject field to the encoded namespace
        $self->{'Request'}->header(CIMObject => $modified_namespace);
    }
    # setting the HOST header to the URI of the WBEM server
    $self->{'Request'}->header(Host => "$self->{'Session'}->{'agent'}->{'host'}:$self->{'Session'}->{'agent'}->{port}");
    # this may be redundant I am not sure
    $self->{'Request'}->header(charset=>"utf-8");
    # removing one of the default headers set by LWP which we don't need
    $self->{'Request'}->remove_header('TE');
    #$self->{'Request'}->remove_header('Connection');
    #print"@{[$self->{'request'}->as_string]}\n";
    
    # returning success
    return 1;
}



# this method sets the headers when the M-POST method is used
sub set_mpost_headers{
    # getting the instance handle for the class
    my $self=shift;
    # setting a random integer
    my $random=int(rand(99));
    # setting the character set to utf8 in the content type header
    $self->{'Request'}->content_type('application/xml; charset="utf-8"');
    # setting the HOST header to the URI of the WBEM server
    $self->{'Request'}->header(Host => "$self->{'Session'}->{'agent'}->{'host'}:$self->{'Session'}->{'agent'}->{port}");
    # this is a long story lol.
    # essentially this sets the path to the DMTF site where the standard can be looked up
    # the random number is used to tie the headers together
    # I'm a little unclear as to why this is needed but it is
    $self->{'Request'}->header('Man' => "http://www.dmtf.org/cim/mapping/http/v1.0;ns=$random");
    # creating an name for a header CIMProtocolVersion suffixed by the random number then a -
    my $protocolversionstring="$random". '-CIMProtocolVersion';
    # setting the CIMProtocolVersion header to 1.0 this will change in the future when we have support for multiple versions.
    $self->{'Request'}->header("$protocolversionstring" => "1.0");
    # creating an name for a header CIMOperation suffixed by the random number then a - 
    my $operationstring="$random". '-CIMOperation';
    # setting the CIMOperation header to MethodCall this seems ridiculous based on the current verso on the standard but it is required.
    $self->{'Request'}->header("$operationstring" => 'MethodCall');
    # check if the query contains multiple CIM methods
    if ($self->{'multi'}){
	# setting the CIMBatch header
        my $batchstring="$random". '-CIMBatch';
        $self->{'Request'}->header("$batchstring" => '');
    }
    else{
	#setting the CIMMethod header
        my $methodstring="$random". '-CIMMethod';
        $self->{'Request'}->header("$methodstring" => $self->{'query'}->{'last_method'});
	# setting the CIMObject to the CIM namespace
        my $objectstring="$random". '-CIMObject';
        $self->{'Request'}->header("$objectstring" => $self->{'query'}->{'last_namespace'});
    }
}

# this probably isn't needed but it makes it easier for programers to use
# essentially this method is it calls the LWP decoded_content method and returns the XML received from the WBEM server 
sub get_raw_xml{
    # getting the instance handle for the class    
    my $self=shift;
    # calling LWP's decoded_content method and returning the result
    return $self->{'Result'}->decoded_content
}

# this probably isn't needed but it makes it easier for programers to use
# essentially this just calls the LWP is_success method and returns 1 if the post was successful and 0 if it wasn't.
# note this does not give you the results of the query just if it was able to connect and got a result code.
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

#__END__
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
    # returning a multi dimensional hash of the results
    my $tree=$parser->buildtree;
  }

=head1 DESCRIPTION

LCP::Post executes a POST or M-POST of a query generated by LCP::Query Class against a WBEM server with the options specified in an instance of the LCP::Session class.


=head2 EXPORT

This is an OO Class and as such exports nothing

=head1 Methods

=item new

=over 4

$post=LCP::Post->new($session,$query);


The new method creates and executes a POST or M-POST of a query against the WBEM server. It requires 2 parameters and returns a accessor upon successful execution of the query.
The first required parameter is the accessor for a instance of LCP::Session
The second required parameter is the accessor to the instance of LCP::Query with the query you want to execute.

You may reuse the same query to repeatedly against multiple instances of LCP::Post, and each time it will execute the query identically except the message id number will increment each time.

Upon successful posting of the query and reception of a response this method returns an accessor to the results, but its important for the user to know that this class does not validate the content of the response at this time only if a response was received.

=back

=item get_raw_xml

=over 4

$xml=$post->get_raw_xml

get_raw_xml returns the unparsed XML response from the WBEM server

=back

=item success

=over 4

$post->success

returns a Boolean result of a query
Note: at this time this method only returns true it the WBEM server responds with a 200 or 207 code it does not parse the XML for error messages embedded in the response.

=back

=item suppressWarnings

=over 4

Call suppressWarnings() you would prefer to keep the constructor from printing to STDOUT if there are errors.

You can get any warning by calling getLastWarning() if suppressWarnings() has been called.

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

