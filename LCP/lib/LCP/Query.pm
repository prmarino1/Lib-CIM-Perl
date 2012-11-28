package LCP::Query;
use strict;
use warnings;
use Carp;
use LCP::XMLWriter;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


sub new {
    my $class = shift;
    my $xmlwriter=LCP::XMLWriter->new();
    my $self = bless {
                        writer => $xmlwriter
                      }, $class;
    return $self;
}

# Starting Intrinsic CIM Methods
sub GetClass($$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='GetClass';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>0,
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>1,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $rawquery={
        namespace=>$namespace,
        classname=>$cimclass,
        options=>$options,
    };
    if (defined $propertylist) {
        $rawquery->{'propertylist'}=$propertylist
    };
    my $method=$self->{'writer'}->mkmethodcall('GetClass');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($rawquery->{'namespace'});
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($rawquery->{'options'})){
        $option->paste('last_child' => $method);
    }
    my $classname=$self->{'writer'}->mkclassname($rawquery->{'classname'});
    $classname->paste('last_child' => $method);
    if (defined $rawquery->{'propertylist'}){
        my $propertylist=$self->{'writer'}->mkpropertylist($rawquery->{'propertylist'});
        $propertylist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
    
}


sub GetInstance($$$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $instanceid=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='GetInstance';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>0,
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>1,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('GetInstance');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    my $iparam=$self->{'writer'}->mkmethodcall('InstanceName');
    $iparam->paste('last_child' => $method);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass);
    $instancename->paste('last_child' => $iparam);
    for my $option ($self->{'writer'}->mkkeybinding($instanceid)){
        $option->paste('last_child' => $instancename);
    }
    my $keybindings=$self->mkkeybindingxml($instanceid);
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);

}



# Untested
sub DeleteClass($$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    $self->{'last_method'}='DeleteClass';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('DeleteClass');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub DeleteInstance{
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $properties=shift;
    $self->{'last_method'}='DeleteInstance';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('DeleteInstance');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste('last_child' => $method);
    my $instance=$self->{'writer'}->mkdelinstance($cimclass,$properties);
    $instance->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}


# need a better understanding before I'll atempt it
sub CreateClass{
    carp "CreateClass not implemented yet\n";
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $cimsuperclass=shift;
    $self->{'last_method'}='CreateClass';
    $self->{'last_namespace'}=$namespace;
    return 0;
}

sub CreateInstance($$$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $properties=shift;
    $self->{'last_method'}='CreateInstance';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('CreateInstance');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste('last_child' => $method);
    my $newinstance=$self->{'writer'}->mknewinstance($cimclass,$properties);
    $newinstance->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

#not implemented yet
sub ModifyClass {
	carp "ModifyClass not implemented yet\n";
	return 0;
}

#not implemented yet
sub ModifyInstance{
	carp "ModifyInstance not implemented yet\n";
	return 0;
}

sub EnumerateClasses($$;$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    $self->{'last_method'}='EnumerateClasses';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>1,
        'DeepInheritance'=>0,
        'IncludeQualifiers'=>1,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('EnumerateClasses');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }

    if ($cimclass and $cimclass !~ /^NULL$/i){
        my $classname=$self->{'writer'}->mkclassname($cimclass);
        $classname->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
    
}

# DeepInheritance is good here even though it violates spec
sub EnumerateClassNames($$;$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    $self->{'last_method'}='EnumerateClassNames';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'DeepInheritance'=>1,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('EnumerateClassNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    if (defined $cimclass and $cimclass !~ /^NULL$/i){
        my $classname=$self->{'writer'}->mkclassname($cimclass);
        $classname->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub EnumerateInstances($$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='EnumerateInstances';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>0,
        'DeepInheritance'=>1,
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>1,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('EnumerateInstances');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    #my $classname=$self->{'writer'}->mkclassname($cimclass);
    #$classname->paste('last_child' => $method);
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub EnumerateInstanceNames($$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    $self->{'last_method'}='EnumerateInstanceNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('EnumerateInstanceNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub ExecQuery{
    carp "ExecQuery not implemented yet\n";
    return 0;
}
   
sub Associators($$$;\%$$$$\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $associatedclass=shift;
    my $resultclass=shift;
    my $role=shift;
    my $resultrole=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='Associators';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
	'IncludeQualifiers'=>0,
	'IncludeClassOrigin'=>1,
    };
    for my $key (keys %{$defaultoptions}){
	unless (defined $options->{$key}){
	    $options->{$key}=$defaultoptions->{$key};
	}
    }
    my $method=$self->{'writer'}->mkmethodcall('Associators');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $associatedclass and $associatedclass !~ /^NULL$/i){
        my $assocclass=$self->{'writer'}->mkassocclass($associatedclass);
        $assocclass->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($associatedclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    if(defined $resultrole and $resultrole !~ /^NULL$/i){
        my $resrole=$self->{'writer'}->mkresultrole($role);
        $resrole->paste('last_child' => $method);
    }
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub AssociatorNames($$$;\%$$$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $associatedclass=shift;
    my $resultclass=shift;
    my $role=shift;
    my $resultrole=shift;
    $self->{'last_method'}='AssociatorNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('AssociatorNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $associatedclass and $associatedclass !~ /^NULL$/i){
        my $assocclass=$self->{'writer'}->mkassocclass($associatedclass);
        $assocclass->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($resultclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    if(defined $resultrole and $resultrole !~ /^NULL$/i){
       my $resrole=$self->{'writer'}->mkresultrole($role);
        $resrole->paste('last_child' => $method); 
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}


sub References($$$;\%$$\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $resultclass=shift;
    my $role=shift;
    my $options=shift;
    my $propertylist=shift;
    my $defaultoptions={
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    $self->{'last_method'}='References';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('References');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($resultclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub ReferenceNames($$$\%;$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $resultclass=shift;
    my $role=shift;
        $self->{'last_method'}='ReferenceNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('ReferenceNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
        if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($resultclass);
        $resclass->paste('last_child' => $method);
    }
	if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub GetProperty($$$\%$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $filter=shift;
    my $property=shift;
    $self->{'last_method'}='GetProperty';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('GetProperty');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $keybindings=$self->{'writer'}->mkkeybinding($filter);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass,$keybindings);
    $instancename->paste( 'first_child' => $method);
    if($property){
        my $propname=$self->{'writer'}->mkpropertyname($property);
        $propname->paste( 'first_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}


sub SetProperty($$$\%$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $instance=shift;
    my $properety=shift;
    my $value=shift;
    $self->{'last_method'}='SetProperty';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('SetProperty');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $propname=$self->{'writer'}->mkpropertyname($properety);
    $propname->paste('last_child' => $method);
    my $propvalue=$self->{'writer'}->mkpropertyvalue($value);
    $propvalue->paste('last_child' => $method);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass,$self->{'writer'}->mkkeybinding($instance));
    $instancename->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

#not implemented yet
sub GetQualifier{
	carp "GetQualifier not implemented yet\n";
    return 0;
}

#not implemented yet
sub SetQualifier{
	carp "SetQualifier not implemented yet\n";
    return 0;
}

#not implemented yet
sub DeleteQualifier{
	carp "DeleteQualifier not implemented yet\n";
    return 0;
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::Query - Lib CIM (Common Information Model) Perl Query Costructor

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
    # returning a multi dimentional hash reference of the results
    my $tree=$parser->buildtree;
  }
  

=head1 DESCRIPTION

    Constructs a CIM query based on the Intrinsic CIM methods as defined in DSP0200

=head2 EXPORT

This is an OO Class and as such exports nothing

=head1 Basic Methods

=item new

=over 4

$query=LCP::Query->new();
    
Creates an accessor for a new query.

=back

=item Using The Intrinsic Methods

=over 4

Each intrisic method is a Perl style version of a method spesified in DTMF DSP0200. All WBEM servers tested with this class thus far support simple queries which means you can use one intrinsic method per instance of the class. If your WBEM server supports it multipart queries may also be generated by simply calling multiple intrinsic methods against a single instance of the class. 

=head1 Intrinsic Methods

=item GetClass

=over 4

$query->GetClass('name/space','ClassName',{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0},['property1','property2']);

$query->GetClass('name/space','ClassName',{ 'LocalOnly'=>0, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0});

$query->GetClass('name/space','ClassName',{},['property1','property2']);

$query->GetClass('name/space','ClassName');

See DSP0200 Version 1.3.1 section 5.3.2.1 for details

=back

=item GetInstance

=over 4

$query->GetInstance ('name/space','ClassName','InstanceID',{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0},['property1','property2']);

$query->GetInstance ('name/space','ClassName','InstanceID',{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0});

$query->GetInstance ('name/space','ClassName','InstanceID',{},['property1','property2']);

$query->GetInstance ('name/space','ClassName','InstanceID');

See DSP0200 Version 1.3.1 section 5.3.2.2 for details

=back

=item DeleteClass

=over 4

$query->DeleteClass ('name/space','ClassName')

WARNING: this has not been tested yet

See DSP0200 Version 1.3.1 section 5.3.2.3 for details

=back

=item DeleteInstance

=over 4

$query->CreateInstance ('name/space','ClassName',{property1=val1,property2=val2});

See DSP0200 Version 1.3.1 section 5.3.2.4 for details

=back

=item CreateClass

=over 4

Not implemented yet

=back

=item CreateInstance

=over 4

$query->CreateInstance ('name/space','ClassName',{property1=val1,property2=val2});

See DSP0200 Version 1.3.1 section 5.3.2.6 for details

=back

=item ModifyClass

=over 4

Not implemented yet

=back

=item ModifyInstance

=over 4

Not implemented yet

=back

=item EnumerateClasses

=over 4

$query->EnumerateClasses('name/space','ClassName', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});

$query->EnumerateClasses('name/space','ClassName');

$query->EnumerateClasses('name/space','NULL', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});

$query->EnumerateClasses('name/space',, { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});

$query->EnumerateClasses('name/space');

See DSP0200 Version 1.3.1 section 5.3.2.9 for details

=back

=item EnumerateClassNames

=over 4 

$query->EnumerateClassNames ('name/space','ClassName', { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space',, { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space','NULL', { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space','ClassName');

$query->EnumerateClassNames ('name/space');

See DSP0200 Version 1.3.1 section 5.3.2.10 for details

=back

=item EnumerateInstances

=over 4

$query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 }, ['property1','property2']);

$query->EnumerateInstances('name/space','ClassName',{ }, ['property1','property2']);

$query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 });

$query->EnumerateInstances('name/space','ClassName');

See DSP0200 Version 1.3.1 section 5.3.2.11 for details

=back

=item EnumerateInstanceNames

=over 4

EnumerateInstanceNames ('name/space','ClassName');

See DSP0200 Version 1.3.1 section 5.3.2.12 for details

=back

=item ExecQuery

=over 4

Not implemented yet

=back

=item Associators

=over 4

$query->Associators ('name/space','ClassName','ObjectName','AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName','ObjectName','AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});

$query->Associators ('name/space','ClassName','ObjectName','AssocClass','ResultClass','Role','ResultRole',{ }, ['property1','property2'] );

$query->Associators ('name/space','ClassName','ObjectName','AssocClass','ResultClass','Role','ResultRole');

$query->Associators ('name/space','ClassName','ObjectName','AssocClass',);

$query->Associators ('name/space','ClassName','ObjectName','NULL','NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName','ObjectName','','','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName','ObjectName','AssocClass','ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);

$query->Associators ('name/space','ClassName','ObjectName','NULL','ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

See DSP0200 Version 1.3.1 section 5.3.2.14 for details

=back

=item AssociatorNames

=over 4

$query->AssociatorNames('name/space','ClassName', {} , 'AssocClass', 'ResultClass', 'Role','ResultRole');

$query->AssociatorNames('name/space','ClassName', 'ObjectName', 'NULL', 'NULL', 'NULL','NULL');

$query->AssociatorNames('name/space','ClassName', 'ObjectName', 'AssocClass', 'NULL', 'Role','ResultRole');

$query->AssociatorNames('name/space','ClassName', 'ObjectName', 'NULL', 'ResultClass', 'NULL','ResultRole');

$query->AssociatorNames('name/space','ClassName', 'ObjectName', '', 'ResultClass', '','ResultRole');

$query->AssociatorNames('name/space','ClassName', 'ObjectName', 'NULL', 'ResultClass');

$query->AssociatorNames('name/space','ClassName', 'ObjectName');

See DSP0200 Version 1.3.1 section 5.3.2.15 for details

=back

=item References

=over 4

$query->References ('name/space','ClassName','{key1=val1,key2=val2}','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName','ObjectName','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});

$query->References ('name/space','ClassName','ObjectName','ResultClass','Role','ResultRole',{ }, ['property1','property2'] );

$query->References ('name/space','ClassName','ObjectName','ResultClass','Role','ResultRole');

$query->References ('name/space','ClassName','ObjectName');

$query->References ('name/space','ClassName','ObjectName','NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName','ObjectName','','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName','ObjectName','ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);

$query->References ('name/space','ClassName','ObjectName','ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

=back

=item ReferenceNames

=over 4

Not implemented yet

=back

=item GetProperty

=over 4

$query->GetProperty ( 'name/space','ClassName', {key1=val1,key2=val2}, 'PropertyName');

See DSP0200 Version 1.3.1 section 5.3.2.18 for details

=back

=item SetProperty

=over 4

$query->SetProperty('name/space','ClassName',{key1=val1,key2=val2},'PropertyName','VALUE')

See DSP0200 Version 1.3.1 section 5.3.2.19 for details

=back

=item GetQualifier

=over 4

Not implemented yet

=back

=item SetQualifier

=over 4

Not implemented yet

=back

=item DeleteQualifier

=over 4

Not implemented yet

=back


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
