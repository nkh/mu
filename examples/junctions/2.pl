# read from STDIN and print

my @color = <red green blue>;

my $x = any @color;


print "enter a colour: ";
my $y = $*IN.get;

my $result = ($x eq $y) ?? "acceptable" !! 'unacceptable' ;

print "$y is an $result color:\n";


