package LCP::SimpleParser;
use strict;
use warnings;
use XML::Twig;
use Carp;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


sub new{
	my $class=shift;
	my $xml=shift;
        my $parseoptions=shift;
	my $self;
        my $defaultoptions={
          'strict_dtd'=>0,
          'workaround_known_server_bugs'=>1,
          'filter_type_fields'=>1,
          'include_name'=>0
          
        };
        unless (defined $xml and $xml and $xml!~/^\s*$/m){
            carp "No XML to parse\n";
            return 0;
        }
	# there is an issue with the dtds right now so until XML::Parser is patched to fix it im going to skip the dtd
	#$self->{'twig'}=XML::Twig->new('load_DTD'=>1);
	$self->{'twig'}=XML::Twig->new();
	$self->{'twig'}->parse($xml);
	$self->{'root'}=$self->{'twig'}->root;
	unless($self->{'root'}->children_count){
		croak "could not parse xml\n";
	}
	bless ($self, $class);
	return $self;
}


sub buildtree{
	my $self=shift;
        my $srctree=shift;
        my $tree=0;
        if (defined $srctree){
            $tree=$srctree
        }
        else{
            $tree=$self->{'root'}
        }
        my $children=$tree->children_count;
        #my $path=$tree->path;
        my $lname=$self->get_field_name($tree);
        my $hashtree;
        #print "$path has $childcount branches and its local name is $lname\n";
        for my $key (%{$tree->{'att'}}){
                if ($tree->{'att'}->{$key}){
                        #print "$path $lname $key = $tree->{att}->{$key}\n";
			#unless ($key=~/^(NAME|TYPE)$/o){
                        	$hashtree->{$lname}->{$key}=$tree->{att}->{$key};
			#}
                }
        }
        if ($tree->is_text){
                my $string=$tree->text;
                #print "$path $lname valus is \"$string\"\n";
                $hashtree->{$self->get_field_name($tree)}=$string;
        }
        if ($children){
                my @props;
                my @proparrays;
                my @keybindings;
                for my $branch($tree->children){
			my $branchname=$self->get_field_name($branch);
			my $rawbranchname=$branch->local_name;
                        if ($rawbranchname =~ /^PROPERTY$/o and $branch->has_children){
                                $hashtree->{$lname}->{$branchname}=$self->property_twig($branch);
                        }
                        elsif($rawbranchname =~ /^KEYBINDING$/o){
                                $hashtree->{$lname}->{$branchname}=$self->get_cim_keybinding_value($branch);
                        }
                       
                        elsif($rawbranchname =~ /^#P?CDATA$/o){
                                $hashtree->{$lname}=$branch->text;
                        }
                        elsif($rawbranchname =~ /^LOCALNAMESPACEPATH$/o){
                                $hashtree->{$lname}->{$branchname}=$self->get_local_namespace_path($branch);
                        }
			elsif($rawbranchname =~ /^VALUE.ARRAY$/o){
				$hashtree->{$lname}=$self->cim_value_array($branch);
			}
			elsif($rawbranchname =~ /^VALUE$/o){
				$hashtree->{$lname}=$self->cim_value($branch);
			}
                        else{
                                unless ($hashtree->{$lname}){
                                        $hashtree->{$lname}=$self->buildtree($branch);
                                }
                                else{
                                        my $temphash=$self->buildtree($branch);
                                        my $conflict=0;
                                        if (ref $hashtree->{$lname} eq 'ARRAY'){
                                                $conflict++;
                                        }
                                        else{
                                                for my $key (keys %{$temphash}){
                                                        if (defined $hashtree->{$lname}->{$key}){
                                                                $conflict++;
                                                        }
                                                }
                                        }
                                        unless($conflict){
                                                for my $key (keys %{$temphash}){
                                                        $hashtree->{$lname}->{$key}=$temphash->{$key};
                                                }
                                        }
                                        else{
                                                for my $key (keys %{$temphash}){
                                                        if(ref $hashtree->{$lname}->{$key} eq 'ARRAY'){
                                                                push(@{$hashtree->{$lname}->{$key}},$temphash->{$key});
                                                        }
                                                        else{
                                                                my $tempref=$hashtree->{$lname}->{$key};
                                                                delete $hashtree->{$lname}->{$key};
                                                                push(@{$hashtree->{$lname}->{$key}},$tempref,$temphash->{$key});
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
        $self->{'twig'}->purge_up_to($tree);
        return $hashtree;
}

sub get_field_name{
    my $self=shift;
    my $field=shift;
    # checking if the NAME attibute exists
    if (defined $field->{'att'}->{'NAME'}){
        # returning the name
        return $field->{'att'}->{'NAME'}
    }
    # if its not defined return the xml tag as the name
    else{
        # returning the xml tag
        return $field->local_name;
    }
}


sub property_twig{
	my $self=shift;
        my $property=shift;
        my $propertyhash;
        if ($property->local_name eq 'PROPERTY'){
                my $value=$property->{'first_child'};
                my $valuetext;
                if ($value){
                        $valuetext=$value->text;
                }
		
                $self->{'twig'}->purge_up_to($property);
                return $valuetext;
        }
        else{
                return  "Error unknown the field was expaected to be a Property field but was not\n";
        }

}


sub property_array_twig{
        my $self=shift;
        my $property_array=shift;
        # defineing a placeholder for the results
        my $resultarray;
        # getting the array of values
        my $valuearray=$property_array->{'first_child'};
        # only process if the value array is valid
        if (defined $valuearray){
            $resultarray=$self->cim_value_array($valuearray);
        }
        # cleaning up the ram used be the property arraythat has already been processed
        $self->{'twig'}->purge_up_to($property_array);
        
        return $resultarray;
}

sub cim_value{
	my $self=shift;
	my $property=shift;
        # getting the value tag
	my $value=$property->{'first_child'};
        # only process if the value tag exists
        if (defined $value){
            # returning the text contents
            return $value->text;
        }
        else{
            # warn the user if there is an error
            carp "cim property undefined\n";
        }
}

sub cim_value_array{
	my $self=shift;
	my $property=shift;
	my $resultarray;
	my $value=$property->{'first_child'};
        # only continue processing if the content is valid
        if(defined $value){
            # starting loop to put every value from the value array into the result array in sequence
            while ($value){
                # tacking the current value into the result array
                push(@{$resultarray},$value->text);
                # getting the next value
                $value=$value->{'next_sibling'};
            }
        }
        else{
            carp"invalid value array\n";
        }
        $self->{'twig'}->purge_up_to($property);
	return $resultarray;
}

sub get_cim_keybinding_value{
    my $self=shift;
    my $property=shift;
    my $property_value=$property->{'first_child'};
    $property_value= $property_value->{'first_child'};
    my $value;
    if ($property_value->is_text){
        $value=$property_value->text;
        $self->{'twig'}->purge_up_to($property);
        return $value;
    }
    else{carp $property->local_name .' '.  $self->get_field_name($property) .' '. $property_value->local_name. " does not apear to have a value\n";}
}


sub get_local_namespace_path{
        my $self=shift;
        my $property=shift;
        my @namespacearray;
        my $value=$property->{'first_child'};
        while ($value){
                push(@namespacearray,$self->get_field_name($value));
                $value=$value->{'next_sibling'};
        }
        my $namespace=join('/',@namespacearray);
        $self->{'twig'}->purge_up_to($property);
        return $namespace;

}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::SimpleParser - Lib CIM (Common Information Model) Perl Simple Parser

=head1 SYNOPSIS

  use LCP;
  
  

=head1 DESCRIPTION



=head2 EXPORT

This is an OO Class and as such exports nothing.



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
