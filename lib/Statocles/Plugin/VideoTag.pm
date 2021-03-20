package Statocles::Plugin::VideoTag;

# ABSTRACT: Change video file anchors to video elements

our $VERSION = '0.0300';

use Statocles::Base 'Class';
with 'Statocles::Plugin';

=head1 SYNOPSIS

  # site.yml
  site:
    class: Statocles::Site
    args:
        plugins:
            video_tag:
                $class: Statocles::Plugin::VideoTag
                $args:
                     file_type: 'youtu'
                     width: 500
                     height: 300

=head1 DESCRIPTION

C<Statocles::Plugin::VideoTag> changes video file anchor elements to
video elements.

=head1 ATTRIBUTES

=head2 file_type

The file type to replace.

Default: C<mp4>

=cut

has file_type => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'mp4' },
);

=head2 width

Width of the iframe for an embedded YouTube video.

Default: C<560>

=cut

has width => (
    is      => 'ro',
    isa     => Int,
    default => sub { 560 },
);

=head2 height

Height of the iframe for an embedded YouTube video.

Default: C<315>

=cut

has height => (
    is      => 'ro',
    isa     => Int,
    default => sub { 315 },
);

=head2 frameborder

Whether to have a frameborder on the iframe for a YouTube video.

Default: C<0>

=cut

has frameborder => (
    is      => 'ro',
    isa     => Int,
    default => sub { 0 },
);

=head2 allow

The iframe B<allow> attribute string for a YouTube video.

Default: C<accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture>

=cut

has allow => (
    is      => 'ro',
    isa     => Str,
    default => sub { 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture' },
);

=head2 allowfullscreen

Whether to allow full-screen for the iframe for a YouTube video.

Default: C<1>

=cut

has allowfullscreen => (
    is      => 'ro',
    isa     => Int,
    default => sub { 1 },
);

=head1 METHODS

=head2 video_tag

  $page = $plugin->video_tag($page);

Process the video bits of a L<Statocles::Page>.

If the B<file_type> is given as C<youtu>, YouTube links of this exact
form will be converted to an embedded iframe:

  https://www.youtube.com/watch?v=abcdefg1234567

Where the C<abcdefg1234567> is a placeholder for the actual video.

* Currently, for YouTube links, including a start time (e.g. C<&t=42>)
in the link is not honored.  In fact including any argument other than
C<v> will not render the embedded video correctly at this time...

=cut

sub video_tag {
    my ($self, $page) = @_;
    if ($page->has_dom) {
        if ($self->file_type eq 'youtu') {
            $page->dom->find('a[href*="'. $self->file_type .'"]')->each(sub {
                my ($el) = @_;
                my $href = $el->attr('href');
                $href =~ s/watch\?v=(.+)$/embed\/$1/;
                my $replacement = sprintf '<iframe width="%d" height="%d" src="%s" frameborder="%d" allow="%s" %s></iframe>',
                    $self->width, $self->height,
                    $href,
                    $self->frameborder,
                    $self->allow,
                    $self->allowfullscreen ? 'allowfullscreen' : '';
                $el->replace($replacement);
            });
        }
        else {
            $page->dom->find('a[href$=.'. $self->file_type .']')->each(sub {
                my ($el) = @_;
                my $replacement = sprintf '<video controls><source type="video/%s" src="%s"></video>',
                    $self->file_type, $el->attr('href');
                $el->replace($replacement);
            });
        }
    }
    return $page;
}

=head2 register

Register this plugin to install its event handlers. (This method is
called automatically.)

=cut

sub register {
    my ($self, $site) = @_;
    $site->on(build => sub {
        my ($event) = @_;
        for my $page (@{ $event->pages }) {
            $page = $self->video_tag($page);
        }
    });
}

1;
__END__

=head1 SEE ALSO

L<Statocles>

L<Statocles::Plugin>

L<Statocles::Plugin::AudioTag>

L<https://ology.github.io/2020/12/06/making-a-statocles-plugin/>

=cut
