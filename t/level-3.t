#!perl

use t::tests;
use Text::API::Blueprint qw(Payload);

use constant EOL => "\n";

plan tests => 1;

################################################################################

tdt(Payload({
    description => 'description',
    headers => [ foo => 'bar' ],
    attributes => [
        a => {
            example => 'b',
            type => 'c',
            description => 'd'
        },
        e => {
            example => 'f',
            type => 'g',
            description => 'h'
        },
    ],
    code => 'code',
    lang => 'lang',
    schema => "schema",
}).EOL, <<'EOT', 'Payload');
description

+ Headers

        Foo: bar

+ Attributes

    + a: `b` (c) - d
    + e: `f` (g) - h

+ Body

    ```lang
    code
    ```

+ Schema

    schema
EOT

################################################################################

done_testing;
