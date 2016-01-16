#!perl

use t::tests;
use Text::API::Blueprint qw(Action);

use constant EOL => "\n";

plan tests => 14;

################################################################################

tdt(Action(
    map {$_=>$_} qw(method)
), <<'EOT', 'Action');
### method

EOT

################################################################################

tdt(Action(
    map {$_=>$_} qw(method identifier)
), <<'EOT', 'Action identifier');
### identifier [method]

EOT

################################################################################

tdt(Action(
    map {$_=>$_} qw(method identifier uri)
), <<'EOT', 'Action identifier uri');
### identifier [method uri]

EOT

################################################################################

tdt(Action(
    map {$_=>$_} qw(method relation)
), <<'EOT', 'Action relation');
### method

+ Relation: relation

EOT

################################################################################

tdt(Action(
    parameters => {
        foo => {
            (map {($_=>$_)} qw(example required type enum shortdesc longdesc default)),
            members => {
                bar => 'baz',
            }
        },
    },
    map {$_=>$_} qw(method)
), <<'EOT', 'Action paramters');
### method

+ Parameters

    + foo: `example` (enum[enum], required) - shortdesc
    
        longdesc
        
        + Default: `default`
        
        + Members
        
            + `bar` - baz

EOT

################################################################################

tdt(Action(
    assets => [[qw[foo bar baz]]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action assets(ref)');
### method

+ foo bar

    [baz][]

EOT

################################################################################

tdt(Action(
    assets => [[
        keyword => 'identifier',
        type => 'type',
        description => 'description',
        headers => { foo => 'bar' },
        code => 'code',
        lang => 'lang',
        schema => "schema",
    ]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action assets(single)');
### method

+ keyword identifier (type)

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

tdt(Action(
    assets => [[qw[foo1 bar1 baz1]],[qw[foo2 bar2 baz2]]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action assets(multi)');
### method

+ foo1 bar1

    [baz1][]

+ foo2 bar2

    [baz2][]

EOT

################################################################################

tdt(Action(
    request => [qw[ foo bar ]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action request(ref)');
### method

+ Request foo

    [bar][]

EOT

################################################################################

tdt(Action(
    request => [
        'identifier',
        type => 'type',
        description => 'description',
        headers => { foo => 'bar' },
        code => 'code',
        lang => 'lang',
        schema => "schema",
    ],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action request(single)');
### method

+ Request identifier (type)

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

tdt(Action(
    requests => [[qw[ foo1 bar1 ]],[qw[ foo2 bar2 ]]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action requests');
### method

+ Request foo1

    [bar1][]

+ Request foo2

    [bar2][]

EOT

################################################################################

tdt(Action(
    response => [qw[ foo bar ]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action response(ref)');
### method

+ Response foo

    [bar][]

EOT

################################################################################

tdt(Action(
    response => [
        'identifier',
        type => 'type',
        description => 'description',
        headers => { foo => 'bar' },
        code => 'code',
        lang => 'lang',
        schema => "schema",
    ],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action response(single)');
### method

+ Response identifier (type)

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

tdt(Action(
    responses => [[qw[ foo1 bar1 ]],[qw[ foo2 bar2 ]]],
    map {$_=>$_} qw(method)
), <<'EOT', 'Action responses');
### method

+ Response foo1

    [bar1][]

+ Response foo2

    [bar2][]

EOT

################################################################################

done_testing;