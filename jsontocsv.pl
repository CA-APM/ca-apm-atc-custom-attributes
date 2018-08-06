use REST::Client;
use Config::Properties;
use JSON;
use Data::Dumper;

my $properties;
my $rest_client;
my @keys;


sub get_vertex_map_from_file {
    my $filename = shift;
    my $json_text = do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open $filename\": $!\n");
       local $/;
       <$json_fh>
    };

    my $json = JSON->new;
    return $json->decode($json_text);
}


#
# main program
#

# read vertices
my $vertex_map_ref = get_vertex_map_from_file($ARGV[0]);
#print Dumper $vertex_map_ref;
my %embedded = %$vertex_map_ref;
my @vertex_list = @{ $embedded{'_embedded'}{'vertex'} };

#print Dumper @vertex_list;

#create csv

my %vertex1 = %{ $vertex_list[0] };
my @keys = keys %{ $vertex1{'attributes'} };

# print header
my $line = 'layer,timestamp,id';
foreach my $key (@keys) {
    $line = $line . ',' . $key;
}
print $line."\n";

#print data
for my $vertex_ref (@vertex_list) {
    my %vertex = %{ $vertex_ref };
    my $line = $vertex{'layer'} . ',' . $vertex{'timestamp'} . ',' . $vertex{'id'};

    my %attr = %{ $vertex{'attributes'} };
    foreach my $key (@keys) {
        $line = $line . ',' . $attr{$key}[0];
    }
    print $line."\n";
}
