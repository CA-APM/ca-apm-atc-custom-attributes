use REST::Client;
use Config::Properties;
use JSON;
use Data::Dumper;

my $properties;
my $rest_client;
my @keys;

#
# read properties
#
sub read_properties {
    open my $fh, '<', 'config.ini'
        or die "unable to open configuration file";

    $properties = Config::Properties->new();
    $properties->load($fh);
}

sub init_restapi() {
    my $client = REST::Client->new();
    $client->addHeader('Content-type', 'application/hal+json;charset=utf-8');
    $client->addHeader('Authorization', 'Bearer '
        + $properties->getProperty('auth_token'));
}


sub read_csv {

    my $file = $properties->getProperty('file_path') or die "Need to get CSV file in config.ini\n";

    #print "opening $file\n";

    open(my $data, '<', $file) or die "Could not open '$file' $!\n";

    my $line = <$data>;
    chomp $line;
    @keys = split "," , $line;

    my $key_column = $properties->getProperty('key_column');
    #print "key column = $key_column, keys = \n" . Dumper(@keys);

    my $i = 0;
    for my $key (@keys) {
        if ($key eq $key_column) {
            splice(@keys, $i, 1);
            last;
        } else {
            $i = $i + 1;
        }
    }

    #print "attribute names: matching key = $key_column, index = $i,\n" . Dumper(@keys);

    my %result;
    while ($line = <$data>) {
        my @attributes;
        #print "read line = $line";
        chomp $line;
        push (@attributes, split("," , $line));
        my $key = $attributes[$i];
        splice(@attributes, $i, 1);
        #print "key = $key,\n" . Dumper(@attributes);
        $result{$key} = \@attributes;
    }
    return \%result;
}


sub get_vertex_map {
    my @hostnames = @_;
    my $values = '';
    for my $host (@hostnames) {
        $values = $values . '"' . $host . '",';
    }
    chop $values; # remove last ','

    my $body = '{ '
        . '      "includeStartPoint": false,'
        . '      "outputLayer": "ATC",'
        . '        "orItems": [{'
        . '          "andItems": [{'
        . '                "itemType": "attributeFilter",'
        . '                             "attributeName": "hostname",'
        . '                "attributeOperator": "IN",'
        . '                "values": ['     . $values . '],'
        . '        "layer": "ATC"'
        . '    }]'
        . '}]'
        . '}';

    $client->POST($properties->getProperty('rest_url'));
    if( $client->responseCode() ne '200' ){
        die $client->responseContent();
    }

    return decode_json($client->responseContent());
}

sub get_vertex_map_from_file {
    my $filename = shift;
    my $json_text = do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open \$filename\": $!\n");
       local $/;
       <$json_fh>
    };

    my $json = JSON->new;
    return $json->decode($json_text);
}

sub update_vertex {
    my ($vertex_ref, $key_ref, $attr_ref) = @_;
    my %vertex = %$vertex_ref;
    my @keys = @$key_ref;
    my @attributes = @attr_ref;

    my $url = $properties->getProperty('rest_url') + $vertex_id;
}


#
# main program
#

# initialize
read_properties();
init_restapi();

# read csv
my $attributes = read_csv();
#print Dumper %$attributes;

# read vertices
#my $vertex_map_ref = get_vertex_map(@hostnames);
my $vertex_map_ref = get_vertex_map_from_file('hostnames.json');
#print Dumper $vertex_map_ref;
my %embedded = %$vertex_map_ref;
my @vertex_list = @{$embedded{'_embedded'}{'vertex'}};

#print Dumper @vertex_list;

#create json
my @items;
for my $vertex_ref (@vertex_list) {
    my %vertex = %$vertex_ref;
    my %update;
    $update{'layer'} = $vertex{'layer'};
    $update{'id'} = $vertex{'id'};

    my $hostname = $vertex{'attributes'}{'hostname'}[0];
    #print "id = $vertex{'id'}, hostname = $hostname\n";
    #print Dumper $attributes{$hostname};
    my $i=0;
    for $attr (@{$attributes->{$hostname}}) {
        my @array;
        push @array, $attr;
        $update{'attributes'}{$keys[$i]} = \@array;
        $i = $i + 1;
    }
    push @items, \%update;
}

my %patch;
$patch{'items'} = \@items;
my $json = JSON->new;
print $json->encode(\%patch) . "\n";
#update_Vertex(\%vertex, \@keys, \@attributes);
