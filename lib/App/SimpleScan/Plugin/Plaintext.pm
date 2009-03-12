package App::SimpleScan::Plugin::Plaintext;

our $VERSION = '0.02';

use warnings;
use strict;
use Carp;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors( qw(plaintext) );

# Module implementation here
sub import {
  no strict 'refs';
  *{caller() . '::plaintext'}     = \&plaintext;
  {
    no warnings 'redefine';
    *old_stack_test = eval("\\&".caller()."::stack_test");
    *{caller() . '::stack_test'}   = \&stack_test;
  }
}

sub pragmas {
  return (['plaintext' => \&plaintext_pragma],
         );
}

sub plaintext_pragma {
  my($self, $args) = @_;
  if( !defined $args or length($args) == 0) {
    $self->stack_test( qq(fail "Missing argument for %%plaintext";\n) );
  }
  elsif ($args =~ /^(on|1)/i) {
    $self->plaintext('1');
  }
  elsif ($args =~ /^(off|0)/i) {
    $self->plaintext('0');
  }
  else {
    $self->stack_test( qq(fail "Invalid argument for %%plaintext: $args";\n) );
  }
}

sub stack_test {
  my ($self, @code) = @_;
  if ($self->plaintext) {
    @code = map { s/page_(.*?)like/text_${1}like/; $_ } @code;
  }

  # Now do what we'd normally do.
  old_stack_test($self, @code);
}


1; # Magic true value required at end of module
__END__

=head1 NAME

App::SimpleScan::Plugin::Plaintext - [One line description of module's purpose here]


=head1 VERSION

This document describes App::SimpleScan::Plugin::Plaintext version 0.0.1


=head1 SYNOPSIS

    # Normal test specs use the entire HTML text
    http://perl.org/ /books<\/a>\n \| / Y Sites list HTML

    # If we want to match just the text, not the HTML:
    %%plaintext on
    http://perl.org/  /|books \| dev \| history \| jobs/ Y Literal list

    # And we can turn this back off again:
    %%plaintext off

=head1 DESCRIPTION

This plugin adds the C<%%plaintext> pragma. This allows you to write test
specs that match the visible text on a page, as opposed to the HTML text.
This is useful if you want to make sure (for instance) if specific text
is on the page, but you don't care how it's marked up.

=head1 INTERFACE 

=head2 pragmas

Exports the C<%%plaintext> pragma handler to C<App::SimpleScan>.

=head2 plaintext_pragma

Actually handles the pragma statement. Calls the exported C<plaintext>
method to record the current state (on or off).

=head2 stack_test

Overrides existing C<stack_test> calls; if the C<plaintext> method
returns true, it alters the text that's about to be stacked.

In either case, it calls the old C<stack_test> routine after it 
does its process so that the tests get stacked as they normally would.

=head1 DIAGNOSTICS

=over

=item C<< Invalid argument for %%plaintext: %s >>

You supplied an argument other than '1' or 'on' to turn
plaintext processing on, or '0' or 'off' to turn it off.

=back


=head1 CONFIGURATION AND ENVIRONMENT

App::SimpleScan::Plugin::Plaintext requires no configuration files or environment variables.


=head1 DEPENDENCIES

App::SimpleScan, Class:Accessot::Fast.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-app-simplescan-plugin-plaintext@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Joe McMahon  C<< <mcmahon@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Joe McMahon C<< <mcmahon@cpan.org> >> and Yahoo!. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
