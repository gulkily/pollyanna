package Unicode::String;

# Copyright 1997-1999, Gisle Aas.

use strict;
use vars qw($VERSION @ISA @EXPORT_OK $UTF7_OPTIONAL_DIRECT_CHARS);
use Carp;

require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw(
    utf16 utf16le utf16be ucs2
    utf8
    utf7
    ucs4 utf32 utf32be utf32le
    latin1
    uchr uhex

    byteswap2 byteswap4
);

$VERSION = '2.10';

$UTF7_OPTIONAL_DIRECT_CHARS ||= 1;

bootstrap Unicode::String $VERSION;

use overload '""'   => \&as_string,
	     'bool' => \&as_bool,
	     '0+'   => \&as_num,
	     '.='   => \&append,
             '.'    => \&concat,
             'x'    => \&repeat,
	     '='    => \&copy,
             'fallback' => 1;

my %stringify = (
   unicode => \&utf16,
   utf16   => \&utf16,
   utf16be => \&utf16,
   utf16le => \&utf16le,
   ucs2    => \&utf16,
   utf8    => \&utf8,
   utf7    => \&utf7,
   ucs4    => \&ucs4,
   utf32   => \&ucs4,
   utf32be => \&ucs4,
   utf32le => \&utf32le,
   latin1  => \&latin1,
  'hex'    => \&hex,
);

my $stringify_as = \&utf8;

# some aliases
*ucs2 = \&utf16;
*utf16be = \&utf16;
*utf32 = \&ucs4;
*utf32be = \&ucs4;
*uhex = \&hex;
*uchr = \&chr;

sub new
{
    #_dump_arg("new", @_);
    my $class = shift;
    my $str;
    my $self = bless \$str, $class;
    &$stringify_as($self, shift) if @_;
    $self;
}


sub repeat
{
    my($self, $count) = @_;
    my $class = ref($self);
    my $str = $$self x $count;
    bless \$str, $class;
}


sub _dump_arg
{
    my $func = shift;
    print "$func(";
    print join(",", map { if (defined $_) {
                             my $x = overload::StrVal($_);
			     $x =~ s/\n/\\n/g;
			     $x = '""' unless length $x;
			     $x;
			 } else {
			     "undef"
			 }
                        } @_);
    print ")\n";
}


sub concat
{
    #_dump_arg("concat", @_);
    my($self, $other, $reversed) = @_;
    my $class = ref($self);
    unless (UNIVERSAL::isa($other, 'Unicode::String')) {
	$other = Unicode::String->new($other);
    }
    my $str = $reversed ? $$other . $$self : $$self . $$other;
    bless \$str, $class;
}


sub append
{
    #_dump_arg("append", @_);
    my($self, $other) = @_;
    unless (UNIVERSAL::isa($other, 'Unicode::String')) {
	$other = Unicode::String->new($other);
    }
    $$self .= $$other;
    $self;
}


sub copy
{
    my($self) = @_;
    my $class = ref($self);
    my $copy = $$self;
    bless \$copy, $class;
}


sub as_string
{
    #_dump_arg("as_string", @_);
    &$stringify_as($_[0]);
}


sub as_bool
{
    # This is different from perl's normal behaviour by not letting
    # a U+0030  ("0") be false.
    my $self = shift;
    $$self ? 1 : "";
}


sub as_num
{
    # Should be able to use the numeric property from Unidata
    # in order to parse a large number of numbers.  Currently we
    # only convert it to a plain string and let perl's normal
    # num-converter do the job.
    my $self = shift;
    my $str = $self->utf8;
    $str + 0;
}


sub stringify_as
{
    my $class;
    if (@_ > 1) {
	$class = shift;
	$class = ref($class) if ref($class);
    } else {
	$class = "Unicode::String";
    }
    my $old = $stringify_as;
    if (@_) {
	my $as = shift;
	croak("Don't know how to stringify as '$as'")
	    unless exists $stringify{$as};
	$stringify_as = $stringify{$as};
    }
    $old;
}


sub utf16
{
    my $self = shift;
    unless (ref $self) {
	my $u = new Unicode::String;
	$u->utf16($self);
	return $u;
    }
    my $old = $$self;
    if (@_) {
	$$self = shift;
	if ((length($$self) % 2) != 0) {
	    warn "Uneven UTF16 data" if $^W;
	    $$self .= "\0";
	}
	if ($$self =~ /^\xFF\xFE/) {
	    # the string needs byte swapping
	    $$self = byteswap2($$self);
	}
    }
    $old;
}


sub utf16le
{
    my $self = shift;
    unless (ref $self) {
	my $u = new Unicode::String;
	$u->utf16(byteswap2($self));
	return $u;
    }
    my $old = byteswap2($$self);
    if (@_) {
        $self->utf16(byteswap2(shift));
    }
    $old;
}


sub utf32le
{
    my $self = shift;
    unless (ref $self) {
	my $u = new Unicode::String;
	$u->ucs4(byteswap4($self));
	return $u;
    }
    my $old = byteswap4($self->ucs4);
    if (@_) {
        $self->ucs4(byteswap4(shift));
    }
    $old;
}


sub utf7   # rfc1642
{
    my $self = shift;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode::String;
	$u->utf7($self);
	return $u;
    }
    my $old;
    if (defined wantarray) {
	# encode into $old
	$old = "";
	pos($$self) = 0;
	my $len = length($$self);
	while (pos($$self) < $len) {
            if (($UTF7_OPTIONAL_DIRECT_CHARS &&
		 $$self =~ /\G((?:\0[A-Za-z0-9\'\(\)\,\-\.\/\:\?\!\"\#\$\%\&\*\;\<\=\>\@\[\]\^\_\`\{\|\}\s])+)/gc)
	        || $$self =~ /\G((?:\0[A-Za-z0-9\'\(\)\,\-\.\/\:\?\s])+)/gc)
            {
		#print "Plain ", utf16($1)->latin1, "\n";
		$old .= utf16($1)->latin1;
	    }
            elsif (($UTF7_OPTIONAL_DIRECT_CHARS &&
                    $$self =~ /\G((?:[^\0].|\0[^A-Za-z0-9\'\(\)\,\-\.\/\:\?\!\"\#\$\%\&\*\;\<\=\>\@\[\]\^\_\`\{\|\}\s])+)/gsc)
                   || $$self =~ /\G((?:[^\0].|\0[^A-Za-z0-9\'\(\)\,\-\.\/\:\?\s])+)/gsc)
            {
		#print "Unplain ", utf16($1)->hex, "\n";
		if ($1 eq "\0+") {
		    $old .= "+-";
		} else {
		    require MIME::Base64;
		    my $base64 = MIME::Base64::encode($1, '');
		    $base64 =~ s/=+$//;
		    $old .= "+$base64-";
		    # XXX should we determine when the final "-" is
		    # unnecessary? depends on next char not being part
		    # of the base64 char set.
		}
	    } else {
		die "This should not happen, pos=" . pos($$self) .
                                            ":  "  . $self->hex . "\n";
	    }
	}
    }

    if (@_) {
	# decode
	my $len = length($_[0]);
	$$self = "";
	pos($_[0]) = 0;
	while (pos($_[0]) < $len) {
	    if ($_[0] =~ /\G([^+]+)/gc) {
		$self->append(latin1($1));
	    } elsif ($_[0] =~ /\G\+-/gc) {
		$$self .= "\0+";
	    } elsif ($_[0] =~ /\G\+([A-Za-z0-9+\/]+)-?/gc) {
		my $base64 = $1;
		my $pad = length($base64) % 4;
		$base64 .= "=" x (4 - $pad) if $pad;
		require MIME::Base64;
		$$self .= MIME::Base64::decode($base64);
		if ((length($$self) % 2) != 0) {
		    warn "Uneven UTF7 base64-data" if $^W;
		    chop($$self); # correct it
		}
            } elsif ($_[0] =~ /\G\+/gc) {
		warn "Bad UTF7 data escape" if $^W;
		$$self .= "\0+";
	    } else {
		die "This should not happen " . pos($_[0]);
	    }
	}
    }
    $old;
}


sub hex
{
    my $self = shift;
    unless (ref $self) {
	my $u = new Unicode::String;
	$u->hex($self);
	return $u;
    }
    my $old;
    if (defined($$self) && defined wantarray) {
	$old = unpack("H*", $$self);
	$old =~ s/(....)/U+$1 /g;
	$old =~ s/\s+$//;
    }
    if (@_) {
	my $new = shift;
	$new =~ tr/0-9A-Fa-f//cd;  # leave only hex chars
	croak("Hex string length must be multiple of four")
	    unless (length($new) % 4) == 0;
	$$self = pack("H*", $new);
    }
    $old;
}


sub length
{
    my $self = shift;
    int(length($$self) / 2);
}

sub byteswap
{
   my $self = shift;
   byteswap2($$self);
   $self;
}

sub unpack
{
    my $self = shift;
    unpack("n*", $$self)
}


sub pack
{
    my $self = shift;
    $$self = pack("n*", @_);
    $self;
}


sub ord
{
    my $self = shift;
    return () unless defined $$self;

    my $array = wantarray;
    my @ret;
    my @chars;
    if ($array) {
        @chars = CORE::unpack("n*", $$self);
    } else {
	@chars = CORE::unpack("n2", $$self);
    }

    while (@chars) {
	my $first = shift(@chars);
	if ($first >= 0xD800 && $first <= 0xDFFF) { 	# surrogate
	    my $second = shift(@chars);
	    #print "F=$first S=$second\n";
	    if ($first >= 0xDC00 || $second < 0xDC00 || $second > 0xDFFF) {
		carp(sprintf("Bad surrogate pair (U+%04x U+%04x)",
			     $first, $second));
		unshift(@chars, $second);
		next;
	    }
	    push(@ret, ($first-0xD800)*0x400 + ($second-0xDC00) + 0x10000);
	} else {
	    push(@ret, $first);
	}
	last unless $array;
    }
    $array ? @ret : $ret[0];
}


sub name
{
    my $self = shift;
    require Unicode::CharName;
    if (wantarray) {
	return map { Unicode::CharName::uname($_) } $self->ord;
    } else {
        return Unicode::CharName::uname(scalar($self->ord));
    }
}


sub chr
{
    my($self,$val) = @_;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode::String;
	return $u->uchr($self);
    }
    if ($val > 0xFFFF) {
	# must be represented by a surrogate pair
	return undef if $val > 0x10FFFF;  # Unicode limit
	$val -= 0x10000;
	my $h = int($val / 0x400) + 0xD800;
	my $l = ($val % 0x400) + 0xDC00;
	$$self = CORE::pack("n2", $h, $l);
    } else {
	$$self = CORE::pack("n", $val);
    }
    $self;
}


sub substr
{
    my($self, $offset, $length, $substitute) = @_;
    $offset ||= 0;
    $offset *= 2;
    my $substr;
    if (defined $substitute) {
	unless (UNIVERSAL::isa($substitute, 'Unicode::String')) {
	    $substitute = Unicode::String->new($substitute);
	}
	if (defined $length) {
	    $substr = substr($$self, $offset, $length*2) = $$substitute;
	} else {
	    $substr = substr($$self, $offset) = $$substitute;
	}
    } else {
	if (defined $length) {
	    $substr = substr($$self, $offset, $length*2);
	} else {
	    $substr = substr($$self, $offset);
	}
    }
    bless \$substr, ref($self);
}


sub index
{
    my($self, $other, $pos) = @_;
    $pos ||= 0;
    $pos *= 2;
    $other = Unicode::String->new($other) unless ref($other);
    $pos++ while ($pos = index($$self, $$other, $pos)) > 0 && ($pos%2) != 0;
    $pos /= 2 if $pos > 0;
    $pos;
}


sub rindex
{
    my($self, $other, $pos) = @_;
    $pos ||= 0;
    die "NYI";
}


sub chop
{
    my $self = shift;
    if (CORE::length $$self) {
	my $chop = chop($$self);
	$chop = chop($$self) . $chop;
	return bless \$chop, ref($self);
    }
    undef;
}


# XXX: Ideas to be implemented
sub scan;
sub reverse;

sub lc;
sub lcfirst;
sub uc;
sub ucfirst;

sub split;
sub sprintf;
sub study;
sub tr;


1;

__END__

=head1 NAME

Unicode::String - String of Unicode characters (UTF-16BE)

=head1 SYNOPSIS

 use Unicode::String qw(utf8 latin1 utf16be);

 $u = utf8("string");
 $u = latin1("string");
 $u = utf16be("\0s\0t\0r\0i\0n\0g");

 print $u->utf32be;   # 4 byte characters
 print $u->utf16le;   # 2 byte characters + surrogates
 print $u->utf8;      # 1-4 byte characters

=head1 DESCRIPTION

A C<Unicode::String> object represents a sequence of Unicode
characters.  Methods are provided to convert between various external
formats (encodings) and C<Unicode::String> objects, and methods are
provided for common string manipulations.

The functions utf32be(), utf32le(), utf16be(), utf16le(), utf8(),
utf7(), latin1(), uhex(), uchr() can be imported from the
C<Unicode::String> module and will work as constructors initializing
strings of the corresponding encoding.

The C<Unicode::String> objects overload various operators, which means
that they in most cases can be treated like plain strings.

Internally a C<Unicode::String> object is represented by a string of 2
byte numbers in network byte order (big-endian). This representation
is not visible by the API provided, but it might be useful to know in
order to predict the efficiency of the provided methods.

=head2 METHODS

=head2 Class methods

The following class methods are available:

=over 4

=item Unicode::String->stringify_as

=item Unicode::String->stringify_as( $enc )

This method is used to specify which encoding will be used when
C<Unicode::String> objects are implicitly converted to and from plain
strings.

If an argument is provided it sets the current encoding.  The argument
should have one of the following: "ucs4", "utf32", "utf32be",
"utf32le", "ucs2", "utf16", "utf16be", "utf16le", "utf8", "utf7",
"latin1" or "hex".  The default is "utf8".

The stringify_as() method returns a reference to the current encoding
function.

=item $us = Unicode::String->new

=item $us = Unicode::String->new( $initial_value )

This is the object constructor.  Without argument, it creates an empty
C<Unicode::String> object.  If an $initial_value argument is given, it
is decoded according to the specified stringify_as() encoding, UTF-8
by default.

In general it is recommended to import and use one of the encoding
specific constructor functions instead of invoking this method.

=back

=head2 Encoding methods

These methods get or set the value of the C<Unicode::String> object by
passing strings in the corresponding encoding.  If a new value is
passed as argument it will set the value of the C<Unicode::String>,
and the previous value is returned.  If no argument is passed then the
current value is returned.

To illustrate the encodings we show how the 2 character sample string
of "µm" (micro meter) is encoded for each one.

=over 4

=item $us->utf32be

=item $us->utf32be( $newval )

The string passed should be in the UTF-32 encoding with bytes in big
endian order.  The sample "µm" is "\0\0\0\xB5\0\0\0m" in this encoding.

Alternative names for this method are utf32() and ucs4().

=item $us->utf32le

=item $us->utf32le( $newval )

The string passed should be in the UTF-32 encoding with bytes in little
endian order.  The sample "µm" is is "\xB5\0\0\0m\0\0\0" in this encoding.

=item $us->utf16be

=item $us->utf16be( $newval )

The string passed should be in the UTF-16 encoding with bytes in big
endian order. The sample "µm" is "\0\xB5\0m" in this encoding.

Alternative names for this method are utf16() and ucs2().

If the string passed to utf16be() starts with the Unicode byte order
mark in little endian order, the result is as if utf16le() was called
instead.

=item $us->utf16le

=item $us->utf16le( $newval )

The string passed should be in the UTF-16 encoding with bytes in
little endian order.  The sample "µm" is is "\xB5\0m\0" in this
encoding.  This is the encoding used by the Microsoft Windows API.

If the string passed to utf16le() starts with the Unicode byte order
mark in big endian order, the result is as if utf16le() was called
instead.

=item $us->utf8

=item $us->utf8( $newval )

The string passed should be in the UTF-8 encoding. The sample "µm" is
"\xC2\xB5m" in this encoding.

=item $us->utf7

=item $us->utf7( $newval )

The string passed should be in the UTF-7 encoding. The sample "µm" is
"+ALU-m" in this encoding.


The UTF-7 encoding only use plain US-ASCII characters for the
encoding.  This makes it safe for transport through 8-bit stripping
protocols.  Characters outside the US-ASCII range are base64-encoded
and '+' is used as an escape character.  The UTF-7 encoding is
described in RFC 1642.

If the (global) variable $Unicode::String::UTF7_OPTIONAL_DIRECT_CHARS
is TRUE, then a wider range of characters are encoded as themselves.
It is even TRUE by default.  The characters affected by this are:

   ! " # $ % & * ; < = > @ [ ] ^ _ ` { | }

=item $us->latin1

=item $us->latin1( $newval )

The string passed should be in the ISO-8859-1 encoding. The sample "µm" is
"\xB5m" in this encoding.

Characters outside the "\x00" .. "\xFF" range are simply removed from
the return value of the latin1() method.  If you want more control
over the mapping from Unicode to ISO-8859-1, use the C<Unicode::Map8>
class.  This is also the way to deal with other 8-bit character sets.

=item $us->hex

=item $us->hex( $newval )

The string passed should be plain ASCII where each Unicode character
is represented by the "U+XXXX" string and separated by a single space
character.  The "U+" prefix is optional when setting the value.  The
sample "µm" is "U+00b5 U+006d" in this encoding.

=back

=head2 String Operations

The following methods are available:

=over 4

=item $us->as_string

Converts a C<Unicode::String> to a plain string according to the
setting of stringify_as().  The default stringify_as() encoding is
"utf8".

=item $us->as_num

Converts a C<Unicode::String> to a number.  Currently only the digits
in the range 0x30 .. 0x39 are recognized.  The plan is to eventually
support all Unicode digit characters.

=item $us->as_bool

Converts a C<Unicode::String> to a boolean value.  Only the empty
string is FALSE.  A string consisting of only the character U+0030 is
considered TRUE, even if Perl consider "0" to be FALSE.

=item $us->repeat( $count )

Returns a new C<Unicode::String> where the content of $us is repeated
$count times.  This operation is also overloaded as:

  $us x $count

=item $us->concat( $other_string )

Concatenates the string $us and the string $other_string.  If
$other_string is not an C<Unicode::String> object, then it is first
passed to the Unicode::String->new constructor function.  This
operation is also overloaded as:

  $us . $other_string


=item $us->append( $other_string )

Appends the string $other_string to the value of $us.  If
$other_string is not an C<Unicode::String> object, then it is first
passed to the Unicode::String->new constructor function.  This
operation is also overloaded as:

  $us .= $other_string

=item $us->copy

Returns a copy of the current C<Unicode::String> object.  This
operation is overloaded as the assignment operator.

=item $us->length

Returns the length of the C<Unicode::String>.  Surrogate pairs are
still counted as 2.

=item $us->byteswap

This method will swap the bytes in the internal representation of the
C<Unicode::String> object.

Unicode reserve the character U+FEFF character as a byte order mark.
This works because the swapped character, U+FFFE, is reserved to not
be valid.  For strings that have the byte order mark as the first
character, we can guaranty to get the byte order right with the
following code:

   $ustr->byteswap if $ustr->ord == 0xFFFE;

=item $us->unpack

Returns a list of integers each representing an UCS-2 character code.

=item $us->pack( @uchr )

Sets the value of $us as a sequence of UCS-2 characters with the
characters codes given as parameter.

=item $us->ord

Returns the character code of the first character in $us.  The ord()
method deals with surrogate pairs, which gives us a result-range of
0x0 .. 0x10FFFF.  If the $us string is empty, undef is returned.

=item $us->chr( $code )

Sets the value of $us to be a string containing the character assigned
code $code.  The argument $code must be an integer in the range 0x0
.. 0x10FFFF.  If the code is greater than 0xFFFF then a surrogate pair
created.

=item $us->name

In scalar context returns the official Unicode name of the first
character in $us.  In array context returns the name of all characters
in $us.  Also see L<Unicode::CharName>.

=item $us->substr( $offset )

=item $us->substr( $offset, $length )

=item $us->substr( $offset, $length, $subst )

Returns a sub-string of $us.  Works similar to the builtin substr()
function.

=item $us->index( $other )

=item $us->index( $other, $pos )

Locates the position of $other within $us, possibly starting the
search at position $pos.

=item $us->chop

Chops off the last character of $us and returns it (as a
C<Unicode::String> object).

=back

=head1 FUNCTIONS

The following functions are provided.  None of these are exported by default.

=over 4

=item byteswap2( $str, ... )

This function will swap 2 and 2 bytes in the strings passed as
arguments.  If this function is called in void context,
then it will modify its arguments in-place.  Otherwise, the swapped
strings are returned.

=item byteswap4( $str, ... )

The byteswap4 function works similar to byteswap2, but will reverse
the order of 4 and 4 bytes.

=item latin1( $str )

=item utf7( $str )

=item utf8( $str )

=item utf16le( $str )

=item utf16be( $str )

=item utf32le( $str )

=item utf32be( $str )

Constructor functions for the various Unicode encodings.  These return
new C<Unicode::String> objects.  The provided argument should be
encoded correspondingly.

=item uhex( $str )

Constructs a new C<Unicode::String> object from a string of hex
values.  See hex() method above for description of the format.

=item uchar( $num )

Constructs a new one character C<Unicode::String> object from a
Unicode character code.  This works similar to perl's builtin chr()
function.

=back

=head1 SEE ALSO

L<Unicode::CharName>,
L<Unicode::Map8>

L<http://www.unicode.org/>

L<perlunicode>

=head1 COPYRIGHT

Copyright 1997-2000,2005 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut


#
# Some old code that is not used any more (because the methods are
# now implemented as XS) and which I did not want to throw away yet.
#

sub ucs4_inperl
{
    my $self = shift;
    unless (ref $self) {
	my $u = new Unicode::String;
	$u->ucs4($self);
	return $u;
    }
    my $old = pack("N*", $self->ord);
    if (@_) {
	$$self = "";
	for (unpack("N*", shift)) {
	    $self->append(uchr($_));
	}
    }
    $old;
}


sub utf8_inperl
{
    my $self = shift;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode::String;
	$u->utf8($self);
	return $u;
    }

    my $old;
    if (defined($$self) && defined wantarray) {
	# encode UTF-8
	my $uc;
	for $uc (unpack("n*", $$self)) {
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
                        chr(0x80 | ($uc & 0x3F));
	    } else {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    }
	}
    }

    if (@_) {
	if (defined $_[0]) {
	    $$self = "";
	    my $bytes = shift;
	    $bytes =~ s/^[\200-\277]+//;  # can't start with 10xxxxxx
	    while (length $bytes) {
		if ($bytes =~ s/^([\000-\177]+)//) {
		    $$self .= pack("n*", unpack("C*", $1));
		} elsif ($bytes =~ s/^([\300-\337])([\200-\277])//) {
		    my($b1,$b2) = (ord($1), ord($2));
		    $$self .= pack("n", (($b1 & 0x1F) << 6) | ($b2 & 0x3F));
		} elsif ($bytes =~ s/^([\340-\357])([\200-\277])([\200-\277])//) {
		    my($b1,$b2,$b3) = (ord($1), ord($2), ord($3));
		    $$self .= pack("n", (($b1 & 0x0F) << 12) |
                                        (($b2 & 0x3F) <<  6) |
				         ($b3 & 0x3F));
		} else {
		    croak "Bad UTF-8 data";
		}
	    }
	} else {
	    $$self = undef;
	}
    }

    $old;
}




sub latin1_inperl
{
    my $self = shift;
    unless (ref $self) {
	# act as ctor
	my $u = new Unicode::String;
	$u->latin1($self);
	return $u;
    }

    my $old;
    # XXX: should really check that none of the chars > 256
    $old = pack("C*", unpack("n*", $$self)) if defined $$self;

    if (@_) {
	# set the value
	if (defined $_[0]) {
	    $$self = pack("n*", unpack("C*", $_[0]));
	} else {
	    $$self = undef;
	}
    }
    $old;
}
