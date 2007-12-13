# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;

package KindaPerl6::Visitor::RegexCapture;
sub new { shift; bless {@_}, "KindaPerl6::Visitor::RegexCapture" }

sub visit {
    my $self   = shift;
    my $List__ = \@_;
    my $node;
    my $node_name;
    do { $node = $List__->[0]; $node_name = $List__->[1]; [ $node, $node_name ] };
    do {
        if ( ( $node_name eq 'Token' ) ) { $node->regex()->capture_count( 0, 0, {} ); return ($node) }
        else { }
    };
    return ( (undef) );
}

package P5Token;
sub new { shift; bless {@_}, "P5Token" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Quantifier;
sub new { shift; bless {@_}, "Rule::Quantifier" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $self->{term}->capture_count( $count, 1, $seen );
    $count;
}

package Rule::Or;
sub new { shift; bless {@_}, "Rule::Or" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    my $max = $count;
    do {

        for my $regex ( @{ $self->{or} } ) {
            my $last = $regex->capture_count( $count, $quantified, $seen );
            do {
                if ( ( $last > $max ) ) { $max = $last }
                else { }
                }
        }
    };
    $max;
}

package Rule::Concat;
sub new { shift; bless {@_}, "Rule::Concat" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    do {
        for my $regex ( @{ $self->{concat} } ) { $count = $regex->capture_count( $count, $quantified, $seen ) }
    };
    $count;
}

package Rule::SubruleNoCapture;
sub new { shift; bless {@_}, "Rule::SubruleNoCapture" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Var;
sub new { shift; bless {@_}, "Rule::Var" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Constant;
sub new { shift; bless {@_}, "Rule::Constant" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Dot;
sub new { shift; bless {@_}, "Rule::Dot" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::SpecialChar;
sub new { shift; bless {@_}, "Rule::SpecialChar" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Block;
sub new { shift; bless {@_}, "Rule::Block" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::InterpolateVar;
sub new { shift; bless {@_}, "Rule::InterpolateVar" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Before;
sub new { shift; bless {@_}, "Rule::Before" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    do {
        if ( ( $self->{assertion_modifier} ne '' ) ) { return ($count) }
        else { }
    };
    $self->{capture_to_array} = ( $quantified || ( $seen->{'before'} && 1 ) );
    do {
        if ( $seen->{'before'} ) { $seen->{'before'}->capture_to_array(1) }
        else { }
    };
    $seen->{'before'} = $self;
    $self->{rule}->capture_count( 0, 0, {} );
    $count;
}

package Rule::After;
sub new { shift; bless {@_}, "Rule::After" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    do {
        if ( ( $self->{assertion_modifier} ne '' ) ) { return ($count) }
        else { }
    };
    $self->{capture_to_array} = ( $quantified || ( $seen->{'after'} && 1 ) );
    do {
        if ( $seen->{'after'} ) { $seen->{'after'}->capture_to_array(1) }
        else { }
    };
    $seen->{'after'} = $self;
    $self->{rule}->capture_count( 0, 0, {} );
    $count;
}

package Rule::NegateCharClass;
sub new { shift; bless {@_}, "Rule::NegateCharClass" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::CharClass;
sub new { shift; bless {@_}, "Rule::CharClass" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $count;
}

package Rule::Subrule;
sub new { shift; bless {@_}, "Rule::Subrule" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    my $meth = ( ( 1 + index( $self->{metasyntax}, '.' ) ) ? ( $self->{metasyntax} . ' ... TODO ' ) : ( '\'$\'.$GLOBAL::_Class.\'::_regex_' . ( $self->{metasyntax} . '\'' ) ) );
    $self->{ident} = $self->{metasyntax};
    $self->{capture_to_array} = ( $quantified || ( $seen->{ $self->{ident} } && 1 ) );
    do {
        if ( $seen->{ $self->{ident} } ) { $seen->{ $self->{ident} }->capture_to_array(1) }
        else { }
    };
    $seen->{ $self->{ident} } = $self;
    $count;
}

package Rule::NamedCapture;
sub new { shift; bless {@_}, "Rule::NamedCapture" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $self->{capture_to_array} = ( $quantified || ( $seen->{ $self->{ident} } && 1 ) );
    $self->{rule}->capture_count( 0, 0, {} );
    do {
        if ( $seen->{ $self->{ident} } ) { $seen->{ $self->{ident} }->capture_to_array(1) }
        else { }
    };
    $seen->{ $self->{ident} } = $self;
    $count;
}

package Rule::Capture;
sub new { shift; bless {@_}, "Rule::Capture" }

sub capture_count {
    my $self   = shift;
    my $List__ = \@_;
    my $count;
    my $quantified;
    my $seen;
    do { $count = $List__->[0]; $quantified = $List__->[1]; $seen = $List__->[2]; [ $count, $quantified, $seen ] };
    $self->{position} = $count;
    $self->{capture_to_array} = ( $quantified || ( $seen->{ $self->{ident} } && 1 ) );
    do {
        if ( $seen->{ $self->{ident} } ) { $seen->{ $self->{ident} }->capture_to_array(1) }
        else { }
    };
    $seen->{$count} = $self;
    $self->{rule}->capture_count( 0, 0, {} );
    ( $count + 1 );
}

1;
