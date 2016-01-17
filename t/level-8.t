#!perl

use t::tests;
use Text::API::Blueprint qw(Compile);

use constant EOL => "\n";

plan tests => 1;

################################################################################

tdt(Compile({
    host => 'host',
    name => 'name',
    description => 'description',
    resources => [{
        uri => 'uri'
    }],
    groups => [
        foo => 'bar'
    ]
}).EOL, <<'EOT', 'Compile');
FORMAT: 1A8
HOST: host

# name

description

## uri

# Group foo

bar
EOT

################################################################################

done_testing;
