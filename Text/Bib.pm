# $Id: Bib.pm,v 1.18 1995/12/21 19:26:41 eryq Exp $

package Text::Bib;

require 5.001;

=head1 NAME

Text::Bib -- parse Unix F<.bib> files


=head1 DESCRIPTION

This module provides routines for parsing in the contents
of bibliographic databases (usually found lurking on Unix-like
operating systems): these are simple text files which contain
one or more bibliography records.  Each record describes a single
paper, book, or article.  Users of nroff/troff often employ 
such databases whenm typesetting papers.

Even if you don't use *roff, this simple, easily-parsed parameter-value 
format is still useful for recording/exchanging bibliographic 
information.  With the Bib:: module, you can easily post-process
F<.bib> files: search them, convert them into LaTeX, whatever.


B<IMPORTANT NOTE FOR OLD Bib:: USERS>:
After conversations with the High-Muckity-Mucks of the CPAN, this
module has been renamed from B<Bib::> to the more appropriate B<Text::Bib.>


=head2 Bibliographic databases 

(From the GNU manpage, C<grefer(1)>:)

The  bibliographic  database  is a text file consisting of
records separated by one or more blank lines.  Within each
record  fields  start with a % at the beginning of a line.
Each field has a one character name that immediately  follows  
the  %.  It is best to use only upper and lower case
letters for the names of fields. The name  of  the  field
should  be  followed by exactly one space, and then by the
contents of the field.  Empty  fields  are  ignored.   The
conventional meaning of each field is as follows:

=over 4

=item A

The name of an author. If the name contains a
title such as Jr. at the end, it should	be separated  
from the last name by a comma.  There can be multiple 
occurrences of the A field.  The order is significant. 
It is a good idea always to supply an A field or a Q field.

=item B

For an article that is part of a book, the title of the book

=item C      

The place (city) of publication.

=item D      

The date of publication.  The year should be specified in full.  
If the month is specified, the name rather than the number of 
the month should be used, but only the first three letters are required.   
It is a good idea always to supply a D field; if the date is unknown, 
a value such as "in press" or "unknown" can be used.

=item E      

For  an article that is part of a book, the name of an editor of the book.  
Where the work has editors and no authors, the names of the editors should 
be  given as A fields and , (ed) or , (eds)  should  be
appended to the last author.

=item G      

US Government ordering number.

=item I      

The publisher (issuer).

=item J

For an article in a journal, the name of the journal.

=item K  

Keywords to be used for searching.

=item L  

Label.

B<NOTE:> Uniquely identifies the entry.  For example, "Able94".

=item N 

Journal issue number.

=item O      

Other information.  This is usually printed at the end of the reference.

=item P      

Page number.  A range of pages can be specified as m-n.

=item Q

The name of the author, if the author is not a person.   
This will only be used if there are no A fields.  There can only be one 
Q field.

B<NOTE:> Thanks to Mike Zimmerman for clarifying this for me:
it means a "corporate" author: when the "author" is listed
as an organization such as the UN, or RAND Corporation, or whatever.
I've changed the access/storage/etc. methods to "corpAuthor" to access it,
but "android" will still work for now.


=item R      

Technical report number.

=item S      

Series name.

=item T      

Title.  For an article in a book or journal, this should be the title 
of the article.

=item V      

Volume number of the journal or book.

=item X      

Annotation.

B<NOTE:> Basically, a brief abstract or description.

=back

For all fields except A and E, if there is more than one occurrence
of a particular field in a record, only the last such field will be used.

If accent strings are used, they should follow the character 
to be accented.  This means that the AM macro must  be
used  with  the -ms macros.  Accent strings should not be
quoted: use one \ rather than two.


=head2 An example

Here's a possible F<.bib> file with three entries:

    %T Cyberiad
    %A Stanislaw Lem
    %K robot fable 
    %I Harcourt/Brace/Jovanovich
    
    %T Invisible Cities
    %A Italo Calvino
    %K city fable philosophy
    %X In this surreal series of fables, Marco Polo tells an
       aged Kublai Khan of the many cities he has visited in 
       his lifetime.  
    
    %T Angels and Visitations
    %A Neil Gaiman               


=head2 For more information

See refer(1) or grefer(1) for a description of F<.bib> files.


=head1 USAGE

=head2 Parsing .bib files

To parse a F<.bib> file, just do this:

    require Text::Bib;
    
    my $bib;			       
    while ($bib = Text::Bib->read($anyOldFileHandle)) {
	# ...do stuff with $bib...
    }
    defined($bib) || die("error parsing input");

You will nearly always use the C<read()> constructor to create
new instances, and nearly always as shown above.  Notice that 
C<read()> returns the following:

    	The new object, on success.
    	The value '0', on expected end-of-file.
    	The undefined value, on error.

Since C<read()> returns "true" if and only if a new object could be read,
and it returns two distinct "false" values otherwise, it's very easy to 
iterate through a F<.bib> stream I<and> to know why the iteration stopped.

By default, the parser accepts any one-character field name that is
a printable character (no whitespace).  Formally, this is:

    [\041-\176]

Use of characters outside this range is a syntax error.  You may define
a narrower range using the GoodFields parser-option: however, this will
slow down your parser, so you may want to consider whether or not you 
really need it.

=head2 Using Bib objects

For every one of the standard fields in a F<.bib> record, the Bib:: 
module has designated a high-level attribute name:

	   A	- author
	   B	- book
	   C	- city
	   D	- date
	   E	- editor
	   G	- govtNo
	   I	- publisher
	   J	- journal
	   K	- keywordList
	   L	- label
	   N	- number
	   O	- otherInfo
	   P	- page
	   Q	- android
	   R	- reportNo
	   S	- series
	   T	- title
	   V	- volume
	   X	- abstract

Then, for each high-level attribute name I<attr>, Text::Bib:: defines three
methods:

=over 4

=item attr()

All access methods of this form (e.g., C<date()>, C<title()>),
return a single scalar value for that particular attribute,
or undef if there is no such value.  For example:

    $date = $bib->date();

If the Bib object has more than one value defined for I<attr>,
the last value that was read in is used.

=item attrs()

All access methods of this form  (e.g., C<dates()>, C<titles()>),
return the array of all values of that attribute, as follows:

    	If invoked in an array context, an array of values is returned, or the empty array if there are no values for that particular attribute.
    	If invoked in an scalar context, a B<reference to> an array of values is returned, or undef if there are no values for that particular attribute.  

For example:

    # Get and print the first author in the list:
    (@authors = $bib->authors()) || die("no authors");
    print "first author = $authors[0]\n";
    
    # Virtually the same thing, but more efficient if many authors:
    ($authorsRef = $bib->authors()) || die("no authors");
    print "first author = $authorsRef->[0]\n";
    
=item setAttrs()

All methods of this form (e.g., C<setAuthors()>, 
C<setEditors()>) set the array of all values of that attribute.
Supply the list of values as the arguments; for example:

    $bib->setAuthors('C. Clausticus', 'H. Hydronimous', 'F. Fwitch');

=back

If you are writing a subclass, you can use the C<makeMethods()> class
method to add new fields, or override the interpretation of
existing ones:

    package MyBibSubclass;
    @ISA = qw(Text::Bib);
    
    # In our files, %Y holds the year, which is *really* the date:
    MyBibSubclass->makeMethods('Y', 'date');
    
    # Also in our files, %u fields hold the URLs of any on-line copies:
    MyBibSubclass->makeMethods('u', 'url');    
    
    ...
    while ($bib = MyBibSubclass->read($FH)) {
	$date   = $bib->date();     # return date, from %Y
	@urls   = $bib->urls();     # return array of URLs, from %u
	$anyUrl = $bib->url();      # return the last URL encountered
        ...
    }


=head2 Printing Bib objects

The normal way to output Bib objects in F<.bib> format is to
use the method:

    $bib->output($filehandle);

The filehandle may be omitted; in such a case, currently-selected filehandle 
is used.  The fields are output with %L first (if it exists), and then the 
remaining fields in alphabetical order.  The following "safety measures" 
are taken:

    	Lines longer than 77 characters are wrapped at the first whitespace character before that length.
    	Any occurences of '%' immediately after a newline are preceded by a single space.

These safety measures are slightly time-consuming, and are silly if you
are merely outputting a Bib object which you have read in verbatim 
(i.e., using the default parset-options) from a valid F<.bib> file.
Thus, we define a faster method, without the seatbelts:

    $bib->dump($filehandle);

B<Warning:> this method does no fixup on the values at all: they are 
output as-is.  That means if you used parser-options which destroyed any
of the formatting whitespace (e.g., C<Newline=TOSPACE> with
C<LeadWhite=KILLALL>), there is a risk that the output object will be 
an invalid Bib record.  

B<Note:> users of 1.8 and previous releases will notice that the
C<print()> method is now undefined by default: it is deprecated in favor of
the perfectly-equivalent C<output()> method.  If you absolutely cannot
change your method calls just yet, simply change your "require" line:

    require Text::Bib;
    Text::Bib->DEFINE_PRINT_METHOD;

That will define the deprecated Text::Bib::print() as being equivalent to 
Text::Bib::output().


=head1 THE GORY DETAILS

=head2 Instance variables, and their encapsulation

Each F<.bib> object has instance variables corresponding to the actual
field names: for example, the F<.bib> record:

    %T The Non-Linear Existence of Menger-Sierpinski Dragons 
    %A S. Trurl
    %A L. Klapaucius
    %A C. Cybr
    %E Abbarat Hyperion
    %C 
    %K dragon nonlinear Menger Sierpinski irrational hat-rack
    %X Of the many varieties of non-existent dragons, perhaps the
    most fascinating one to not exist is the Menger-Sierpinski Dragon, 
    a.k.a. the Fractal Dragon.  This paper discusses how these "fragons"
    are, in fact, irrationally-dimensional (e.g., pi-dimensional) curves,
    and concludes with the proof that a nonexistent dragon which nonexists 
    in such an impossible manner must logically exist in conventional
    space -- surprisingly, as a hat-rack.
    %D 1996


Would, when parsed, result in a Bib object with the following instance
variables:

    $self->{T} = ["The Non-Linear ... Dragons"];
    $self->{A} = ["S. Trurl",
		  "L. Klapaucius",
		  "C. Cybr"];
    $self->{C} = [""];
    $self->{E} = ["Abbarat Hyperion"];
    $self->{K} = ["dragon nonlinear Menger Sierpinski irrational hat-rack"];
    $self->{D} = ["1996"];


Notice that, for maximum flexibility and consistency (but at the cost of
some space and access-efficiency), the semantics of F<.bib> records do
not come into play at this time: since everything resides in an array,
you can have as many %K, %D, etc. records as you like, and given them
entirely different semantics.   For example, the Library Of Boring Stuff 
That Everyone Reads (LOBSTER) uses the unused %Y as a "year" field.
The parser accomodates this case by politely not choking on LOBSTER
bibliographies.

The F<.bib> semantics come into play in the storage/access methods... which, 
of course, you can override in subclasses.  So, while the default date-access
looks something like this:

    sub date {
	my $self = shift;
	defined($self->{D}) ? $self->{D}[-1] : undef;
    }

The LOBSTER would create a subclass LobsterBib::, and override the date() 
method to be:

    sub date {
	my $self = shift;
	defined($self->{Y}) ? $self->{Y}[-1] : undef;
    }

Furthermore, since this is identical in format to a "standard" scalar-access
method, the LOBSTER could just place in F<LobsterBib.pm> the line:

    LobsterBib->makeMethods('Y', 'date');

And voila, the appropriate methods will be defined.


=head2 Parser options

Before you parse a Bib object, you can set certain parser options
to adjust for the peculiarities in a particular F<.bib>-flavored file.
    
Since we're trying to steer clear of package-level state information,
we pass the parser options right into the C<read()> call, as the
optional second argument:

    my $opts = Text::Bib->makeOpts(LeadWhite  => KEEP, 
                                   GoodFields => '[AEFZ]');
    
    while ($bib = Text::Bib->read($fh, $opts)) {
        # ...do stuff...
    }

The options are as follows:

=over 4

=item GoodFields

By default, the parser accepts any (one-character) field name that is
a printable character (no whitespace).  Formally, this is:

    [\041-\176]

However, when compiling parser options, you can supply your own regular 
expression for validating (one-character) field names.
(I<note:> you must supply the square brackets; they are there to remind 
you that you should give a well-formed single-character expression).
One standard expression is provided for you: 

    $Text::Bib::GroffFields  = '[A-EGI-LN-TVX]';  # legal groff fields

Illegal fields which are encounterd during parsing result in a syntax error.

B<NOTE:> You really shouldn't use this unless you absolutely need to.
The added regular expression test slows down the parser.


=item LeadWhite

In many F<.bib> files, continuation lines (the 2nd, 3rd, etc. lines of a 
field) are written with leading whitespace, like this:

    %T Incontrovertible Proof that Pi Equals Three
       (for Large Values of Three)
    %A S. Trurl
    %X The author shows how anyone can use various common household 
       objects to obtain successively less-accurate estimations of 
       pi, until finally arriving at a desired integer approximation,
       which nearly always is three.                 

This leading whitespace serves two purposes: 

    	It makes it impossible to mistake a continuation line for a field, since % can no longer be the first character.
    	It makes the .bib entries easier to read.

The C<LeadWhite> option controls what is done with this whitespace:

    KEEP	- default; the whitespace is untouched
    KILLONE	- exactly one character of leading whitespace is removed
    KILLALL	- all leading whitespace is removed

See the section below on "using the parser options" for hints and warnings.


=item Newline

The C<Newline> option controls what is done with the newlines that
separate adjacent lines in the same field:

    KEEP	- default; the newlines are kept in the field value
    TOSPACE     - convert each newline to a single space
    KILL	- the newlines are removed

See the section below on "using the parser options" for hints and warnings.


=back

Default values will be used for any options which are left unspecified.


=head2 Using the parser options

The default values for C<Newline> and C<LeadWhite> will preserve the
input text exactly.

The C<Newline=TOSPACE> option, when used in conjunction with the
C<LeadWhite=KILLALL> option, effectively "word-wraps" the text of
each field into a single line.

B<Be careful!> If you use the C<Newline=KILL> option with
either the C<LeadWhite=KILLONE> or the C<LeadWhite=KILLALL> option,
you could end up eliminating all whitespace that separates the word
at the end of one line from the word at the beginning of the next line.


=head2 Why parser options work the way they do

Since you generally will parse an entire file with the same parser options,
it's silly to have to determine the options used (and fill-in the defaults
for unspecified options) on every call to  C<read()>.  So instead, if
you want to provide parser options, you specify them in a call to 
C<makeOpts()>: this method will "compile" your options for fastest-possible
usage, and then return a parser-options "object" to you which you can
plug into C<read()>.


=head1 DIAGNOSTICS

If a Text::Bib:: method returns an error value (usually undef), you can get
the last error by using any of these forms:

    # If you happen to be using Bib objects:
    Text::Bib->lastError();
    
    # If you happen to be using MyBibSubclass objects:
    MyBibSubclass->lastError();
    
    # If you happen to have an instance on hand:
    $bibobject->lastError();

It doesn't matter which form you use: they're all equivalent.
All return a string representation of the last error, which will
look like this:

    "syntax: unexpected end of file"

The error message will always be of the form C<"category: description">,
where the currently-legal categories include...

    ok       not really an error: e.g., expected end-of-file
    syntax   syntax error in parsing

B<NOTE:> This error string is for diagnostics only: you shouldn't depend
on it for flow-control.


=head1 PERFORMANCE

Tolerable... barely.  Even with a lot of hacking to speed things up,
it parses a typical 500 KB F<.bib> file (of 1600 records) in 13
seconds of user time on my 66 MHz/32 MB RAM/I486 box running Linux 1.1.18.
So, figure about 125 records/sec, or about 40 KB/sec.

By contrast, a C program which does the same work is about 8 times
as fast.  But of course, the C code is 8 times as large, and 8 times
as ugly.  :-)

Since the parsing doesn't really "need" regular expressions, I'm
willing to bet that a variation of the parser which uses
dynamically-loaded C functions would be a little faster.  Perhaps such
an alternate parser-method would be a parser-option, available for
people who've compiled their Perl5 to support dynamic-loading.  But,
for now, we go with a more-portable approach.

Bottom line: I'd recommend using this module to I<process> F<.bib> files, 
but if you're looking for query tool... well... maybe we need someone
to implement a C<readInfo()> substitute in C, which this module could
load.


=head1 NOTE TO SERIOUS BIB-FILE USERS

I actually do not use F<.bib> files for *roffing... I used them as a
quick-and-dirty database for WebLib, and that's where this code comes
from.  If you're a serious user of F<.bib> files, and this module doesn't
do what you need it to, please contact me: I'll add the functionality
in.


=head1 BUGS

Compiles a lot of storage/access methods that the user may not need
(e.g., authors(), setAuthors(), etc.).  In the future, the creation of
these methods should be done on-demand, by a custom AUTOLOAD routine.

To speed up the access/storage methods calls, the full methods are created
and loaded (as opposed to having one-line "stubs" which call some 
generic "back-end" function).  The access/storage methods are pretty small,
but still... this means that all the more Perl code must be eval'ed and
loaded, and it may or may not have been a good design choice.

If any of the auto-compiled storage/access methods are invoked improperly,
the error messages are I<very> cryptic, since the "filename" mentioned
is "eval".

Some combinations of parser-options are silly.


=head1 VERSION

$Id: Bib.pm,v 1.18 1995/12/21 19:26:41 eryq Exp $

=head1 AUTHOR

Copyright (C) 1995 by Eryq. 
The author may be reached at 

    eryq@rhine.gsfc.nasa.gov

=head1 NO WARRANTY

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

For a copy of the GNU General Public License, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut



#------------------------------------------------------------
#
# GLOBALS
#
#------------------------------------------------------------

# The package version:
my $rcsid = '$Id: Bib.pm,v 1.18 1995/12/21 19:26:41 eryq Exp $';
($Text::Bib::VERSION = $rcsid) =~ s/.*(\d+\.\d+).*/$1/;

# Legal fields for different situations:
$Text::Bib::GroffFields  = '[A-EGI-LN-TVX]';    # groff

# Default parser options (put this last):
$Text::Bib::DefaultOpts = Text::Bib->makeOpts();



#------------------------------------------------------------
#
# SPECIAL UTILITY (CLASS) METHODS
#
#------------------------------------------------------------
#
# DESCRIPTION
#    To avoid repetitive code, we define a whole lot of methods by
#    iterating through a table of all the fields.
#
#    As an example, the entry 
#
#         B => 'book'
#
#    Defines the methods:
#
#         book()            -- Return the (last-encountered) book, taken 
#                              from the %B field.
#
#         books()           -- Return all books, taken from the %B field.
#                              Returns array in array context, arrayref in
#                              scalar context.
#  
#         setBooks(@values) -- Set the book (%B) field to the new value(s).
#
#
my %Fields = (
	   # fieldname => attr
	   A => 'author',
	   B => 'book',
	   C => 'city',
	   D => 'date',
	   E => 'editor',
	   G => 'govtNo',
	   I => 'publisher',
	   J => 'journal',
	   K => 'keywordList',
	   L => 'label',
	   N => 'number',
	   O => 'otherInfo',
	   P => 'page',
	   Q => 'corpAuthor',
	   R => 'reportNo',
	   S => 'series',
	   T => 'title',
	   V => 'volume',
	   X => 'abstract',
	   );
{
    my ($field, $attr);
    while (($field, $attr) = each %Fields) {
	Text::Bib->makeMethods($field, $attr);
    }
}

# Compatibility with 1.12 and previous:
Text::Bib->makeMethods('Q', 'android');



#------------------------------------------------------------
# makeMethods -- utility: make standard methods for a field
#------------------------------------------------------------

sub makeMethods {
    my ($type, $field, $attr) = @_;
    $type->makeMethod_attr($field, $attr);
    $type->makeMethod_attrs($field, $attr);
    $type->makeMethod_setAttrs($field, $attr);
}

#------------------------------------------------------------
# makeMethod_attr -- utility: create $self->attr() access method
#------------------------------------------------------------
#
# DESCRIPTION
#    Compile a single-value access method, of the form "attr()" (e.g., 
#    date(), title(), etc.).
#
#    All access methods of this form return a single scalar value, or 
#    undef if there is no value for that particular attribute.
#
#    If the Bib object has more than one value defined for that
#    attribute, the last value in the array is used.

sub makeMethod_attr {
    my ($type, $field, $attr) = @_;

    eval <<EOF;
    sub ${type}::${attr} {  
        my \$self = shift;
        defined(\$self->{'$field'}) ? \$self->{'$field'}[-1] : undef;
    }
EOF
}

#------------------------------------------------------------
# makeMethod_attrs -- utility: create $self->attrs() access method
#------------------------------------------------------------
#
# DESCRIPTION
#    Compile a multi-value access method, of the form "attrs()" (e.g., 
#    authors(), editors(), etc.).
#
#    All access methods of this form return the array of all values of 
#    that attribute, as follows:
#
#       * If invoked in an array context, an array of values is returned,
#         or the empty array if there are no values for that particular 
#         attribute.
#
#       * If invoked in an scalar context, a REFERENCE TO an array of values 
#         is returned, or undef if there are no values for that particular 
#         attribute.  
#
# NOTES
#    A returned reference points to the actual instance data, so it should
#    be used in a read-only fashion!

sub makeMethod_attrs {
    my ($type, $field, $attr) = @_;

    eval <<EOF;
    sub ${type}::${attr}s {  
        my \$self = shift;
	(wantarray 
	 ? (defined(\$self->{'$field'}) ? \@{\$self->{'$field'}} : ())
	 : \$self->{'$field'});
    }
EOF
}

#------------------------------------------------------------
# makeMethod_setAttrs -- utility: create $self->setAttrs() storage method
#------------------------------------------------------------
#
# DESCRIPTION
#    Compile a multi-value storage method, of the form "setAttrs()" (e.g., 
#    setAuthors(), setEditors(), etc.).
#
#    All methods of this form set the array of all values of that attribute,
#    and are invoked (for example) as "setAuthors(value, ..., value)".

sub makeMethod_setAttrs {
    my ($type, $field, $attr) = @_;

    eval <<EOF;
    sub ${type}::set\u${attr}s {
        my \$self = shift;
        my \@values = \@_;
        \$self->{'$field'} = \\\@values;
    }
EOF
}



#------------------------------------------------------------
#
# CLASS METHODS
#
#------------------------------------------------------------

#------------------------------------------------------------
# new -- constructor: build an empty Bib object
#------------------------------------------------------------

sub new {
    my $type = shift;
    bless {}, $type;
}

#------------------------------------------------------------
# read -- constructor: read the next Bib object from a .bib stream
#------------------------------------------------------------
#
# RETURNS
#    The object on success.
#    The string '0' on expected end-of-file.
#    Undef on error.

sub read {
    my $type = shift;
    my $new = $type->new();
    $new->readInfo(@_);
}

#------------------------------------------------------------
# error -- internal: called when an error is encountered
#------------------------------------------------------------
#
# WARNINGS
#    Currently, this places the information in Bib::. 
#    DO NOT OVERRIDE THIS METHOD!

sub error { 
    my $self = shift;
    $Text::Bib::Msg = shift;          # of the form "type: message"
    return (wantarray ? () : undef);
}

#------------------------------------------------------------
# lastError -- call this to get the last error
#------------------------------------------------------------
#
# WARNINGS
#    Currently, this looks for the information in Bib::. 
#    DO NOT OVERRIDE THIS METHOD!

sub lastError { 
    my $type = shift;
    $Text::Bib::Msg;
}

#------------------------------------------------------------
# makeOpts -- create quicker-to-use parser options
#------------------------------------------------------------
#
# ARGUMENTS
#    GoodFields => single-character regular expression for legal fields
#    LeadWhite  => what to do with leading whitespace in continuation lines
#    Newline    => what to do with newlines before continuation lines?
#
# RETURNS
#    This always returns a fully-fleshed-out parser-options object,
#    so readInfo() doesn't have to check for unspecified options.
#    It returns undef on error.

sub makeOpts {
    my $type = shift;
    my %params = @_;
    my $opts = {};
    my $value;

    # GoodFields -- valid fields: 
    if (defined($value = $params{GoodFields})) {
	$opts->{GoodFields} = $params{GoodFields};
    }

    # LeadWhite -- what to do with leading whitespace on continuation lines?
    defined($value = $params{LeadWhite}) || ($value = 'KEEP');
    $opts->{LeadWhite} = $value;

    # NewlineChar -- what to append to end of line where newline should be:
    defined($value = $params{Newline}) || ($value = 'KEEP');
    $opts->{Newline} = $value;
    if ($value eq 'KEEP') {              # keep newline
	$opts->{NewlineChar} = "\n";
    } elsif ($value eq 'TOSPACE') {      # convert newline to space
	$opts->{NewlineChar} = ' ';	
    } else {                             # kill newline
	$opts->{NewlineChar} = '';       
    }

    # Parser -- which parser to use?
    defined($value = $params{Parser}) || ($value = 'LINE');
    $opts->{Parser} = $value;

    # Return the parser-options object:
    $opts;
}


#------------------------------------------------------------
#
# INSTANCE METHODS
#
#------------------------------------------------------------

#------------------------------------------------------------
# readInfo -- initiallize a Bib object from next record in a .bib stream
#------------------------------------------------------------
#
# RETURNS
#    The $self object on success.
#    The string '0' on expected end-of-file.
#    Undef on error.
#
# NOTES
#    We use '0' since it makes the user code simpler: iterate through
#    a file until the result is false, then check to see if the result
#    is 0 or undef.
#
# WARNING
#    Not a constructor! Use class method read().
#
#    If an error, the object will only be partially initialized, 
#    and should not be used.

sub readInfo {
    my $self = shift;
    my ($fh,              # the filehandle to read from
	$opts) = @_;      # parsing options
    my $line;             # the next line
    my $field;            # last key read in, or undef
    local($/) = "\n";     # in case our caller has been naughty


    # Get options into scalars for faster usage:
    defined($opts) || ($opts = $Text::Bib::DefaultOpts);
    my $oGoodFields  = $opts->{GoodFields};
    my $oLeadWhite   = $opts->{LeadWhite};
    my $oNewlineChar = $opts->{NewlineChar};

    # Skip blank lines until (legal) EOF or record:
    while (1) {
	($_ = <$fh>) || return '0';
	last if ($_ ne "\n");           # break if we hit a record line
    }

    # Remember this line:
    $self->{LineNo} = $.;

    # Read record lines until (unexpected) EOF or done:
    while (1) {
	
	# Process line in queue:
	chomp;
	if (substr($_, 0, 1) eq '%') {     # line (presumably) begins field...
	    if (/^%([\041-\176]) ?/) {           # well-formed field...
		$field = $1;
		($oGoodFields && ($field !~ $oGoodFields)) &&
		    return $self->error("syntax: not a good field: $_");
		defined($self->{$field}) || ($self->{$field} = []);
		push(@{$self->{$field}}, substr($_, 3));
	    } 
	    else {                               # garbage after the %:
		return $self->error("syntax: bad field: $_");
	    }
	}
	elsif (defined($field)) {          # add line to last field...

	    # Muck about with leading whitespace (implicit else is KEEP):
	    if ($oLeadWhite eq 'KILLONE') {      # kill first leading white:
		s/^\s//;
	    } elsif ($oLeadWhite eq 'KILLALL') { # kill all leading white:
		s/^\s+//;
	    }

	    # Add separator and new line to existing value:
	    ($self->{$field}[-1] .= $oNewlineChar) .= $_;
	}
	else {                             # yow! undefined field!
	    return $self->error("syntax: line outside of field: $_");
	}
	
	# Next line:
	($_ = <$fh>) || return $self->error("syntax: unexpected EOF");
	last if ($_ eq "\n");           # blank line means end of record
    }

    $self;
}

#------------------------------------------------------------
# readInfo2 -- UNUSED: slower, stupider readInfo()
#------------------------------------------------------------
#
# DESCRIPTION
#    A compact variant of readInfo() w/o diagnostics or parser options.  
#    Interestingly enough, it's also slower. 
#    Provided for the curious.

sub readInfo2 {
    my $self = shift;
    my ($fh,              # the filehandle to read from
	$opts) = @_;      # parsing options
    my $field;            # last key read in, or undef
    my $fullfield;        # full file contents
    local($/) = "";        

    ($_ = <$fh>) || return 0;
    s/\n+$/\n/;     
    foreach $fullfield (split(/(^|\n)%/m)) {
	next if (($fullfield eq '') || ($fullfield eq "\n"));
	$field = substr($fullfield, 0, 1);
	defined($self->{$field}) || ($self->{$field} = []);
	push(@{$self->{$field}}, substr($fullfield, 2));
    }
    $self;
}

#------------------------------------------------------------
# keyword -- access: treat keywordList() like a multi-valued field
#------------------------------------------------------------

sub keyword {
    my $self = shift;
    my $keywordList;

    defined($keywordList = $self->keywordList()) || ($keywordList = '');
    (split(/\s+/, $keywordList, 2))[0];
}

#------------------------------------------------------------
# keywords -- access: treat keywordList() like a multi-valued field
#------------------------------------------------------------

sub keywords {
    my $self = shift;
    my $keywordList;

    defined($keywordList = $self->keywordList()) || ($keywordList = '');
    my @kwds = split(/\s+/, $keywordList);
    (wantarray ? @kwds : \@kwds);
}

#------------------------------------------------------------
# setKeywords -- storage: treat keywordList() like a multi-valued field
#------------------------------------------------------------

sub setKeywords {
    my $self = shift;
    my $kwds = join(' ', @_);
    $self->{'K'} = [$kwds];
}

#------------------------------------------------------------
# anyAuthor -- access: get either author() or android()
#------------------------------------------------------------

sub anyAuthor {
    my $self = shift;
    my $author = $self->author();
    defined($author ? $author : $self->android());
}

#------------------------------------------------------------
# anyAuthors -- access: get either authors() or androids()
#------------------------------------------------------------

sub anyAuthors {
    my $self = shift;
    my $field = defined($self->{'A'}) ? 'A' : 'Q';   # get real field to use
    (wantarray 
     ? (defined($self->{$field}) ? @{$self->{$field}} : ())
     : $self->{$field});    
}

#------------------------------------------------------------
# lineno -- return line number that this object was read() in from 
#------------------------------------------------------------

sub lineno {
    $_[0]->{LineNo};
}

#------------------------------------------------------------
# _splitstr -- split string into lines not exceeding 80 chars in length
#------------------------------------------------------------

sub _splitstr {
    my $strref = shift;
    my $safe = '';

    # Get longest prefix of up to 77 chars, ending in space or EOS:
    while ($$strref =~ /^(.{1,77})(\s|$)/) {
	$safe .= $1;
	($2 ne '') && ($safe .= "\n ");
	$$strref = substr($$strref, length($&));    # always gets shorter
    }
    $safe .= $$strref;    # nothing more we can do; tack the rest on 
    $$strref = $safe;
}

#------------------------------------------------------------
# _output -- private: output object in Bib format
#------------------------------------------------------------

sub _output {
    my ($self, $safeness, $fh) = @_;
    my ($key, $val);

    # Get the filehandle to use:
    defined($fh) || ($fh = select);

    # Figure out the keys to use, and put them in order:
    my @keys = sort grep {(length == 1) && ($_ ne 'L')} (keys %$self);
    defined($self->{'L'}) && unshift(@keys, 'L');

    # Output:
    foreach $key (@keys) {
	foreach $val (@{$self->{$key}}) {
	    if ($safeness eq 'SAFE') {

		# Make sure no line exceeds 80 characters:
		&_splitstr(\$val);
		
		# Make sure all newlines are NOT followed by a %:
		$val =~ s/\n\%/\n \%/g;
	    }
	    print $fh "\%$key $val\n";
	}	
    }
    print $fh "\n";
}

#------------------------------------------------------------
# output -- output object in Bib format, safe but slow
#------------------------------------------------------------

sub output {
    my $self = shift;
    $self->_output('SAFE', @_);
}

#------------------------------------------------------------
# dump -- output object in Bib format, fast but fragile
#------------------------------------------------------------

sub dump {
    my $self = shift;
    $self->_output('UNSAFE', @_);
}

#------------------------------------------------------------
#
# Compatibility patches:
#
#------------------------------------------------------------

# DEFINE_PRINT_METHOD: This is for 1.8-and-previous users:
sub DEFINE_PRINT_METHOD {
    local $^W = 0;
    eval 'sub Text::Bib::print { my $self = shift; $self->output(@_); } ';
}


1;
#----------------------- end of Bib.pm -----------------------
