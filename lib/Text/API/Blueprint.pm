use strictures 2;

package Text::API::Blueprint;

# ABSTRACT: ...

use Class::Load qw(load_class);
use Exception::Delayed;
use Carp qw(croak confess);
use Exporter::Attributes qw(import);

# VERSION

our $Autoprint = 0;
our $Offset = 0;

sub _autoprint {
    my ($wantarray, $str) = @_;
    if ($Autoprint and not defined $wantarray) {
        if (ref $Autoprint eq 'SCALAR') {
            $$Autoprint .= $str;
        } elsif (ref $Autoprint eq 'GLOB') {
            print $Autoprint $str;
        } else {
            print $str;
        }
    } else {
        return $str;
    }
}

sub _rpl {
    my ( $re, $str, $rpl ) = @_;
    $rpl //= '';
    $str =~ s{^${re}}{$rpl}seg;
    $str =~ s{${re}$}{$rpl}seg;
    return $str;
}

sub _trim {
    _rpl( qr{\s+}, +shift );
}

sub _indent {
    my ( $str, $n ) = @_;
    $n //= 4;
    my $indent = ' ' x $n;
    $str =~ s{(\r?\n)}{$1.$indent}eg;
    return $indent . $str;
}

sub _flatten {
    my ($str) = @_;
    my ($pre) = ( $str =~ m{^(\s*)\S} );
    return $str unless $pre;
    $str =~ s{^\Q$pre\E}{}rmg;
}

sub _arrayhash {
    my %hash;
    while (@_) {
        my ( $key, $val ) = ( shift, shift );
        next unless defined $key;
        $hash{$key} //= [];
        push @{ $hash{$key} } => $val;
    }
    return %hash;
}

sub _header {
    my ($level, $title, $body, $indent) = @_;
    my $str = '#' x ($level + $Offset);
    $str .= " $title\n\n";
    $body = _indent($body, $indent) if $indent;
    $str .= "$body\n\n" if $body;
    return $str;
}

sub _listitem {
    my ($keyword, $body, $indent) = @_;
    my $str = "+ $keyword\n\n";
    $str .= _indent($body, $indent)."\n\n" if $body;
    return $str;
}

use namespace::clean;

=func Compile

=cut

# Compile: Meta Intro Resource Group Concat
sub Compile : Exportable(simple) {
    my $struct = shift;
    my @Body;
    push @Body => Meta(delete $struct->{host});
    push @Body => Intro(delete $struct->{name}, delete $struct->{description});
    foreach my $resource (@{ delete $struct->{resources} }) {
        push @Body => Resource(%$resource);
    }
    if (my $groups = delete $struct->{groups}) {
        foreach my $group (keys %$groups) {
            push @Body => Group($group, delete $groups->{$group});
        }
    }
    return _autoprint(wantarray, Concat(@Body));
}

=func Section

B<Invokation>: Section(
    CodeRef C<$coderef>,
    [ Int C<$offset> = C<1> ]
)

Increments header offset by C<$offset> for everything executed in C<$coderef>.

=cut

# Section:
sub Section : Exportable(singles) {
    my ($coderef, $offset) = @_;
    $offset //= 1;
    $Offset += $offset;
    my $autoprint = $Autoprint;
    $Autoprint = \"";
    my $X = Exception::Delayed->wantany(undef, $coderef);
    my $str = $$Autoprint;
    $Autoprint = $autoprint;
    $Offset -= $offset;
    $X->result;
    return _autoprint(wantarray, $str);
}

=func Meta

B<Invokation>: Meta(
    [ Str C<$host> ]
)

    FORMAT: 1A8
    HOST: $host

=cut

# Meta:
sub Meta : Exportable(singles) {
    my $host = shift;
    my $str = "FORMAT: 1A8\n";
    $str .= "HOST: $host\n" if defined $host;
    return _autoprint(wantarray, "$str\n");
}

=func Intro

B<Invokation>: Intro(
    Str C<$name>,
    Str C<$description>
)

    # $name
    $description

=cut

# Intro:
sub Intro : Exportable(singles) {
    my ($name, $description) = @_;
    return _autoprint(wantarray, _header(1, $name, $description));
}

=func Concat

B<Invokation>: Concat(
    Str C<@blocks>
)

    $block[0]

    $block[1]

    $block[2]

    ...

=cut

# Concat:
sub Concat : Exportable(singles) {
    return _autoprint(wantarray, join "", map { "$_\n\n" } map _trim, grep defined, @_);
}

=func Text

B<Invokation>: Text(
    Str C<@strings>
)

    $string[0]
    $string[1]
    $string[2]
    ...

=cut

# Text: Concat
sub Text : Exportable(helpers) {
    map _autoprint(wantarray, Concat(map _flatten, map { s{[\r\n]+}{\n}r } @_));
}

=func Code

B<Invokation>: Code(
    Str C<$code>,
    [ Str C<$lang> = C<''> ],
    [ Int C<$delimiters> = C<3> ]
)

    ```$lang
    $code
    ```

=cut

# Code:
sub Code : Exportable(singles) {
    my ($code, $lang, $delimiters) = @_;
    $code = _flatten($code);
    $lang //= '';
    $delimiters //= 3;
    my $delimiter = '`' x $delimiters;
    return _autoprint(wantarray, "$delimiter$lang\n$code\n$delimiter\n\n");
}

=func Group

B<Invokation>: Group(
    Str C<$identifier>,
    Str|ArrayRef[HashRef|Str] C<$body>,
    [ Int C<$indent> ]
)

If C<$body> is an ArrayRef, every item which is a HashRef will be passed to L</Resource>.

    # Group $identifier

    $body

=cut

# Group: Concat Resource
sub Group : Exportable(minimal) {
    my ($identifier, $body, $indent) = @_;
    if (ref $body eq 'ARRAY') {
        $body = Concat(map { (ref($_) eq 'HASH') ? Resource(%$_) : $_ } @$body);
    }
    return _autoprint(wantarray, _header(1, "Group $identifier", $body, $indent));
}

=func Resource

B<Invokation>: Resource(
    Str C<:$method>,
    Str C<:$uri>,
    Str C<:$identifier>,
    Str|CodeRef C<:$body>,
    Int C<:$indent>,
    Int C<:$level>,
    HashRef C<:$parameters>,
    HashRef C<:$model>,
    ArrayRef C<:$actions>
)

=over 4

=item * See L</Parameters> for C<$parameters>

=item * See L</Model> for C<$model>

=item * See L</Action> for C<$actions>

=back

With C<$method> and C<$uri>

    ## $method $uri

    $body

With C<$identifier> and C<$uri>

    ## $identifier [$uri]

    $body

With C<$uri>

    ## $uri

    $body

=cut

# Resource: Sesction Parameters Model Action
sub Resource : Exportable(resource) {
    my %args = @_;
    my ($method, $uri, $identifier, $body, $indent, $level, $parameters, $model, $actions) = @args{qw{ method uri identifier body indent level parameters model actions }};
    $level //= 2;
    $body //= '';
    if (ref $body eq 'CODE') {
        $body = Section($body);
    } else {
        my @body;
        push @body => Parameters(%$parameters) if ref $parameters eq 'HASH';
        push @body => Model($model) if ref $model eq 'HASH';
        push @body => map { Action(%$_) } @$actions if ref $actions eq 'ARRAY';
    }
    if ($method and $uri) {
        return _autoprint(wantarray, _header($level, "$method $uri", $body, $indent));
    } elsif ($identifier and $uri) {
        return _autoprint(wantarray, _header($level, "$identifier [$uri]", $body, $indent));
    } elsif ($uri) {
        return _autoprint(wantarray, _header($level, "$uri", $body, $indent));
    } else {
        die "no method and uri or identifier and uri or single uri given";
    }
}

=func Model

B<Invokation>: Model(
    Str C<$media_type>,
    Str|HashRef C<$payload>,
    [ Int C<$indent> ]
)

See L</Payload> if C<$payload> is a HashRef.

    + Model ($media_type)

    $payload

=cut

# Model: Payload
sub Model : Exportable(resource) {
    if (@_ == 1 and ref $_[0] eq 'HASH') {
        my $args = shift;
        my $type = delete $args->{type};
        return _autoprint(wantarray, Model($type, $args));
    } else {
        my ($media_type, $payload, $indent) = @_;
        $payload = Payload(%$payload) if ref $payload eq 'HASH';
        return _autoprint(wantarray, _listitem("Model ($media_type)", $payload, $indent));
    }
}

=func Schema

B<Invokation>: Schema(
    Str C<$body>,
    [ Int C<$indent> ]
)

    + Schema

    $body

=cut

# Schema:
sub Schema : Exportable(singles) {
    my ($body, $indent) = @_;
    return _autoprint(wantarray, _listitem("Schema", $body, $indent));
}

=func Attributes

=cut

# Attributes:
sub Attributes : Exportable(singles) {
    my ($typedef, $attrs) = @_;
    if ($attrs) {
        my @attrs;
        foreach my $attr (keys %$attrs) {
            my %def = %{ $attrs->{$attr} };
            my $str = "$attr";
            if (my $example = delete $def{example}) {
                $str .= ": $example";
            }
            if (my $type = delete $def{type}) {
                $str .= " ($type)";
            }
            if (my $desc = delete $def{description}) {
                $str .= " - $desc";
            }
            push @attrs => $str;
        }
        {
            use Data::Dumper;
            print Dumper(\@attrs);
        }
        return _autoprint(wantarray, _listitem("Attributes ($typedef)", map { _listitem($_) } @attrs));
    } else {
        return _autoprint(wantarray, _listitem("Attributes ($typedef)"));
    }
}

=func Action

B<Invokation>: Action(
    Str C<:$method>,
    Str C<:$uri>,
    Str C<:$identifier>,
    Str|CodeRef C<:$body>,
    Int C<:$indent>,
    Int C<:$level>,
    Str C<:$relation>,
    HashRef C<:$parameters>,
    ArrayRef C<:$assets>,
    ArrayRef C<:$request>,
    ArrayRef C<:$requests>,
    ArrayRef C<:$response>,
    ArrayRef C<:$responses>
)

=over 4

=item * See L</Section> if C<$body> is a CodeRef

=item * See L</Parameters> for C<$parameters>

=item * See L</Asset> for C<$assets>

=item * See L</Request> for C<$request> and C<$requests>

=item * See L</Response> for C<$response> and C<$responses>

=back

With C<$identifier> C<$method> and C<$uri>:

    ### $identifier [$method $uri]

    $body

With C<$identifier> and C<$method>:

    ### $identifier [$method]

    $body

With C<$method>:

    ### $method

    $body

=cut

# Action: Relation Parameters Reference Asset Request_Ref Request Response_Ref Response Concat
sub Action : Exportable() {
    my %args = @_;
    my ($method, $uri, $identifier, $body, $indent, $level, $relation, $parameters, $assets, $requests, $responses, $request, $response) = @args{qw{ method uri identifier body indent level relation parameters assets requests responses request response }};
    $level //= 3;
    $body //= '';
    if (ref $body eq 'CODE') {
        $body = Section($body);
    } else {
        my @body;
        push @body => Relation($relation) if defined $relation;
        push @body => Parameters(%$parameters) if ref $parameters eq 'HASH';
        if (ref $assets eq 'ARRAY') {
            push @body => map { my @args = @$_; @args == 3 ? Reference(@args) : Asset(@args) } @$assets;
        } else {
            if (ref $requests eq 'ARRAY') {
                push @body => map { my @args = @$_; @args == 2 ? Request_Ref(@args) : Request(@args) } @$requests;
            } elsif (ref $request eq 'ARRAY') {
                my @args = @$request;
                if (@args == 2) {
                    push @body => Request_Ref(@args);
                } else {
                    push @body => Request(@args);
                }
            }
            if (ref $responses eq 'ARRAY') {
                push @body => map { my @args = @$_; @args == 2 ? Response_Ref(@args) : Response(@args) } @$responses;
            } elsif (ref $response eq 'ARRAY') {
                my @args = @$response;
                if (@args == 2) {
                    push @body => Response_Ref(@args);
                } else {
                    push @body => Response(@args);
                }
            }
        }
        $body = Concat(@body) if @body;
    }

    if ($identifier and $method and $uri) {
        return _autoprint(wantarray, _header($level, "$identifier [$method $uri]", $body, $indent));
    } elsif ($identifier and $method) {
        return _autoprint(wantarray, _header($level, "$identifier [$method]", $body, $indent));
    } elsif ($method) {
        return _autoprint(wantarray, _header($level, "$method", $body, $indent));
    } else {
        die "no identifier and method and uri or identifier and method or single method given";
    }
}

=func Payload

B<Invokation>: Payload(
    Str C<:$description>,
    HashRef C<:$headers>,
    Str C<:$body>,
    Str C<:$code>,
    Str C<:$lang>,
    AnyRef C<:$yaml>,
    AnyRef C<:$json>,
    Str C<:$schema>
)

=over 4

=item * See L</Body> for C<$body>

=item * See L</Body_CODE> for C<$code> and C<$lang>

=item * See L</Body_YAML> for C<$yaml>

=item * See L</Body_JSON> for C<$json>

=back

Complete output:

    $description

    + Headers
            $key: $value

    + Body

    $body

    + Schema

    $schema

With C<$code> and C<$lang>:

    + Body

        ```$lang
        $code
        ```

With C<$yaml>:

    + Body

        ```yaml
        $yaml
        ```

With C<$json>:

    + Body

        ```json
        $json
        ```

=cut

# Payload: Headers Body Body_CODE Body_YAML Body_JSON Schema Concat
sub Payload : Exportable() {
    my %args = @_;
    my @body;
    push @body => delete $args{description} if exists $args{description};
    push @body => Headers(%{ delete $args{headers} }) if exists $args{headers};

    if (exists $args{body}) {
        push @body => Body(delete $args{body});
    } elsif (exists $args{code}) {
        push @body => Body_CODE(delete $args{code}, delete $args{lang});
    } elsif (exists $args{yaml}) {
        push @body => Body_YAML(delete $args{yaml});
    } elsif (exists $args{json}) {
        push @body => Body_JSON(delete $args{json});
    }

    push @body => Schema(delete $args{schema}) if exists $args{schema};

    return _autoprint(wantarray, Concat(@body));
}

=func Asset

B<Invokation>: Asset(
    Str C<$keyword>,
    Str C<$identifier>,
    Str C<:$type>,
    C<%payload>
)

See L</Payload> for C<%payload>

    # $keyword $identifier ($type)

    $payload

=cut

# Asset: Payload
sub Asset : Exportable(singles) {
    my ($keyword, $identifier, %payload) = @_;
    my $str = "$keyword $identifier";
    my $media_type = delete $payload{type};
    $str .= " ($media_type)" if defined $media_type;
    return _autoprint(wantarray, _listitem($str, Payload(%payload)));
}

=func Reference

B<Invokation>: Reference(
    Str C<$keyword>,
    Str C<$identifier>,
    Str C<$reference>
)

    # $keyword $identifier

        [$reference][]

=cut

# Reference:
sub Reference : Exportable(singles) {
    my ($keyword, $identifier, $reference) = @_;
    return _autoprint(wantarray, _listitem("$keyword $identifier", "[$reference][]"));
}

=func Request

B<Invokation>: Request(
    C<@args>
)

Calls L</Asset>( C<'Request'>, C<@args> )

=cut

# Request: Asset
sub Request : Exportable() {
    unshift @_ => 'Request';
    goto &Asset;
}

=func Request_Ref

B<Invokation>: Request_Ref(
    C<@args>
)

Calls L</Reference>( C<'Request'>, C<@args> )

=cut

# Request_Ref: Reference
sub Request_Ref : Exportable() {
    unshift @_ => 'Request';
    goto &Reference;
}

=func Response

B<Invokation>: Response(
    C<@args>
)

Calls L</Asset>( C<'Response'>, C<@args> )

=cut

# Response: Asset
sub Response : Exportable() {
    unshift @_ => 'Response';
    goto &Asset;
}

=func Response_Ref

B<Invokation>: Response_Ref(
    C<@args>
)

Calls L</Reference>( C<'Response'>, C<@args> )

=cut

# Response_Ref: Reference
sub Response_Ref : Exportable() {
    unshift @_ => 'Response';
    goto &Reference;
}

=func Parameters

B<Invokation>: Parameters(
    [
        Str C<$name>
        =>
        HashRef C<$options>
    ]*
)

For every keypair, L</Parameter>(C<$name>, C<%$options>) will be called

=cut

# Parameters: Parameter
sub Parameters : Exportable() {
    my $body = '';
    while (my ($name, $opts) = (shift, shift)) {
        $body .= Parameter($name, %$opts);
    }
    return _autoprint(wantarray, _listitem('Parameters', $body));
}

=func Parameter

B<Invokation>: Parameter(
    Str C<$name>,
    Str C<:$example>,
    Bool C<:$required>,
    Bool C<:$optional>,
    Str C<:$type>,
    Str C<:$enum>,
    Str C<:$shortdesc>,
    Str|ArrayRef[Str] C<:$longdesc>,
    Str C<:$default>,
    HashRef C<:$members>
)

    + $name: `$example` ($type, $required_or_optional) - $shortdesc

        $longdesc

        + Default: `$default`

        + Members
            + `$key` - $value
            + ...

=cut

# Parameter:
sub Parameter : Exportable(singles) {
    my ($name, %opts) = @_;
    my ($example_value, $required, $optional, $type, $enum, $shortdesc, $longdesc, $default, $members) = @opts{qw{ example required optional type enum shortdesc longdesc default members }};
    my $constraint = 'optional';
    if (defined $required) {
        $constraint = $required ? 'required' : 'optional';
    }
    if (defined $optional) {
        $constraint = $optional ? 'optional' : 'required';
    }
    if (defined $enum) {
        $type = "enum[$enum]";
    }

    my @longdesc = (ref($longdesc) eq 'ARRAY') ? @$longdesc : [ split /\n{2,}/ => $longdesc ];
    my @itembody = (@longdesc);
    push @itembody => _listitem("Default: `$default`") if defined $default;
    if (defined $members) {
        $members = join "\n", map { "+ `$_` - ".$members->{$_} } sort keys %$members;
        push @itembody => _listitem("Members", $members) if length $members;
    }
    my $itembody = _text(@itembody);
    return _autoprint(wantarray, _listitem("$name: `$example_value` ($type, $constraint) - $shortdesc", $itembody));
}

=func Headers

B<Invokation>: Headers(
    [
        Str C<$key>
        =>
        Str C<$value>
    ]*
)

    + Headers
        $key: $value
        ...

=cut

# Headers:
sub Headers : Exportable(singles) {
    my $body = '';
    while (@_ and my ($name, $value) = (shift(@_), shift(@_))) {
        $name = lc($name =~ s{([a-z])([A-Z])}{$1-$2}gr);
        $name =~ s{_}{-}g;
        $name =~ s{-+([^-]+)}{'-'.ucfirst($1)}eg;
        $name = ucfirst($name);
        $body .= "    $name: $value";
    }
    return _autoprint(wantarray, _listitem('Headers', $body));
}

=func Body

B<Invokation>: Body(
    Str C<$body>
)

    + Body

            $body

=cut

# Body:
sub Body : Exportable(singles) {
    my $body = _flatten(shift);
    return _autoprint(wantarray, _listitem('Body', $body, 8));
}

=func Body_CODE

B<Invokation>: Body_CODE(
    Str C<$code>,
    Str C<$lang>
)

    + Body

        ```$lang
        $code
        ```

=cut

# Body_CODE: Code
sub Body_CODE : Exportable() {
    my ($code, $lang) = @_;
    return _autoprint(wantarray, _listitem('Body', Code(_flatten($code), $lang)));
}

=func Body_YAML

B<Invokation>: Body_YAML(
    AnyRef C<$struct>
)

    + Body

        ```yaml
        $struct
        ```

=cut

# Body_YAML: Body_CODE
sub Body_YAML : Exportable() {
    my ($struct) = @_;
    load_class('YAML::Any');
    return _autoprint(wantarray, Body_CODE(YAML::Any::Dump($struct), 'yaml'));
}

=func Body_JSON

B<Invokation>: Body_JSON(
    AnyRef C<$struct>
)

    + Body

        ```json
        $struct
        ```

=cut

# Body_JSON: Body_CODE
sub Body_JSON : Exportable() {
    my ($struct) = @_;
    load_class('JSON');
    our $JSON //= JSON->new->utf8->pretty->allow_nonref->convert_blessed;
    return _autoprint(wantarray, Body_CODE($JSON->encode($struct), 'json'));
}

=func Relation

B<Invokation>: Relation(
    Str C<$link>
)

    + Relation: $link

=cut

# Relation:
sub Relation : Exportable(singles) {
    my $link = shift;
    return _autoprint(wantarray, _listitem("Relation: $link"));
}

1;
