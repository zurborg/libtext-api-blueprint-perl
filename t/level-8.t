#!perl

use t::tests;
use Text::API::Blueprint qw(Compile);

use constant EOL => "\n";

plan tests => 1;

################################################################################

tdt(Compile({
    host => 'host',
    name => 'name',
    description => 'description1',
    resources => [{
        description => 'description2',
        uri => 'uri'
    }],
    groups => [
        foo => 'bar'
    ]
}).EOL, <<'EOT', 'Compile');
FORMAT: 1A8
HOST: host

# name

description1

## uri

description2

# Group foo

bar
EOT

################################################################################

done_testing;
