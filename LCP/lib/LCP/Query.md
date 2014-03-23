# NAME

LCP::Query - Lib CIM (Common Information Model) Perl Query Constructor

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
    # returning a multi dimensional hash reference of the results
    my $tree=$parser->buildtree;
    }

<br>



# DESCRIPTION

- Constructs a CIM query based on the Intrinsic CIM methods as defined in DSP0200

## EXPORT

- This is an OO Class and as such it exports nothing

# FIELD FORMATS

## FIELD VALUE Constraints

### CIMType constraint

- The CIMType constraint is a common constraint used in two contexts. The first is as a value of a field defining a constraint on a second field. The second is defining a restricting the contents of a field.
- The possible types of constraints supported by the CIMType constraints are as follows.
- boolean, string, char16, uint8, sint8, uint16, sint16, uint32, sint32, uint64, sint64, datetime, real32, or real64

## __Specially Formatted Fields__

&#10;

### __Keybinding__

&#10;

- Keyindings are a complex key value paring construct that includes a name, value or value reference, valuetype description, and type description.

    &#10;

- Structurally each key in a keybinding contains the following elements.

    &#10;

- __NAME__

    The NAME field is a required field containing a string that defines the name of the key

- __VALUE.REFERENCE__ or __VALUE__

    Next you must define either the VALUE.REFERENCE or VALUE

    __WARNING:__ Creation of a VALUE.REFERENCE is not currently supported by this API yet but will be in the future.

    The VALUE field is a field containing a string, boolean, or numeric data. If you define the VALUE field you can define the VALUETYPE, and TYPE fields.

- __VALUETYPE__

    The VALUETYPE field describes the type of data contained in the VALUE field. The VALUETYPE may be defined as string, boolean, or numeric.

    If the VALUE field is defined and VALUETYPE is not defined it will default to "string"

- __TYPE__

    The TYPE field is an extended description of the content of the VALUE field which may be defined as any one of the types defined in the "CIMType constraint". the default is undefined but implied by the VALUETYPE field.

    __WARNING:__ Not all implementations of CIM-XML and WBEM handle the TYPE filed in a key binding properly and some even tools consider it to be invalid despite the fact that it is clearly included in the specification, so defining it may break things. At this time I advise users not to set this field unless you are trying to QA test other implementations CIM-XML or your WBEM servers.

- LCP supports defining a key binding in 4 different formats

#### Simple hash

    %hash=(
        'key1'=>'value1',
        'key2'=>'35',
        'key3'=>$value_ref_object
    );

&#10;

- In the simple hash format all VALUETYPE fields are set to string unless the value is a VALUE.REFERENCE object 

#### Complex hash

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

&#10;

- The name of the top level key is the name of the keybinding
- The supported fields for the child hash are as follows
- 1) __VALUE__

    The VALUE field is required unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding

- 2) __VALUE.REFERENCE__

    The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It should contain and reference to a VALUE.REFERENCE object.

    __Caviot:__ LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future.

- 3) __VALUETYPE__

    The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.

- 4) __TYPE__

    The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more precise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE field

    __WARNING:__ Implementation of the TYPE filed in a keybinding is inconsistent and some CIM implementations break when you define it. As such I advise users not to define it unless absolutely necessary or you want to QA test other CIM implementations.

- Each Key must contain a hash with either a VALUE or a VALUE.REFERENCE defined.
- If both a VALUE and a VALUE.REFERENCE are defined the VALUE.REFERENCE will be ignored.
- If the default for VALUETYPE is "string" if a VALUE is specified and the VALUETYPE has not been defined.

#### Mixed Hash

    %hash=(
        'key1'=>'value1',
        'key2'=>{
            'VALUE'=>'35',
            'VALUETYPE'=>'numeric',
            'TYPE'=>'uint8'
        }
        'key3'=>$value_ref_object
    ); >>>

&#10;

- You may use both the simple and complex format in a single hash mixed hash if you find it more convenient each key will function in accordance to the rules of the simple or complex format as appropriate

#### Array of Hashes

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

&#10;

- Defining a keybinding has one major advantage it preserves the order of the keys where as the other methods do not.
- This method is an array containing hash references in a complex format containing no less than 2 and up to 5 fields.
- The keys are as follows.
- 1) __NAME__

    The NAME field is a required field containing the name of the key

- 2) __VALUE__

    The VALUE field is required unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding

- 3) __VALUE.REFERENCE__

    The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It should contain and referent to a VALUE.REFERENCE object.

    __Caviot:__ LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future

- 3) __VALUETYPE__

    The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.

- 5) __TYPE__

    The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more precise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE field

    __WARNING:__ Implementation of the TYPE filed in a keybinding is inconsistent and some CIM implementations break when you define it. As such I advise users not to define it unless absolutely necessary or you want to QA test other CIM implementations.

# Basic Methods

### __new()__

    $query=LCP::Query->new();

Creates an accessor for a new query.

All queries must be made via an accessor created by this method.

To create a simple query just create a new query instance and then use one of the intrinsic methods to create your query.

To create a multireq (Multiple requests in one query) create a query handle via this method then use a combination of the intrinsic methods against the same query handle.

This method does not take any options.

__WARNING: multireq queries are not supported by all WBEM servers. If you have doubts about your WBEM server use simple queries instead they are safer because all WBEM servers support them.__

# Using The Intrinsic Methods

&#10;

- Each intrinsic method is a Perl style version of a method specified in DTMF DSP0200. All WBEM servers tested with this class thus far support simple queries which means you can use one intrinsic method per instance of the class. If your WBEM server supports it multipart queries may also be generated by simply calling multiple intrinsic methods against a single instance of the class.



## __Intrinsic Methods__

&#10;

### __GetClass()__

    $query->GetClass('Name/Space','ClassName',{ 'LocalOnly'=>1, 'IncludeQualifiers'=>1, IncludeClassOrigin=>1},['property1','property2']);
    $query->GetClass('Name/Space','ClassName',{ 'LocalOnly'=>1, 'IncludeQualifiers'=>0, IncludeClassOrigin=>1},['property1','property2']);
    $query->GetClass('name/space','ClassName',{ 'LocalOnly'=>0, 'IncludeQualifiers'=>1, IncludeClassOrigin=>0});
    $query->GetClass('name/space','ClassName',{},['property1','property2']);
    $query->GetClass('name/space','ClassName');

&#10;

The GetClass method retrieves the structural information about a CIM class, this information describes all of the fields in the CIM Class, if they are required or optional, the type of data they fields may contain, and in most cases any relevant documentation about the intended use of the CIM class.

The LCP::Query's GetClass method requires 2 fields and has 2 optional fields described as follows.

- 1 __Name/Space__

    The CIM namespace you want to query.

    This field is required

- 2 __ClassName__

    The name of the CIM class you want the structural information for.

    This field is required

- 3 __Query Modifiers__

    An optional hash reference containing any combination of the following query modifiers.

    - __LocalOnly__

            'LocalOnly'=>1 # True

        If set to 1 (True) local only will instruct the WBEM server to only return elements which have been added to the class, or has had its contents or default values overridden from the class from the class it inherited the field from.

        If set to 0 (False) the WBEM server will return all elements of the class regardless of any other considerations.

        Defaults to 1 (True)

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1 # True

        Qualifiers are intended to be human understandable descriptions of a CIM field.

        If set to 1 (True) will instruct the WBEM server include all relevant qualifiers in its response.

        If set to 0 (False) instruct the WBEM server not to include any qualifiers in its response.

        Defaults to 1 (True)

        __See DSP0004 section 5.5 for details__

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>0 # False

        If set to 1 (True) it instructs the WBEM server to include the name of origin class from which each field came from if it was inherited from a parent CIM class.

        If set to 0 (False) instructs the WBEM server not to include the origin class information in any of the fields it describes.

        Defaults to 0 (False)

- 4 __Property Array Reference__

        ['property1','property2']

    An optional array reference that instructs the WBEM server only to provide information about specific fields instead of the entire class.

    just include the name of each property you want to know about as an item in the array.

    Defaults to undefined which means the WBEM server will return everything that the query modifiers allow.

- __Implementation Note:__

    All examples below were produced using TOG-OpenPegasus with SBLIM on Fedora Linux

    - here is a basic use of the CIM\_UnitaryComputerSystem CIM class using GetClass

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>0,'IncludeClassOrigin'=>0,'IncludeQualifiers'=>0};

        Querying this class returns a large number of properties.

        the following output was achieved by grepping the resulting XML for PROPERTY and NAME

            <PROPERTY NAME="InstanceID"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="Caption"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="Description"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="ElementName"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="InstallDate"  PROPAGATED="true" TYPE="datetime">
            <PROPERTY.ARRAY NAME="OperationalStatus"  TYPE="uint16" PROPAGATED="true">
            <PROPERTY.ARRAY NAME="StatusDescriptions"  TYPE="string" PROPAGATED="true">
            <PROPERTY NAME="Status"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="HealthState"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="CommunicationStatus"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="DetailedStatus"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="OperatingStatus"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="PrimaryStatus"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="EnabledState"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="OtherEnabledState"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="RequestedState"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="EnabledDefault"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="TimeOfLastStateChange"  PROPAGATED="true" TYPE="datetime">
            <PROPERTY.ARRAY NAME="AvailableRequestedStates"  TYPE="uint16" PROPAGATED="true">
            <PROPERTY NAME="TransitioningToState"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="CreationClassName"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="Name"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="PrimaryOwnerName"  PROPAGATED="true" TYPE="string">
            <PROPERTY NAME="PrimaryOwnerContact"  PROPAGATED="true" TYPE="string">
            <PROPERTY.ARRAY NAME="Roles"  TYPE="string" PROPAGATED="true">
            <PROPERTY.ARRAY NAME="OtherIdentifyingInfo"  TYPE="string" PROPAGATED="true">
            <PROPERTY.ARRAY NAME="IdentifyingDescriptions"  TYPE="string" PROPAGATED="true">
            <PROPERTY NAME="NameFormat"  PROPAGATED="true" TYPE="string">
            <PROPERTY.ARRAY NAME="Dedicated"  TYPE="uint16" PROPAGATED="true">
            <PROPERTY.ARRAY NAME="OtherDedicatedDescriptions"  TYPE="string" PROPAGATED="true">
            <PROPERTY NAME="ResetCapability"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY.ARRAY NAME="PowerManagementCapabilities"  TYPE="uint16" PROPAGATED="true">
            <PROPERTY.ARRAY NAME="InitialLoadInfo"  TYPE="string">
            <PROPERTY NAME="LastLoadInfo"  TYPE="string">
            <PROPERTY NAME="PowerManagementSupported"  TYPE="boolean">
            <PROPERTY NAME="PowerState"  TYPE="uint16">
            <PROPERTY NAME="WakeUpType"  TYPE="uint16">

    - We can refine this query by specifying specific properties, methods etc..

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>0,'IncludeClassOrigin'=>0,'IncludeQualifiers'=>0},['HealthState','PowerState','RequestStateChange']);

        With this query we only get the following two properties.

            <PROPERTY NAME="HealthState"  PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="PowerState"  TYPE="uint16">

    - Now lets start looking at the query modifiers starting with IncludeClassOrigin

        In the previous queries you will notice some say PROPAGATED="true" and others do not. PROPAGATED="true" indicates that this property has been inherited from an other Parent CIM Class (A. K. A. SUPERCLASS). By enabling IncludeClassOrigin we can see what CIM class these properties were inherited from.

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>0,'IncludeClassOrigin'=>1,'IncludeQualifiers'=>0},['HealthState','PowerState','RequestStateChange']);

        Now the results includes a new tag indicating the ORIGINCLASS of each PROPERTY.

            <PROPERTY NAME="HealthState"  CLASSORIGIN="CIM_ManagedSystemElement" PROPAGATED="true" TYPE="uint16">
            <PROPERTY NAME="PowerState"  CLASSORIGIN="CIM_UnitaryComputerSystem" TYPE="uint16">

        In this query PowerState has an CLASSORIGIN of CIM\_UnitaryComputerSystem indicating it came from the Class we queried; however HealthState which also says PROPAGATED="True" has the CLASSORIGIN of CIM\_ManagedSystemElement which means it originally came from that class and was either directly inherited it from CIM\_ManagedSystemElement or indirectly from another class which itself directly or indirectly inherited it from the CIM\_ManagedSystemElement class

    - next lets see what happens when we enable LocalOnly

        when enabling LocalOnly we are indicating that we only want elements with the same CLASSORIGIN as the class we are querying or elements that have been some how modified only in this class so it differs from any of the classes it was inherited from.

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>1,'IncludeClassOrigin'=>1,'IncludeQualifiers'=>0},['HealthState','PowerState','RequestStateChange']);

        Now only the PowerState property is returned.

            <PROPERTY NAME="PowerState"  CLASSORIGIN="CIM_UnitaryComputerSystem" TYPE="uint16">

        The reason why is that the HealthState property was inherited from an other class and has been otherwise unaltered form the parent class (AKA. SUPERCLASS) of the CIM\_UnitaryComputerSystem class. So even though the Property list says to include it the LocalOnly query modifier filters it out.

    - finally Lets look at the IncludeQualifiers query modifier.

        To understand the difference you must first see the full contents of a property without it enabled.

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>1,'IncludeClassOrigin'=>1,'IncludeQualifiers'=>0},['HealthState','PowerState','RequestStateChange']);

        returns the PowerState class as follows

            <PROPERTY NAME="PowerState"  CLASSORIGIN="CIM_UnitaryComputerSystem" TYPE="uint16">
            </PROPERTY>

        Now when we enable IncludeQualifiers in this query

            $query->GetClass('root/cimv2','CIM_UnitaryComputerSystem',{'LocalOnly'=>1,'IncludeClassOrigin'=>1,'IncludeQualifiers'=>1},['HealthState','PowerState','RequestStateChange']);

        we get very different results

            <PROPERTY NAME="PowerState"  CLASSORIGIN="CIM_UnitaryComputerSystem" TYPE="uint16">
            <QUALIFIER NAME="Deprecated" TYPE="string" TOSUBCLASS="false">
            <VALUE.ARRAY>
            <VALUE>CIM_AssociatedPowerManagementService.PowerState</VALUE>
            </VALUE.ARRAY>
            </QUALIFIER>
            <QUALIFIER NAME="Description" TYPE="string" TRANSLATABLE="true">
            <VALUE>Indicates the current power state of the ComputerSystem and its associated OperatingSystem. This property is being deprecated. Instead, the PowerState property in the AssociatedPowerManagementService class SHOULD be used. Regarding the Power Save states, these are defined as follows: Value 4 (&quot;Power Save - Unknown&quot;) indicates that the System is known to be in a power save mode, but its exact status in this mode is unknown; &#10;Value 2 (&quot;Power Save - Low Power Mode&quot;) indicates that the System is in a power save state but still functioning, and may exhibit degraded performance; &#10;Value 3 (&quot;Power Save - Standby&quot;) describes that the System is not functioning but could be brought to full power &apos;quickly&apos;; value 7 (&quot;Power Save - Warning&quot;) indicates that the ComputerSystem is in a warning state, though also in a power save mode. &#10;Values 8 and 9 describe the ACPI &quot;Hibernate&quot; and &quot;Soft Off&quot; states.</VALUE>
            </QUALIFIER>
            <QUALIFIER NAME="ValueMap" TYPE="string">
            <VALUE.ARRAY>
            <VALUE>0</VALUE>
            <VALUE>1</VALUE>
            <VALUE>2</VALUE>
            <VALUE>3</VALUE>
            <VALUE>4</VALUE>
            <VALUE>5</VALUE>
            <VALUE>6</VALUE>
            <VALUE>7</VALUE>
            <VALUE>8</VALUE>
            <VALUE>9</VALUE>
            </VALUE.ARRAY>
            </QUALIFIER>
            <QUALIFIER NAME="Values" TYPE="string" TRANSLATABLE="true">
            <VALUE.ARRAY>
            <VALUE>Unknown</VALUE>
            <VALUE>Full Power</VALUE>
            <VALUE>Power Save - Low Power Mode</VALUE>
            <VALUE>Power Save - Standby</VALUE>
            <VALUE>Power Save - Unknown</VALUE>
            <VALUE>Power Cycle</VALUE>
            <VALUE>Power Off</VALUE>
            <VALUE>Power Save - Warning</VALUE>
            <VALUE>Power Save - Hibernate</VALUE>
            <VALUE>Power Save - Soft Off</VALUE>
            </VALUE.ARRAY>
            </QUALIFIER>
            </PROPERTY>

        Well this is a lot more verbose.





        First you have the Description QUALIFIER which is a full text description of the property and what it means.

        Next we have the ValueMap and Values qualifiers which are tied together. A common mistake here is that people some times think ValueMap may only contain numbers and that they are always sequential in the array of values but this is not true. the values may contain may contain text strings or any thing else based on the constrain specified in the TYPE field, which in this case is "string". So what you need to do when decoding an instance of the class is to find the item in the value array that matches the content of the results returned for this property in the instance and match its content position in the "VALUE.ARRAY" under the ValueMap and return corresponding position in the VALUE.ARRAY under Values Qualifier to decode the results as human readable text. To ease this process if you use LCP::SimpleParser to parse the XML an additional hash will be added named 'ValueHash'. The 'ValueHash'Quallifier is not part of the standard nor was it returned by the WBEM server, instead it was generated by LCP::SimpleParser as a quick cheat sheet to use in application. Each value in the 'ValueMap' is a key in the ValueHash containing the corosponding content from the 'Values' array.

        Here is how the PowerState property looks after its been parsed by the the LCP::SimpleParser class and just printing the PowerState property via Data::Dumper

            $VAR1 = {
                      'ValueMap' => [
                                      '0',
                                      '1',
                                      '2',
                                      '3',
                                      '4',
                                      '5',
                                      '6',
                                      '7',
                                      '8',
                                      '9'
                                    ],
                      'NAME' => 'PowerState',
                      'TYPE' => 'uint16',
                      'Deprecated' => [
                                      'CIM_AssociatedPowerManagementService.PowerState'
                                    ],
                      'Values' => [
                                    'Unknown',
                                    'Full Power',
                                    'Power Save - Low Power Mode',
                                    'Power Save - Standby',
                                    'Power Save - Unknown',
                                    'Power Cycle',
                                    'Power Off',
                                    'Power Save - Warning',
                                    'Power Save - Hibernate',
                                    'Power Save - Soft Off'
                                  ],
                      'ValueHash' => {
                                       '6' => 'Power Off',
                                       '3' => 'Power Save - Standby',
                                       '7' => 'Power Save - Warning',
                                       '9' => 'Power Save - Soft Off',
                                       '2' => 'Power Save - Low Power Mode',
                                       '8' => 'Power Save - Hibernate',
                                       '1' => 'Full Power',
                                       '4' => 'Power Save - Unknown',
                                       '0' => 'Unknown',
                                       '5' => 'Power Cycle'
                                     },
                      'CLASSORIGIN' => 'CIM_UnitaryComputerSystem',
                      'Description' => 'Indicates the current power state of the ComputerSystem and its associated OperatingSystem. This property is being deprecated. Instead, the PowerState property in the AssociatedPowerManagementService class SHOULD be used. Regarding the Power Save states, these are defined as follows: Value 4 ("Power Save - Unknown") indicates that the System is known to be in a power save mode, but its exact status in this mode is unknown; 
            Value 2 ("Power Save - Low Power Mode") indicates that the System is in a power save state but still functioning, and may exhibit degraded performance; 
            Value 3 ("Power Save - Standby") describes that the System is not functioning but could be brought to full power \'quickly\'; value 7 ("Power Save - Warning") indicates that the ComputerSystem is in a warning state, though also in a power save mode. 
            Values 8 and 9 describe the ACPI "Hibernate" and "Soft Off" states.'
                    };

- See DSP0200 Version 1.3.1 section 5.3.2.1 for details

### __GetInstance__

    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0},['property1','property2']);
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0});
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{},['property1','property2']);
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

GetInstance retrieves the contents of a specific instance of a CIM class.

The LCP::Query's GetInstance method requires 3 fields and has additional 2 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to query

    This field is required

- 2 __ClassName__

    The name of the CIM class of the instance you want the contents from

    This field is required

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query.

    Please see the Keybinding field format described in the "Specially Formatted Fields" section for precise information the format of this field.

    This field is required

- 4 __Query Modifiers__

    An optional hash reference containing any combination of the following query modifiers. Each of these modifier change the results returned from the WBEM server in very specific ways.

    each modifier may be specified as a key in the hash reference with a value of 1 for True or 0 for False.

    Any key not specified will assume their default values.

    __NOTE: Modifiers with the same name may or may not have the same effect depending on the method so please read the definitions for each intrinsic method carefully.__

    - __LocalOnly__

            'LocalOnly'=>1, # True
            'LocalOnly'=>0, # False

        If set to 1 (True) the behavior varies base on which version of the standard the WBEM server supports.

        In __versions prior to 1.1__ of the standard this modifier to 1 (True) returns only the elements that differ from the defaults of the class or differ from the defaults of the parent classes for elements which are inherited from other classes.

        In __version 1.1 or higher__ of the standard setting this modifier to 1 (True) only returns the elements in the instance that are different from the defaults for class will be returned but not any elements inherited from a parent class unless their defaults in the class you are querying differ from the parent class. Any elements of the instance that have been altered which were inherited from the parent class are not included in the results.





        If set to 0 (False) all elements of the instance except those filtered out by other options will be returned.

        __WARNING: This modifier is deprecated in the standard for the GetInstance method and will be removed from a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), furthermore some WBEM servers now ignore this modifier and act as though it set to 0 (False) regardless of what you set it to.__

        See DSP0200 Version 1.3.1 section ANNEX B "LocalOnly Parameter Discussion" for details

        Defaults to 0 (False)

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1, # True
            'IncludeQualifiers'=>0, # False

        If set to 1 (True) includes the qualifiers for the instance will be returned in the results.

        If set to 0 (False) no qualifiers will be included in the results.

        Qualifiers are intended to be human understandable descriptions of a CIM field

        __WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), in addition WBEM servers are no longer required to honer it if you set it to 1 (True). The preferred method to get the qualifiers is to use the GetClass method instead.__

        Defaults to 0 (False)

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>1, # True
            'IncludeClassOrigin'=>0, # False

        If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element describing which class it was inherited from.

        If set to 0 (False) the no CLASSORIGIN tags will be included.

        Defaults to 0 (False)

- 5 __Property Array Reference__

    `['property1','property2']`

    An optional array reference containing a list of specific properties you want the values of instead of retuning all of the properties in the instance.

- __Implementation Note:__



- See DSP0200 Version 1.3.1 section 5.3.2.2 for details

### __DeleteClass__

    $query->DeleteClass('name/space','ClassName');

DeleteClass deletes a CIM Class from a namespace.

The LCP::Query's DeleteClass method requires 2 fields described as follows

&#10;

- 1 __name/space__

    The CIM namespace you want to delete the class from

    This field is required

- 2 __ClassName__

    The name of the CIM class you want delete

    This field is required

- __WARNING:__ This method has not been tested in LCP yet but should work in theory.
- See DSP0200 Version 1.3.1 section 5.3.2.3 for details

### __DeleteInstance__

    $query->DeleteInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

DeleteInstance deletes a specific instance of a CIM class from a namespace.

The LCP::Query's DeleteInstance method requires 3 fields described as follows.

- 1 __name/space__

    The CIM namespace you want to delete the instance from.

    This field is required

- 2 __ClassName__

    The name of the CIM class you want delete an instance of.

    This field is required

- 3 __InstanceName__ 

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to delete. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

    This field is required

- __WARNING:__ This method has not been tested in LCP yet but should work in theory
- See DSP0200 Version 1.3.1 section 5.3.2.4 for details

### __CreateClass__

- Not implemented in LCP::Query yet

### __CreateInstance__

    $query->CreateInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format);

CreateInstance creates specific unique instance of a CIM class in a namespace.

The LCP::Query's CreateInstance method requires 3 fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to create the instance of the class in

    This field is required

- 2 __ClassName__

    The name of the CIM class you want create an instance of.

    This field is required

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance including all of its properties of the class you want to create. Please see the Keybinding field format described in the "Specially Formatted Fields" section. The exact keys allowed are CIM class specific.

- See DSP0200 Version 1.3.1 section 5.3.2.6 for details

### __ModifyClass__

- Not implemented in LCP::Query yet

### __ModifyInstance__

- Not implemented in LCP::Query yet

### __EnumerateClasses()__

    $query->EnumerateClasses('name/space','ClassName', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space','ClassName');
    $query->EnumerateClasses('name/space','NULL', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space','', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space');

EnumerateClasses outputs the structure of any subclasses of name space or a class specified. The results are nearly identical to that of doing multiple GetClass operations; however the results may not include any classes or may include multiple classes depending on howmany subclasses are found.

The LCP::Query's EnumerateClasses method requires 1 fields and has 2 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to enumerate the classes from

    This field is required

- 2 __ClassName__

    The name of the CIM class you want information about.

    This field is optional. If you don't wish to specify a value but wish to specify the next field you may leave it empty quotes or set it to 'NULL'

- 3 __Query Modifiers__

    An optional hash reference containing any combination of the following query modifiers 

    - __DeepInheritance__

            'DeepInheritance'=>1, # True
            'DeepInheritance'=>0, # False

        If this modifier is set to 1 (True) and you have specified a class in the ClassName field then all subclasses that inherit directly or indirectly from that class will be returned.

        If this modifier is set to 1 (True) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then all classes in the namespace will be returned.

        If this modifier is set to 0 (False) and you have specified a class in the ClassName field then only the classes that directly inherit from the class specified will be returned.

        If this modifier is set to 0 (False) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then only the base classes in the namespace will be returned.

        Defaults to 0 (False)

    - __LocalOnly__

            'LocalOnly'=>1, # True
            'LocalOnly'=>0, # False

        If set to 1 (True) only elements modified or defined specifically in the ClassName field will be included in the result, but not any elements inherited from the origin class which haven't been overridden.

        If set to 0 (False) all elements will be included in the results.

        Defaults to 1 (True)

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1, # True
            'IncludeQualifiers'=>0, # False

        If set to 1 (True) includes the qualifiers for the instance will be returned in the results.

        If set to 0 (False) no qualifiers will be included in the results.

        Defaults to 1 (True)

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>1, # True
            'IncludeClassOrigin'=>0, # False

        If set to 1 (True) all elements inherited from a parent class will include a CLASSORIGIN field specifying what class it was originally inherited from.

        If set to 0 (True) no elements will include the CLASSORIGIN field.

        Setting this field to 1 (True) only makes sense if you set LocalOnly to 0 (False)

        Defaults to 0 (False)

- __Implementation Note:__

    All examples below were produced using TOG-OpenPegasus with SBLIM on Fedora Linux 16

    - If I run an EnumerateClasses query against the root/cimv2 namespase with no other options

            $query->EnumerateClasses('root/cimv2');

        The results simmilar to running a multireq set of GetClass queries against all 99 of the base classes in the name space.

    - If I ran the same query with DeepInheritance enabled

            $query->EnumerateClasses('root/cimv2','',{ 'DeepInheritance' = 1});

        The results simmilar to running a multireq set of GetClass queries against all 1583 of the classes in the name space.

    - If I ran the against the CIM\_UnitaryComputerSystem CIM Class

            $query->EnumerateClasses('root/cimv2','CIM_UnitaryComputerSystem',{ 'DeepInheritance' = 1});

        The results simmilar to running GetClass query against the PG\_ComputerSystem class because that is the only class that directly or indirectly inherits from the CIM\_UnitaryComputerSystem class.

    - If I ran the against the PG\_ComputerSystem CIM Class

        $query->EnumerateClasses('root/cimv2','PG\_ComputerSystem',{ 'DeepInheritance' = 1});

        The query would succede however it wouldn't include any results because no other classes inherit from the PG\_ComputerSystem class.

        The resulitng XML looks like this

            <?xml version="1.0" ?>
            <CIM CIMVERSION="2.0" DTDVERSION="2.0">
        	<MESSAGE ID="1942" PROTOCOLVERSION="1.0">
        	    <SIMPLERSP>
        		<IMETHODRESPONSE NAME="EnumerateClasses">
        		</IMETHODRESPONSE>
        	    </SIMPLERSP>
        	</MESSAGE>
            </CIM>

        All other query modifiers work the same way as they do in a GetClass query.

- See DSP0200 Version 1.3.1 section 5.3.2.9 for details

### __EnumerateClassNames()__

    $query->EnumerateClassNames ('name/space','ClassName', { 'DeepInheritance' = 1});
    $query->EnumerateClassNames ('name/space','', { 'DeepInheritance' = 0});
    $query->EnumerateClassNames ('name/space','NULL', { 'DeepInheritance' = 0});
    $query->EnumerateClassNames ('name/space','ClassName');
    $query->EnumerateClassNames ('name/space');

The EnumerateClassNames method returns the names of any CIM classes that inherit from the CIM class name specified in the ClassName or if the ClassName filed is not specified the it returns the names of all of the base CIM classes in the name space specified in the name/space field.

The LCP::Query's EnumerateClassNames method requires 1 fields and has 2 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to enumerate the class names from

    This field is required

- 2 __ClassName__

    The name of the CIM class you want to enumerate the class names of

    This field is optional.

    If you don't wish to specify a value but wish to specify the next field you may leave it empty or set it to 'NULL'

    __Note:__ This option may not sound like it make sense but its, especially when you enable the __DeepInheritence__ modifier.

- 3 __Query Modifiers__

    An optional hash reference containing any combination of the following query modifiers 

    - __DeepInheritance__

            'DeepInheritance'=>1, # True
            'DeepInheritance'=>0, # False

        If this modifier is set to 1 (True) and you have specified a class in the ClassName field then all of the names of any of subclasses that inherit directly or indirectly from that class will be returned as well.

        If this modifier is set to 1 (True) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then the names of all classes in the namespace will be returned.

        If this modifier is set to 0 (False) and you have specified a class in the ClassName field then only the names of the classes which directly inherit from the one specified will be returned

        If this modifier is set to 0 (False) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then only the names of the base classes in the namespace will be returned.

        Defaults to 0 (False)

- __Implementation Note:__

    One of the common complaints about SMI-S is that the class names are not standardized from one vendor to the next; but this is a half truth.

    SMI-S allows a vendor to create their own CIM subclasses of the CIM classes named the standard. This allows the vendor to add fields for their one proprietary features and in some cases remove optional fields that do not apply to their devices. By using the EnumerateClassNames CIM Intrinsic method with DeepInheritance enabled you can usually figure out very quickly what the vendor specific CIM class names are, or if you're in doubt just assume they all are.

    For example if I wanted to know the name of the vendor specific version of CIM\_ComputerSystem on a Fedora Linux box with SBLIM and TOG\_OpenPegasus installed I would execute the following query

    here is the query I might create.

        $query->EnumerateClassNames ('name/space','CIM_ComputerSystem', { 'DeepInheritance' = 1});

    Once the query was posted and the results parsed results were either of the following two results depending on the value of DeepInheritance.

    With DeepInheritence set to 0 (False) it returns

        "CIM_Cluster", "CIM_VirtualComputerSystem", "CIM_UnitaryComputerSystem", "Linux_ComputerSystem", "Xen_ComputerSystem", "KVM_ComputerSystem", "LXC_ComputerSystem"

    With DeepInheritence set to 1 (True) it returns

        "CIM_Cluster", "PG_ComputerSystem", "CIM_VirtualComputerSystem", "CIM_UnitaryComputerSystem", "Linux_ComputerSystem", "Xen_ComputerSystem", "KVM_ComputerSystem", "LXC_ComputerSystem"

    Notice with DeepInheritence set to 1 (True) and additional CIM class name PG\_ComputerSystem is included in the results, this is because the super class for PG\_ComputerSystem is CIM\_UnitaryComputerSystem and the super class for CIM\_UnitaryComputerSystem is CIM\_ComputerSystem

    Here is the relevant portions of the raw XML from a GetClass against the two classes that illustrates the relationship.

    From the PG\_ComputerSystem CIM Class'

        <CLASS NAME="PG_ComputerSystem"  SUPERCLASS="CIM_UnitaryComputerSystem" >

    What that tells me is that CIM\_UnitaryComputerSystem class was used as the initial template for creating the PG\_ComputerSystem class

- From the CIM\_UnitaryComputerSystem Class.

        <CLASS NAME="CIM_UnitaryComputerSystem"  SUPERCLASS="CIM_ComputerSystem" >

    What that tells me is that CIM\_ComputerSystem class was used as the initial template for creating the CIM\_UnitaryComputerSystem class.

    That means that PG\_ComputerSystem indirectly inherits from CIM\_ComputerSystem and by enabling DeepInheritance we can see this relationship by using the EnumerateClassNames method on the CIM\_ComputerSystem class; however without DeepInheritance enabled we can not.

    The great thing about this is it works for standard CIM, SMI-S, WMI, WMWare, etc.. Any standard or API based on CIM is structured in this manner so the class name discovery process works the same way for all of them.

- See DSP0200 Version 1.3.1 section 5.3.2.10 for details

### __EnumerateInstances()__

    $query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 }, ['property1','property2']);
    $query->EnumerateInstances('name/space','ClassName',{ }, ['property1','property2']);
    $query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 });
    $query->EnumerateInstances('name/space','ClassName');

The EnumerateInstances method returns the content of every instance of the CIM class specified in the ClassName and all of the sub classes that it inherits fields from within the namespace specified in the name/space field.

The LCP::Query's EnumerateClassNames method requires 2 fields and has 2 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace from which you want to enumerate the instances of the class.

    This field is required

- 2 __ClassName__

    The name of the CIM class you want to enumerate the instances of.

    This field is required.

    If you don't wish to specify a value but wish to specify a latter field next field you may leave it empty or set it to 'NULL'

- 3 __Query Modifiers__

    An optional hash reference containing any combination of the following query modifiers.

    If you wish to use the defaults for the modifiers and want to specify a latter field you may define the field as {}

    - __LocalOnly__

            'LocalOnly'=>1, # True
            'LocalOnly'=>0, # False

        If set to 1 (True) the behavior varies base on which version of the standard the WBEM server supports.

        In versions prior to 1.1 of the standard this modifier to 1 (True) returns only the elements that differ from the defaults of the class or differ from the defaults of the parent classes for elements which are inherited from other classes.

        In version 1.1 or higher of the standard setting this modifier to 1 (True) only returns the elements in each instance that are different from the defaults for class will be returned but not any elements inherited from a parent class unless their defaults in the class you are querying differ from the parent class. Any elements of each instance that have been altered which were inherited from the parent class are not included in the results.

        If set to 0 (False) all elements of each instance except those filtered out by other options will be returned.

        __WARNING: This modifier is deprecated in the standard for the EnumerateInstances method and will be removed from a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), furthermore some WBEM servers now ignore this modifier and act as though it set to 0 (False) regardless of what you set it to .__

        See DSP0200 Version 1.3.1 section ANNEX B "LocalOnly Parameter Discussion" for details on why this modifier was deprecated

        Defaults to 1 (True)

    - __DeepInheritance__

            'DeepInheritance'=>1, # True
            'DeepInheritance'=>0, # False

        If set to 1 (True) then all instances of the CIM class specified in the ClassName properties, and all of the instances of CIM classes that inherit field directly or indirectly from the CIM class specified

        If set to 0 (False) the only instances of the CIM class specified in the ClassName and any CIM classes that directly inherit from it.

        Defaults to 1 (True)

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1, # True
            'IncludeQualifiers'=>0, # False

        If set to 1 (True) the qualifiers for each instance will be returned in the results.

        If set to 0 (False) no qualifiers will be included in the results.

        __WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), in addition WBEM servers are no longer required to honer it if you set it to 1 (True). The preferred method to get the qualifiers is to use the GetClass method instead.__

        Defaults to 0 (False)

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>1, # True
            'IncludeClassOrigin'=>0, # False

        If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element describing which class it was inherited from.

        If set to 0 (False) the no CLASSORIGIN tags will be included.

        Defaults to 0 (False)

- 4 __Property List__

    An array reference containing a list of the specific elements of the instances you want to return, all other elements will not be included in the results.

- __Implementation Note:__



- See DSP0200 Version 1.3.1 section 5.3.2.11 for details

### __EnumerateInstanceNames()__

    query-> EnumerateInstanceNames ('name/space','ClassName');

The LCP::Query's EnumerateClassNames method requires 2 fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to enumerate the instances name of the classes from

    This field is required

- 2 __ClassName__

    The name of the CIM class you want to enumerate the instance names of.

    This field is required.

- See DSP0200 Version 1.3.1 section 5.3.2.12 for details

### __ExecQuery()__

- Not implemented yet

### __Associators()__

    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{ }, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole');
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass',);
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

The Associators operation enumerates CIM objects (classes or instances) associated with a particular source CIM class or instance.

The LCP::Query's Associators method requires 2 fields and has 7 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to enumerate the class instances from

    This field is required

- 2 __ClassName__

    The name of the CIM class for which you want enumerate the CIM classes or instances which are associated to the CIM class specified here.

    This field is required.

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

    This field is optional and may be left blank

- 4 __AssocClass__

    The name of a CIM class for which the resulting enumerated classes must be associated to the original CIM class or instance of the CIM Class associated via the CIM class specified here or one of its subclasses.

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 5 __ResultClass__

    The name of a CIM class for which the resulting enumerated CIM classes must be an instance of the CIM class named here or a class that immediately inherits from it.

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 6 __Role__

    The name of a property in the source CIM class that is the source of the association between the source class or instance and the resulting enumerated instances.

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 7 __Result Role__

    The name of a property in the resulting CIM class instances that is the source of the association between the source class or instance and the resulting enumerated instances

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 8 __Query Modifiers__

    A hash reference containing any combination of the following query modifiers.

    This field is optional and may be left blank

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1, # True
            'IncludeQualifiers'=>0, # False

        If set to 1 (True) all of the elements which were inherited from a parent class will include an QUALIFIER the field.

        If set to 0 (False) the no Qualifiers will be included.

        __WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), in addition WBEM servers are no longer required to honer it if you set it to 1 (True). The preferred method to get the qualifiers is to use the GetClass method instead.__

        Defaults to 0 (False)

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>1, # True
            'IncludeClassOrigin'=>0, # False

        If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element describing which class it was inherited from.

        If set to 0 (False) the no CLASSORIGIN elements will be included.

        Defaults to 0 (False)

- 9 __Property List__

    An optional array reference containing a list of the specific properties of the enumerated instances you want to get.

- See DSP0200 Version 1.3.1 section 5.3.2.14 for details

### __AssociatorNames()__

    $query->AssociatorNames('name/space','ClassName', {} , 'AssocClass', 'ResultClass', 'Role','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'NULL', 'NULL','NULL');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'AssocClass', 'NULL', 'Role','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass', 'NULL','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, '', 'ResultClass', '','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format);

The AssociatorNames operation enumerates the names of CIM objects (classes or instances) associated with a particular source CIM class or instance. 

The LCP::Query's AssociatorNames method requires 2 fields and has 5 optional fields described as follows.

- 1 __name/space__

    The CIM namespace you want to enumerate the classes or instances from

    This field is required

- 2 __ClassName__

    The name of the CIM class for which you want enumerate the names of CIM classes or instances which are associated to the CIM class specified here.

    This field is required.

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

    This field is optional and may be left blank

- 4 __AssocClass__

    The name of a class for which the resulting enumerated classes must be associated to the original CIM class or instance of the CIM Class via the CIM class specified here or a sub class of the CIM class specified here.

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 5 __ResultClass__

    The name of a class for which the resulting enumerated classes must be an instance of the CIM class named here or one of its sub classes

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 6 __Role__

    The name of a property in the source CIM class that is the source of the association between the source class or instance and the resulting enumerated instances

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 7 __Result Role__

    The name of a property in the resulting CIM class instances that is the source of the association between the source class or instance and the resulting enumerated instances

    This field is optional and may be left blank or explicitly specified as 'NULL'

- See DSP0200 Version 1.3.1 section 5.3.2.15 for details

### __References()__

    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{ }, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role');
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );

References enumerates the instances or CIM classes that reference a a specific CIM class or instance

The LCP::Query's References method requires 2 fields and has 5 optional fields described as follows.

&#10;

- 1 __name/space__

    The CIM namespace you want to enumerate the classes or instances from

    This field is required

- 2 __ClassName__

    The name of the CIM class that the classes you want to enumerate reference

    This field is required.

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

    This field is optional and may be left blank

- 4 __ResultClass__

    The name of a class for which the resulting enumerated classes must be an instance of the CIM class named here or one of its sub classes

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 5 __Role__

    The name of a property in the CIM class named in the ClassName field that is the source of the association between the source class or instance and the resulting enumerated instances

    This field is optional and may be left blank or explicitly specified as 'NULL'

- 6 __Query Modifiers__

    A hash reference containing any combination of the following query modifiers.

    This field is optional and may be left blank

    - __IncludeQualifiers__

            'IncludeQualifiers'=>1, # True
            'IncludeQualifiers'=>0, # False

        If set to 1 (True) the qualifiers for each property in each instance will be returned in the results.

        If set to 0 (False) no qualifiers will be included in the results.

        __WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), in addition WBEM servers are no longer required to honer it if you set it to 1 (True). The preferred method to get the qualifiers is to use the GetClass method instead.__

        Defaults to 0 (False)

    - __IncludeClassOrigin__

            'IncludeClassOrigin'=>1, # True
            'IncludeClassOrigin'=>0, # False

        If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN property describing which class it was inherited from.

        If set to 0 (False) the no CLASSORIGIN properties will be included.

        Defaults to 0 (False)

    - __Property List__

        An optional array reference containing a list of the specific properties of the enumerated instances you want to get

- See DSP0200 Version 1.3.1 section 5.3.2.16 for details

### __ReferenceNames()__

- Not implemented yet

### __GetProperty()__

    $query->GetProperty ( 'name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'PropertyName');

GetProperty returns only a specific property from an instance of a class

The LCP::Query's GetProperty method requires 4 fields fields described as follows.

&#10;

- 1 __name/space__

    A string containing the namespace that the instance of the class can be found in a common example is 'root/cimv2' or 'root/interop'

- 2 __ClassName__

    A string containing the name of the CIM class you want to query the property from.

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

- 4 __PropertyName__

    The name of the property you wish to extract.

- __Implementation Note:__

    All examples below were produced using TOG-OpenPegasus with SBLIM on Fedora Linux 16

    - Lets say I wat to get just the ElementName property from an instance of Linux\_OperatingSystem Class

        This is exactly what the GetProperty class is meant for. Assuming the hostname for the box I want the information from is myhost and ive already gotten the instance name via an other method here are the fielda in the name

        CSCreationClassName = "Linux\_ComputerSystem"
        CSName = "myhost"
        Name = "myhost"
        CreationClassName = "Linux\_OperatingSystem"

        Here is the query I would run.

            $query->GetProperty('root/cimv2','Linux_OperatingSystem',{CSCreationClassName=>"Linux_ComputerSystem",CSName=>"myhost",Name=>"myhost",CreationClassName=>"Linux_OperatingSystem"},'ElementName');

        Notice the instansce name is just a simple hash refference which represents a keybinding the order of the keys themselves is not important just that they are all there and populated with the apropriate information.

        Once I post the quety via LCP::Post and parse the rsults via LCP::SimpleParser the result is a data structure which looks like this

            $VAR1 = {
                'CIM' => {
                    'CIMVERSION' => '2.0',
                    'MESSAGE' => {
                        'SIMPLERSP' => {
                            'GetProperty' => {
                                'NAME' => 'GetProperty',
                                'IRETURNVALUE' => 'Fedora release 16 (Verne)'
                            }
                        },
                        'ID' => '18267',
                        'PROTOCOLVERSION' => '1.0'
                    },
                    'DTDVERSION' => '2.0'
                }
            };



    - See DSP0200 Version 1.3.1 section 5.3.2.18 for details

### __SetProperty()__

    $query->SetProperty('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'PropertyName','VALUE');

SetProperty allows you to set the value of a specific property in an instance of a CIM class.

The LCP::Query's SetProperty method requires 5 fields fields described as follows.

&#10;

- 1 __name/space__

    A string containing the namespace that the instance of the class can be found in a common example is 'root/cimv2' or 'root/interop'

- 2 __ClassName__

    A string containing the name of the CIM class of the instance you wish to modify.

- 3 __InstanceName__

    A hash or array reference matching a valid keybinding format which describes the instance of the class you want to modify. Please see the Keybinding field format described in the "Specially Formatted Fields" section.

- 4 __PropertyName__

    The name of the property you wish to modify.

- 5 __VALUE__

    The new value for the property.

- See DSP0200 Version 1.3.1 section 5.3.2.19 for details

### __GetQualifier()__

- Not implemented yet

### __SetQualifier()__

- Not implemented yet

### __DeleteQualifier()__

- Not implemented yet

# SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

# AUTHOR

Paul Robert Marino, <code@TheMarino.net>

# COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


