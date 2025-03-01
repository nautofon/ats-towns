#! /usr/bin/env perl

use v5.12;
use warnings;
use open ':std', IO => ':encoding(UTF-8)';

use Getopt::Long 2.33 qw( GetOptions :config gnu_getopt );
use JSON::PP ();
use Pod::Usage qw( pod2usage );
use Text::CSV qw( csv );

my @attributes = qw(
  token
  text
  easting
  southing
  kind
  signed
  access
  industry
  city
  country
  show
  checked
  remark
  ref
);

# Data type of metadata attributes
my %numeric = (
  easting  => 1,
  southing => 1,
);
my %boolean = (
  access   => 1,
  industry => 1,
  show     => 1,
);

pod2usage unless GetOptions \my %opts, qw(
  help|?
  output|o=s
);
pod2usage -verbose => 2 if $opts{help};
pod2usage unless @ARGV;

my @metas = map {
  @{ csv headers => 'auto', in => $_ }
} @ARGV;

for my $meta (@metas) {
  for my $attr (keys %$meta) {
    if (length $meta->{$attr} == 0) {
      delete $meta->{$attr};
    }
    elsif ($meta->{$attr} eq '~') {
      undef $meta->{$attr};
    }
    elsif ($numeric{$attr}) {
      $meta->{$attr} += 0;
    }
    elsif ($boolean{$attr}) {
      $meta->{$attr} = $meta->{$attr} !~ m/^no?\b/i
        ? JSON::PP::true : JSON::PP::false;
    }
  }
}

# Within each metadata record, sort attributes in the order they are defined in
my $attr_order = do {
  my %attr_order = map {( $attributes[$_] => $_ )} 0 .. $#attributes;
  sub { $attr_order{ $JSON::PP::a } <=> $attr_order{ $JSON::PP::b } }
};

my $coder = JSON::PP->new->indent->indent_length(2)->space_after->sort_by($attr_order);
my $json = $coder->encode(\@metas);

my $fh = defined $opts{output}
  ? do { open my $fh, '>', $opts{output} or die "$opts{output}: $!"; $fh }
  : *STDOUT;

print $fh $json;

__END__

=head1 SYNOPSIS

  script/csv2json.pl US/*.csv > usa-labels-meta.json
  script/csv2json.pl --help

=head1 DESCRIPTION

Convert serialized map label metadata from CSV to JSON format.

The conversion result is printed to standard output by default.
The record order in the output is the same as that in the input.
Input and output are in UTF-8, irrespective of the locale.

=head1 OPTIONS

=over

=item --help, -?

Display this manual page.

=item --output, -o

Write JSON data to the given output path instead of standard output.

=back

=head1 SEE ALSO

L<https://github.com/nautofon/ats-towns/blob/main/label-metadata.md>
