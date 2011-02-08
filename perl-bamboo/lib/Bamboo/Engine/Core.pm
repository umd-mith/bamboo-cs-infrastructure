package Bamboo::Engine::Core;
  use Bamboo::Engine::TagLib;
  use Math::BigRat;

  namespace 'http://dh.tamu.edu/ns/fabulator/1.0#';

  type boolean => (
    goings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        'string' => {
          weight => 1.0,
          converting => sub {
            $_[0] -> root -> value ? 'true' : '';
          }
        },
        'numeric' => {
          weight => 1.0,
          converting => sub {
            Math::BigRat -> new($_[0] -> root -> value ? '1' : '0');
          }
        },
      }
    },
  );

  type string => (
    goings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        boolean => {
          weight => 0.0001,
          converting => sub {
            my $v = $_[0] -> root -> value;
            !(!defined($v) || $v eq '' || $v =~ /^\s*$/);
          },
        },
        html => {
          weight => 1.0,
          converting => sub {
            my $v = $_[0] -> root -> value;
            $v =~ s/&/&amp;/g;
            $v =~ s/</&lt;/g;
            $v =~ s/>/&gt;/g;
            $v;
          },
        },
      },
    },
  );

  type html => (
    goings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        string => {
          weight => 1.0,
          converting => sub {
            my $v = $_[0] -> root -> value;
            $v =~ s/&gt;/>/g;
            $v =~ s/&lt;/</g;
            $v =~ s/&amp;/&/g;
            $v;
          },
        },
      },
    },
  );

  type uri => (
    goings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        string => {
          weight => 1.0,
          converting => sub {
            $_[0] -> root -> get_attribute('namespace').value .
            $_[0] -> root -> get_attribute('name').value 
          },
        },
      },
    },
    comings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        string => {
          weight => 1.0,
          converting => sub {
            my $p = $_[0] -> root -> value;
            my($ns, $name);
            if($p =~ /^([a-zA-Z_][-a-zA-Z0-9_.]*):([a-zA-Z_][-a-zA-Z0-9_.]*)$/) {
              my $ns_prefix = $1;
              $name = $2;
              $ns = $_[0] -> ns($ns_prefix);
            }
            else {
              $p =~ /^(.*?)([a-zA-Z_][-a-zA-Z0-9_/]*)$/
              $ns = $1;
              $name = $2;
            }
            my $r = $_[0] -> root -> anon_node();
            $r -> attribute(namespace => $ns);
            $r -> attribute(name => $name);
            $r;
          },
        },
      },
    },
  );

  type numeric => (
    goings => {
      'http://dh.tamu.edu/ns/fabulator/1.0#' => {
        string => {
          weight => 1.0,
          converting => sub {
            my($n, $d) = $_[0] -> root -> value -> parts();
            if( $n > $d ) {
              my( $quo, $rem ) = $n -> bdiv( $d );
              return "$quo $rem/$d";
            }
            return "$n/$d";
          },
        },
        boolean => {
          weight => 0.0001,
          converting => sub {
            !$_[0] -> root -> value -> is_zero;
          }
        },
      },
    },
  );

  mapping abs => sub {
    $_[0] -> to(type 'numeric') -> value -> babs();
  };

  mapping ceiling => sub {
    $_[0] -> to(type 'numeric') -> value -> bceil();
  };

  mapping floor => sub {
    $_[0] -> to(type 'numeric') -> value -> bfloor();
  };

  mapping 'random' => sub {
    my $v = $_[0] -> to(type 'numeric') -> value -> as_int();
    if($v <= 0) {
      return Math::BigRat -> new('0');
    }
    else {
      return Math::BigRat -> new(rand($v) + 1);
    }
  };

  reduction sum => sub {
    my $sum = Math::BigRat -> new(0);
    +{
      'next' => sub {
        $sum += $_;
      },
      'done' => sub {
        $sum
      }
    }
  };

  reduction avg => sub {
    my $sum = Math::BigRat -> new(0);
    my $n = Math::BigRat -> new(0);
    +{
      'next' => sub {
        $sum += $_;
        $n += 1;
      },
      'done' => sub {
        $sum / $n;
      }
    }
  };

  reduction max => sub {
    my $max;

    +{
      'next' => sub {
        $max = $_[0] unless defined($max) && $max > $_[0];
      },
      'done' => sub { $max }
    }
  };

  consolidation max => reduction 'max';

  reduction 'min' => sub {
    my $min;
    +{
      next => sub {
       $min = $_[0] unless defined($min) && $min < $_[0];
      },
      done => sub { $min }
    }
  };

  consolidation min => reduction 'min';

  reduction histogram => sub {
    my $acc = { };
    +{
      next => sub {
        my $k = $_[0] -> to(type 'string') -> value;
        $acc{$k} ||= 0;
        $acc{$k} += 1;
      },
      done => sub { $acc }
    }
  };

  consolidation histogram => sub {
    my $acc = { };
    +{
      next => sub { },
      done => sub { },
    }
  };

  ###
  ### String functions
  ###

  reduction concat => sub {
    my $acc = '';
    +{
      next => sub {
        $acc .= $_[0] -> to(type 'string') -> value;
      },
      done => sub { $acc }
    }
  };

  consolidation concat => reduction 'concst';

  function 'string-join' => sub {
    my($ctx, $joiner, @args) = @_;

  };

  function substring => sub {
  };

  mapping 'string-length' => sub {
    
  };


  consolidation count => reduction 'sum';

1;

__END__
use Bamboo::Engine::TagLib;

library 'http://dh.tamu.edu/ns/fabulator/1.0#' => 'Bamboo::Engine::Core' {

  xmlns f => 'http://dh.tamu.edu/ns/fabulator/1.0#';

  structural application;
  structural view;
  structural goes-to;
  structural params;
  structural group;
  structural param;
  structural value;
  structural constraint;
  structural filter;

  action choose;
  action for-each;
  action value-of;
  action value,
  action variable;
  action if;
  action go-to;
  action raise;
  action div;
  action catch;

  mapping abs (f:numeric) {
    abs($arg -> value);
  }

  mapping ceiling (f:numeric) {
    $_ -> value;
  }

  mapping floor (f:numeric) {
  }

  mapping random (f:numeric) {
  }

  reduction sum (f:numeric) {
    my $sum = 0;
    $sum += $_->value for @_;
    return $sum;
  }

  consolidation sum {
    my $sum = 0;
    $sum += $_->value for @_;
    return $sum;
  }

  reduction avg (f:numeric) {
    my $sum = 0;
    $sum += $_->value for @_;
    return $sum/@_;
  }

}
