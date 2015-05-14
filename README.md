# NAME

Text::API::Blueprint - ...

# VERSION

version 0.001

# FUNCTIONS

## Section

**Invokation**: Section( CodeRef `$coderef` , \[ Int `$offset` \] )

## Meta

**Invokation**: Meta( \[ Str `$host` \] )

## Intro

**Invokation**: Intro( Str `$name`, Str `$description` )

## Concat

**Invokation**: Concat( Str `@blocks` )

## Text

**Invkokation**: Text( Str `@strings` )

## Code

**Invkokation**: Code( Str `$code`, \[ Str `$lang` = `''` \], \[ Int `$delimiters` = `3` \] )

## Definition

**Invkokation**: Definition( Str `$keyword`, \[ Str `$identifier` \], \[ Str `$media_type` \], \[ Str <$body> \], \[ Int <$indent> \] )

## Group

**Invokation**: Group( Str `$identifier`, Str | ArrayRef\[ HashRef | Str \] `$body`, \[ Int `$indent` \] )

If `$body` is an ArrayRef, every item which is a HashRef will be passed to ["Resource"](#resource). 

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

## Model

**Invokation**: Model( Str `$media_type`, Str | HashRef `$payload`, \[ Int `$indent` \] )

See ["Payload"](#payload) if `$payload` is a HashRef.

## Schema

**Invokation**: Schema( Str `$body`, \[ Int `$indent` \] )

## Action

**Invokation**: Action(
    Str `:$method`,
    Str `:$uri`,
    Str `:$identifier`,
    Str | CodeRef `:$body`,
    Int `:$indent`,
    Int `:$level`,
    Str `:$relation`,
    HashRef `:$parameters`,
    ArrayRef `:$assets`,
    ArrayRef `:$request`,
    ArrayRef `:$requests`,
    ArrayRef `:$response`,
    ArrayRef `:$responses`,
)

## Payload

**Invokation**: PayLoad(
    Str `:$description`,
    HashRef `:$headers`,
    Str `:$body`,
    Str `:$code`,
    Str `:$lang`,
    AnyRef `:$yaml`,
    AnyRef `:$json`,
    Str `:$schema`,
)

## Asset

**Invokation**: Asset( Str `$keyword`, Str `$identifier`, Str <:$type>, %payload )

See ["Payload"](#payload) for `%payload`

## Reference

**Invokation**: Reference( Str `$keyword`, Str `$identifier`, Str `$reference` )

## Request

**Invokation**: Request( `@args` )

Calls ["Asset"](#asset)( `'Request'`, `@args` )

## Request\_Ref

**Invokation**: Request\_Ref( `@args` )

Calls ["Reference"](#reference)( `'Request'`, `@args` )

## Response

**Invokation**: Response( `@args` )

Calls ["Asset"](#asset)( `'Response'`, `@args` )

## Response\_Ref

**Invokation**: Response\_Ref( `@args` )

Calls ["Reference"](#reference)( `'Response'`, `@args` )

## Parameters

**Invokation**: Parameters( \[ Str `$name` => HashRef `$options` \]\* )

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
    Str | ArrayRef\[ Str \] `:$longdesc`,
    Str `:$default`,
    HashRef `:$members`,
)

## Headers

**Invokation**: Headers( \[ Str `$key` => Str `$value` \]\* )

## Body

**Invokation**: Body( Str `$body` )

## Body\_CODE

**Invokation**: Body\_CODE( Str `$code`, Str `$lang` )

## Body\_YAML

**Invokation**: Body\_YAML( AnyRef `$struct` )

## Body\_JSON

**Invokation**: Body\_JSON( AnyRef `$struct` )

## Relation

**Invokation**: Relation( Str `$link` )

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
