package Statocles::Plugin::VideoTag;

# ABSTRACT: Change video file anchors to video elements

our $VERSION = '0.0100';

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
                     file_type: 'ogg'

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

=head1 METHODS

=head2 video_tag

  $page = $plugin->video_tag($page);

Process the video bits of a L<Statocles::Page>.

=cut

sub video_tag {
    my ($self, $page) = @_;
    if ($page->has_dom) {
        $page->dom->find('a[href$=.'. $self->file_type .']')->each(sub {
            my ($el) = @_;
            my $replacement = sprintf '<video controls><source type="video/%s" src="%s"></video>',
                $self->file_type, $el->attr('href');
            $el->replace($replacement);
        });
    }
    return $page;
}

=head2 register

Register this plugin to install its event handlers. Called automatically.

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
