use strict;
use warnings;
use utf8;
use Test::More;

use Nichibotwit;

subtest 'initialize' => sub {
    my $ntb = Nichibotwit->new(date => '2014-01-01', messages => {});
    isa_ok $ntb, 'Nichibotwit';
};

subtest 'ymd'    => sub {
    my $ntb = Nichibotwit->new(date => '2014-01-01', messages => {});
    is $ntb->ymd => '2014-01-01';

};

done_testing;

