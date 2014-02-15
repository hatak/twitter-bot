package Nichibotwit;
use strict;
use warnings;
use utf8;

use Astro::Sunrise;
use Moo;
use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util 'blessed';
use Time::Piece;
use Time::Seconds;

use namespace::clean;

my $tokyo = [139.7414, 35.6581, 9, 0];

has date => (
    is => 'ro',
    isa => sub {
        die 'date cannot parsed' unless (ref $_[0] eq 'Time::Piece')
    },
    coerce => sub {
        localtime(Time::Piece->strptime($_[0], '%Y-%m-%d'))
    },
    required => 1
);

has messages => (
    is => 'ro',
    isa => sub {
        die 'can\'t find data' unless ref $_[0] eq 'HASH'
    },
    required => 1
);

has sunrise => ( is => 'lazy' );
has sunset => ( is => 'lazy' );

before 'sunrise', 'sunset' => sub {
    my $self = shift;

    # return if sunrise times already calculated
    $self->{_sunrise} && $self->{_sunset} && return;

    ($self->{_sunrise}, $self->{_sunset}) = Astro::Sunrise::sunrise($self->date->year, $self->date->mon, $self->date->mday, @$tokyo, -0.583);
};

sub _build_sunrise {
    localtime(Time::Piece->strptime($_[0]->ymd . ' ' . $_[0]->{_sunrise}, '%Y-%m-%d %H:%M'));
}

sub _build_sunset {
    localtime(Time::Piece->strptime($_[0]->ymd . ' ' . $_[0]->{_sunset}, '%Y-%m-%d %H:%M'));
}

sub ymd {
    $_[0]->date->ymd;
}

sub is_expired {
    my $self = shift;
    my $t = shift || localtime;

    $self->ymd ne $t->ymd;
}

sub mode {
    my $self = shift;
    my $t = shift || localtime;

    # dawn(before sunrise), sunrise, daytime, sunset, night(after sunset)
    return 'sunrise' if (($t - $self->sunrise) >= 0 && ($t - $self->sunrise) < ONE_MINUTE);
    return 'sunset'  if (($t - $self->sunset) >= 0 && ($t - $self->sunset) < ONE_MINUTE);

    ($self->sunset < $t) ? 'night' : ($self->sunrise < $t) ? 'daytime' : 'dawn';
}

sub say {
    my $self = shift;
    my $t = shift;

    my $message;

    my $mode = $self->mode;
    my $index = int rand @{$self->messages->{$mode}};
    if ($mode =~ /sun(rise|set)/) {
        # sunrise or sunset
        my $time = $self->$mode;
        $message = sprintf $self->messages->{$mode}[$index], $time->hour, $time->min;
    }

    return $message;
}

sub tweet {
    my $self = shift;

    if (my $message = $self->say) {
        my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
            consumer_key        => '<consumer key>',
            consumer_secret     => '<consumer secret>',
            access_token        => '<access token>',
            access_token_secret => '<access_token_secret>',
            ssl                 => 1,
        );
        $nt->update($message);
    }
}

1;
