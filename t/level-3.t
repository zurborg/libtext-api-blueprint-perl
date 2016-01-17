#!perl

use t::tests;
use Text::API::Blueprint qw(Payload);

use constant EOL => "\n";

plan tests => 1;

################################################################################

tdt(Payload({
    description => 'description',
    headers => [ foo => 'bar' ],
    code => 'code',
    lang => 'lang',
    schema => "schema",
}).EOL, <<'EOT', 'Payload');
description

+ Headers

        Foo: bar

+ Body

    ```lang
    code
    ```

+ Schema

    schema
EOT

################################################################################

done_testing;
