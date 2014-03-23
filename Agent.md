# NAME

LCP::Agent - Lib CIM (Common Information Model) Perl

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

LCP::Agent is a class to configure a basic user agent with a set of default options for connecting to a WBEM server. 

## EXPORT

This is an OO Class and as such exports nothing.

# Methods

- new

        $agent=LCP::Agent->new('hostname',%{ 'protocol' =>'https', 'port' => 5989, 'Method'=>'M-POST', username=>'someuser', 'password'=>'somepassword', 'Timeout'=>180, 'useragent' => $optionalUserAgent  });

    This class only has one method however its important to set the default information for several of the other classes.
    There is one required parameter the hostname or IP address of the WBEM server.
    there are 5 optional perimeters defined in a hash that are as follows

    - 1 protocol

        Protocol is defined as http or https the default if not specified is https

    - 2 port

        The port number the WBEM server is listening on. the default if not specified it 5989 for https and 5988 for http.

    - 3 Method

        The post method used may be POST, M-POST, or AUTO. if it is not specified the default is AUTO.
        POST is the standard http post used by web servers and most API's that utilize http and https
        M-POST or Method POST is the DMTF preferred method for Common Information Model it utilizes different headers than the standard POST method however it is not supported by all WBEM servers yet and can be buggy in some others.
        AUTO attempts to utilizes M-POST first then fails back to POST if the WBEM server reports it is not supported or if there is a null response.

        Unfortunately the fail back for AUTO has not been implemented yet; however it will be in the future so users are encouraged to use it in the mean time for future API compatibility.
        The safest choice is POST. Currently not every WBEM server supports M-POST and even some of the ones that do occasionally malfunction and as a result cause the AIP to hang for a few seconds before returning an error or more often a null response.

    - 4 username

        The username to use for authentication to the WBEM server

    - 5 password

        The password to use for authentication to the WBEM server

    - 6 Timeout

        How long to wait in seconds for a query to return results before timing out.

# Advanced Tuning Notes

LCP::Agent uses LWP::UserAgent for a large part of its non CIM specific functionality. The LWP::UserAgent instance can be accessed via the Agent hashref key of the accessor created by the new method.
Advanced developers who are familiar with LWP may utilize this to further tune their settings however this is not advisable for most, and eventually may go away as this module evolves.

If you wish to pass in a mock user agent for testing or for other reasons, the options key to use is 'useragent'.

# SEE ALSO

LCP::Session
LCP::Query
LCP::Post
LCP::SimpleParser
LWP::UserAgent

# AUTHOR

Paul Robert Marino, <code@TheMarino.net>

# COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


