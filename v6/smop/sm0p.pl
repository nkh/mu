#!/usr/bin/perl

use strict;
use warnings;
use IO::Select;
use IO::Handle;
use IPC::Open3;
use Symbol;

my ($base, $in, $out) = @ARGV;

die 'You need to checkout v6/ and not v6/smop, because smop depends on KP6' unless -d $base.'/../v6-KindaPerl6';

open my $input, '<', $in or die $!;
open my $output, '>', $out or die $!;

my $sm0p_code = '';
my $out_count = 1;
print {$output} qq{#line 1 "$in"\n};

sub quasi {
    my %quasi = @_;
    while ( my ($lang,$processor) = each %quasi) {
        if (/^(\s*)(.*?)q:\Q$lang\E\s*\{\s*$/) {
            print {$output} $1.$2;
            my $code = '';
            my $indent = $1;
            #warn "quasi $lang indent<$indent>\n";
            while (<$input>) {
                $out_count++;
                if (/^$indent\}(.*)$/) {
                    print {$output} $processor->($code);
                    print {$output} $1;
                    last;
                }
                $code .= $_;
            }
            return 1;
        }
    }
    return 0;
}
eval {
  PRINCIPAL:
    while (<$input>) {
        $out_count++;
        quasi(
            'sm0p' => \&preprocess_sm0p,
            'm0ld' => \&preprocess_m0ld,
            'v6-sm0p' => \&preprocess_p6_sm0p,
            'v6-m0ld' => \&preprocess_p6_m0ld,
        ) and next;
        print {$output} $_;
    }
};

if ($@) {
    close $output;
    unlink $out;
    print STDERR $@;
    exit 1;
}


sub preprocess {
    my $code = shift;
    my ($writer, $reader, $error) = map { gensym } 1..3;
    my $pid = open3($writer, $reader, $error,@_) || die "$@";
    print {$writer} $code;
    close $writer;

    my ($errbuf, $retbuf) = ('','');

    $reader->blocking(0);
    $error->blocking(0);

    my $select = IO::Select->new();
    $select->add($reader);
    $select->add($error);

    while ($select->can_read(10000) && (!eof($reader) || !eof($error))) {

        my $buf = '';
        my $returncode = read $reader, $buf, 1024;
        $retbuf .= $buf;

        $buf = '';
        my $returncode2 = read $error, $buf, 1024;
        $errbuf .= $buf;

    }

    print $errbuf;
    close $reader;
    close $error;
    waitpid($pid,0);
    die join(' ',@_).' returned failure '.$? if ($? || !$retbuf || $retbuf eq "\n") ;
    return $retbuf;
}
sub preprocess_p6_sm0p {
    my $code = shift;
    my ($writer, $reader, $error) = map { gensym } 1..3;
    my $sm0p = preprocess('','perl',"$base/../../misc/elfish/elfX/elfX",'-C','sm0p','-s','-e',$code);
    return preprocess_sm0p(
        $sm0p
        . "\$SMOP__SLIME__CurrentFrame.\$SMOP__ID__forget();\n"
        . "\$interpreter.goto(|\$continuation);\n"
        );
}
sub preprocess_p6_m0ld {
    my $code = shift;
    my ($writer, $reader, $error) = map { gensym } 1..3;
    my $m0ld = preprocess('','perl',"$base/../../misc/elfish/elfX/elfX",'-C','m0ld','-s','-e',$code);
    return preprocess_m0ld($m0ld);
}
sub preprocess_sm0p {
    my $code = shift;
    #warn "got sm0p code <$code>\n";
    return preprocess($code,'perl',"-I$base/../../src/perl6",
        '-I'.$base.'/sm0p',
        $base.'/sm0p/sm0p_with_actions');
}
sub preprocess_m0ld {
    my $code = shift;
    #warn "got m0ld code <$code>\n";
    return preprocess($code,"$base/m0ld/m0ld");
}
