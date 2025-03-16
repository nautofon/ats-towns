#! /usr/bin/env perl

use v5.14;
use warnings;

use File::Basename qw( dirname );
use Getopt::Long 2.33 qw( GetOptions :config gnu_getopt );
use JSON::PP ();
use Pod::Usage qw( pod2usage );

my $coder = JSON::PP->new->sort_by( do {
  my @properties = qw(

    state
    country
    name
    text

    token
    easting
    southing
    kind
    signed
    access
    industry
    city
    show
    checked
    remark
    ref

    type
    coordinates
    geometry
    properties

  );
  my %prop_order = map {( $properties[$_] => $_ )} 0 .. $#properties;
  sub { $prop_order{ $JSON::PP::a } <=> $prop_order{ $JSON::PP::b } }
});

pod2usage unless GetOptions \my %opts, qw(
  all-features|a!
  default-name|O
  full-meta|m!
  help|?
  output|o=s
);
pod2usage -verbose => 2 if $opts{help};
pod2usage unless @ARGV == 1;

my $file = $ARGV[0];
my $geojson = $coder->decode( do {
  local $/;
  open my $fh, '<:raw', $file or die "$file: $!";
  <$fh>
});

ref $geojson eq 'HASH' && $geojson->{type} eq 'FeatureCollection' or die
  "$file: Not a GeoJSON FeatureCollection";

$opts{'default-name'} and $opts{output} = do {
  chdir dirname dirname __FILE__;
  'all-towns.geojson'
};

my $fh = defined $opts{output}
  ? do { open my $fh, '>', $opts{output} or die "$opts{output}: $!"; $fh }
  : *STDOUT;

# Try to sort features in about the same order as the old files

my @features = @{ $geojson->{features} };
@features = sort {
  $a->{properties}{country} cmp $b->{properties}{country}
  or $a->{properties}{text} cmp $b->{properties}{text}
} @features;

# These GeoJSON files are written with one feature per line, which isn't
# something JSON::PP does on its own, so we need to hand-roll the JSON
# for the FeatureCollection

print $fh '{',
  '"type":"FeatureCollection", ',
  '"deprecated": true, ',
  '"note": "This dataset is being phased out. See README.md for details.", ',
  '"features":[';

FEATURE:
for my $feature (@features) {

  # Limit the features to those that should be shown on the map by default
  next FEATURE if ! $opts{'all-features'}
    && exists $feature->{properties}{show}
    && ! $feature->{properties}{show};

  # Add legacy all-towns fields
  $feature->{properties}{name}  //= $feature->{properties}{text};
  $feature->{properties}{state} //= $feature->{properties}{country} =~ s/^US-//r;

  # Skip all other metadata
  $feature->{properties} = {
    name    => $feature->{properties}{name},
    text    => $feature->{properties}{text},
    country => $feature->{properties}{country},
    state   => $feature->{properties}{state},
  } unless $opts{'full-meta'};

  print $fh "," if state $not_first++;
  print $fh "\n", $coder->encode($feature);
}

print $fh "\n]}\n";

__END__

=head1 SYNOPSIS

  script/all-towns.pl extra-labels.geojson > all-towns.geojson
  script/all-towns.pl extra-labels.geojson -O
  script/all-towns.pl --help

=head1 DESCRIPTION

Produce the F<all-towns.geojson> legacy file from C<extra-labels> output.

The features in the output are sorted by state and name.

=head1 OPTIONS

=over

=item --all-features, -a

Include all features in the output. To limit the output features
to only those that I<don't> have their C<show> attribute set to a
boolean false value, use C<--no-all-features>.

The C<--all-features> option is currently disabled by default,
but this may change in future.

=item --default-name, -O

Write the C<all-towns> GeoJSON to the default output path instead of
standard output. The default path is the file F<all-towns.geojson>
in the repository root.

=item --full-meta, -m

Include all label metadata in the output. To limit the output to
only the legacy C<name> and C<state> fields and their equivalents
in the new metadata spec, use C<--no-full-meta>.

The C<--full-meta> option is currently disabled by default,
but this may change in future.

=item --help, -?

Display this manual page.

=item --output, -o

Write C<all-towns> GeoJSON data to the given output path instead of
standard output.

=back

=head1 SEE ALSO

L<https://github.com/nautofon/ats-towns/blob/main/label-metadata.md>
