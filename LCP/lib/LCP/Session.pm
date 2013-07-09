package LCP::Session;
use strict;
use warnings;
use Carp;
use LCP::Post;
use Data::Dumper;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

sub new{
    my $class=shift;
    my $agent=shift;
    my $options=shift;
    my $self={};
    
    if(defined $agent){
        $self->{'agent'}=$agent;
    }
    else{
        carp "No agent defined\n";
        return 0;
    }
    # I need to add auto M-POST first then POST logic
    # This detection can be done via a simple query such as listing the supported namespaces and checking the return code on the result
    if (defined $options->{'Method'}){
        if ($options->{'Method'}=~/^(POST|M-POST|AUTO)$/i){
            $self->{'Method'}=$options->{'Method'};
        }
        else{
            carp "\"$options->{'Method'}\" is not a recognized method please use \"POST\", \"M-POST\", or \"AUTO\"\n";
            return 0;
        }
    }
    else{
        $self->{'Method'}=$self->{'agent'}->{'Method'};
    }
    if (defined $options->{'Timeout'} and $options->{'Timeout'}=~/^\d+$/){
	$self->{'Timeout'}=$options->{'Timeout'};
    }
    else{
	$self->{'Timeout'}=$self->{'agent'}->{'Timeout'};
    }
    #interop namespace logic
    if (defined $options->{'Interop'} and $options->{'Interop'}=~/\w+(\/\w+)*/){
	$self->{'Interop'}=$options->{'Interop'};
    }
    elsif(defined $options->{'Interop'}){
	carp "WARNING: \"$options->{'Interop'}\" does not match the patern for CIM namespace\n";
	warn "ERROR: Overriding the Interop namespace specified for this session because it failed the format validation check\n";
	$self->{'Interop'}=$self->{'agent'}->{'Interop'};
    }
    else{
	$self->{'Interop'}=$self->{'agent'}->{'Interop'};
    }
    #setting a random message id number to start with;
    $self->{'messageid'}=int(rand(65535));
    bless ($self, $class);
    return $self;
}

sub listnamespaces($){
    my $self=shift;
    my $results=[];
    my $query=LCP::Query->new();
    $query->EnumerateInstances($self->{'Interop'},'CIM_Namespace');
    my $post=LCP::Post->new($self,$query);
    # print $post->get_raw_xml . "\n"; # debuging line
    my $parser=LCP::SimpleParser->new($post->get_raw_xml);
    my $tree=$parser->buildtree; # debuging line 
    # print Dumper($tree) . "\n"; 
    if (defined $tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'ERROR'}){
        carp "$tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'ERROR'}->{'DESCRIPTION'}\n";
	return;
    }
    else{
	for my $instance (@{$tree->{'CIM'}->{'MESSAGE'}->{'SIMPLERSP'}->{'EnumerateInstances'}->{'IRETURNVALUE'}->{'VALUE.NAMEDINSTANCE'}}){
	    push(@{$results},"$instance->{'INSTANCE'}->{'PROPERTY'}->{'Name'}");
	}
    }
    if(wantarray){
	return @{$results};
    }
    else{
	return $results;
    }
}



1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::Session - Lib CIM (Common Information Model) Perl Session managment class

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

Right Now this module doesnt do much but is required
latter on it will allow per session modification of connection option



=head2 EXPORT

This is an OO Class and as such exports nothing.

=head2 Methods

=item new

$session=LCP::Session->new($agent,%{ 'Method' => 'M-POST', 'Timeout'=> '180'});

$session=LCP::Session->new($agent);

The new method requires one paramiter the accessor to the instance of the LCP::Agent class
One optional paramiter can also be added a hash containing the options to be used for this session only
The options that can be specified in the hash are as follows

1) Method
Sets the post method for the session to POST, M-POST, or AUTO. currently AUTO only attempts M-Post; however the functionality will be expanded in the future so that if the WBEM server doesnt support M-POST it will attempt to execute the query via a POST.

Default Method=>'AUTO'

2) Timeout
Sets how long to wait in seconds for querys posted via the session to return results befor timing out. This option overrides the equivelent option in the Agent instance.
Default Timeout=>180

3) Interop
Sets the interop namespace used for the session for queries to discover the cpabilities of the WBEM server. Some WBEM providers stray from the standard for example most versions of OpenPegasus use 'root/PG_Interop'. This option overrides the equivelent option in the Agent instance.
Default Interop=>'root/interop'

=item listnamespaces

my @namespacearray=$session->listnamespaces

my $namespacearrayref=$session->listnamespaces

The listnamespaces method returns an array or array reference containing a list of all of the namespaces registerd on the WBEM server. This method requiers that the Interop option be set correctly in the Agent instance or the session instanceto work.


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
