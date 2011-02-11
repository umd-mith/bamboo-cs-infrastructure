package Utukku::Shell::Base;
  use Utukku::Shell::CommandSet;

  command '?' => sub {
    my($shell, @bits) = @_;

    if( @bits ) {
      # do help for the command
    }
    else {
      $shell -> print("help!!\n");
    }
  };

  command quit => sub {
    exit 0;
  };

  command clear => sub {
    my($shell, @bits) = @_;

    # we can clear vars - start with a $
    # or namespaces - start with xmlns:
    if( @bits == 1 ) {
      if( $bits[0] =~ /^\$(.*)$/ ) {
        # clear variable
      }
      elsif( $bits[0] =~ /^xmlns:(.*)$/ ) {
        # clear namespace
      }
    }
  };

1;  
