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
        'LocalOnly'=>1,
        'IncludeQualifiers'=>1,
        'IncludeClassOrigin'=>0,
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
    my $optionsconstraints={
	'LocalOnly'=>'boolean',
	'IncludeQualifiers'=>'boolean',
        'IncludeClassOrigin'=>'boolean',
    };
    my $resultoptions=$self->{'writer'}->comparedefaults($defaultoptions,$options,$optionsconstraints);
    my $method=$self->{'writer'}->mkmethodcall('GetInstance',$namespace);
    for my $option ($self->{'writer'}->mkbool($resultoptions)){
        $option->paste('last_child' => $method);
    }
    my $iparam=$self->{'writer'}->mkmethodcall('InstanceName');
    $iparam->paste('last_child' => $method);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass);
    $instancename->paste('last_child' => $iparam);
    for my $option ($self->{'writer'}->mkkeybinding($instanceid)){
        $option->paste('last_child' => $instancename);
    }
    #my $keybindings=$self->mkkeybindingxml($instanceid);
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

=head1 FIELD FORMATS

=head2 FIELD VALUE Constraints

=item CIMType constraint

=over 4

The CIMType constraint is a common constraint used in two contexts. The first is as a value of a field defining a constraint on a second field. The second is defining a restricting the contents of a field.

The possible typs of constraints supported by the CIMType constraints are boolean, string, char16, uint8, sint8, uint16, sint16, uint32, sint32, uint64, sint64, datetime, real32, or real64

=back

=head2 Specialy Formated Fields 

=head3 Keybinding

=over 4

Keyindings are a complex key value paring construct that includes a name, value or value reference, valuetype description, and type description which is an extended version of the valuetype.

The NAME field is a requiered field containing a string that defines the name of the key

Next you must define either the VALUE.REFERENCE or VALUE

Creation of a VALUE.REFERENCE is not supported by this API yet but will be in the future.

The VALUE field is a field containing a string, boolean, or numeric data. If you define the VALUE field you can define the VALUETYPE, and TYPE fields.

The VALUETYPE field describes the type of data contained in the VALUE field. the VALUETYPE may be defined as string, boolean, or numeric. Unless the field is specified it will default to string.

Finally the TYPE field is an extended description of the content of the VALUE field which may be defined as any one of the types defined in the "CIMType constraint". the default is undefind but implied by the VALUETYPE field.
WARNING: Not all implementions of CIM-XML and WBEM handle the TYPE filed in a key binding properly and some even tools consider it to be invalid, so defining it may break things. At this time I advise users not to set this field unless you are trying to QA test other implementations CIM-XML or your WBEM servers.

LCP supports defining a key binding in 4 different formats

=back

=item Simple hash

=over 4

%hash=(
  'key1'=>'value1',
  'key2'=>'35',
  'key3'=>$value_ref_object
);

In the simple hash format all VALUETYPE fields are set to string unless the value is a VALUE.REFERENCE object 

=back

=item Complex hash

=over 4

%hash=(
    'key1'=>{
	'VALUE'=>'value1',
	'VALUETYPE'=>'string'
    },
    'key2'=>{
	'VALUE'=>'35',
	'VALUETYPE'=>'numeric',
	'TYPE'=>'uint8',
    }
    'key3'=>{
	'VALUE.REFERENCE'=>$value_ref_object
    }
);

The name of the top level key is the name of the keybinding
The supported fields for the child hash are

1) VALUE
    The VALUE field is requiered unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding
2) VALUE.REFERENCE
    The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It shoud contain and referent to a VALUE.REFERENCE object.
    Caviot: LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future
3) VALUETYPE
    The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.
4) TYPE
    The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more percise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE feild
    WARNING: Implementation of the TYPE filed in a keybinding is inconsistant and some CIM implementations break when you define it. As such I advise users not to define it unless absolutly nessisary or you want to QA test other CIM implementations.
    
Each Key must contain a hash with either a VALUE or a VALUE.REFERENCE defined
If both a VALUE and a VALUE.REFERENCE are defined the VALUE.REFERENCE will be ignored
If the default for VALUETYPE is "string" if a VALUE is specified and the VALUETYPE has not been defined


=back

=item Mixed Hash

=over 4
You may use both the simple and complex format in a single hash mixed hash if you find it more convinient each key will function in accordent to the rules of the simple or complex format as apropriate

%hash=(
    'key1'=>'value1',
    'key2'=>{
	'VALUE'=>'35',
	'VALUETYPE'=>'numeric',
	'TYPE'=>'uint8'
    }
    'key3'=>$value_ref_object
);

=back

=item Array of Hashes

@array(
    {
	'NAME'=>'key1',
	'VALUE'=>'value1'
    },
    {
	'NAME'=>'key2',
	'VALUE'=>'35',
	'VALUETYPE'=>'numeric',
	'TYPE'=>'uint8'
    },
    {
	'NAME'=>'key3'
	'VALUE.REFERENCE'=>$value_ref_object
    },
);

Defining a keybinding has one major advantage it preserves the order of the keys where as the other methods do not.
This method is an array containing hahs references in a complex format containing no less than 2 and up to 5 fields.
the keys are as follows.

1) NAME
    The NAME field is a requierd field containing the name of the key
2) VALUE
    The VALUE field is requiered unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding
3) VALUE.REFERENCE
    The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It shoud contain and referent to a VALUE.REFERENCE object.
    Caviot: LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future
3) VALUETYPE
    The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.
5) TYPE
    The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more percise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE feild
    WARNING: Implementation of the TYPE filed in a keybinding is inconsistant and some CIM implementations break when you define it. As such I advise users not to define it unless absolutly nessisary or you want to QA test other CIM implementations.
 

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

$query-E<gt>GetClass('name/space','ClassName',{ 'LocalOnly'=E<gt> 1, 'IncludeQualifiers' =E<gt> 1, IncludeClassOrigin=E<gt> 0},['property1','property2']);

$query-E<gt>GetClass('name/space','ClassName',{ 'LocalOnly'=E<gt>0, 'IncludeQualifiers' =E<gt>1, IncludeClassOrigin=E<gt> 0});

$query-E<gt>GetClass('name/space','ClassName',{},['property1','property2']);

$query-E<gt>GetClass('name/space','ClassName');

The GetClass method retrievs the information about a CIM class, thie information that describes the requiered fields, all of the optional fields and in most cases any relivant documentation about how the Class is inteded to be used.
The LCP's GetClass method requiers 2 fields and has 2 optional fields

1) The CIM namespace you want to query
This field is requiered
2) The name of the CIM class you want information about
This field is requiered
3) An optioal hash reference containing any combination of the following query modifiers 
3.1) LocalOnly
Defaults to 1 (True)
3.2) IncludeQualifiers
Defaults to 1 (True)
3.3) IncludeClassOrigin
Defaults to 0 (False)
4) An optional array reference containing a list of specific properties you want to know about instead of retuning every thing.

See DSP0200 Version 1.3.1 section 5.3.2.1 for details

=back

=item GetInstance

=over 4

$query->GetInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0},['property1','property2']);

$query->GetInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0});

$query->GetInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{},['property1','property2']);

$query->GetInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

GetInstance retrieves the data from a specific instance of a CIM class. 

1) The CIM namespace you want to query
This field is requiered
2) The name of the CIM class you want information about
This field is requiered
3) InstanceName 
A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.
3) An optioal hash reference containing any combination of the following query modifiers 
3.1) LocalOnly
Defaults to 1 (True)
3.2) IncludeQualifiers
Defaults to 1 (True)
3.3) IncludeClassOrigin
Defaults to 0 (False)
4) An optional array reference containing a list of specific properties you want to know about instead of retuning every thing


See DSP0200 Version 1.3.1 section 5.3.2.2 for details

=back

=item DeleteClass

=over 4

$query->DeleteClass ('name/space','ClassName')

DeleteClass deletes a CIM Class from a namespace.

1) The CIM namespace you want to delet the class from
This field is requiered
2) The name of the CIM class you want delete
This field is requiered


WARNING: This method has not been tested yet

See DSP0200 Version 1.3.1 section 5.3.2.3 for details

=back

=item DeleteInstance

=over 4

$query->DeleteInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

DeleteInstance deletes a specific instance of a CIM class from a namespace.

1) The CIM namespace you want to delete the class from
This field is requiered
2) The name of the CIM class you want delete an intance of.
This field is requiered
3) InstanceName 
A hash or array reference matching a valid keybinding format which describes the instance of the class you want to delete. Please see the Keybinding field format described in the "Specialy Formated Fields" section.
This field is requiered

WARNING: This method has not been tested yet

See DSP0200 Version 1.3.1 section 5.3.2.4 for details

=back

=item CreateClass

=over 4

Not implemented yet

=back

=item CreateInstance

=over 4

$query->CreateInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

CreateInstance creates specific uniqe instance of a CIM class in a namespace.

1) The CIM namespace you want to create the instance of the class in
This field is requiered
2) The name of the CIM class you want create an intance of.
This field is requiered
3) InstanceName 
A hash or array reference matching a valid keybinding format which describes the instance of the class you want to create. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

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


1) The CIM namespace you want to enumerate the classes from
This field is requiered
2) The name of the CIM class you want information about
This field is optional. If you dont wish to specify a value but wish to specify the next field you may leave it empty or sete it to 'NULL'
3) An optioal hash reference containing any combination of the following query modifiers 
3.1) DeepInheritance
Defaults to 0 (False)
3.2) LocalOnly
Defaults to 1 (True)
3.2) IncludeQualifiers
Defaults to 1 (True)
3.3) IncludeClassOrigin
Defaults to 1 (True)


See DSP0200 Version 1.3.1 section 5.3.2.9 for details

=back

=item EnumerateClassNames

=over 4 

$query->EnumerateClassNames ('name/space','ClassName', { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space',, { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space','NULL', { 'DeepInheritance' = 0});

$query->EnumerateClassNames ('name/space','ClassName');

$query->EnumerateClassNames ('name/space');

1) The CIM namespace you want to enumerate the class names from
This field is requiered
2) The name of the CIM class you want to enumerate the class names of
This field is optional.
If you dont wish to specify a value but wish to specify the next field you may leave it empty or sete it to 'NULL'
Note: this may not sound like it make sence but it does especialy when you enable the Deepinheritence modifier
3) An optioal hash reference containing any combination of the following query modifiers 
3.1) DeepInheritance
Defaults to 0 (False)


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

1) The CIM namespace you want to enumerate the instances name of the classes from
This field is requiered
2) The name of the CIM class you want to enumerate the intance names of
This field is required.


See DSP0200 Version 1.3.1 section 5.3.2.12 for details

=back

=item ExecQuery

=over 4

Not implemented yet

=back

=item Associators

=over 4

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{ }, ['property1','property2'] );

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole');

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass',);

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);

$query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

See DSP0200 Version 1.3.1 section 5.3.2.14 for details

=back

=item AssociatorNames

=over 4

$query->AssociatorNames('name/space','ClassName', {} , 'AssocClass', 'ResultClass', 'Role','ResultRole');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'NULL', 'NULL','NULL');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'AssocClass', 'NULL', 'Role','ResultRole');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass', 'NULL','ResultRole');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, '', 'ResultClass', '','ResultRole');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass');

$query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format);

See DSP0200 Version 1.3.1 section 5.3.2.15 for details

=back

=item References

=over 4

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role','ResultRole',{ }, ['property1','property2'] );

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role','ResultRole');

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);

$query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

=back

=item ReferenceNames

=over 4

Not implemented yet

=back

=item GetProperty

=over 4

$query->GetProperty ( 'name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'PropertyName');

GetProperty returns only a specific property from an instance of a class
It requiers 4 paramiters

1) Namespace
A string containing the namespace that the instance of the class can be found in a common example is 'root/cimv2' or 'root/interop'

2) ClassName
A string containing the name of the class you want to query

3) InstanceName 
A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

4) PropertyName
The name of the property you wisht to extrace.


See DSP0200 Version 1.3.1 section 5.3.2.18 for details

=back

=item SetProperty

=over 4

$query->SetProperty('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'PropertyName','VALUE')

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
