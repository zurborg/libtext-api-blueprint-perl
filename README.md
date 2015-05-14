# NAME

Text::API::Blueprint - ...

# VERSION

version 0.001

# FUNCTIONS

## Section

**Invokation**: Section(
    CodeRef `$coderef`,
    \[ Int `$offset` = `1` \]
)

Increments header offset by `$offset` for everything executed in `$coderef`.

## Meta

**Invokation**: Meta(
    \[ Str `$host` \]
)

    FORMAT: 1A8
    HOST: $host

## Intro

**Invokation**: Intro(
    Str `$name`,
    Str `$description`
)

    # $name
    $description

## Concat

**Invokation**: Concat(
    Str `@blocks`
)

    $block[0]
    
    $block[1]
    
    $block[2]
    
    ...

## Text

**Invokation**: Text(
    Str `@strings`
)

    $string[0]
    $string[1]
    $string[2]
    ...

## Code

**Invokation**: Code(
    Str `$code`,
    \[ Str `$lang` = `''` \],
    \[ Int `$delimiters` = `3` \]
)

    ```$lang
    $code
    ```

## Group

**Invokation**: Group(
    Str `$identifier`,
    Str|ArrayRef\[HashRef|Str\] `$body`,
    \[ Int `$indent` \]
)

If `$body` is an ArrayRef, every item which is a HashRef will be passed to ["Resource"](#resource).

    # Group $identifier
    
    $body

## Resource

**Invokation**: Resource(
    Str `:$method`,
    Str `:$uri`,
    Str `:$identifier`,
    Str|CodeRef `:$body`,
    Int `:$indent`,
    Int `:$level`,
    HashRef `:$parameters`,
    HashRef `:$model`,
    ArrayRef `:$actions`
)

- See ["Parameters"](#parameters) for `$parameters`
- See ["Model"](#model) for `$model`
- See ["Action"](#action) for `$actions`

With `$method` and `$uri`

    ## $method $uri
    
    $body

With `$identifier` and `$uri`

    ## $identifier [$uri]
    
    $body

With `$uri`

    ## $uri
    
    $body

## Model

**Invokation**: Model(
    Str `$media_type`,
    Str|HashRef `$payload`,
    \[ Int `$indent` \]
)

See ["Payload"](#payload) if `$payload` is a HashRef.

    + Model ($media_type)
    
    $payload

## Schema

**Invokation**: Schema(
    Str `$body`,
    \[ Int `$indent` \]
)

    + Schema
    
    $body

## Action

**Invokation**: Action(
    Str `:$method`,
    Str `:$uri`,
    Str `:$identifier`,
    Str|CodeRef `:$body`,
    Int `:$indent`,
    Int `:$level`,
    Str `:$relation`,
    HashRef `:$parameters`,
    ArrayRef `:$assets`,
    ArrayRef `:$request`,
    ArrayRef `:$requests`,
    ArrayRef `:$response`,
    ArrayRef `:$responses`
)

- See ["Section"](#section) if `$body` is a CodeRef
- See ["Parameters"](#parameters) for `$parameters`
- See ["Asset"](#asset) for `$assets`
- See ["Request"](#request) for `$request` and `$requests`
- See ["Response"](#response) for `$response` and `$responses`

With `$identifier` `$method` and `$uri`:

    ### $identifier [$method $uri]
    
    $body

With `$identifier` and `$method`:

    ### $identifier [$method]
    
    $body

With `$method`:

    ### $method
    
    $body

## Payload

**Invokation**: Payload(
    Str `:$description`,
    HashRef `:$headers`,
    Str `:$body`,
    Str `:$code`,
    Str `:$lang`,
    AnyRef `:$yaml`,
    AnyRef `:$json`,
    Str `:$schema`
)

- See ["Body"](#body) for `$body`
- See ["Body\_CODE"](#body_code) for `$code` and `$lang`
- See ["Body\_YAML"](#body_yaml) for `$yaml`
- See ["Body\_JSON"](#body_json) for `$json`

Complete output:

    $description
    
    + Headers
            $key: $value
    
    + Body
    
    $body
    
    + Schema
    
    $schema

With `$code` and `$lang`:

    + Body
    
        ```$lang
        $code
        ```

With `$yaml`:

    + Body
    
        ```yaml
        $yaml
        ```

With `$json`:

    + Body

        ```json
        $json
        ```

## Asset

**Invokation**: Asset(
    Str `$keyword`,
    Str `$identifier`,
    Str `:$type`,
    `%payload`
)

See ["Payload"](#payload) for `%payload`

    # $keyword $identifier ($type)
    
    $payload

## Reference

**Invokation**: Reference(
    Str `$keyword`,
    Str `$identifier`,
    Str `$reference`
)

    # $keyword $identifier
    
        [$reference][]

## Request

**Invokation**: Request(
    `@args`
)

Calls ["Asset"](#asset)( `'Request'`, `@args` )

## Request\_Ref

**Invokation**: Request\_Ref(
    `@args`
)

Calls ["Reference"](#reference)( `'Request'`, `@args` )

## Response

**Invokation**: Response(
    `@args`
)

Calls ["Asset"](#asset)( `'Response'`, `@args` )

## Response\_Ref

**Invokation**: Response\_Ref(
    `@args`
)

Calls ["Reference"](#reference)( `'Response'`, `@args` )

## Parameters

**Invokation**: Parameters(
    \[
        Str `$name`
        =>
        HashRef `$options`
    \]\*
)

For every keypair, ["Parameter"](#parameter)(`$name`, `%$options`) will be called

## Parameter

**Invokation**: Parameter(
    Str `$name`,
    Str `:$example`,
    Bool `:$required`,
    Bool `:$optional`,
    Str `:$type`,
    Str `:$enum`,
    Str `:$shortdesc`,
    Str|ArrayRef\[Str\] `:$longdesc`,
    Str `:$default`,
    HashRef `:$members`
)

    + $name: `$example` ($type, $required_or_optional) - $shortdesc
    
        $longdesc
        
        + Default: `$default`
        
        + Members
            + `$key` - $value
            + ...

## Headers

**Invokation**: Headers(
    \[
        Str `$key`
        =>
        Str `$value`
    \]\*
)

    + Headers
        $key: $value
        ...

## Body

**Invokation**: Body(
    Str `$body`
)

    + Body
    
            $body

## Body\_CODE

**Invokation**: Body\_CODE(
    Str `$code`,
    Str `$lang`
)

    + Body
    
        ```$lang
        $code
        ```

## Body\_YAML

**Invokation**: Body\_YAML(
    AnyRef `$struct`
)

    + Body
    
        ```yaml
        $struct
        ```

## Body\_JSON

**Invokation**: Body\_JSON(
    AnyRef `$struct`
)

    + Body
    
        ```json
        $struct
        ```

## Relation

**Invokation**: Relation(
    Str `$link`
)

    + Relation: $link

# BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/zurborg/libtext-api-blueprint-perl/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

David Zurborg <zurborg@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by David Zurborg.

This is free software, licensed under:

    The ISC License
