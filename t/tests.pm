use strictures 2;

package t::tests;

use Import::Into ();
use Exporter::Attributes ();

use Test::More ();
use Text::Diff ();

sub import {
    my $caller = scalar caller;
    for my $module (qw(strictures Test::More)) {
        $module->import::into($caller);
    }
    goto &Exporter::Attributes::import;
}

sub tdt : Exported { # test with diff text
    my ($is, $should) = (shift, shift);
    if ($is eq $should) {
        goto &Test::More::pass;
    } else {
        print Text::Diff::diff(\$should, \$is);
        goto &Test::More::BAIL_OUT;
    }
}


1;
