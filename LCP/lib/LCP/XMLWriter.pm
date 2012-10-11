package LCP::XMLWriter;
use strict;
use warnings;
use Carp;
use XML::Twig;


our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


sub new {
    my $class = shift;
    my $id=shift;
    my $self = bless {
        'twig' => XML::Twig->new(),
        'query' => [],
        'id' => $id,
        'xml' => '',
        'root' => ''
    }, $class;
}

sub set_query_id($$){
    my $self=shift;
    my $id=shift;
    if($id=~/\d+/){
        if ($id lt 65536){
            $self->{'id'}=$id;
        }
    }
    
}

sub addquery{
    my $self=shift;
    my $query=shift;
    push(@{$self->{'query'}},$query);
}

sub mkiparam($$;$){
    my $self=shift;
    my $name=shift;
    my $value=shift;
    my $param=XML::Twig::Elt->new('IPARAMVALUE'=>{'NAME'=>$name});
    if (defined $value){
        my $val=XML::Twig::Elt->new('VALUE'=>$value);
        $val->paste($param);
    }
    return $param;
}

sub mkmethodcall($$){
    my $self=shift;
    my $type=shift;
    my $method=XML::Twig::Elt->new('IMETHODCALL',{'NAME' => $type});
    return $method;
}



# replaced mknamespacexml
# requieres 1 argument the CIM name space for example root/lsiarray13
# returns an xml twig element for the formated namespace
# example
# my $namespace=mknamespace('root/lsiarray13');

sub mknamespace{
    my $self=shift;
    my $namespaceraw=shift;
    my @namearray=split('/',$namespaceraw);
    my $namespace= XML::Twig::Elt->new('LOCALNAMESPACEPATH');
    for my $name (@namearray){
        my $xmlname= XML::Twig::Elt->new('NAMESPACE'=>{'NAME'=>$name});
        $xmlname->paste( last_child => $namespace);
    }
    return $namespace;
}

sub mkkeybinding{
    my $self=shift;
    my $hash=shift;
    my @keybindings;
    for my $key (keys %{$hash}){
        my $keybinding=XML::Twig::Elt->new('KEYBINDING'=>{'NAME'=>$key});
        #$newkey->set_att('NAME'=>$key);
        my $keyvalue=XML::Twig::Elt->new('KEYVALUE'=>{'VALUETYPE'=>'string'},$hash->{$key});
        $keyvalue->paste( last_child => $keybinding);
        push(@keybindings,$keybinding);
    }
    return @keybindings;
}


sub mkbool{
    my $self=shift;
    my $hash=shift;
    my @params;
    for my $key (keys %{$hash}){
        if ($hash->{$key}){
            my $param=XML::Twig::Elt->new('IPARAMVALUE'=>{'NAME'=>$key});
            my $value=XML::Twig::Elt->new('VALUE'=>'TRUE');
            $value->paste( last_child => $param);
            push(@params,$param);
        }
        else{
            my $param=XML::Twig::Elt->new('IPARAMVALUE'=>{'NAME'=>$key});
            my $value=XML::Twig::Elt->new('VALUE'=>'FALSE');
            $value->paste( last_child => $param);
            push(@params,$param);
        }
    }
    return @params;
}

sub mkproperty($$;$$){
    my $self=shift;
    my $name=shift;
    my $value=shift;
    my $type=shift;
    unless(defined $type){
        $type='string';
    }
    my $param=XML::Twig::Elt->new('PROPERTY'=>{'NAME'=>$name,'TYPE'=>$type});
    if (defined $value){
        my $val=XML::Twig::Elt->new('VALUE'=>$value);
        $val->paste($param);
    }
    return $param;
}

sub mkpropertylist{
    my $self=shift;
    my $array=shift;
    my $param=XML::Twig::Elt->new('IPARAMVALUE'=>{'NAME'=>'PropertyList'});
    my $valuearray=XML::Twig::Elt->new('VALUE.ARRAY');
    $valuearray->paste( last_child => $param);
    for my $item (@{$array}){
        my $value=XML::Twig::Elt->new('VALUE'=> $item);
        $value->paste( 'last_child'=>$valuearray)
    }
    return $param;
}

sub mkclassname{
    my $self=shift;
    my $rawclassname=shift;
    my $param=$self->mkiparam('ClassName');
    my $classname=XML::Twig::Elt->new('CLASSNAME'=>{'NAME'=>$rawclassname});
    $classname->paste($param);
    return $param;
}

sub mkobjectname{
    my $self=shift;
    my $rawclassname=shift;
    my $value=shift;
    my $param=$self->mkiparam('ObjectName');
    my $classname=XML::Twig::Elt->new('INSTANCENAME'=>{'CLASSNAME'=>$rawclassname});
    $classname->paste('last_child'=>$param);
    if ($value){
        $value->paste('last_child'=>$classname);
    }
    return $param;
}

sub mkinstancename{
    my $self=shift;
    my $rawclassname=shift;
    my $value=shift;
    my $param=$self->mkiparam('InstanceName');
    my $classname=XML::Twig::Elt->new('INSTANCENAME'=>{'CLASSNAME'=>$rawclassname});
    $classname->paste('last_child'=>$param);
    if ($value){
        if (ref($value) eq 'ARRAY'){
            for my $val (@{$value}){
                $val->paste('last_child'=>$classname);
            }
        }
        else{
            $value->paste('last_child'=>$classname);
        }
    }
    return $param;
}

sub mkassocclass{
    my $self=shift;
    my $rawclassname=shift;
    my $param=$self->mkiparam('AssocClass');
    my $classname=XML::Twig::Elt->new('CLASSNAME'=>{'NAME'=>$rawclassname});
    $classname->paste($param);
    return $param;
}

sub mkresultclass{
    my $self=shift;
    my $rawclassname=shift;
    my $param=$self->mkiparam('ResultClass');
    my $classname=XML::Twig::Elt->new('CLASSNAME'=>{'NAME'=>$rawclassname});
    $classname->paste($param);
    return $param;
}

sub mkrole{
    my $self=shift;
    my $value=shift;
    my $param=$self->mkiparam('Role');
    my $classname=XML::Twig::Elt->new('VALUE'=>$value);
    $classname->paste($param);
    return $param;
}

sub mkresultrole{
    my $self=shift;
    my $value=shift;
    my $param=$self->mkiparam('ResultRole');
    my $classname=XML::Twig::Elt->new('VALUE'=>$value);
    $classname->paste($param);
    return $param;
}

sub mkpropertyname{
    my $self=shift;
    my $value=shift;
    my $param=$self->mkiparam('PropertyName');
    my $classname=XML::Twig::Elt->new('VALUE'=>$value);
    $classname->paste($param);
    return $param;
}

sub mkpropertyvalue{
    my $self=shift;
    my $value=shift;
    my $param=$self->mkiparam('NewValue');
    my $classname=XML::Twig::Elt->new('VALUE'=>$value);
    $classname->paste($param);
    return $param;
}

sub mknewinstance($$\%){
    my $self=shift;
    my $class=shift;
    my $params=shift;
    my $newinstance=$self->mkiparam('NewInstance');
    my $classname=XML::Twig::Elt->new('INSTANCE',{'CLASSNAME' => $class});
    $classname->paste('last_child' => $newinstance);
    for my $propname (keys %{$params}){
        my $prop=$self->mkproperty($propname,$params->{$propname},'string');
        $prop->paste('last_child' => $classname);
    }
    return $newinstance;
}

sub generatetree{
    my $self=shift;
    my $messageid=shift;
    unless (defined $messageid and $messageid=~/^\d+$/){
        if (defined $messageid){
            carp "Invalid message id \"$messageid\"\n";
            return 0;
        }
        elsif(defined $self->{'id'} and $self->{'id'}=~/^\d+$/ ){
            $messageid=$self->{'id'};
        }
        else {
            $messageid=int(rand(65536));
        }
    }
    unless(@{$self->{'query'}}){
        carp "No CIM query defined\n";
        return 0;
    }
    $self->{'twig'}->purge;
    #$self->{'root'}=$self->{'twig'}->root;
    my $root=XML::Twig::Elt->new('CIM'=>{'CIMVERSION'=> '2.0', 'DTDVERSION' => '2.0'});
    #$root->paste( 'last_child' => $self->{'root'});
    $self->{'twig'}->set_root($root);
    $self->{'twig'}->set_xml_version('1.0');
    $self->{'twig'}->set_encoding('utf-8');
    my $message=XML::Twig::Elt->new('MESSAGE' => {'ID' => $messageid, 'PROTOCOLVERSION' => '1.0'});
    $message->paste('last_child' => $root);
    my $multireq=0;
    if (@{$self->{'query'}} > 1){
        $multireq=XML::Twig::Elt->new('MULTIREQ');
        $multireq->paste( 'first_child' => $message);
    }
    for my $rawquery (@{$self->{'query'}}){
        my $request=XML::Twig::Elt->new('SIMPLEREQ');
        if ($multireq){
            $request->paste( 'first_child' => $multireq);
        }
        else{
            $request->paste( 'first_child' => $message);
        }
        #if (defined $pointers->{$rawquery->{'type'}}){
            #print "$rawquery->{'namespace'}\n";
            #my $query=&$pointers->{$rawquery->{'type'}}->($rawquery);
            #my $query=$self->"$rawquery->{'type'}"($rawquery);
            $rawquery->paste('last_child' => $request);
        #}
        #else {carp "$rawquery->{'type'} not implemented\n";}
    }
}

sub extractxml{
    my $self=shift;
    $self->generatetree;
    my $xml=$self->{'twig'}->sprint;
}



1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::XMLWriter - Lib CIM (Common Information Model) Perl XML Writer

=head1 SYNOPSIS

  use LCP::XMLWriter;
  

=head1 DESCRIPTION

This is a helper class to create XML messages to query an WBEM
provider. This class is not meant to be used by the LCP::Post class
after a query has been created by the LCP::Query class. 


=head2 EXPORT

This is an OO Class and as such exports nothing



=head1 SEE ALSO

Please See DSP0200, DSP0201, DSP0203 from DMTF for details

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
