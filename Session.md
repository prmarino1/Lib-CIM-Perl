# NAME

LCP::Session - Lib CIM (Common Information Model) Perl Session management class

# SYNOPSIS

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

# DESCRIPTION

Right Now this module doesn't do much but is required
latter on it will allow per session modification of connection option





## EXPORT

This is an OO Class and as such exports nothing.

## Methods

- new

        $session=LCP::Session->new($agent,%{ 'Method' => 'M-POST', 'Timeout'=> '180'});

        $session=LCP::Session->new($agent);

    The new method requires one parameter the accessor to the instance of the LCP::Agent class
    One optional parameter can also be added a hash containing the options to be used for this session only
    The options that can be specified in the hash are as follows

    - 1 Method

        Sets the post method for the session to POST, M-POST, or AUTO. currently AUTO only attempts M-Post; however the functionality will be expanded in the future so that if the WBEM server doesn't support M-POST it will attempt to execute the query via a POST.

        Default Method=>'AUTO'

    - 2 Timeout

        Sets how long to wait in seconds for query is posted via the session to return results before timing out. This option overrides the equivalent option in the Agent instance.

        Default Timeout=>180

    - 3 Interop

        Sets the interop namespace used for the session for queries to discover the capabilities of the WBEM server. Some WBEM providers stray from the standard for example most versions of OpenPegasus use 'root/PG\_Interop'. This option overrides the equivalent option in the Agent instance.

        Default Interop=>'root/interop'

- listnamespaces

        my @namespacearray=$session->listnamespaces

        my $namespacearrayref=$session->listnamespaces

    The listnamespaces method returns an array or array reference containing a list of all of the namespaces registered on the WBEM server.

    This method requires that the Interop option be set correctly in the Agent instance or the session instance to work.

# SEE ALSO

LCP::Agent
LCP::Query
LCP::Post
LCP::SimpleParser



# AUTHOR

Paul Robert Marino, <code@TheMarino.net>

# COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


