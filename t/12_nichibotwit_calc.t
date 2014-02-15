use strict;
use warnings;
use utf8;
use Test::Base::Less;

use Time::Piece;

use Nichibotwit;

# Tokyo 2014-01-01  06:51 -> 16:38
subtest '2014-01-01 at Tokyo'    => sub {
    my $ntb = Nichibotwit->new(date => '2014-01-01', messages => {});

    is $ntb->sunrise->strftime('%H:%M') => '06:51';
    is $ntb->sunset->strftime('%H:%M')  => '16:38';
};

done_testing;
