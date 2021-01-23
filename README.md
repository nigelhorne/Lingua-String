# NAME

Lingua::String - Class to contain a string in many different languages

# VERSION

Version 0.01

# SYNOPSIS

Hold many strings in one object.

    use Lingua::String;

    my $str = Lingua::String->new();

    $str->fr('Bonjour Tout le Monde');
    $str->en('Hello, World');

    $ENV{'LANG'} = 'en_GB';
    print "$str\n";     # Prints Hello, World
    $ENV{'LANG'} = 'fr_FR';
    print "$str\n";     # Prints Bonjour Tout le Monde
    $LANG{'LANG'} = 'de_DE';
    print "$str\n";     # Prints nothing

# METHODS

## new

Create a Lingua::String object.

    use Lingua::String;

    my $str = Lingua::String->new({ 'en' => 'Here', 'fr' => 'Ici' });

## set

Sets a string in a language.

    $str->set({ string => 'House', lang => 'en' });

Autoload will do this for you as

    $str->en('House');

## as\_string

Returns the string in the language requested in the parameter.
If that parameter is not given, the system language is used.

    my $string = Lingua::String->new(en => 'boat', fr => 'bateau'); 
    print $string->as_string(), "\n";
    print $string->as_string('fr'), "\n";
    print $string->as_string({ lang => 'en' }), "\n";

# AUTHOR

Nigel Horne, `<njh at bandsman.co.uk>`

# BUGS

# SEE ALSO

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lingua::String

You can also look for information at:

- MetaCPAN

    [https://metacpan.org/release/Lingua-String](https://metacpan.org/release/Lingua-String)

- RT: CPAN's request tracker

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-String](https://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-String)

- CPANTS

    [http://cpants.cpanauthors.org/dist/Lingua-String](http://cpants.cpanauthors.org/dist/Lingua-String)

- CPAN Testers' Matrix

    [http://matrix.cpantesters.org/?dist=Lingua-String](http://matrix.cpantesters.org/?dist=Lingua-String)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Lingua-String](http://cpanratings.perl.org/d/Lingua-String)

- CPAN Testers Dependencies

    [http://deps.cpantesters.org/?module=Lingua-String](http://deps.cpantesters.org/?module=Lingua-String)

# LICENCE AND COPYRIGHT

Copyright 2021 Nigel Horne.

This program is released under the following licence: GPL2
