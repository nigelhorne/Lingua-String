package Lingua::Text;

use strict;
use warnings;

use Carp;
use HTML::Entities;
use Params::Get;
use Scalar::Util;

# TODO: Investigate Locale::Maketext

=head1 NAME

Lingua::Text - Class to contain text in many different languages

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

use overload (
	# '==' => \&equal,
	# '!=' => \&not_equal,
	'""' => \&as_string,
	bool => sub { 1 },
	fallback => 1   # So that boolean tests don't cause as_string to be called
);

=head1 SYNOPSIS

Hold many texts in one object,
thereby encapsulating internationalized text.

    use Lingua::Text;

    my $str = Lingua::Text->new();

    $str->fr('Bonjour Tout le Monde');
    $str->en('Hello, World');

    $ENV{'LANG'} = 'en_GB';
    print "$str\n";	# Prints Hello, World
    $ENV{'LANG'} = 'fr_FR';
    print "$str\n";	# Prints Bonjour Tout le Monde
    $ENV{'LANG'} = 'de_DE';
    print "$str\n";	# Prints nothing

    my $text = Lingua::Text->new('hello');	# Initialises the 'current' language

=cut

=head1 METHODS

=head2 new

Create a Lingua::Text object.

    use Lingua::Text;

    my $str = Lingua::Text->new({ 'en' => 'Here', 'fr' => 'Ici' });

Accepts various input formats, e.g. HASH or reference to a HASH.
Clones existing objects with or without modifications.
Uses Carp::carp to log warnings for incorrect usage or potential mistakes.

=cut

sub new {
	my $class = shift;

	# Handle hash or hashref arguments
	my %args;
	if((scalar(@_) == 1) && (!ref($_[0])) && (my $lang = _get_language())) {
		$args{$lang} = $_[0];
	} elsif(my $params = Params::Get::get_params(undef, @_)) {
		%args = %{$params};
	}

	if(!defined($class)) {
		if((scalar keys %args) > 0) {
			# Using Lingua::Text->new(), not Lingua::Text::new()
			carp(__PACKAGE__, ' use ->new() not ::new() to instantiate');
			return;
		}

		# FIXME: this only works when no arguments are given
		$class = __PACKAGE__;
	} elsif(Scalar::Util::blessed($class)) {
		# If $class is an object, clone it with new arguments
		if(scalar(%args)) {
			return bless { texts => {%{$class->{'texts'}}, %args} }, ref($class);
		}
		return bless { %{$class} }, ref($class);
	}

	# Return the blessed object
	if(scalar(%args)) {
		return bless { texts => \%args }, $class;
	}

	return bless { }, $class;
}

=head2 set

Sets a text in a language.

    $str->set({ text => 'House', lang => 'en' });

Autoload will do this for you as

    $str->en('House');

=cut

sub set
{
	my $self = shift;
	my $params = Params::Get::get_params('text', @_);

	my $lang = $params->{'lang'} || $self->_get_language();
	if(!defined($lang)) {
		Carp::carp(__PACKAGE__, ': usage: set(text => text, lang => $language)');
		return;
	}

	my $text = $params->{'text'};
	if(!defined($text)) {
		Carp::carp(__PACKAGE__, ': usage: set(text => text, lang => $language)');
		return;
	}

	$self->{'texts'}->{$lang} = $text;

	return $self;
}

# https://www.gnu.org/software/gettext/manual/html_node/Locale-Environment-Variables.html
# https://www.gnu.org/software/gettext/manual/html_node/The-LANGUAGE-variable.html
sub _get_language
{
	if(($ENV{'LANGUAGE'}) && ($ENV{'LANGUAGE'} =~ /^([a-z]{2})/i)) {
		return lc($1);
	}

	foreach my $variable('LC_ALL', 'LC_MESSAGES', 'LANG') {
		my $val = $ENV{$variable};
		next unless(defined($val));

		if($val =~ /^([a-z]{2})/i) {
			return lc($1);
		}
	}

	# if(defined($ENV{'LANG'}) && (($ENV{'LANG'} =~ /^C\./) || ($ENV{'LANG'} eq 'C'))) {
		# return 'en';
	# }
	return 'en' if defined $ENV{'LANG'} && $ENV{'LANG'} =~ /^C(\.|$)/;
	return;	# undef
}

=head2 as_string

Returns the text in the language requested in the parameter.
If that parameter is not given, the system language is used.

    my $text = Lingua::Text->new(en => 'boat', fr => 'bateau');
    print $text->as_string(), "\n";
    print $text->as_string('fr'), "\n";
    print $text->as_string({ lang => 'en' }), "\n";

=cut

sub as_string {
	my $self = shift;
	my %params;

	if(ref($_[0]) eq 'HASH') {
		%params = %{$_[0]};
	} elsif((scalar(@_) % 2) == 0) {
		if(defined($_[0])) {
			%params = @_;
		}
	} else {
		$params{'lang'} = shift;
	}

	if(my $lang = ($params{'lang'} || $self->_get_language())) {
		return $self->{'texts'}->{$lang};
	}
	Carp::carp(__PACKAGE__, ': usage: as_string(lang => $language)');
}

=head2 encode

=encoding utf-8

Turns the encapsulated texts into HTML entities

    my $text = Lingua::Text->new(en => 'study', fr => 'étude')->encode();
    print $text->fr(), "\n";	# Prints &eacute;tude

=cut

sub encode {
	my $self = shift;

	while(my($k, $v) = each(%{$self->{'texts'}})) {
		utf8::decode($v) unless utf8::is_utf8($v);  # Only decode if not already UTF-8
		$self->{'texts'}->{$k} = HTML::Entities::encode_entities($v);
	}
	return $self;
}

sub AUTOLOAD
{
	our $AUTOLOAD;
	my $self = shift or return;

	# Extract the key name from the AUTOLOAD variable
	my ($key) = $AUTOLOAD =~ /::(\w+)$/;

	# Skip if called on destruction
	return if $key eq 'DESTROY';

	# Ensure the key is called on the correct package object
	return unless ref($self) eq __PACKAGE__;

	if(my $value = shift) {
		# Set the requested language ($key) to the given text ($value)
		$self->{'texts'}->{$key} = $value;
	}

	# Get the requested language ($key)
	return $self->{'texts'}->{$key};
}

=head1 AUTHOR

Nigel Horne, C<< <njh at nigelhorne.com> >>

=head1 BUGS

There's no decode() (yet),
so you'll have to be extra careful to avoid double encoding.

=head1 SEE ALSO

=head1 SUPPORT

This module is provided as-is without any warranty.

You can find documentation for this module with the perldoc command.

    perldoc Lingua::Text

You can also look for information at:

=over 4

=item * MetaCPAN

L<https://metacpan.org/release/Lingua-Text>

=item * RT: CPAN's request tracker

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-Text>

=item * CPANTS

L<http://cpants.cpanauthors.org/dist/Lingua-Text>

=item * CPAN Testers' Matrix

L<http://matrix.cpantesters.org/?dist=Lingua-Text>

=item * CPAN Testers Dependencies

L<http://deps.cpantesters.org/?module=Lingua-Text>

=back

=head1 LICENCE AND COPYRIGHT

Copyright 2021-2025 Nigel Horne.

This program is released under the following licence: GPL2 for personal use on
a single computer.
All other users (for example, Commercial, Charity, Educational, Government)
must apply in writing for a licence for use from Nigel Horne at `<njh at nigelhorne.com>`.

=cut

1;
