#! /usr/bin/env perl

use v5.14;
use warnings;
use open ':std', IO => ':encoding(UTF-8)';

use Getopt::Long 2.33 qw( GetOptions :config gnu_getopt );
use JSON::PP ();
use Pod::Usage qw( pod2usage );

sub read_text {
  my ($file) = @_;
  local $/;
  open my $fh, '<', $file or die "$file: $!";
  scalar <$fh>
}

sub csv {
  my %params = @_;
  my (@records, @fields, $quoted);
  my $field = '';

  CHAR:
  for my $char ( split m//, read_text $params{in} ) {
    $quoted = ! $quoted if $char eq '"';
    if (! $quoted && $char eq ',') {
      $field =~ s{ \A" (.*) "\z }{ $1 =~ s("")(")gr }ex;
      push @fields, $field;
      $field = '';
      next CHAR;
    }
    if (! $quoted && $char =~ m/\v/) {
      push @records, [@fields, $field] if length $field || @fields;
      @fields = ();
      $field = '';
      next CHAR;
    }
    $field .= $char;
  }

  my $headers = shift @records;
  die 'Varying field counts in CSV' if grep { @$headers != @$_ } @records;
  die 'Unescaped quote in CSV' if $quoted;
  die 'No line break after last record in CSV' if length $field || @fields;

  # Yield array ref of hash refs (like Text::CSV headers => 'auto')
  @records = map {
    my $record = $_;
    +{ map {( $headers->[$_] => $record->[$_] )} 0 .. $#$headers }
  } @records;
  return \@records;
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

pod2usage unless GetOptions \my %opts, qw(
  help|?
  output|o=s
);
pod2usage -verbose => 2 if $opts{help};
pod2usage unless @ARGV;

my @metas = map {
  @{ csv in => $_ }
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

This script has no prerequisites other than perl itself
(v5.14 or later), so it should run pretty much anywhere.

=head1 OPTIONS

=over

=item --help, -?

Display this manual page.

=item --output, -o

Write JSON data to the given output path instead of standard output.

=back

=head1 SEE ALSO

L<https://github.com/nautofon/ats-towns/blob/main/label-metadata.md>
