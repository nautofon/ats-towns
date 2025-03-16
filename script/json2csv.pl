#! /usr/bin/env perl

use v5.14;
use warnings;
use open ':std', OUT => ':encoding(UTF-8)';

use Getopt::Long 2.33 qw( GetOptions :config gnu_getopt );
use JSON::PP qw( decode_json );
use Pod::Usage qw( pod2usage );
use Socket qw( CRLF );

sub read_binary {
  my ($file) = @_;
  local $/;
  open my $fh, '<:raw', $file or die "$file: $!";
  scalar <$fh>
}

sub csv {
  my %params = @_;
  my ($headers, $records, $fh) = ($params{headers}, $params{in}, $params{out});

  local $, = ',';
  print $fh @$headers;
  print $fh CRLF;

  # Expect array ref of hash refs
  for my $record (@$records) {
    my @fields = map { $record->{$_} // '' } @$headers;
    for (@fields) {
      next unless /[,"\v]/;
      s/"/""/g;
      s/\A/"/;
      s/\z/"/;
    }
    print $fh @fields;
    print $fh CRLF;
  }
}

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

my %opts = (
  decimals => 0,
);
pod2usage unless GetOptions \%opts, qw(
  country|c=s
  decimals=i
  help|?
  output|o=s
);
pod2usage -verbose => 2 if $opts{help};
pod2usage unless @ARGV;

my @metas = map {
  @{ decode_json read_binary $_ }
} @ARGV;

if ( defined $opts{country} ) {
  my $filter = length $opts{country} ? qr/$opts{country}\z/i : qr/\A\z/;
  @metas = grep { ($_->{country} // '') =~ $filter } @metas;
}

for my $meta (@metas) {
  for my $attr (@attributes) {
    if (! defined $meta->{$attr}) {
      $meta->{$attr} = '~' if exists $meta->{$attr};
    }
    elsif ($numeric{$attr} && $opts{decimals} >= 0) {
      $meta->{$attr} = sprintf '%.*f', $opts{decimals}, $meta->{$attr};
    }
    elsif ($boolean{$attr}) {
      $meta->{$attr} = $meta->{$attr} ? 'yes' : 'no';
    }
  }
}

my $fh = defined $opts{output}
  ? do { open my $fh, '>', $opts{output} or die "$opts{output}: $!"; $fh }
  : *STDOUT;

csv
  headers => \@attributes,
  in      => \@metas,
  out     => $fh;

__END__

=head1 SYNOPSIS

  script/json2csv.pl extra-labels.json > extra-labels.csv
  script/json2csv.pl extra-labels.json -c KS > kansas.csv
  script/json2csv.pl --help

=head1 DESCRIPTION

Convert serialized map label metadata from JSON to CSV format.

The conversion result is printed to standard output by default.
The record order in the output is the same as that in the input.
Input and output are in UTF-8, irrespective of the locale.

This script has no prerequisites other than perl itself
(v5.14 or later), so it should run pretty much anywhere.

=head1 OPTIONS

=over

=item --country, -c

Limit output to metadata records with a C<country> attribute that
matches the given argument case-insensitively.

=item --decimals

Round coordinate values to the given number of decimal places.
A negative value disables rounding. Defaults to C<0>.

=item --help, -?

Display this manual page.

=item --output, -o

Write CSV data to the given output path instead of standard output.

=back

=head1 SEE ALSO

L<https://github.com/nautofon/ats-towns/blob/main/label-metadata.md>
