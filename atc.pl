use REST::Client;
use Config::Properties;
use JSON;
use Data::Dumper;

my $properties;
my $rest_client;
my @keys;
my $debug = 0;
my $client;
my $log;

#
# read properties
#
sub read_properties {
    print "opening config.ini\n" if ($debug > 0);
   
    open my $fh, '<', 'config.ini'
        or die "unable to open configuration file";

    $properties = Config::Properties->new();
    $properties->load($fh);
	
	# set debug level and open log file
	$debug = $properties->getProperty('debug', 1);
	my $logfile = $properties->getProperty('output_file_path', 'atc.log');
	open($log, '>', $logfile);
	print "logging to $logfile\n" if ($debug > 0);
	print $log "finished reading properties\n\n" if ($debug > 0);
}

sub init_restapi() {
    $client = REST::Client->new();
    $client->addHeader('Content-type', 'application/hal+json;charset=utf-8');
    $client->addHeader('Authorization', 'Bearer '
        . $properties->getProperty('auth_token'));
}


sub read_csv {

    my $file = $properties->getProperty('file_path') or die "Need to get CSV file in config.ini\n";

    print $log "opening $file\n" if ($debug > 0);

    open(my $data, '<', $file) or die "Could not open '$file' $!\n";

    my $line = <$data>;
    while ($line =~ /[\n\r]$/) { chop $line; }
    @keys = split /,/, $line;

    my $key_column = $properties->getProperty('key_column');
    print $log "key column = $key_column, keys = \n" . Dumper(@keys) if ($debug > 1);

    my $i = 0;
    for my $key (@keys) {
        if ($key eq $key_column) {
            splice(@keys, $i, 1);
            last;
        } else {
            $i = $i + 1;
        }
    }

    print $log "attribute names: matching key = $key_column, index = $i,\n" . Dumper(@keys) if ($debug > 1);

    my %result;
    while ($line = <$data>) {
        print $log "read line = $line" if ($debug > 1);
		while ($line =~ /[\n\r]$/) { chop $line; }
        my @attributes = split /,/, $line;
        my $key = $attributes[$i];
        splice(@attributes, $i, 1);
        print $log "key = $key,\n" . Dumper(@attributes) if ($debug > 1);
        $result{$key} = \@attributes;
    }
    print $log "read ". keys(%result) . " entries from $file\n\n" if ($debug > 0);

    return \%result;
}


sub get_vertex_map {
    print $log "retrieving vertices from APM Teamcenter\n" if ($debug > 0);

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

    print $log "posting to APM Teamcenter " . $properties->getProperty('rest_url') . "\n" if ($debug > 0);

    $client->POST($properties->getProperty('rest_url'), $body);
    if( $client->responseCode() ne '200' ) {
		print $log $client->responseCode() . "\n" . $client->responseContent() . "\n";
        die $client->responseContent();
    }

	print $log "finished retrieving vertices from APM Teamcenter\n\n" if ($debug > 0);

    return decode_json($client->responseContent());
}

sub get_vertex_map_from_file {
    my $filename = shift;

    print $log "reading vertices from file $filename\n" if ($debug > 0);

    my $json_text = do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open \$filename\": $!\n");
       local $/;
       <$json_fh>
    };

	print $log "finished reading vertices from file $filename\n" if ($debug > 0);

    return decode_json($json_text);
}

#
# not used
#

sub update_vertex {
    my ($vertex_ref, $key_ref, $attr_ref) = @_;

	print $log "updating vertex in APM Teamcenter\n" if ($debug > 0);

    my %vertex = %$vertex_ref;
    my @keys = @$key_ref;
    my @attributes = @attr_ref;

    my $url = $properties->getProperty('rest_url') + $vertex_id;

	# TODO finish http PATCH
	print $log "finished updating vertex in APM Teamcenter\n" if ($debug > 0);

}

sub update_vertex_map {
    my ($vertex_list_ref, $attr_ref) = @_;
	my @vertex_list = @$vertex_list_ref;
    my %attributes = %$attr_ref;
	my @items;

	print $log "creating json for Teamcenter update\n" if ($debug > 0);

	for my $vertex_ref (@vertex_list) {
		my %vertex = %$vertex_ref;
		my %update;
		$update{'layer'} = $vertex{'layer'};
		$update{'id'} = $vertex{'id'};

		my $hostname = $vertex{'attributes'}{'hostname'}[0];
		print $log "id = $vertex{'id'}, hostname = $hostname\n" if ($debug > 2);
		print $log Dumper $attributes{$hostname} if ($debug > 2);
		my $i=0;
		my @test = @{$attributes{$hostname}};
		print $log Dumper \@test if ($debug > 2);
		
		for my $attr (@{$attributes{$hostname}}) {
			print $log "adding attribute " . $keys[$i] . " = $attr\n" if ($debug > 2);
			my @array;
			push @array, $attr;
			$update{'attributes'}{$keys[$i]} = \@array;
			$i = $i + 1;
			print $log Dumper %update if ($debug > 2);
		
		}
		push @items, \%update;
	}

	my %patch;
	$patch{'items'} = \@items;
	my $json = encode_json(\%patch);
	
	print $log "finished creating json for Teamcenter update\n\n" if ($debug > 0);
	print $log $json. "\n" if ($debug > 1);
	print $log "updating vertices in APM Teamcenter\n" if ($debug > 0);
	
	$client->PATCH($properties->getProperty('rest_url'), $json);
   
    if ($client->responseCode() ne '200') {
        die $client->responseContent();
    }
	print $log "finished updating " . @items . " vertices in APM Teamcenter\n\n" if ($debug > 0);
}

#
# main program
#

# initialize
read_properties();
init_restapi();

# read csv
my $attributes = read_csv();
print $log Dumper %$attributes if ($debug > 1);

my @hostnames = keys %$attributes;
print $log Dumper @hostnames if ($debug > 1);

# read vertices
my $vertex_map_ref = get_vertex_map(@hostnames);
#my $vertex_map_ref = get_vertex_map_from_file('hostnames.json');
print $log Dumper $vertex_map_ref if ($debug > 1);

my %embedded = %$vertex_map_ref;
my @vertex_list = @{$embedded{'_embedded'}{'vertex'}};
print $log "read " . scalar @vertex_list . " vertices\n\n" if ($debug > 0);
print $log Dumper @vertex_list if ($debug > 1);

# update vertices
update_vertex_map(\@vertex_list, $attributes);

#update_Vertex(\%vertex, \@keys, \@attributes);
