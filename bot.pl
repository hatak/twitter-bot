#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.018000;
use autodie;

use AnyEvent;
use Time::Piece;
use Log::Minimal;
use YAML::Syck; $YAML::Syck::ImplicitUnicode = 1;
use FindBin;

use lib "$FindBin::RealBin/lib";
use Nichibotwit;

my $file_path = $FindBin::Bin . '/data/nichibotwit.yaml';

my $start_time = localtime;

my $ntb = Nichibotwit->new(
    date     => $start_time->ymd,
    messages => YAML::Syck::LoadFile($file_path)->{'normal'}
);
infof('create new instance: %s', $ntb->ymd);

my $cv = AnyEvent->condvar;
my $w = AnyEvent->timer(
    after => 0,
    interval => 60,
    cb => sub {
        my $current_time = localtime;
        if ($ntb->is_expired) {
            $ntb = Nichibotwit->new(
                date     => $current_time->ymd,
                messages => YAML::Syck::LoadFile($file_path)->{'normal'}
            );
            infof('create new instance: %s', $ntb->ymd);
        }
        $ntb->tweet;
    }
);

$cv->recv;
