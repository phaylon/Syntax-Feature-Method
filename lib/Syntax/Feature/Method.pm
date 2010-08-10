use strict;
use warnings;

# ABSTRACT: Provide a method keyword

package Syntax::Feature::Method;

use Method::Signatures::Simple  ();
use B::Hooks::EndOfScope;
use Carp                        ();

use namespace::clean;

$Carp::Internal{ +__PACKAGE__ }++;

sub install {
    my ($class, %args) = @_;

    my $target      = $args{into};
    my $name        = $args{options}{ -as }         || 'method';
    my $invocant    = $args{options}{ -invocant }   || '$self';

    # install keyword
    Method::Signatures::Simple->import(
        into        => $target,
        name        => $name,
        invocant    => $invocant,
    );

    # remove runtime handler at end of scope
    on_scope_end {
        namespace::clean->clean_subroutines($target, $name);
    };

    return 1;
}

1;

__END__

=method install

Called by the L<syntax> dispatcher to install the exntension into the
requesting package.

=option -as

    use syntax method => { -as => 'provide' };

    provide addition ($n, $m) { $n + $m }

The C<-as> keyword allows you to install the keyword under a different name.
This is especially useful if you want a separate keyword for class methods with
a different L<invocant|/-invocant>.

=option -invocant

    use syntax method => { -invocant => '$me' };

    method sum { $me->foo + $me->bar }

Allows you to set a different default invocant. Useful if you want to import
a second keyword for class methods that has a C<$class> invocant.

=head1 SYNOPSIS

    use syntax 'method';

    method foo ($n) { $n * $self->bar }

    my $method = method ($msg) { 
        print "$msg\n";
    };

=head1 DESCRIPTION

This module will install the L<Method::Signatures::Simple> syntax extension
into the requesting namespace.

You can import the keyword multiple times under different names with different
options:

    use syntax 
        'method',
        'method' => { 
            -as         => 'classmethod',
            -invocant   => '$class',
        };

=head1 SEE ALSO

L<syntax>,
L<Method::Signatures::Simple>

=cut
