# Setting the name of the module
package LCP::Session;
# Enforcing strict this will change eventually
use strict;
# Enforcing Warnings this will change eventually
use warnings;
# loading carp so I can tell users what line umber in the calling script caused an error
use Carp;
# loading the module to post queries to the WBEM server
use LCP::Post;
# this is for debugging only and will go away in the future
use Data::Dumper;
# setting the version number of the module.
our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>
# creating the accessor method called new
sub new{
    # getting the class name
    my $class=shift;
    # setting the user defined agent instance which should be an instance of but is not required to be LCP::Agent
    my $agent=shift;
    # pulling in a hash reference of all the possible user defined options
    my $options=shift;
    # defining a skeleton hast which will later be blessed as the accessor for the instance
    my $self={};
    # checking if the user defined an agent
    if(defined $agent){
	# pulling the agent instance into the self hash as the key named agent
        $self->{'agent'}=$agent;
    }
    # if the user hasn't defined one
    else{
	#notify the user
        carp "No agent defined\n";
	# exit in failure but do not kill the calling script
        return 0;
    }
    # I need to add auto M-POST first then POST logic
    # This detection can be done via a simple query such as listing the supported namespaces and checking the return code on the result
    # checking if the user has specified a method for communicating with the WBEM server
    if (defined $options->{'Method'}){
	# if they have check if its a valid one
        if ($options->{'Method'}=~/^(POST|M-POST|AUTO)$/i){
	    #setting the method to the one the user has specified
            $self->{'Method'}=$options->{'Method'};
        }
	# if the user has specified one but it is invalid
        else{
	    # notify the user with the line number from the calling script
            carp "\"$options->{'Method'}\" is not a recognized method please use \"POST\", \"M-POST\", or \"AUTO\"\n";
	    # exit in failure but don't kill the script.
            return 0;
        }
    }
    # if the user hasn't specified a communications method use the one from the agent instance
    else{
        $self->{'Method'}=$self->{'agent'}->{'Method'};
    }
    # checking if the user specified a timeout and that its a valid integer
    if (defined $options->{'Timeout'} and $options->{'Timeout'}=~/^\d+$/){
	# setting it to the value set by the user
	$self->{'Timeout'}=$options->{'Timeout'};
    }
    # if the user specified a timeout which is invalid
    elsif(defined $options->{'Timeout'}){
	# notifying the user wit the line number in the calling script
	carp "ERROR: \"$options->{'Timeout'}\" is not a valid Timeout setting to to \"$self->{'agent'}->{'Timeout'};\"\n";
	# setting the timeout to the value from the agent
	$self->{'Timeout'}=$self->{'agent'}->{'Timeout'};
    }
    # if the user hasn't specified a timeout
    else{
	# setting the timeout to the value from the agent
	$self->{'Timeout'}=$self->{'agent'}->{'Timeout'};
    }
    #interop namespace logic
    # Check if the user has specified a valid Interop name space specific to this session
    if (defined $options->{'Interop'} and $options->{'Interop'}=~/\w+(\/\w+)*/){
	# Setting it to the one used by this session
	$self->{'Interop'}=$options->{'Interop'};
    }
    # If the user has specified a namespace but the formatting is invalid warn the user and set it to the one the Agent instance is set to use.
    elsif(defined $options->{'Interop'}){
	# notifying the user with the line number of the calling script
	carp "WARNING: \"$options->{'Interop'}\" does not match the pattern for CIM namespace\n";
	# further notifying the user with the line number of the module
	warn "ERROR: Overriding the Interop namespace specified for this session because it failed the format validation check\n";
	# setting the interop name space to the one the agent is set to
	$self->{'Interop'}=$self->{'agent'}->{'Interop'};
    }
    # if the user has not specified an Interop name space sett it to the one the Agent instance is set to use.
    else{
	# setting the interop name space to the one the agent is set to
	$self->{'Interop'}=$self->{'agent'}->{'Interop'};
    }
    #setting a random message id number to start with;
    $self->{'messageid'}=int(rand(65535));
    #blessing the instance with the options
    bless ($self, $class);
    # returning the instance handle to the user
    return $self;
}

sub listnamespaces($){
    # importing the instance of the class
    my $self=shift;
    # creating a place older array reference for the results
    my $results=[];
    # creating a new query handle
    my $query=LCP::Query->new();
    # creating a query to enumerate the names of all the namespaces available on the WBEM server
    $query->EnumerateInstances($self->{'Interop'},'CIM_Namespace');
    # posting the query to the WBEM server
    my $post=LCP::Post->new($self,$query);
    # print $post->get_raw_xml . "\n"; # debugging line
    # parsing the resulting XML
    my $parser=LCP::SimpleParser->new($post->get_raw_xml);
    # turning the parsed XML into a multi-dimentional hash structure which looks like a tree
    my $tree=$parser->buildtree;
    # print Dumper($tree) . "\n"; # debugging line
    # checking for errors in the results
    if (defined $tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'ERROR'}){
	# warning the user of an error with the line number in the calling script
        carp "$tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'ERROR'}->{'DESCRIPTION'}\n";
	# returning a null result indicating failure
	return;
    }
    # if there are no errors process the results
    else{
	# loop through the list of results
	for my $instance (@{$tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'IRETURNVALUE'}->{'VALUE.NAMEDINSTANCE'}}){
	    # add each result to the results array reference
	    push(@{$results},"$instance->{'INSTANCE'}->{'PROPERTY'}->{'Name'}");
	}
    }
    # if the calling script expects an array give it to them in that format
    if(wantarray){
	# returning the results in an array context
	return @{$results};
    }
    # if the user didn't ask for it in an array give it to them in an array reference
    else{
	# returning the results as an array reference
	return $results;
    }
}


# returning success as required by all Perl modules
1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::Session - Lib CIM (Common Information Model) Perl Session management class

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

Right Now this module doesn't do much but is required
latter on it will allow per session modification of connection option



=head2 EXPORT

This is an OO Class and as such exports nothing.

=head2 Methods

=over 1

=item new

    $session=LCP::Session->new($agent,%{ 'Method' => 'M-POST', 'Timeout'=> '180'});

    $session=LCP::Session->new($agent);

The new method requires one parameter the accessor to the instance of the LCP::Agent class
One optional parameter can also be added a hash containing the options to be used for this session only
The options that can be specified in the hash are as follows

=over 2

=item 1 Method

Sets the post method for the session to POST, M-POST, or AUTO. currently AUTO only attempts M-Post; however the functionality will be expanded in the future so that if the WBEM server doesn't support M-POST it will attempt to execute the query via a POST.

Default Method=>'AUTO'

=item 2 Timeout

Sets how long to wait in seconds for query is posted via the session to return results before timing out. This option overrides the equivalent option in the Agent instance.

Default Timeout=>180

=item 3 Interop

Sets the interop namespace used for the session for queries to discover the capabilities of the WBEM server. Some WBEM providers stray from the standard for example most versions of OpenPegasus use 'root/PG_Interop'. This option overrides the equivalent option in the Agent instance.

Default Interop=>'root/interop'

=back

=item listnamespaces

    my @namespacearray=$session->listnamespaces

    my $namespacearrayref=$session->listnamespaces

The listnamespaces method returns an array or array reference containing a list of all of the namespaces registered on the WBEM server.

This method requires that the Interop option be set correctly in the Agent instance or the session instance to work.

=back

=head1 SEE ALSO

LCP::Agent
LCP::Query
LCP::Post
LCP::SimpleParser


=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
