use strict;
use warnings;
use utf8;
use Test::Base::Less;

use Time::Piece;

use Nichibotwit;

# Tokyo 2014-01-01  06:51 -> 16:38
my $ntb = Nichibotwit->new(date => '2014-01-01', messages => {});

run {
    my $block = shift;

    my $time = localtime(Time::Piece->strptime('2014-01-01 '.$block->input, '%Y-%m-%d %H:%M'));
    is $ntb->mode($time) => $block->expected;
};

done_testing;

__DATA__

===
--- input: 00:00
--- expected: dawn

===
--- input: 06:50
--- expected: dawn

===
--- input: 06:51
--- expected: sunrise

===
--- input: 06:52
--- expected: daytime

===
--- input: 12:00
--- expected: daytime

===
--- input: 16:37
--- expected: daytime

===
--- input: 16:38
--- expected: sunset

===
--- input: 16:39
--- expected: night

===
--- input: 23:59
--- expected: night
