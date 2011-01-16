########################################################################################
#
#    This file was generated using Parse::Eyapp version 1.178.
#
# (c) Parse::Yapp Copyright 1998-2001 Francois Desarmenien.
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon. Universidad de La Laguna.
#        Don't edit this file, use source file 'engine-parser.eyp' instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
########################################################################################
package Bamboo::Engine::Parser;
use strict;

push @Bamboo::Engine::Parser::ISA, 'Parse::Eyapp::Driver';



  # Loading Parse::Eyapp::Driver
  BEGIN {
    unless (Parse::Eyapp::Driver->can('YYParse')) {
      eval << 'MODULE_Parse_Eyapp_Driver'
#
# Module Parse::Eyapp::Driver
#
# This module is part of the Parse::Eyapp package available on your
# nearest CPAN
#
# This module is based on Francois Desarmenien Parse::Yapp module
# (c) Parse::Yapp Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (c) Parse::Eyapp Copyright 2006-2010 Casiano Rodriguez-Leon, all rights reserved.

our $SVNREVISION = '$Rev: 2399M $';
our $SVNDATE     = '$Date: 2009-01-06 12:28:04 +0000 (mar, 06 ene 2009) $';

package Parse::Eyapp::Driver;

require 5.006;

use strict;

our ( $VERSION, $COMPATIBLE, $FILENAME );


# $VERSION is also in Parse/Eyapp.pm
$VERSION = "1.178";
$COMPATIBLE = '0.07';
$FILENAME   =__FILE__;

use Carp;
use Scalar::Util qw{blessed reftype looks_like_number};

use Getopt::Long;

#Known parameters, all starting with YY (leading YY will be discarded)
my (%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
       YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '', 
       # added by Casiano
       #YYPREFIX  => '',  # Not allowed at YYParse time but in new
       YYFILENAME => '', 
       YYBYPASS   => '',
       YYGRAMMAR  => 'ARRAY', 
       YYTERMS    => 'HASH',
       YYBUILDINGTREE  => '',
       YYACCESSORS => 'HASH',
       YYCONFLICTHANDLERS => 'HASH',
       YYLABELS => 'HASH',
       ); 
my (%newparams) = (%params, YYPREFIX => '',);

#Mandatory parameters
my (@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;

    my($errst,$nberr,$token,$value,$check,$dotpos);

    my($self)={ 
      ERRST => \$errst,
      NBERR => \$nberr,
      TOKEN => \$token,
      VALUE => \$value,
      DOTPOS => \$dotpos,
      STACK => [],
      DEBUG => 0,
      PREFIX => "",
      CHECK => \$check, 
    };

  _CheckParams( [], \%newparams, \@_, $self );

    exists($$self{VERSION})
  and $$self{VERSION} < $COMPATIBLE
  and croak "Eyapp driver version $VERSION ".
        "incompatible with version $$self{VERSION}:\n".
        "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    unless($self->{ERROR}) {
      $self->{ERROR} = $class->error;
      $self->{ERROR} = \&_Error unless ($self->{ERROR});
    }

    unless ($self->{LEX}) {
        $self->{LEX} = $class->YYLexer;
        @params = ('RULES','STATES');
    }

    my $parser = bless($self,$class);

    $parser;
}

sub YYParse {
    my($self)=shift;
    my($retval);

  _CheckParams( \@params, \%params, \@_, $self );

  unless($self->{ERROR}) {
    $self->{ERROR} = $self->error;
    $self->{ERROR} = \&_Error unless ($self->{ERROR});
  }

  unless($self->{LEX}) {
    $self->{LEX} = $self->YYLexer;
    croak "Missing parameter 'yylex' " unless $self->{LEX} && reftype($self->{LEX}) eq 'CODE';
  }

  if($$self{DEBUG}) {
    _DBLoad();
    $retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
  }
  else {
    $retval = $self->_Parse();
  }
    return $retval;
}

sub YYData {
  my($self)=shift;

    exists($$self{USER})
  or  $$self{USER}={};

  $$self{USER};
  
}

sub YYErrok {
  my($self)=shift;

  ${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
  my($self)=shift;

  ${$$self{NBERR}};
}

sub YYRecovering {
  my($self)=shift;

  ${$$self{ERRST}} != 0;
}

sub YYAbort {
  my($self)=shift;

  ${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
  my($self)=shift;

  ${$$self{CHECK}}='ACCEPT';
    undef;
}

# Used to set that we are in "error recovery" state
sub YYError {
  my($self)=shift;

  ${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
  my($self)=shift;
  my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

    $index < 0
  and -$index <= @{$$self{STACK}}
  and return $$self{STACK}[$index][1];

  undef;  #Invalid index
}

### Casiano methods

sub YYRule { 
  # returns the list of rules
  # counting the super rule as rule 0
  my $self = shift;
  my $index = shift;

  if ($index) {
    $index = $self->YYIndex($index) unless (looks_like_number($index));
    return wantarray? @{$self->{RULES}[$index]} : $self->{RULES}[$index]
  }

  return wantarray? @{$self->{RULES}} : $self->{RULES}
}

# YYState returns the list of states. Each state is an anonymous hash
#  DB<4> x $parser->YYState(2)
#  0  HASH(0xfa7120)
#     'ACTIONS' => HASH(0xfa70f0) # token => state
#           ':' => '-7'
#     'DEFAULT' => '-6'
# There are three keys: ACTIONS, GOTOS and  DEFAULT
#  DB<7> x $parser->YYState(13)
# 0  HASH(0xfa8b50)
#    'ACTIONS' => HASH(0xfa7530)
#       'VAR' => 17
#    'GOTOS' => HASH(0xfa8b20)
#       'type' => 19
sub YYState {
  my $self = shift;
  my $index = shift;

  if ($index) {
    # Comes from the stack: a pair [state number, attribute]
    $index = $index->[0] if 'ARRAY' eq reftype($index);
    die "YYState error. Expecting a number, found <$index>" unless (looks_like_number($index));
    return $self->{STATES}[$index]
  }

  return $self->{STATES}
}

sub YYGoto {
  my ($self, $state, $symbol) = @_;
 
  my $stateLRactions = $self->YYState($state);

  $stateLRactions->{GOTOS}{$symbol};
}

sub YYRHSLength {
  my $self = shift;
  # If no production index is given, is the production begin used in the current reduction
  my $index = shift || $self->YYRuleindex;

  # If the production was given by its name, compute its index
  $index = $self->YYIndex($index) unless looks_like_number($index); 
  
  return unless looks_like_number($index);

  my $currentprod = $self->YYRule($index);

  $currentprod->[1] if reftype($currentprod);
}

# To be used in a semantic action, when reducing ...
# It gives the next state after reduction
sub YYNextState {
  my $self = shift;

  my $lhs = $self->YYLhs;

  if ($lhs) { # reduce
    my $length = $self->YYRHSLength;

    my $state = $self->YYTopState($length);
    #print "state = $$state[0]\n";
    $self->YYGoto($state, $lhs);
  }
  else { # shift: a token must be provided as argument
    my $token = shift;
    
    my $state = $self->YYTopState;
    $self->YYGetLRAction($state, $token);
  }
}

# TODO: make it work with a list of indices ...
sub YYGrammar { 
  my $self = shift;
  my $index = shift;

  if ($index) {
    $index = $self->YYIndex($index) unless (looks_like_number($index));
    return wantarray? @{$self->{GRAMMAR}[$index]} : $self->{GRAMMAR}[$index]
  }
  return wantarray? @{$self->{GRAMMAR}} : $self->{GRAMMAR}
}

# Return the list of production names
sub YYNames { 
  my $self = shift;

  my @names = map { $_->[0] } @{$self->{GRAMMAR}};

  return wantarray? @names : \@names;
}

# Return the hash of indices  for each production name
# Initializes the INDICES attribute of the parser
# Returns the index of the production rule with name $name
sub YYIndex {
  my $self = shift;

  if (@_) {
    my @indices = map { $self->{LABELS}{$_} } @_;
    return wantarray? @indices : $indices[0];
  }
  return wantarray? %{$self->{LABELS}} : $self->{LABELS};

}

sub YYTopState {
  my $self = shift;
  my $length = shift || 0;

  $length = -$length unless $length <= 0;
  $length--;

  $_[1] and $self->{STACK}[$length] = $_[1];
  $self->{STACK}[$length];
}

sub YYStack {
  my $self = shift;

  return $self->{STACK};
}

# To dynamically set syntactic actions
# Change it to state, token, action
# it is more natural
sub YYSetLRAction {
  my ($self,  $state, $token, $action) = @_;

  die "YYLRAction: Provide a state " unless defined($state);

  # Action can be given using the name of the production
  $action = -$self->YYIndex($action) unless looks_like_number($action);
  $token = [ $token ] unless ref($token);
  for (@$token) {
    $self->{STATES}[$state]{ACTIONS}{$_} = $action;
  }
}

sub YYRestoreLRAction {
  my $self = shift;
  my $conflictname = shift;
  my @tokens = @_;

  for (@tokens) {
    my ($conflictstate, $action) = @{$self->{CONFLICT}{$conflictname}{$_}};
    $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $action;
  }
}

# Fools the lexer to get a new token
# without modifying the parsing position (pos)
# Warning, warning! this and YYLookaheads assume
# that the input comes from the string
# referenced by $self->input.
# It will not work for a stream 
sub YYLookahead {
  my $self = shift;

  my $pos = pos(${$self->input});
  my ($nextToken, $val) = $self->YYLexer->($self);
  # restore pos
  pos(${$self->input}) = $pos;
  return $nextToken;
}

# Fools the lexer to get $spec new tokens
sub YYLookaheads {
  my $self = shift;
  my $spec = shift || 1; # a number

  my $pos = pos(${$self->input});
  my @r; # list of lookahead tokens

  my ($t, $v);
  if (looks_like_number($spec)) {
    for my $i (1..$spec) { 
      ($t, $v) = $self->YYLexer->($self);
      push @r, $t;
      last if $t eq '';
    }
  }
  else { # if string
    do {
      ($t, $v) = $self->YYLexer->($self);
      push @r, $t;
    } while ($t ne $spec && $t ne '');
  }

  # restore pos
  pos(${$self->input}) = $pos;

  return @r;
}


# more parameters: debug, etc, ...
#sub YYNestedParse {
sub YYPreParse {
  my $self = shift; 
  my $parser = shift;
  my $file = shift() || $parser;

  # Check for errors!
  eval "require $file";
   
  # optimize to state variable for 5.10
  my $rp = $parser->new( yyerror => sub {});

  my $pos  = pos(${$self->input});
  my $rpos = $self->{POS};;

  #print "pos = $pos\n";
  $rp->input($self->input);
  pos(${$rp->input}) = $rpos;

  my $t = $rp->Run(@_);
  my $ne = $rp->YYNberr;

  #print "After nested parsing\n";

  pos(${$self->input}) = $pos;

  return (wantarray ? ($t, !$ne) : !$ne);
}

sub YYNestedParse {
  my $self = shift;
  my $parser = shift;
  my $conflictName = $self->YYLhs;
  $conflictName =~ s/_explorer$//;

  my ($t, $ok) = $self->YYPreParse($parser, @_);

  $self->{CONFLICTHANDLERS}{$conflictName}{".".$parser} = [$ok, $t];

  return $ok;
}

sub YYIs {
  my $self = shift;
  # this is ungly and dangeorus. Don't use the dot. Change it!
  my $syntaxVariable = '.'.(shift());
  my $conflictName = $self->YYLhs;
  my $v = $self->{CONFLICTHANDLERS}{$conflictName};

  $v->{$syntaxVariable}[0] = shift if @_;
  return $v->{$syntaxVariable}[0];
}


sub YYVal {
  my $self = shift;
  # this is ungly and dangeorus. Don't use the dot. Change it!
  my $syntaxVariable = '.'.(shift());
  my $conflictName = $self->YYLhs;
  my $v = $self->{CONFLICTHANDLERS}{$conflictName};

  $v->{$syntaxVariable}[1] = shift if @_;
  return $v->{$syntaxVariable}[1];
}

#x $self->{CONFLICTHANDLERS}                                                                              
#0  HASH(0x100b306c0)
#   'rangeORenum' => HASH(0x100b30660)
#      'explorerline' => 12
#      'line' => 5
#      'production' => HASH(0x100b30580)
#         '-13' => ARRAY(0x100b30520)
#            0  1 <------- mark: conflictive position in the rhs 
#         '-5' => ARRAY(0x100b30550)
#            0  1 <------- mark: conflictive position in the rhs 
#      'states' => ARRAY(0x100b30630)
#         0  HASH(0x100b30600)
#            25 => ARRAY(0x100b305c0)
#               0  '\',\''
#               1  '\')\''
sub YYSetReduce {
  my $self = shift;
  my $action = pop;
  my $token = shift;
  

  croak "YYSetReduce error: specify a production" unless defined($action);

  # Conflict state
  my $conflictstate = $self->YYNextState();

  my $conflictName = $self->YYLhs;

  #$self->{CONFLICTHANDLERS}{conflictName}{states}
  # is a hash
  #        statenumber => [ tokens, '\'-\'' ]
  my $cS = $self->{CONFLICTHANDLERS}{$conflictName}{states};
  my @conflictStates = $cS ? @$cS : ();

  # Perform the action to change the LALR tables only if the next state 
  # is listed as a conflictstate
  my ($cs) = (grep { exists $_->{$conflictstate}} @conflictStates); 
  return unless $cs;

  # Action can be given using the name of the production
  unless (looks_like_number($action)) {
    my $actionnum = $self->{LABELS}{$action};
    unless (looks_like_number($actionnum)) {
      croak "YYSetReduce error: can't find production '$action'. Did you forget to name it?";
    }
    $action = -$actionnum;
  }

  $token = $cs->{$conflictstate} unless defined($token);
  $token = [ $token ] unless ref($token);
  for (@$token) {
    # save if shift
    if ($self->{STATES}[$conflictstate]{ACTIONS}{$_} >= 0) {
      $self->{CONFLICT}{$conflictName}{$_}  = [ $conflictstate,  $self->{STATES}[$conflictstate]{ACTIONS}{$_} ];
    }
    $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $action;
  }
}

sub YYSetShift {
  my ($self, $token) = @_;

  # my ($self, $token, $action) = @_;
  # $action is syntactic sugar ...

  # Conflict state
  my $conflictstate = $self->YYNextState();

  my $conflictName = $self->YYLhs;

  my $cS = $self->{CONFLICTHANDLERS}{$conflictName}{states};
  my @conflictStates = $cS ? @$cS : ();

  # Perform the action to change the LALR tables only if the next state 
  # is listed as a conflictstate
  my ($cs) = (grep { exists $_->{$conflictstate}} @conflictStates); 
  return unless $cs;

  $token = $cs->{$conflictstate} unless defined($token);
  $token = [ $token ] unless ref($token);

  my $conflictname = $self->YYLhs;
  for (@$token) {
    if (defined($self->{CONFLICT}{$conflictname}{$_}))  {
      my ($conflictstate2, $action) = @{$self->{CONFLICT}{$conflictname}{$_}};
      # assert($conflictstate == $conflictstate2) 

      $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $self->{CONFLICT}{$conflictname}{$_}[1];
    }
    else {
      #croak "YYSetShift error. No shift action found";
      # shift is the default ...  hope to be lucky!
    }
  }
}


  # if is reduce ...
    # x $self->{CONFLICTHANDLERS}{$conflictName}{production}{$action} $action is a number
    #0  ARRAY(0x100b3f930)
    #   0  2
    # has the position in the item, starting at 0
    # DB<19> x $self->YYRHSLength(4)
    # 0  3
    # if pos is length -1 then is reduce otherwise is shift


# It does YYSetReduce or YYSetshift according to the 
# decision variable
# I need to know the kind of conflict that there is
# shift-reduce or reduce-reduce
sub YYIf {
  my $self = shift;
  my $syntaxVariable = shift;

  if ($self->YYIs($syntaxVariable)) {
    if ($_[0] eq 'shift') {
      $self->YYSetShift(@_); 
    }
    else {
      $self->YYSetReduce($_[0]); 
    }
  }
  else {
    if ($_[1] eq 'shift') {
      $self->YYSetShift(@_); 
    }
    else {
      $self->YYSetReduce($_[1]); 
    }
  }
}

sub YYGetLRAction {
  my ($self,  $state, $token) = @_;

  $state = $state->[0] if reftype($state) && (reftype($state) eq 'ARRAY');
  my $stateentry = $self->{STATES}[$state];

  if (defined($token)) {
    return $stateentry->{ACTIONS}{$token} if exists $stateentry->{ACTIONS}{$token};
  }

  return $stateentry->{DEFAULT} if exists $stateentry->{DEFAULT};

  return;
}

# to dynamically set semantic actions
sub YYAction {
  my $self = shift;
  my $index = shift;
  my $newaction = shift;

  croak "YYAction error: Expecting an index" unless $index;

  # If $index is the production 'name' find the actual index
  $index = $self->YYIndex($index) unless looks_like_number($index);
  my $rule = $self->{RULES}->[$index];
  $rule->[2] = $newaction if $newaction && (reftype($newaction) eq 'CODE');

  return $rule->[2];
}

sub YYSetaction {
  my $self = shift;
  my %newaction = @_;

  for my $n (keys(%newaction)) {
    my $m = looks_like_number($n) ? $n : $self->YYIndex($n);
    my $rule = $self->{RULES}->[$m];
    $rule->[2] = $newaction{$n} if ($newaction{$n} && (reftype($newaction{$n}) eq 'CODE'));
  }
}

#sub YYDebugtree  {
#  my ($self, $i, $e) = @_;
#
#  my ($name, $lhs, $rhs) = @$e;
#  my @rhs = @$rhs;
#
#  return if $name =~ /_SUPERSTART/;
#  $name = $lhs."::"."@rhs";
#  $name =~ s/\W/_/g;
#  return $name;
#}
#
#sub YYSetnames {
#  my $self = shift;
#  my $newname = shift || \&YYDebugtree;
#
#    die "YYSetnames error. Exected a CODE reference found <$newname>" 
#  unless $newname && (reftype($newname) eq 'CODE');
#
#  my $i = 0;
#  for my $e (@{$self->{GRAMMAR}}) {
#     my $nn= $newname->($self, $i, $e);
#     $e->[0] = $nn if defined($nn);
#     $i++;
#  }
#}

sub YYLhs { 
  # returns the syntax variable on
  # the left hand side of the current production
  my $self = shift;

  return $self->{CURRENT_LHS}
}

sub YYRuleindex { 
  # returns the index of the rule
  # counting the super rule as rule 0
  my $self = shift;

  return $self->{CURRENT_RULE}
}

sub YYRightside { 
  # returns the rule
  # counting the super rule as rule 0
  my $self = shift;
  my $index = shift || $self->{CURRENT_RULE};
  $index = $self->YYIndex($index) unless looks_like_number($index);

  return @{$self->{GRAMMAR}->[$index]->[2]};
}

sub YYTerms {
  my $self = shift;

  return $self->{TERMS};
}


sub YYIsterm {
  my $self = shift;
  my $symbol = shift;

  return exists ($self->{TERMS}->{$symbol});
}

sub YYIssemantic {
  my $self = shift;
  my $symbol = shift;

  return 0 unless exists($self->{TERMS}{$symbol});
  $self->{TERMS}{$symbol}{ISSEMANTIC} = shift if @_;
  return ($self->{TERMS}{$symbol}{ISSEMANTIC});
}

sub YYName {
  my $self = shift;

  my $current_rule = $self->{GRAMMAR}->[$self->{CURRENT_RULE}];
  $current_rule->[0] = shift if @_;
  return $current_rule->[0];
}

sub YYPrefix {
  my $self = shift;

  $self->{PREFIX} = $_[0] if @_;
  $self->{PREFIX};
}

sub YYAccessors {
  my $self = shift;

  $self->{ACCESSORS}
}

# name of the file containing
# the source grammar
sub YYFilename {
  my $self = shift;

  $self->{FILENAME} = $_[0] if @_;
  $self->{FILENAME};
}

sub YYBypass {
  my $self = shift;

  $self->{BYPASS} = $_[0] if @_;
  $self->{BYPASS};
}

sub YYBypassrule {
  my $self = shift;

  $self->{GRAMMAR}->[$self->{CURRENT_RULE}][3] = $_[0] if @_;
  return $self->{GRAMMAR}->[$self->{CURRENT_RULE}][3];
}

sub YYFirstline {
  my $self = shift;

  $self->{FIRSTLINE} = $_[0] if @_;
  $self->{FIRSTLINE};
}

# Used as default action when writing a reusable grammar.
# See files examples/recycle/NoacInh.eyp 
# and examples/recycle/icalcu_and_ipost.pl 
# in the Parse::Eyapp distribution
sub YYDelegateaction {
  my $self = shift;

  my $action = $self->YYName;
  
  $self->$action(@_);
}

# Influences the behavior of YYActionforT_X1X2
# YYActionforT_single and YYActionforT_empty
# If true these methods will build simple lists of attributes 
# for the lists operators X*, X+ and X? and parenthesis (X Y)
# Otherwise the classic node construction for the
# syntax tree is used
sub YYBuildingTree {
  my $self = shift;

  $self->{BUILDINGTREE} = $_[0] if @_;
  $self->{BUILDINGTREE};
}

sub BeANode {
  my $class = shift;

    no strict 'refs';
    push @{$class."::ISA"}, "Parse::Eyapp::Node" unless $class->isa("Parse::Eyapp::Node");
}

#sub BeATranslationScheme {
#  my $class = shift;
#
#    no strict 'refs';
#    push @{$class."::ISA"}, "Parse::Eyapp::TranslationScheme" unless $class->isa("Parse::Eyapp::TranslationScheme");
#}

{
  my $attr =  sub { 
      $_[0]{attr} = $_[1] if @_ > 1;
      $_[0]{attr}
    };

  sub make_node_classes {
    my $self = shift;
    my $prefix = $self->YYPrefix() || '';

    { no strict 'refs';
      *{$prefix."TERMINAL::attr"} = $attr;
    }

    for (@_) {
       my ($class) = split /:/, $_;
       BeANode("$prefix$class"); 
    }

    my $accessors = $self->YYAccessors();
    for (keys %$accessors) {
      my $position = $accessors->{$_};
      no strict 'refs';
      *{$prefix.$_} = sub {
        my $self = shift;

        return $self->child($position, @_)
      }
    } # for
  }
}

####################################################################
# Usage      : ????
# Purpose    : Responsible for the %tree directive 
#              On each production the default action becomes:
#              sub { goto &Parse::Eyapp::Driver::YYBuildAST }
#
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# To Do      : many things: Optimize this!!!!
sub YYBuildAST { 
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside(); # Symbols on the right hand side of the production
  my $lhs = $self->YYLhs;
  my $fullname = $self->YYName();
  my ($name) = split /:/, $fullname;
  my $bypass = $self->YYBypassrule; # Boolean: shall we do bypassing of lonely nodes?
  my $class = "$PREFIX$name";
  my @children;

  my $node = bless {}, $class;

  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i]; # The symbol
    my $ch = $_[$i]; # The attribute/reference

    # is $ch already a Parse::Eyapp::Node. May be a terminal and a syntax variable share the same name?
    unless (UNIVERSAL::isa($ch, 'Parse::Eyapp::Node')) {
      if ($self->YYIssemantic($_)) {
        my $class = $PREFIX.'TERMINAL';
        my $node = bless { token => $_, attr => $ch, children => [] }, $class;
        push @children, $node;
        next;
      }

      if ($self->YYIsterm($_)) {
        TERMINAL::save_attributes($ch, $node) if UNIVERSAL::can($PREFIX."TERMINAL", "save_attributes");
        next;
      }
    }

    if (UNIVERSAL::isa($ch, $PREFIX."_PAREN")) { # Warning: weak code!!!
      push @children, @{$ch->{children}};
      next;
    }

    # If it is an intermediate semantic action skip it
    next if $_ =~ qr{@}; # intermediate rule
    next unless ref($ch);
    push @children, $ch;
  }

  
  if ($bypass and @children == 1) {
    $node = $children[0]; 

    my $childisterminal = ref($node) =~ /TERMINAL$/;
    # Re-bless unless is "an automatically named node", but the characterization of this is 
    bless $node, $class unless $name =~ /${lhs}_\d+$/; # lazy, weak (and wicked).

   
    my $finalclass =  ref($node);
    $childisterminal and !$finalclass->isa($PREFIX.'TERMINAL') 
      and do { 
        no strict 'refs';
        push @{$finalclass."::ISA"}, $PREFIX.'TERMINAL' 
      };

    return $node;
  }
  $node->{children} = \@children; 
  return $node;
}

sub YYBuildTS { 
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside(); # Symbols on the right hand side of the production
  my $lhs = $self->YYLhs;
  my $fullname = $self->YYName();
  my ($name) = split /:/, $fullname;
  my $class;
  my @children;

  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i]; # The symbol
    my $ch = $_[$i]; # The attribute/reference

    if ($self->YYIsterm($_)) { 
      $class = $PREFIX.'TERMINAL';
      push @children, bless { token => $_, attr => $ch, children => [] }, $class;
      next;
    }

    if (UNIVERSAL::isa($ch, $PREFIX."_PAREN")) { # Warning: weak code!!!
      push @children, @{$ch->{children}};
      next;
    }

    # Substitute intermediate code node _CODE(CODE()) by CODE()
    if (UNIVERSAL::isa($ch, $PREFIX."_CODE")) { # Warning: weak code!!!
      push @children, $ch->child(0);
      next;
    }

    next unless ref($ch);
    push @children, $ch;
  }

  if (unpack('A1',$lhs) eq '@') { # class has to be _CODE check
          $lhs =~ /^\@[0-9]+\-([0-9]+)$/
      or  croak "In line rule name '$lhs' ill formed: report it as a BUG.\n";
      my $dotpos = $1;
 
      croak "Fatal error building metatree when processing  $lhs -> @right" 
      unless exists($_[$dotpos]) and UNIVERSAL::isa($_[$dotpos], 'CODE') ; 
      push @children, $_[$dotpos];
  }
  else {
    my $code = $_[@right];
    if (UNIVERSAL::isa($code, 'CODE')) {
      push @children, $code; 
    }
    else {
      croak "Fatal error building translation scheme. Code or undef expected" if (defined($code));
    }
  }

  $class = "$PREFIX$name";
  my $node = bless { children => \@children }, $class; 
  $node;
}

sub YYActionforT_TX1X2_tree {
  my $self = shift;
  my $head = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside();
  my $class;

  for(my $i = 1; $i < @right; $i++) {
    local $_ = $right[$i];
    my $ch = $_[$i-1];
    if ($self->YYIssemantic($_)) {
      $class = $PREFIX.'TERMINAL';
      push @{$head->{children}}, bless { token => $_, attr => $ch, children => [] }, $class;
      
      next;
    }
    next if $self->YYIsterm($_);
    if (ref($ch) eq  $PREFIX."_PAREN") { # Warning: weak code!!!
      push @{$head->{children}}, @{$ch->{children}};
      next;
    }
    next unless ref($ch);
    push @{$head->{children}}, $ch;
  }

  return $head;
}

# For * and + lists 
# S2 -> S2 X         { push @$_[1] the node associated with X; $_[1] }
# S2 -> /* empty */  { a node with empty children }
sub YYActionforT_TX1X2 {
  goto &YYActionforT_TX1X2_tree if $_[0]->YYBuildingTree;

  my $self = shift;
  my $head = shift;

  push @$head, @_;
  return $head;
}

sub YYActionforParenthesis {
  goto &YYBuildAST if $_[0]->YYBuildingTree;

  my $self = shift;

  return [ @_ ];
}


sub YYActionforT_empty_tree {
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my $name = $self->YYName();

  # Allow use of %name
  my $class = $PREFIX.$name;
  my $node = bless { children => [] }, $class;
  #BeANode($class);
  $node;
}

sub YYActionforT_empty {
  goto &YYActionforT_empty_tree  if $_[0]->YYBuildingTree;

  [];
}

sub YYActionforT_single_tree {
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my $name = $self->YYName();
  my @right = $self->YYRightside();
  my $class;

  # Allow use of %name
  my @t;
  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i];
    my $ch = $_[$i];
    if ($self->YYIssemantic($_)) {
      $class = $PREFIX.'TERMINAL';
      push @t, bless { token => $_, attr => $ch, children => [] }, $class;
      #BeANode($class);
      next;
    }
    next if $self->YYIsterm($_);
    if (ref($ch) eq  $PREFIX."_PAREN") { # Warning: weak code!!!
      push @t, @{$ch->{children}};
      next;
    }
    next unless ref($ch);
    push @t, $ch;
  }
  $class = $PREFIX.$name;
  my $node = bless { children => \@t }, $class;
  #BeANode($class);
  $node;
}

sub YYActionforT_single {
  goto &YYActionforT_single_tree  if $_[0]->YYBuildingTree;

  my $self = shift;
  [ @_ ];
}

### end Casiano methods

sub YYCurtok {
  my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
  my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

{
  sub YYSimStack {
    my $self = shift;
    my $stack = shift;
    my @reduce = @_;
    my @expected;

    for my $index (@reduce) {
      my ($lhs, $length) = @{$self->{RULES}[-$index]};
      if (@$stack > $length) {
        my @auxstack = @$stack;
        splice @auxstack, -$length if $length;

        my $state = $auxstack[-1]->[0];
        my $nextstate = $self->{STATES}[$state]{GOTOS}{$lhs};
        if (defined($nextstate)) {
          push @auxstack, [$nextstate, undef];
          push @expected, $self->YYExpected(\@auxstack);
        }
      }
      # else something went wrong!!! See Frank Leray report
    }

    return map { $_ => 1 } @expected;
  }

  sub YYExpected {
    my($self)=shift;
    my $stack = shift;

    # The state in the top of the stack
    my $state = $self->{STATES}[$stack->[-1][0]];

    my %actions;
    %actions = %{$state->{ACTIONS}} if exists $state->{ACTIONS};

    # The keys of %reduction are the -production numbers
    # Use hashes and not lists to guarantee that no tokens are repeated
    my (%expected, %reduce); 
    for (keys(%actions)) {
      if ($actions{$_} > 0) { # shift
        $expected{$_} = 1;
        next;
      }
      $reduce{$actions{$_}} = 1;
    }
    $reduce{$state->{DEFAULT}} = 1 if exists($state->{DEFAULT});

    if (keys %reduce) {
      %expected = (%expected, $self->YYSimStack($stack, keys %reduce));
    }
    
    return keys %expected;
  }

  sub YYExpect {
    my $self = shift;
    $self->YYExpected($self->{STACK}, @_);
  }
}

# $self->expects($token) : returns true if the token is among the expected ones
sub expects {
  my $self = shift;
  my $token = shift;

  my @expected = $self->YYExpect;
  return grep { $_ eq $token } @expected;
}

BEGIN {
*YYExpects = \&expects;
}

# Set/Get a static/class attribute for $class
# Searches the $class ancestor tree for  an ancestor
# having defined such attribute. If found, that value is returned
sub static_attribute { 
    my $class = shift;
    $class = ref($class) if ref($class);
    my $attributename = shift;

    # class/static method
    no strict 'refs';
    my $classlexer;
    my $classname = $classlexer = $class.'::'.$attributename;
    if (@_) {
      ${$classlexer} = shift;
    }

    return ${$classlexer} if defined($$classlexer);
   
    # Traverse the inheritance tree for a defined
    # version of the attribute
    my @classes = @{$class.'::ISA'};
    my %classes = map { $_ => undef } @classes;
    while (@classes) {
      my $c = shift @classes || return;  
      $classlexer = $c.'::'.$attributename;
      if (defined($$classlexer)) {
        $$classname = $$classlexer;
        return $$classlexer;
      }
      # push those that aren't already there
      push @classes, grep { !exists $classes{$_} } @{$c.'::ISA'};
    }
    return undef;
}

sub YYEndOfInput {
   my $self = shift;

   for (${$self->input}) {
     return !defined($_) || ($_ eq '') || (defined(pos($_)) && (pos($_) >= length($_)));
   }
}

#################
# Private stuff #
#################


sub _CheckParams {
  my ($mandatory,$checklist,$inarray,$outhash)=@_;
  my ($prm,$value);
  my ($prmlst)={};

  while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
      exists($$checklist{$prm})
    or  croak("Unknown parameter '$prm'");
      ref($value) eq $$checklist{$prm}
    or  croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
    $$outhash{$prm}=$value;
  }
  for (@$mandatory) {
      exists($$outhash{$_})
    or  croak("Missing mandatory parameter '".lc($_)."'");
  }
}

#################### TailSupport ######################
sub line {
  my $self = shift;

  if (ref($self)) {
    $self->{TOKENLINE} = shift if @_;

    return $self->static_attribute('TOKENLINE', @_,) unless defined($self->{TOKENLINE}); # class/static method 
    return $self->{TOKENLINE};
  }
  else { # class/static method
    return $self->static_attribute('TOKENLINE', @_,); # class/static method 
  }
}

# attribute to count the lines
sub tokenline {
  my $self = shift;

  if (ref($self)) {
    $self->{TOKENLINE} += shift if @_;

    return $self->static_attribute('TOKENLINE', @_,) unless defined($self->{TOKENLINE}); # class/static method 
    return $self->{TOKENLINE};
  }
  else { # class/static method
    return $self->static_attribute('TOKENLINE', @_,); # class/static method 
  }
}

our $ERROR = \&_Error;
sub error {
  my $self = shift;

  if (ref $self) { # instance method
    $self->{ERROR} = shift if @_;

    return $self->static_attribute('ERROR', @_,) unless defined($self->{ERROR}); # class/static method 
    return $self->{ERROR};
  }
  else { # class/static method
    return $self->static_attribute('ERROR', @_,); # class/static method 
  }
}

# attribute with the input
# is a reference to the actual input
# slurp_file. 
# Parameters: object or class, filename, prompt messagge, mode (interactive or not: undef or "\n")
*YYSlurpFile = \&slurp_file;
sub slurp_file {
  my $self = shift;
  my $fn = shift;
  my $f;

  my $mode = undef;
  if ($fn && -r $fn) {
    open $f, $fn  or die "Can't find file '$fn'!\n";
  }
  else {
    $f = \*STDIN;
    my $msg = $self->YYPrompt();
    $mode = shift;
    print($msg) if $msg;
  }
  $self->YYInputFile($f);

  local $/ = $mode;
  my $input = <$f>;

  if (ref($self)) {  # called as object method
    $self->input(\$input);
  }
  else { # class/static method
    my $classinput = $self.'::input';
    ${$classinput}->input(\$input);
  }
}

our $INPUT = \undef;
*Parse::Eyapp::Driver::YYInput = \&input;
sub input {
  my $self = shift;

  $self->line(1) if @_; # used as setter
  if (ref $self) { # instance method
    if (@_) {
      if (ref $_[0]) {
        $self->{INPUT} = shift;
      }
      else {
        my $input = shift;
        $self->{INPUT} = \$input;
      }
    }

    return $self->static_attribute('INPUT', @_,) unless defined($self->{INPUT}); # class/static method 
    return $self->{INPUT};
  }
  else { # class/static method
    return $self->static_attribute('INPUT', @_,); # class/static method 
  }
}
*YYInput = \&input;  # alias

# Opened file used to get the input
# static and instance method
our $INPUTFILE = \*STDIN;
sub YYInputFile {
  my $self = shift;

  if (ref($self)) { # object method
     my $file = shift;
     if ($file) { # setter
       $self->{INPUTFILE} = $file;
     }
    
    return $self->static_attribute('INPUTFILE', @_,) unless defined($self->{INPUTFILE}); # class/static method 
    return $self->{INPUTFILE};
  }
  else { # static
    return $self->static_attribute('INPUTFILE', @_,); # class/static method 
  }
}


our $PROMPT;
sub YYPrompt {
  my $self = shift;

  if (ref($self)) { # object method
     my $prompt = shift;
     if ($prompt) { # setter
       $self->{PROMPT} = $prompt;
     }
    
    return $self->static_attribute('PROMPT', @_,) unless defined($self->{PROMPT}); # class/static method 
    return $self->{PROMPT};
  }
  else { # static
    return $self->static_attribute('PROMPT', @_,); # class/static method 
  }
}

# args: parser, debug and optionally the input or a reference to the input
sub Run {
  my ($self) = shift;
  my $yydebug = shift;
  
  if (defined($_[0])) {
    if (ref($_[0])) { # if arg is a reference
      $self->input(shift());
    }
    else { # arg isn't a ref: make a copy
      my $x = shift();
      $self->input(\$x);
    }
  }
  croak "Provide some input for parsing" unless ($self->input && defined(${$self->input()}));
  return $self->YYParse( 
    #yylex => $self->lexer(), 
    #yyerror => $self->error(),
    yydebug => $yydebug, # 0xF
  );
}
*Parse::Eyapp::Driver::YYRun = \&run;

# args: class, prompt, file, optionally input (ref or not)
# return the abstract syntax tree (or whatever was returned by the parser)
*Parse::Eyapp::Driver::YYMain = \&main;
sub main {
  my $package = shift;
  my $prompt = shift;

  my $debug = 0;
  my $file = '';
  my $showtree = 0;
  my $TERMINALinfo;
  my $help;
  my $slurp;
  my $inputfromfile = 1;
  my $commandinput = '';
  my $quotedcommandinput = '';
  my $yaml = 0;
  my $dot = 0;

  my $result = GetOptions (
    "debug!"         => \$debug,         # sets yydebug on
    "file=s"         => \$file,          # read input from that file
    "commandinput=s" => \$commandinput,  # read input from command line arg
    "tree!"          => \$showtree,      # prints $tree->str
    "info"           => \$TERMINALinfo,  # prints $tree->str and provides default TERMINAL::info
    "help"           => \$help,          # shows SYNOPSIS section from the script pod
    "slurp!"         => \$slurp,         # read until EOF or CR is reached
    "argfile!"       => \$inputfromfile, # take input string from @_
    "yaml"           => \$yaml,          # dumps YAML for $tree: YAML must be installed
    "dot=s"          => \$dot,          # dumps YAML for $tree: YAML must be installed
    "margin=i"       => \$Parse::Eyapp::Node::INDENT,      
  );

  $package->_help() if $help;

  $debug = 0x1F if $debug;
  $file = shift if !$file && @ARGV; # file is taken from the @ARGV unless already defined
  $slurp = "\n" if defined($slurp);

  my $parser = $package->new();
  $parser->YYPrompt($prompt) if defined($prompt);

  if ($commandinput) {
    $parser->input(\$commandinput);
  }
  elsif ($inputfromfile) {
    $parser->slurp_file( $file, $slurp);
  }
  else { # input must be a string argument
    croak "No input provided for parsing! " unless defined($_[0]);
    if (ref($_[0])) {
      $parser->input(shift());
    }
    else {
      my $x = shift();
      $parser->input(\$x);
    }
  }

  if (defined($TERMINALinfo)) {
    my $prefix = ($parser->YYPrefix || '');
    no strict 'refs';
    *{$prefix.'TERMINAL::info'} = sub { 
      (ref($_[0]->attr) eq 'ARRAY')? $_[0]->attr->[0] : $_[0]->attr 
    };
  }

  my $tree = $parser->Run( $debug, @_ );

  if (my $ne = $parser->YYNberr > 0) {
    print "There were $ne errors during parsing\n";
    return undef;
  }
  else {
    if ($showtree) {
      if ($tree && blessed $tree && $tree->isa('Parse::Eyapp::Node')) {

          print $tree->str()."\n";
      }
      elsif ($tree && ref $tree) {
        require Data::Dumper;
        print Data::Dumper::Dumper($tree)."\n";
      }
      elsif (defined($tree)) {
        print "$tree\n";
      }
    }
    if ($yaml && ref($tree)) {
      eval {
        require YAML;
      };
      if ($@) {
        print "You must install 'YAML' to use this option\n";
      }
      else {
        YAML->import;
        print Dump($tree);
      }
    }
    if ($dot && blessed($tree)) {
      my ($sfile, $extension) = $dot =~ /^(.*)\.([^.]*)$/;
      $extension = 'png' unless (defined($extension) and $tree->can($extension));
      ($sfile) = $file =~ m{(.*[^.])} if !defined($sfile) and defined($file);
      $tree->$extension($sfile);
    }

    return $tree
  }
}

sub _help {
  my $package = shift;

  print << 'AYUDA';
Available options:
    --debug                    sets yydebug on
    --nodebug                  sets yydebug off
    --file filepath            read input from filepath
    --commandinput string      read input from string
    --tree                     prints $tree->str
    --notree                   does not print $tree->str
    --info                     When printing $tree->str shows the value of TERMINALs
    --help                     shows this help
    --slurp                    read until EOF reached
    --noslurp                  read until CR is reached
    --argfile                  main() will take the input string from its @_
    --noargfile                main() will not take the input string from its @_
    --yaml                     dumps YAML for $tree: YAML module must be installed
    --margin=i                 controls the indentation of $tree->str (i.e. $Parse::Eyapp::Node::INDENT)      
    --dot format               produces a .dot and .format file (png,jpg,bmp, etc.)
AYUDA

  $package->help() if ($package & $package->can("help"));

  exit(0);
}

# Generic error handler
# Convention adopted: if the attribute of a token is an object
# assume it has 'line' and 'str' methods. Otherwise, if it
# is an array, follows the convention [ str, line, ...]
# otherwise is just an string representing the value of the token
sub _Error {
  my $parser = shift;

  my $yydata = $parser->YYData;

    exists $yydata->{ERRMSG}
  and do {
      warn $yydata->{ERRMSG};
      delete $yydata->{ERRMSG};
      return;
  };

  my ($attr)=$parser->YYCurval;

  my $stoken = '';

  if (blessed($attr) && $attr->can('str')) {
     $stoken = " near '".$attr->str."'"
  }
  elsif (ref($attr) eq 'ARRAY') {
    $stoken = " near '".$attr->[0]."'";
  }
  else {
    if ($attr) {
      $stoken = " near '$attr'";
    }
    else {
      $stoken = " near end of input";
    }
  }

  my @expected = map { ($_ ne '')? "'$_'" : q{'end of input'}} $parser->YYExpect();
  my $expected = '';
  if (@expected) {
    $expected = (@expected >1) ? "Expected one of these terminals: @expected" 
                              : "Expected terminal: @expected"
  }

  my $tline = '';
  if (blessed($attr) && $attr->can('line')) {
    $tline = " (line number ".$attr->line.")" 
  }
  elsif (ref($attr) eq 'ARRAY') {
    $tline = " (line number ".$attr->[1].")";
  }
  else {
    # May be the parser object knows the line number ?
    my $lineno = $parser->line;
    $tline = " (line number $lineno)" if $lineno > 1;
  }

  local $" = ', ';
  warn << "ERRMSG";

Syntax error$stoken$tline. 
$expected
ERRMSG
};

################ end TailSupport #####################

sub _DBLoad {

  #Already loaded ?
  __PACKAGE__->can('_DBParse') and return;
  
  my($fname)=__FILE__;
  my(@drv);
  local $/ = "\n";
  if (open(DRV,"<$fname")) {
    local $_;
    while(<DRV>) {
       #/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/ and do {
       /^my\s+\$lex;##!!##$/ .. /^\s*}\s*#\s*_Parse\s*$/ and do {
          s/^#DBG>//;
          push(@drv,$_);
      }
    }
    close(DRV);

    $drv[1]=~s/_P/_DBP/;
    eval join('',@drv);
  }
  else {
    # TODO: debugging for standalone modules isn't supported yet
    *Parse::Eyapp::Driver::_DBParse = \&_Parse;
  }
}

### Receives an  index for the parsing stack: -1 is the top
### Returns the symbol associated with the state $index
sub YYSymbol {
  my $self = shift;
  my $index = shift;
  
  return $self->{STACK}[$index][2];
}

# # YYSymbolStack(0,-k) string with symbols from 0 to last-k
# # YYSymbolStack(-k-2,-k) string with symbols from last-k-2 to last-k
# # YYSymbolStack(-k-2,-k, filter) string with symbols from last-k-2 to last-k that match with filter
# # YYSymbolStack('SYMBOL',-k, filter) string with symbols from the last occurrence of SYMBOL to last-k
# #                                    where filter can be code, regexp or string
# sub YYSymbolStack {
#   my $self = shift;
#   my ($a, $b, $filter) = @_;
#   
#   # $b must be negative
#   croak "Error: Second index in YYSymbolStack must be negative\n" unless $b < 0;
# 
#   my $stack = $self->{STACK};
#   my $bottom = -@{$stack};
#   unless (looks_like_number($a)) {
#     # $a is a string: search from the top to the bottom for $a. Return empty list if not found
#     # $b must be a negative number
#     # $b must be a negative number
#     my $p = $b;
#     while ($p >= $bottom) {
#       last if (defined($stack->[$p][2]) && ($stack->[$p][2] eq $a));
#       $p--;
#     }
#     return () if $p < $bottom;
#     $a = $p;
#   }
#   # If positive, $a is an offset from the bottom of the stack 
#   $a = $bottom+$a if $a >= 0;
#   
#   my @a = map { $self->YYSymbol($_) or '' } $a..$b;
#    
#   return @a                          unless defined $filter;          # no filter
#   return (grep { $filter->{$_} } @a) if reftype($filter) && (reftype($filter) eq 'CODE');   # sub
#   return (grep  /$filter/, @a)       if reftype($filter) && (reftype($filter) eq 'SCALAR'); # regexp
#   return (grep { $_ eq $filter } @a);                                  # string
# }

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
my $lex;##!!##
sub _Parse {
    my($self)=shift;

  #my $lex = $self->{LEX};

  my($rules,$states,$error)
     = @$self{ 'RULES', 'STATES', 'ERROR' };
  my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };


#DBG> my($debug)=$$self{DEBUG};
#DBG> my($dbgerror)=0;

#DBG> my($ShowCurToken) = sub {
#DBG>   my($tok)='>';
#DBG>   for (split('',$$token)) {
#DBG>     $tok.=    (ord($_) < 32 or ord($_) > 126)
#DBG>         ? sprintf('<%02X>',ord($_))
#DBG>         : $_;
#DBG>   }
#DBG>   $tok.='<';
#DBG> };

  $$errstatus=0;
  $$nberror=0;
  ($$token,$$value)=(undef,undef);
  @$stack=( [ 0, undef, ] );
#DBG>   push(@{$stack->[-1]}, undef);
  #@$stack=( [ 0, undef, undef ] );
  $$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG> print STDERR ('-' x 40),"\n";
#DBG>   $debug & 0x2
#DBG> and print STDERR "In state $stateno:\n";
#DBG>   $debug & 0x08
#DBG> and print STDERR "Stack: ".
#DBG>          join('->',map { defined($$_[2])? "'$$_[2]'->".$$_[0] : $$_[0] } @$stack).
#DBG>          "\n";


        $self->{POS} = pos(${$self->input()});
        if  (exists($$actions{ACTIONS})) {

        defined($$token)
            or  do {
        ($$token,$$value)=$self->{LEX}->($self); # original line
        #($$token,$$value)=$self->$lex;   # to make it a method call
        #($$token,$$value) = $self->{LEX}->($self); # sensitive to the lexer changes
#DBG>       $debug & 0x01
#DBG>     and do { 
#DBG>       print STDERR "Need token. Got ".&$ShowCurToken."\n";
#DBG>     };
      };

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>     $debug & 0x01
#DBG>   and print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>       $debug & 0x04
#DBG>     and print STDERR "Shift and go to state $act.\n";

          $$errstatus
        and do {
          --$$errstatus;

#DBG>         $debug & 0x10
#DBG>       and $dbgerror
#DBG>       and $$errstatus == 0
#DBG>       and do {
#DBG>         print STDERR "**End of Error recovery.\n";
#DBG>         $dbgerror=0;
#DBG>       };
        };


        push(@$stack,[ $act, $$value ]);
#DBG>   push(@{$stack->[-1]},$$token);

          $$token ne '' #Don't eat the eof
        and $$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>     $debug & 0x04
#DBG>   and $act
#DBG>   #and  print STDERR "Reduce using rule ".-$act." ($lhs,$len): "; # old Parse::Yapp line
#DBG>   and do { my @rhs = @{$self->{GRAMMAR}->[-$act]->[2]};
#DBG>            @rhs = ( '/* empty */' ) unless @rhs;
#DBG>            my $rhs = "@rhs";
#DBG>            $rhs = substr($rhs, 0, 30).'...' if length($rhs) > 30; # chomp if too large
#DBG>            print STDERR "Reduce using rule ".-$act." ($lhs --> $rhs): "; 
#DBG>          };

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $self->{CURRENT_LHS} = $lhs;
            $self->{CURRENT_RULE} = -$act; # count the super-rule?
            $semval = $code ? $self->$code( @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Accept.\n";

        return($semval);
      };

                $$check eq 'ABORT'
            and do {

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Abort.\n";

        return(undef);

      };

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>       $debug & 0x04
#DBG>     and print STDERR 
#DBG>           "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>       $debug & 0x10
#DBG>     and $dbgerror
#DBG>     and $$errstatus == 0
#DBG>     and do {
#DBG>       print STDERR "**End of Error recovery.\n";
#DBG>       $dbgerror=0;
#DBG>     };

          push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval, ]);
                     #[ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval, $lhs ]);
#DBG>     push(@{$stack->[-1]},$lhs);
                $$check='';
                $self->{CURRENT_LHS} = undef;
                next;
            };

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>     $debug & 0x10
#DBG>   and do {
#DBG>     print STDERR "**Entering Error recovery.\n";
#DBG>     { 
#DBG>       local $" = ", "; 
#DBG>       my @expect = map { ">$_<" } $self->YYExpect();
#DBG>       print STDERR "Expecting one of: @expect\n";
#DBG>     };
#DBG>     ++$dbgerror;
#DBG>   };

            ++$$nberror;

        };

      $$errstatus == 3  #The next token is not valid: discard it
    and do {
        $$token eq '' # End of input: no hope
      and do {
#DBG>       $debug & 0x10
#DBG>     and print STDERR "**At eof: aborting.\n";
        return(undef);
      };

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Discard invalid token ".&$ShowCurToken.".\n";

      $$token=$$value=undef;
    };

        $$errstatus=3;

    while(    @$stack
        and (   not exists($$states[$$stack[-1][0]]{ACTIONS})
              or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
          or  $$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Pop state $$stack[-1][0].\n";

      pop(@$stack);
    }

      @$stack
    or  do {

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**No state left on stack: aborting.\n";

      return(undef);
    };

    #shift the error token

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Shift \$error token and go to state ".
#DBG>            $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>            ".\n";

    push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef, 'error' ]);

    }

    #never reached
  croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

*Parse::Eyapp::Driver::lexer = \&Parse::Eyapp::Driver::YYLexer;
sub YYLexer {
  my $self = shift;

  if (ref $self) { # instance method
    # The class attribute isn't changed, only the instance
    $self->{LEX} = shift if @_;

    return $self->static_attribute('LEX', @_,) unless defined($self->{LEX}); # class/static method 
    return $self->{LEX};
  }
  else {
    return $self->static_attribute('LEX', @_,);
  }
}


1;


MODULE_Parse_Eyapp_Driver
    }; # Unless Parse::Eyapp::Driver was loaded
  } ########### End of BEGIN { load /Library/Perl/5.10.0/Parse/Eyapp/Driver.pm }

  # Loading Parse::Eyapp::Node
  BEGIN {
    unless (Parse::Eyapp::Node->can('m')) {
      eval << 'MODULE_Parse_Eyapp_Node'
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon, all rights reserved.
package Parse::Eyapp::Node;
use strict;
use Carp;
no warnings 'recursion';use List::Util qw(first);
use Data::Dumper;

our $FILENAME=__FILE__;

sub firstval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[0]
}

sub lastval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[-1]
}

####################################################################
# Usage      : 
# line: %name PROG
#        exp <%name EXP + ';'>
#                 { @{$lhs->{t}} = map { $_->{t}} ($lhs->child(0)->children()); }
# ;
# Returns    : The array of children of the node. When the tree is a
#              translation scheme the CODE references are also included
# Parameters : the node (method)
# See Also   : Children

sub children {
  my $self = CORE::shift;
  
  return () unless UNIVERSAL::can($self, 'children');
  @{$self->{children}} = @_ if @_;
  @{$self->{children}}
}

####################################################################
# Usage      :  line: %name PROG
#                        (exp) <%name EXP + ';'>
#                          { @{$lhs->{t}} = map { $_->{t}} ($_[1]->Children()); }
#
# Returns    : The true children of the node, excluding CODE CHILDREN
# Parameters : The Node object

sub Children {
  my $self = CORE::shift;
  
  return () unless UNIVERSAL::can($self, 'children');

  @{$self->{children}} = @_ if @_;
  grep { !UNIVERSAL::isa($_, 'CODE') } @{$self->{children}}
}

####################################################################
# Returns    : Last non CODE child
# Parameters : the node object

sub Last_child {
  my $self = CORE::shift;

  return unless UNIVERSAL::can($self, 'children') and @{$self->{children}};
  my $i = -1;
  $i-- while defined($self->{children}->[$i]) and UNIVERSAL::isa($self->{children}->[$i], 'CODE');
  return  $self->{children}->[$i];
}

sub last_child {
  my $self = CORE::shift;

  return unless UNIVERSAL::can($self, 'children') and @{$self->{children}};
  ${$self->{children}}[-1];
}

####################################################################
# Usage      :  $node->child($i)
#  my $transform = Parse::Eyapp::Treeregexp->new( STRING => q{
#     commutative_add: PLUS($x, ., $y, .)
#       => { my $t = $x; $_[0]->child(0, $y); $_[0]->child(2, $t)}
#  }
# Purpose    : Setter-getter to modify a specific child of a node
# Returns    : Child with index $i. Returns undef if the child does not exists
# Parameters : Method: the node and the index of the child. The new value is used 
#              as a setter.
# Throws     : Croaks if the index parameter is not provided
sub child {
  my ($self, $index, $value) = @_;
  
  #croak "$self is not a Parse::Eyapp::Node" unless $self->isa('Parse::Eyapp::Node');
  return undef unless  UNIVERSAL::can($self, 'child');
  croak "Index not provided" unless defined($index);
  $self->{children}[$index] = $value if defined($value);
  $self->{children}[$index];
}

sub descendant {
  my $self = shift;
  my $coord = shift;

  my @pos = split /\./, $coord;
  my $t = $self;
  my $x = shift(@pos); # discard the first empty dot
  for (@pos) {
      croak "Error computing descendant: $_ is not a number\n" 
    unless m{\d+} and $_ < $t->children;
    $t = $t->child($_);
  }
  return $t;
}

####################################################################
# Usage      : $node->s(@transformationlist);
# Example    : The following example simplifies arithmetic expressions
# using method "s":
# > cat Timeszero.trg
# /* Operator "and" has higher priority than comma "," */
# whatever_times_zero: TIMES(@b, NUM($x) and { $x->{attr} == 0 }) => { $_[0] = $NUM }
#
# > treereg Timeszero
# > cat arrays.pl
#  !/usr/bin/perl -w
#  use strict;
#  use Rule6;
#  use Parse::Eyapp::Treeregexp;
#  use Timeszero;
#
#  my $parser = new Rule6();
#  my $t = $parser->Run;
#  $t->s(@Timeszero::all);
#
#
# Returns    : Nothing
# Parameters : The object (is a method) and the list of transformations to apply.
#              The list may be a list of Parse::Eyapp:YATW objects and/or CODE
#              references
# Throws     : No exceptions
# Comments   : The set of transformations is repeatedly applied to the node
#              until there are no changes.
#              The function may hang if the set of transformations
#              matches forever.
# See Also   : The "s" method for Parse::Eyapp::YATW objects 
#              (i.e. transformation objects)

sub s {
  my @patterns = @_[1..$#_];

  # Make them Parse::Eyapp:YATW objects if they are CODE references
  @patterns = map { ref($_) eq 'CODE'? 
                      Parse::Eyapp::YATW->new(
                        PATTERN => $_,
                        #PATTERN_ARGS => [],
                      )
                      :
                      $_
                  } 
                  @patterns;
  my $changes; 
  do { 
    $changes = 0;
    foreach (@patterns) {
      $_->{CHANGES} = 0;
      $_->s($_[0]);
      $changes += $_->{CHANGES};
    }
  } while ($changes);
}


####################################################################
# Usage      : ????
# Purpose    : bud = Bottom Up Decoration: Decorates the tree with flowers :-)
#              The purpose is to decorate the AST with attributes during
#              the context-dependent analysis, mainly type-checking.
# Returns    : ????
# Parameters : The transformations.
# Throws     : no exceptions
# Comments   : The tree is traversed bottom-up. The set of
#              transformations is applied to each node in the order
#              supplied by the user. As soon as one succeeds
#              no more transformations are applied.
# See Also   : n/a
# To Do      : Avoid closure. Save @patterns inside the object
{
  my @patterns;

  sub bud {
    @patterns = @_[1..$#_];

    @patterns = map { ref($_) eq 'CODE'? 
                        Parse::Eyapp::YATW->new(
                          PATTERN => $_,
                          #PATTERN_ARGS => [],
                        )
                        :
                        $_
                    } 
                    @patterns;
    _bud($_[0], undef, undef);
  }

  sub _bud {
    my $node = $_[0];
    my $index = $_[2];

      # Is an odd leaf. Not actually a Parse::Eyapp::Node. Decorate it and leave
      if (!ref($node) or !UNIVERSAL::can($node, "children"))  {
        for my $p (@patterns) {
          return if $p->pattern->(
            $_[0],  # Node being visited  
            $_[1],  # Father of this node
            $index, # Index of this node in @Father->children
            $p,  # The YATW pattern object   
          );
        }
      };

      # Recursively decorate subtrees
      my $i = 0;
      for (@{$node->{children}}) {
        $_->_bud($_, $_[0], $i);
        $i++;
      }

      # Decorate the node
      #Change YATW object to be the  first argument?
      for my $p (@patterns) {
        return if $p->pattern->($_[0], $_[1], $index, $p); 
      }
  }
} # closure for @patterns

####################################################################
# Usage      : 
# @t = Parse::Eyapp::Node->new( q{TIMES(NUM(TERMINAL), NUM(TERMINAL))}, 
#      sub { 
#        our ($TIMES, @NUM, @TERMINAL);
#        $TIMES->{type}       = "binary operation"; 
#        $NUM[0]->{type}      = "int"; 
#        $NUM[1]->{type}      = "float"; 
#        $TERMINAL[1]->{attr} = 3.5; 
#      },
#    );
# Purpose    : Multi-Constructor
# Returns    : Array of pointers to the objects created
#              in scalar context a pointer to the first node
# Parameters : The class plus the string description and attribute handler

{

my %cache;

  sub m_bless {

    my $key = join "",@_;
    my $class = shift;
    return $cache{$key} if exists $cache{$key};

    my $b = bless { children => \@_}, $class;
    $cache{$key} = $b;

    return $b;
  }
}

sub _bless {
  my $class = shift;

  my $b = bless { children => \@_ }, $class;
  return $b;
}

sub hexpand {
  my $class = CORE::shift;

  my $handler = CORE::pop if ref($_[-1]) eq 'CODE';
  my $n = m_bless(@_);

  my $newnodeclass = CORE::shift;

  no strict 'refs';
  push @{$newnodeclass."::ISA"}, 'Parse::Eyapp::Node' unless $newnodeclass->isa('Parse::Eyapp::Node');

  if (defined($handler) and UNIVERSAL::isa($handler, "CODE")) {
    $handler->($n);
  }

  $n;
}

sub hnew {
  my $blesser = \&m_bless;

  return _new($blesser, @_);
}

# Regexp for a full Perl identifier
sub _new {
  my $blesser = CORE::shift;
  my $class = CORE::shift;
  local $_ = CORE::shift; # string: tree description
  my $handler = CORE::shift if ref($_[0]) eq 'CODE';


  my %classes;
  my $b;
  #TODO: Shall I receive a prefix?

  my (@stack, @index, @results, %results, @place, $open);
  #skip white spaces
  s{\A\s+}{};
  while ($_) {
    # If is a leaf is followed by parenthesis or comma or an ID
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s*([),])} 
     {$1()$2} # ... then add an empty pair of parenthesis
      and do { 
        next; 
       };

    # If is a leaf is followed by an ID
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s+([A-Za-z_])} 
     {$1()$2} # ... then add an empty pair of parenthesis
      and do { 
        next; 
       };

    # If is a leaf at the end
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s*$} 
     {$1()} # ... then add an empty pair of parenthesis
      and do { 
        $classes{$1} = 1;
        next; 
       };

    # Is an identifier
    s{\A([A-Za-z_][A-Za-z0-9_:]*)}{} 
      and do { 
        $classes{$1} = 1;
        CORE::push @stack, $1; 
        next; 
      };

    # Open parenthesis: mark the position for when parenthesis closes
    s{\A[(]}{} 
      and do { 
        my $pos = scalar(@stack);
        CORE::push @index, $pos; 
        $place[$pos] = $open++;

        # Warning! I don't know what I am doing
        next;
      };

    # Skip commas
    s{\A,}{} and next; 

    # Closing parenthesis: time to build a node
    s{\A[)]}{} and do { 
        croak "Syntax error! Closing parenthesis has no left partner!" unless @index;
        my $begin = pop @index; # check if empty!
        my @children = splice(@stack, $begin);
        my $class = pop @stack;
        croak "Syntax error! Any couple of parenthesis must be preceded by an identifier"
          unless (defined($class) and $class =~ m{^[a-zA-Z_][\w:]*$});

        $b = $blesser->($class, @children);

        CORE::push @stack, $b;
        $results[$place[$begin]] = $b;
        CORE::push @{$results{$class}}, $b;
        next; 
    }; 

    last unless $_;

    #skip white spaces
    croak "Error building Parse::Eyapp::Node tree at '$_'." unless s{\A\s+}{};
  } # while
  croak "Syntax error! Open parenthesis has no right partner!" if @index;
  { 
    no strict 'refs';
    for (keys(%classes)) {
      push @{$_."::ISA"}, 'Parse::Eyapp::Node' unless $_->isa('Parse::Eyapp::Node');
    }
  }
  if (defined($handler) and UNIVERSAL::isa($handler, "CODE")) {
    $handler->(@results);
  }
  return wantarray? @results : $b;
}

sub new {
  my $blesser = \&_bless;

  _new($blesser, @_);
}

## Used by _subtree_list
#sub compute_hierarchy {
#  my @results = @{shift()};
#
#  # Compute the hierarchy
#  my $b;
#  my @r = @results;
#  while (@results) {
#    $b = pop @results;
#    my $d = $b->{depth};
#    my $f = lastval { $_->{depth} < $d} @results;
#    
#    $b->{father} = $f;
#    $b->{children} = [];
#    unshift @{$f->{children}}, $b;
#  }
#  $_->{father} = undef for @results;
#  bless $_, "Parse::Eyapp::Node::Match" for @r;
#  return  @r;
#}

# Matches

sub m {
  my $self = shift;
  my @patterns = @_ or croak "Expected a pattern!";
  croak "Error in method m of Parse::Eyapp::Node. Expected Parse::Eyapp:YATW patterns"
    unless $a = first { !UNIVERSAL::isa($_, "Parse::Eyapp:YATW") } @_;

  # array context: return all matches
  local $a = 0;
  my %index = map { ("$_", $a++) } @patterns;
  my @stack = (
    Parse::Eyapp::Node::Match->new( 
       node => $self, 
       depth => 0,  
       dewey => "", 
       patterns =>[] 
    ) 
  );
  my @results;
  do {
    my $mn = CORE::shift(@stack);
    my %n = %$mn;

    # See what patterns do match the current $node
    for my $pattern (@patterns) {
      push @{$mn->{patterns}}, $index{$pattern} if $pattern->{PATTERN}($n{node});
    } 
    my $dewey = $n{dewey};
    if (@{$mn->{patterns}}) {
      $mn->{family} = \@patterns;

      # Is at this time that I have to compute the father
      my $f = lastval { $dewey =~ m{^$_->{dewey}}} @results;
      $mn->{father} = $f;
      # ... and children
      push @{$f->{children}}, $mn if defined($f);
      CORE::push @results, $mn;
    }
    my $childdepth = $n{depth}+1;
    my $k = -1;
    CORE::unshift @stack, 
          map 
            { 
              $k++; 
              Parse::Eyapp::Node::Match->new(
                node => $_, 
                depth => $childdepth, 
                dewey => "$dewey.$k", 
                patterns => [] 
              ) 
            } $n{node}->children();
  } while (@stack);

  wantarray? @results : $results[0];
}

#sub _subtree_scalar {
#  # scalar context: return iterator
#  my $self = CORE::shift;
#  my @patterns = @_ or croak "Expected a pattern!";
#
#  # %index gives the index of $p in @patterns
#  local $a = 0;
#  my %index = map { ("$_", $a++) } @patterns;
#
#  my @stack = ();
#  my $mn = { node => $self, depth => 0, patterns =>[] };
#  my @results = ();
#
#  return sub {
#     do {
#       # See if current $node matches some patterns
#       my $d = $mn->{depth};
#       my $childdepth = $d+1;
#       # See what patterns do match the current $node
#       for my $pattern (@patterns) {
#         push @{$mn->{patterns}}, $index{$pattern} if $pattern->{PATTERN}($mn->{node});
#       } 
#
#       if (@{$mn->{patterns}}) { # matched
#         CORE::push @results, $mn;
#
#         # Compute the hierarchy
#         my $f = lastval { $_->{depth} < $d} @results;
#         $mn->{father} = $f;
#         $mn->{children} = [];
#         $mn->{family} = \@patterns;
#         unshift @{$f->{children}}, $mn if defined($f);
#         bless $mn, "Parse::Eyapp::Node::Match";
#
#         # push children in the stack
#         CORE::unshift @stack, 
#                   map { { node => $_, depth => $childdepth, patterns => [] } } 
#                                                       $mn->{node}->children();
#         $mn = CORE::shift(@stack);
#         return $results[-1];
#       }
#       # didn't match: push children in the stack
#       CORE::unshift @stack, 
#                  map { { node => $_, depth => $childdepth, patterns => [] } } 
#                                                      $mn->{node}->children();
#       $mn = CORE::shift(@stack);
#     } while ($mn); # May be the stack is empty now, but if $mn then there is a node to process
#     # reset iterator
#     my @stack = ();
#     my $mn = { node => $self, depth => 0, patterns =>[] };
#     return undef;
#   };
#}

# Factorize this!!!!!!!!!!!!!!
#sub m {
#  goto &_subtree_list if (wantarray()); 
#  goto &_subtree_scalar;
#}

####################################################################
# Usage      :   $BLOCK->delete($ASSIGN)
#                $BLOCK->delete(2)
# Purpose    : deletes the specified child of the node
# Returns    : The deleted child
# Parameters : The object plus the index or pointer to the child to be deleted
# Throws     : If the object can't do children or has no children
# See Also   : n/a

sub delete {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer

  croak "Parse::Eyapp::Node::delete error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);
  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::delete warning: node:\n".Parse::Eyapp::Node::str($self)
           ."\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)
           ."\nThe node was not deleted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i, 1);
    return $child;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::delete error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child, 1);
  return $child;
}

####################################################################
# Usage      : $BLOCK->shift
# Purpose    : deletes the first child of the node
# Returns    : The deleted child
# Parameters : The object 
# Throws     : If the object can't do children 
# See Also   : n/a

sub shift {
  my $self = CORE::shift; # The tree object

  croak "Parse::Eyapp::Node::shift error, node:\n"
       .Parse::Eyapp::Node->str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children');

  return CORE::shift(@{$self->{children}});
}

sub unshift {
  my $self = CORE::shift; # The tree object
  my $node = CORE::shift; # node to insert

  CORE::unshift @{$self->{children}}, $node;
}

sub push {
  my $self = CORE::shift; # The tree object
  #my $node = CORE::shift; # node to insert

  #CORE::push @{$self->{children}}, $node;
  CORE::push @{$self->{children}}, @_;
}

sub insert_before {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer
  my $node = CORE::shift; # node to insert

  croak "Parse::Eyapp::Node::insert_before error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);

  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::insert_before warning: node:\n"
           .Parse::Eyapp::Node::str($self)
           ."\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)."\nThe node was not inserted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i, 0, $node);
    return $node;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::insert_before error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child, 0, $node);
  return $child;
}

sub insert_after {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer
  my $node = CORE::shift; # node to insert

  croak "Parse::Eyapp::Node::insert_after error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);

  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::insert_after warning: node:\n"
           .Parse::Eyapp::Node::str($self).
           "\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)."\nThe node was not inserted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i+1, 0, $node);
    return $node;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::insert_after error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child+1, 0, $node);
  return $child;
}

{ # $match closure

  my $match;

  sub clean_tree {
    $match = pop;
    croak "clean tree: a node and code reference expected" unless (ref($match) eq 'CODE') and (@_ > 0);
    $_[0]->_clean_tree();
  }

  sub _clean_tree {
    my @children;
    
    for ($_[0]->children()) {
      next if (!defined($_) or $match->($_));
      
      $_->_clean_tree();
      CORE::push @children, $_;
    }
    $_[0]->{children} = \@children; # Bad code
  }
} # $match closure

####################################################################
# Usage      : $t->str 
# Returns    : Returns a string describing the Parse::Eyapp::Node as a term
#              i.e., s.t. like: 'PROGRAM(FUNCTION(RETURN(TERMINAL,VAR(TERMINAL))))'
our @PREFIXES = qw(Parse::Eyapp::Node::);
our $INDENT = 0; # -1 new 0 = compact, 1 = indent, 2 = indent and include Types in closing parenthesis
our $STRSEP = ',';
our $DELIMITER = '[';
our $FOOTNOTE_HEADER = "\n---------------------------\n";
our $FOOTNOTE_SEP = ")\n";
our $FOOTNOTE_LEFT = '^{';
our $FOOTNOTE_RIGHT = '}';
our $LINESEP = 4;
our $CLASS_HANDLER = sub { type($_[0]) }; # What to print to identify the node

my %match_del = (
  '[' => ']',
  '{' => '}',
  '(' => ')',
  '<' => '>'
);

my $pair;
my $footnotes = '';
my $footnote_label;

sub str {

  my @terms;

  # Consume arg only if called as a class method Parse::Eyap::Node->str($node1, $node2, ...)
  CORE::shift unless ref($_[0]);

  for (@_) {
    $footnote_label = 0;
    $footnotes = '';
    # Set delimiters for semantic values
    if (defined($DELIMITER) and exists($match_del{$DELIMITER})) {
      $pair = $match_del{$DELIMITER};
    }
    else {
      $DELIMITER = $pair = '';
    }
    CORE::push @terms,  _str($_).$footnotes;
  }
  return wantarray? @terms : $terms[0];
}  

sub _str {
  my $self = CORE::shift;          # root of the subtree
  my $indent = (CORE::shift or 0); # current depth in spaces " "

  my @children = Parse::Eyapp::Node::children($self);
  my @t;

  my $res;
  my $fn = $footnote_label;
  if ($INDENT >= 0 && UNIVERSAL::can($self, 'footnote')) {
    $res = $self->footnote; 
    $footnotes .= $FOOTNOTE_HEADER.$footnote_label++.$FOOTNOTE_SEP.$res if $res;
  }

  # recursively visit nodes
  for (@children) {
    CORE::push @t, Parse::Eyapp::Node::_str($_, $indent+2) if defined($_);
  }
  local $" = $STRSEP;
  my $class = $CLASS_HANDLER->($self);
  $class =~ s/^$_// for @PREFIXES; 
  my $information;
  $information = $self->info if ($INDENT >= 0 && UNIVERSAL::can($self, 'info'));
  $class .= $DELIMITER.$information.$pair if defined($information);
  if ($INDENT >= 0 &&  $res) {
   $class .= $FOOTNOTE_LEFT.$fn.$FOOTNOTE_RIGHT;
  }

  if ($INDENT > 0) {
    my $w = " "x$indent;
    $class = "\n$w$class";
    $class .= "(@t\n$w)" if @children;
    $class .= " # ".$CLASS_HANDLER->($self) if ($INDENT > 1) and ($class =~ tr/\n/\n/>$LINESEP);
  }
  else {
    $class .= "(@t)" if @children;
  }
  return $class;
}

sub _dot {
  my ($root, $number) = @_;

  my $type = $root->type();

  my $information;
  $information = $root->info if ($INDENT >= 0 && $root->can('info'));
  my $class = $CLASS_HANDLER->($root);
  $class = qq{$class<font color="red">$DELIMITER$information$pair</font>} if defined($information);

  my $dot = qq{  $number [label = <$class>];\n};

  my $k = 0;
  my @dots = map { $k++; $_->_dot("$number$k") }  $root->children;

  for($k = 1; $k <= $root->children; $k++) {;
    $dot .= qq{  $number -> $number$k;\n};
  }

  return $dot.join('',@dots);
}

sub dot {
  my $dot = $_[0]->_dot('0');
  return << "EOGRAPH";
digraph G {
ordering=out

$dot
}
EOGRAPH
}

sub fdot {
  my ($self, $file) = @_;

  if ($file) {
    $file .= '.dot' unless $file =~ /\.dot$/;
  }
  else {
    $file = $self->type().".dot";
  }
  open my $f, "> $file";
  print $f $self->dot();
  close($f);
}

BEGIN {
  my @dotFormats = qw{bmp canon cgimage cmap cmapx cmapx_np eps exr fig gd gd2 gif gv imap imap_np ismap jp2 jpe jpeg jpg pct pdf pict plain plain-ext png ps ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp x11 xdot xlib};

  for my $format (@dotFormats) {
     
    no strict 'refs';
    *{'Parse::Eyapp::Node::'.$format} = sub { 
       my ($self, $file) = @_;
   
       $file = $self->type() unless defined($file);
   
       $self->fdot($file);
   
       $file =~ s/\.(dot|$format)$//;
       my $dotfile = "$file.dot";
       my $pngfile = "$file.$format";
       my $err = qx{dot -T$format $dotfile -o $pngfile 2>&1};
       return ($err, $?);
    }
  }
}

sub translation_scheme {
  my $self = CORE::shift; # root of the subtree
  my @children = $self->children();
  for (@children) {
    if (ref($_) eq 'CODE') {
      $_->($self, $self->Children);
    }
    elsif (defined($_)) {
      translation_scheme($_);
    }
  }
}

sub type {
 my $type = ref($_[0]);

 if ($type) {
   if (defined($_[1])) {
     $type = $_[1];
     Parse::Eyapp::Driver::BeANode($type);
     bless $_[0], $type;
   }
   return $type 
 }
 return 'Parse::Eyapp::Node::STRING';
}

{ # Tree "fuzzy" equality

####################################################################
# Usage      : $t1->equal($t2, n => sub { return $_[0] == $_[1] })
# Purpose    : Checks the equality between two AST
# Returns    : 1 if equal, 0 if not 'equal'
# Parameters : Two Parse::Eyapp:Node nodes and a hash of comparison handlers.
#              The keys of the hash are the attributes of the nodes. The value is
#              a comparator function. The comparator for key $k receives the attribute
#              for the nodes being visited and rmust return true if they are considered similar
# Throws     : exceptions if the parameters aren't Parse::Eyapp::Nodes

  my %handler;

  # True if the two trees look similar
  sub equal {
    croak "Parse::Eyapp::Node::equal error. Expected two syntax trees \n" unless (@_ > 1);

    %handler = splice(@_, 2);
    my $key = '';
    defined($key=firstval {!UNIVERSAL::isa($handler{$_},'CODE') } keys %handler) 
    and 
      croak "Parse::Eyapp::Node::equal error. Expected a CODE ref for attribute $key\n";
    goto &_equal;
  }

  sub _equal {
    my $tree1 = CORE::shift;
    my $tree2 = CORE::shift;

    # Same type
    return 0 unless ref($tree1) eq ref($tree2);

    # Check attributes via handlers
    for (keys %handler) {
      # Check for existence
      return 0 if (exists($tree1->{$_}) && !exists($tree2->{$_}));
      return 0 if (exists($tree2->{$_}) && !exists($tree1->{$_}));

      # Check for definition
      return 0 if (defined($tree1->{$_}) && !defined($tree2->{$_}));
      return 0 if (defined($tree2->{$_}) && !defined($tree1->{$_}));

      # Check for equality
      return 0 unless $handler{$_}->($tree1->{$_}, $tree2->{$_});
    }

    # Same number of children
    my @children1 = @{$tree1->{children}};
    my @children2 = @{$tree2->{children}};
    return 0 unless @children1 == @children2;

    # Children must be similar
    for (@children1) {
      my $ch2 = CORE::shift @children2;
      return 0 unless _equal($_, $ch2);
    }
    return 1;
  }
}

1;

package Parse::Eyapp::Node::Match;
our @ISA = qw(Parse::Eyapp::Node);

# A Parse::Eyapp::Node::Match object is a reference
# to a tree of Parse::Eyapp::Nodes that has been used
# in a tree matching regexp. You can think of them
# as the equivalent of $1 $2, ... in treeregexeps

# The depth of the Parse::Eyapp::Node being referenced

sub new {
  my $class = shift;

  my $matchnode = { @_ };
  $matchnode->{children} = [];
  bless $matchnode, $class;
}

sub depth {
  my $self = shift;

  return $self->{depth};
}

# The coordinates of the Parse::Eyapp::Node being referenced
sub coord {
  my $self = shift;

  return $self->{dewey};
}


# The Parse::Eyapp::Node being referenced
sub node {
  my $self = shift;

  return $self->{node};
}

# The Parse::Eyapp::Node:Match that references
# the nearest ancestor of $self->{node} that matched
sub father {
  my $self = shift;

  return $self->{father};
}
  
# The patterns that matched with $self->{node}
# Indexes
sub patterns {
  my $self = shift;

  @{$self->{patterns}} = @_ if @_;
  return @{$self->{patterns}};
}
  
# The original list of patterns that produced this match
sub family {
  my $self = shift;

  @{$self->{family}} = @_ if @_;
  return @{$self->{family}};
}
  
# The names of the patterns that matched
sub names {
  my $self = shift;

  my @indexes = $self->patterns;
  my @family = $self->family;

  return map { $_->{NAME} or "Unknown" } @family[@indexes];
}
  
sub info {
  my $self = shift;

  my $node = $self->node;
  my @names = $self->names;
  my $nodeinfo;
  if (UNIVERSAL::can($node, 'info')) {
    $nodeinfo = ":".$node->info;
  }
  else {
    $nodeinfo = "";
  }
  return "[".ref($self->node).":".$self->depth.":@names$nodeinfo]"
}

1;



MODULE_Parse_Eyapp_Node
    }; # Unless Parse::Eyapp::Node was loaded
  } ########### End of BEGIN { load /Library/Perl/5.10.0/Parse/Eyapp/Node.pm }

  # Loading Parse::Eyapp::YATW
  BEGIN {
    unless (Parse::Eyapp::YATW->can('m')) {
      eval << 'MODULE_Parse_Eyapp_YATW'
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon, all rights reserved.
package Parse::Eyapp::YATW;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use List::Util qw(first);

sub firstval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[0]
}

sub lastval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[-1]
}

sub valid_keys {
  my %valid_args = @_;

  my @valid_args = keys(%valid_args); 
  local $" = ", "; 
  return "@valid_args" 
}

sub invalid_keys {
  my $valid_args = shift;
  my $args = shift;

  return (first { !exists($valid_args->{$_}) } keys(%$args));
}


our $VERSION = $Parse::Eyapp::Driver::VERSION;

our $FILENAME=__FILE__;

# TODO: Check args. Typical args:
# 'CHANGES' => 0,
# 'PATTERN' => sub { "DUMMY" },
# 'NAME' => 'fold',
# 'PATTERN_ARGS' => [],
# 'PENDING_TASKS' => {},
# 'NODE' => []

my %_new_yatw = (
  PATTERN => 'CODE',
  NAME => 'STRING',
);

my $validkeys = valid_keys(%_new_yatw); 

sub new {
  my $class = shift;
  my %args = @_;

  croak "Error. Expected a code reference when building a tree walker. " unless (ref($args{PATTERN}) eq 'CODE');
  if (defined($a = invalid_keys(\%_new_yatw, \%args))) {
    croak("Parse::Eyapp::YATW::new Error!: unknown argument $a. Valid arguments are: $validkeys")
  }


  # obsolete, I have to delete this
  #$args{PATTERN_ARGS} = [] unless (ref($args{PATTERN_ARGS}) eq 'ARRAY'); 

  # Internal fields

  # Tell us if the node has changed after the visit
  $args{CHANGES} = 0;
  
  # PENDING_TASKS is a queue storing the tasks waiting for a "safe time/node" to do them 
  # Usually that time occurs when visiting the father of the node who generated the job 
  # (when asap criteria is applied).
  # Keys are node references. Values are array references. Each entry defines:
  #  [ the task kind, the node where to do the job, and info related to the particular job ]
  # Example: @{$self->{PENDING_TASKS}{$father}}, ['insert_before', $node, ${$self->{NODE}}[0] ];
  $args{PENDING_TASKS} = {};

  # NODE is a stack storing the ancestor of the node being visited
  # Example: my $ancestor = ${$self->{NODE}}[$k]; when k=1 is the father, k=2 the grandfather, etc.
  # Example: CORE::unshift @{$self->{NODE}}, $_[0]; Finished the visit so take it out
  $args{NODE} = [];

  bless \%args, $class;
}

sub buildpatterns {
  my $class = shift;
  
  my @family;
  while (my ($n, $p) = splice(@_, 0,2)) {
    push @family, Parse::Eyapp::YATW->new(NAME => $n, PATTERN => $p);
  }
  return wantarray? @family : $family[0];
}

####################################################################
# Usage      : @r = $b{$_}->m($t)
#              See Simple4.eyp and m_yatw.pl in the examples directory
# Returns    : Returns an array of nodes matching the treeregexp
#              The set of nodes is a Parse::Eyapp::Node::Match tree 
#              showing the relation between the matches
# Parameters : The tree (and the object of course)
# depth is no longer used: eliminate
sub m {
  my $p = shift(); # pattern YATW object
  my $t = shift;   # tree
  my $pattern = $p->{PATTERN}; # CODE ref

  # References to the found nodes are stored in @stack
  my @stack = ( Parse::Eyapp::Node::Match->new(node=>$t, depth=>0, dewey => "") ); 
  my @results;
  do {
    my $n = CORE::shift(@stack);
    my %n = %$n;

    my $dewey = $n->{dewey};
    my $d = $n->{depth};
    if ($pattern->($n{node})) {
      $n->{family} = [ $p ];
      $n->{patterns} = [ 0 ];

      # Is at this time that I have to compute the father
      my $f = lastval { $dewey =~ m{^$_->{dewey}}} @results;
      $n->{father} = $f;
      # ... and children
      push @{$f->{children}}, $n if defined($f);
      push @results, $n;
    }
    my $k = 0;
    CORE::unshift @stack, 
       map { 
              local $a;
              $a = Parse::Eyapp::Node::Match->new(node=>$_, depth=>$d+1, dewey=>"$dewey.$k" );
              $k++;
              $a;
           } $n{node}->children();
  } while (@stack);

  return wantarray? @results : $results[0];
}

######################### getter-setter for YATW objects ###########################

sub pattern {
  my $self = shift;
  $self->{PATTERN} = shift if (@_);
  return $self->{PATTERN};
}

sub name {
  my $self = shift;
  $self->{NAME} = shift if (@_);
  return $self->{NAME};
}

#sub pattern_args {
#  my $self = shift;
#
#  $self->{PATTERN_ARGS} = @_ if @_;
#  return @{$self->{PATTERN_ARGS}};
#}

########################## PENDING TASKS management ################################

# Purpose    : Deletes the node that matched from the list of children of its father. 
sub delete {
  my $self = shift;

  bless $self->{NODE}[0], 'Parse::Eyapp::Node::DELETE';
}
  
sub make_delete_effective {
  my $self = shift;
  my $node = shift;

  my $i = -1+$node->children;
  while ($i >= 0) {
    if (UNIVERSAL::isa($node->child($i), 'Parse::Eyapp::Node::DELETE')) {
      $self->{CHANGES}++ if defined(splice(@{$node->{children}}, $i, 1));
    }
    $i--;
  }
}

####################################################################
# Usage      :    my $b = Parse::Eyapp::Node->new( 'NUM(TERMINAL)', sub { $_[1]->{attr} = 4 });
#                 $yatw_pattern->unshift($b); 
# Parameters : YATW object, node to insert, 
#              ancestor offset: 0 = root of the tree that matched, 1 = father, 2 = granfather, etc.

sub unshift {
  my ($self, $node, $k) = @_;
  $k = 1 unless defined($k); # father by default

  my $ancestor = ${$self->{NODE}}[$k];
  croak "unshift: does not exist ancestor $k of node ".Dumper(${$self->{NODE}}[0]) unless defined($ancestor);

  # Stringification of $ancestor. Hope it works
                                            # operation, node to insert, 
  push @{$self->{PENDING_TASKS}{$ancestor}}, ['unshift', $node ];
}

sub insert_before {
  my ($self, $node) = @_;

  my $father = ${$self->{NODE}}[1];
  croak "insert_before: does not exist father of node ".Dumper(${$self->{NODE}}[0]) unless defined($father);

                                           # operation, node to insert, before this node 
  push @{$self->{PENDING_TASKS}{$father}}, ['insert_before', $node, ${$self->{NODE}}[0] ];
}

sub _delayed_insert_before {
  my ($father, $node, $before) = @_;

  my $i = 0;
  for ($father->children()) {
    last if ($_ == $before);
    $i++;
  }
  splice @{$father->{children}}, $i, 0, $node;
}

sub do_pending_tasks {
  my $self = shift;
  my $node = shift;

  my $mytasks = $self->{PENDING_TASKS}{$node};
  while ($mytasks and (my $job = shift @{$mytasks})) {
    my @args = @$job;
    my $task = shift @args;

    # change this for a jump table
    if ($task eq 'unshift') {
      CORE::unshift(@{$node->{children}}, @args);
      $self->{CHANGES}++;
    }
    elsif ($task eq 'insert_before') {
      _delayed_insert_before($node, @args);
      $self->{CHANGES}++;
    }
  }
}

####################################################################
# Parameters : pattern, node, father of the node, index of the child in the children array
# YATW object. Probably too many 
sub s {
  my $self = shift;
  my $node = $_[0] or croak("Error. Method __PACKAGE__::s requires a node");
  CORE::unshift @{$self->{NODE}}, $_[0];
  # father is $_[1]
  my $index = $_[2];

  # If is not a reference or can't children then simply check the matching and leave
  if (!ref($node) or !UNIVERSAL::can($node, "children"))  {
                                         
    $self->{CHANGES}++ if $self->pattern->(
      $_[0],  # Node being visited  
      $_[1],  # Father of this node
      $index, # Index of this node in @Father->children
      $self,  # The YATW pattern object   
    );
    return;
  };
  
  # Else, is not a leaf and is a regular Parse::Eyapp::Node
  # Recursively transform subtrees
  my $i = 0;
  for (@{$node->{children}}) {
    $self->s($_, $_[0], $i);
    $i++;
  }
  
  my $number_of_changes = $self->{CHANGES};
  # Now is safe to delete children nodes that are no longer needed
  $self->make_delete_effective($node);

  # Safely do pending jobs for this node
  $self->do_pending_tasks($node);

  #node , father, childindex, and ... 
  #Change YATW object to be the  first argument?
  if ($self->pattern->($_[0], $_[1], $index, $self)) {
    $self->{CHANGES}++;
  }
  shift @{$self->{NODE}};
}

1;


MODULE_Parse_Eyapp_YATW
    }; # Unless Parse::Eyapp::YATW was loaded
  } ########### End of BEGIN { load /Library/Perl/5.10.0/Parse/Eyapp/YATW.pm }



sub unexpendedInput { defined($_) ? substr($_, (defined(pos $_) ? pos $_ : 0)) : '' }





#line 3361 Parser.pm

my $warnmessage =<< "EOFWARN";
Warning!: Did you changed the \@Bamboo::Engine::Parser::ISA variable inside the header section of the eyapp program?
EOFWARN

sub new {
  my($class)=shift;
  ref($class) and $class=ref($class);

  warn $warnmessage unless __PACKAGE__->isa('Parse::Eyapp::Driver'); 
  my($self)=$class->SUPER::new( 
    yyversion => '1.178',
    yyGRAMMAR  =>
[#[productionNameAndLabel => lhs, [ rhs], bypass]]
  [ '_SUPERSTART' => '$start', [ 'statements', '$end' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-1', [ 'PLUS-1', ';', 'statement' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-1', [ 'statement' ], 0 ],
  [ 'statements_3' => 'statements', [ 'PLUS-1' ], 0 ],
  [ 'statement_4' => 'statement', [  ], 0 ],
  [ 'statement_5' => 'statement', [ 'expr' ], 0 ],
  [ 'statement_6' => 'statement', [ 'let_expr' ], 0 ],
  [ 'statement_7' => 'statement', [ 'ns_expr' ], 0 ],
  [ 'expr_8' => 'expr', [ 'or_expr' ], 0 ],
  [ 'expr_9' => 'expr', [ 'range_expr' ], 0 ],
  [ 'expr_10' => 'expr', [ 'if_expr' ], 0 ],
  [ 'expr_11' => 'expr', [ 'for_expr' ], 0 ],
  [ 'expr_12' => 'expr', [ 'quant_expr' ], 0 ],
  [ 'expr_13' => 'expr', [ 'with_expr' ], 0 ],
  [ 'expr_14' => 'expr', [ 'err_expr' ], 0 ],
  [ 'err_expr_15' => 'err_expr', [ 'expr', 'err', 'expr' ], 0 ],
  [ 'with_expr_16' => 'with_expr', [ 'expr', 'with', 'expr_set_list' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-2', [ 'PLUS-2', ',', 'expr_set' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-2', [ 'expr_set' ], 0 ],
  [ 'expr_set_list_19' => 'expr_set_list', [ 'PLUS-2' ], 0 ],
  [ 'expr_set_20' => 'expr_set', [ 'relative_location_path', ':=', 'expr' ], 0 ],
  [ 'let_expr_21' => 'let_expr', [ 'let', 'DOLLAR_QNAME', ':=', 'expr' ], 0 ],
  [ 'ns_expr_22' => 'ns_expr', [ 'let', 'XMLNS', ':=', 'LITERAL' ], 0 ],
  [ 'if_expr_23' => 'if_expr', [ 'if', '(', 'expr', ')', 'then', 'expr', 'else', 'expr' ], 0 ],
  [ 'if_expr_24' => 'if_expr', [ 'if', '(', 'expr', ')', 'then', 'expr' ], 0 ],
  [ 'for_expr_25' => 'for_expr', [ 'for', 'for_vars', 'return', 'expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-3', [ 'PLUS-3', ',', 'for_var' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-3', [ 'for_var' ], 0 ],
  [ 'for_vars_28' => 'for_vars', [ 'PLUS-3' ], 0 ],
  [ 'for_var_29' => 'for_var', [ 'DOLLAR_QNAME', 'in', 'expr' ], 0 ],
  [ 'quant_expr_30' => 'quant_expr', [ 'some', 'for_vars', 'satisfies', 'expr' ], 0 ],
  [ 'quant_expr_31' => 'quant_expr', [ 'every', 'for_vars', 'satisfies', 'expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-4', [ 'PLUS-4', 'or', 'and_expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-4', [ 'and_expr' ], 0 ],
  [ 'or_expr_34' => 'or_expr', [ 'PLUS-4' ], 0 ],
  [ 'and_expr_35' => 'and_expr', [ 'equality_expr' ], 0 ],
  [ 'and_expr_36' => 'and_expr', [ 'and_expr', 'and', 'equality_expr' ], 0 ],
  [ 'and_expr_37' => 'and_expr', [ 'and_expr', 'except', 'equality_expr' ], 0 ],
  [ 'equality_expr_38' => 'equality_expr', [ 'relational_expr' ], 0 ],
  [ 'equality_expr_39' => 'equality_expr', [ 'additive_expr', '=', 'additive_expr' ], 0 ],
  [ 'equality_expr_40' => 'equality_expr', [ 'additive_expr', '!=', 'additive_expr' ], 0 ],
  [ 'tuple_41' => 'tuple', [ '[', 'list', ']' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-5', [ 'PLUS-5', ',', 'expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-5', [ 'expr' ], 0 ],
  [ 'list_44' => 'list', [ 'PLUS-5' ], 0 ],
  [ 'relational_expr_45' => 'relational_expr', [ 'additive_expr' ], 0 ],
  [ 'relational_expr_46' => 'relational_expr', [ 'additive_expr', '<', 'additive_expr' ], 0 ],
  [ 'relational_expr_47' => 'relational_expr', [ 'additive_expr', '>', 'additive_expr' ], 0 ],
  [ 'relational_expr_48' => 'relational_expr', [ 'additive_expr', '<=', 'additive_expr' ], 0 ],
  [ 'relational_expr_49' => 'relational_expr', [ 'additive_expr', '>=', 'additive_expr' ], 0 ],
  [ 'range_expr_50' => 'range_expr', [ 'additive_expr', '..', 'additive_expr' ], 0 ],
  [ 'range_expr_51' => 'range_expr', [ 'additive_expr', 'to', 'additive_expr' ], 0 ],
  [ 'additive_expr_52' => 'additive_expr', [ 'multiplicative_expr' ], 0 ],
  [ 'additive_expr_53' => 'additive_expr', [ 'additive_expr', '+', 'multiplicative_expr' ], 0 ],
  [ 'additive_expr_54' => 'additive_expr', [ 'additive_expr', '-', 'multiplicative_expr' ], 0 ],
  [ 'multiplicative_expr_55' => 'multiplicative_expr', [ 'unary_expr' ], 0 ],
  [ 'multiplicative_expr_56' => 'multiplicative_expr', [ 'multiplicative_expr', 'MPY', 'unary_expr' ], 0 ],
  [ 'multiplicative_expr_57' => 'multiplicative_expr', [ 'multiplicative_expr', 'div', 'unary_expr' ], 0 ],
  [ 'multiplicative_expr_58' => 'multiplicative_expr', [ 'multiplicative_expr', 'mod', 'unary_expr' ], 0 ],
  [ 'unary_expr_59' => 'unary_expr', [ 'union_expr' ], 0 ],
  [ 'unary_expr_60' => 'unary_expr', [ '-', 'unary_expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-6', [ 'PLUS-6', '|', 'path_expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-6', [ 'path_expr' ], 0 ],
  [ 'union_expr_63' => 'union_expr', [ 'PLUS-6' ], 0 ],
  [ 'path_expr_64' => 'path_expr', [ 'location_path' ], 0 ],
  [ 'path_expr_65' => 'path_expr', [ 'primary_expr', 'predicates', 'segment' ], 0 ],
  [ 'segment_66' => 'segment', [  ], 0 ],
  [ 'segment_67' => 'segment', [ '/', 'relative_location_path' ], 0 ],
  [ 'segment_68' => 'segment', [ '//', 'relative_location_path' ], 0 ],
  [ 'location_path_69' => 'location_path', [ 'relative_location_path' ], 0 ],
  [ 'location_path_70' => 'location_path', [ 'absolute_location_path' ], 0 ],
  [ 'absolute_location_path_71' => 'absolute_location_path', [ '/' ], 0 ],
  [ 'absolute_location_path_72' => 'absolute_location_path', [ '/', 'relative_location_path' ], 0 ],
  [ 'absolute_location_path_73' => 'absolute_location_path', [ '//', 'relative_location_path' ], 0 ],
  [ 'absolute_location_path_74' => 'absolute_location_path', [ 'axis_name', '/', 'relative_location_path' ], 0 ],
  [ 'absolute_location_path_75' => 'absolute_location_path', [ 'axis_name', '//', 'relative_location_path' ], 0 ],
  [ 'axis_name_76' => 'axis_name', [ 'NCNAME', '::' ], 0 ],
  [ 'relative_location_path_77' => 'relative_location_path', [ 'step' ], 0 ],
  [ 'relative_location_path_78' => 'relative_location_path', [ 'relative_location_path', '/', 'step' ], 0 ],
  [ 'relative_location_path_79' => 'relative_location_path', [ 'relative_location_path', '//', 'step' ], 0 ],
  [ 'step_80' => 'step', [ 'axis', 'predicates' ], 0 ],
  [ 'step_81' => 'step', [ '.' ], 0 ],
  [ 'step_82' => 'step', [ '..' ], 0 ],
  [ 'axis_83' => 'axis', [ 'node_test' ], 0 ],
  [ 'axis_84' => 'axis', [ 'NCNAME', '::', 'node_test' ], 0 ],
  [ 'axis_85' => 'axis', [ '@', 'node_test' ], 0 ],
  [ '_STAR_LIST' => 'STAR-7', [ 'STAR-7', 'predicate' ], 0 ],
  [ '_STAR_LIST' => 'STAR-7', [  ], 0 ],
  [ 'predicates_88' => 'predicates', [ 'STAR-7' ], 0 ],
  [ 'num_expr_89' => 'num_expr', [ 'additive_expr' ], 0 ],
  [ 'num_expr_90' => 'num_expr', [ 'range_expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-8', [ 'PLUS-8', ',', 'num_expr' ], 0 ],
  [ '_PLUS_LIST' => 'PLUS-8', [ 'num_expr' ], 0 ],
  [ 'num_list_93' => 'num_list', [ 'PLUS-8' ], 0 ],
  [ 'predicate_94' => 'predicate', [ '[', 'expr', ']' ], 0 ],
  [ 'predicate_95' => 'predicate', [ '[', 'num_list', ']' ], 0 ],
  [ 'plist_96' => 'plist', [ '(', 'list', ')' ], 0 ],
  [ '_PAREN' => 'PAREN-9', [ 'plist' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-10', [ 'PAREN-9' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-10', [  ], 0 ],
  [ 'opt_plist_100' => 'opt_plist', [ 'OPTIONAL-10' ], 0 ],
  [ 'primary_expr_101' => 'primary_expr', [ 'DOLLAR_QNAME' ], 0 ],
  [ 'primary_expr_102' => 'primary_expr', [ 'DOLLAR_INT' ], 0 ],
  [ 'primary_expr_103' => 'primary_expr', [ 'plist' ], 0 ],
  [ 'primary_expr_104' => 'primary_expr', [ 'tuple' ], 0 ],
  [ 'primary_expr_105' => 'primary_expr', [ 'LITERAL' ], 0 ],
  [ 'primary_expr_106' => 'primary_expr', [ 'NUMBER' ], 0 ],
  [ 'primary_expr_107' => 'primary_expr', [ 'FUNCTION_NAME', 'opt_plist' ], 0 ],
  [ 'node_test_108' => 'node_test', [ 'QNAME' ], 0 ],
  [ 'node_test_109' => 'node_test', [ '{', 'expr', '}' ], 0 ],
  [ 'node_test_110' => 'node_test', [ '*' ], 0 ],
],
    yyLABELS  =>
{
  '_SUPERSTART' => 0,
  '_PLUS_LIST' => 1,
  '_PLUS_LIST' => 2,
  'statements_3' => 3,
  'statement_4' => 4,
  'statement_5' => 5,
  'statement_6' => 6,
  'statement_7' => 7,
  'expr_8' => 8,
  'expr_9' => 9,
  'expr_10' => 10,
  'expr_11' => 11,
  'expr_12' => 12,
  'expr_13' => 13,
  'expr_14' => 14,
  'err_expr_15' => 15,
  'with_expr_16' => 16,
  '_PLUS_LIST' => 17,
  '_PLUS_LIST' => 18,
  'expr_set_list_19' => 19,
  'expr_set_20' => 20,
  'let_expr_21' => 21,
  'ns_expr_22' => 22,
  'if_expr_23' => 23,
  'if_expr_24' => 24,
  'for_expr_25' => 25,
  '_PLUS_LIST' => 26,
  '_PLUS_LIST' => 27,
  'for_vars_28' => 28,
  'for_var_29' => 29,
  'quant_expr_30' => 30,
  'quant_expr_31' => 31,
  '_PLUS_LIST' => 32,
  '_PLUS_LIST' => 33,
  'or_expr_34' => 34,
  'and_expr_35' => 35,
  'and_expr_36' => 36,
  'and_expr_37' => 37,
  'equality_expr_38' => 38,
  'equality_expr_39' => 39,
  'equality_expr_40' => 40,
  'tuple_41' => 41,
  '_PLUS_LIST' => 42,
  '_PLUS_LIST' => 43,
  'list_44' => 44,
  'relational_expr_45' => 45,
  'relational_expr_46' => 46,
  'relational_expr_47' => 47,
  'relational_expr_48' => 48,
  'relational_expr_49' => 49,
  'range_expr_50' => 50,
  'range_expr_51' => 51,
  'additive_expr_52' => 52,
  'additive_expr_53' => 53,
  'additive_expr_54' => 54,
  'multiplicative_expr_55' => 55,
  'multiplicative_expr_56' => 56,
  'multiplicative_expr_57' => 57,
  'multiplicative_expr_58' => 58,
  'unary_expr_59' => 59,
  'unary_expr_60' => 60,
  '_PLUS_LIST' => 61,
  '_PLUS_LIST' => 62,
  'union_expr_63' => 63,
  'path_expr_64' => 64,
  'path_expr_65' => 65,
  'segment_66' => 66,
  'segment_67' => 67,
  'segment_68' => 68,
  'location_path_69' => 69,
  'location_path_70' => 70,
  'absolute_location_path_71' => 71,
  'absolute_location_path_72' => 72,
  'absolute_location_path_73' => 73,
  'absolute_location_path_74' => 74,
  'absolute_location_path_75' => 75,
  'axis_name_76' => 76,
  'relative_location_path_77' => 77,
  'relative_location_path_78' => 78,
  'relative_location_path_79' => 79,
  'step_80' => 80,
  'step_81' => 81,
  'step_82' => 82,
  'axis_83' => 83,
  'axis_84' => 84,
  'axis_85' => 85,
  '_STAR_LIST' => 86,
  '_STAR_LIST' => 87,
  'predicates_88' => 88,
  'num_expr_89' => 89,
  'num_expr_90' => 90,
  '_PLUS_LIST' => 91,
  '_PLUS_LIST' => 92,
  'num_list_93' => 93,
  'predicate_94' => 94,
  'predicate_95' => 95,
  'plist_96' => 96,
  '_PAREN' => 97,
  '_OPTIONAL' => 98,
  '_OPTIONAL' => 99,
  'opt_plist_100' => 100,
  'primary_expr_101' => 101,
  'primary_expr_102' => 102,
  'primary_expr_103' => 103,
  'primary_expr_104' => 104,
  'primary_expr_105' => 105,
  'primary_expr_106' => 106,
  'primary_expr_107' => 107,
  'node_test_108' => 108,
  'node_test_109' => 109,
  'node_test_110' => 110,
},
    yyTERMS  =>
{ '' => { ISSEMANTIC => 0 },
	'!=' => { ISSEMANTIC => 0 },
	'(' => { ISSEMANTIC => 0 },
	')' => { ISSEMANTIC => 0 },
	'*' => { ISSEMANTIC => 0 },
	'+' => { ISSEMANTIC => 0 },
	',' => { ISSEMANTIC => 0 },
	'-' => { ISSEMANTIC => 0 },
	'.' => { ISSEMANTIC => 0 },
	'..' => { ISSEMANTIC => 0 },
	'/' => { ISSEMANTIC => 0 },
	'//' => { ISSEMANTIC => 0 },
	'::' => { ISSEMANTIC => 0 },
	':=' => { ISSEMANTIC => 0 },
	';' => { ISSEMANTIC => 0 },
	'<' => { ISSEMANTIC => 0 },
	'<=' => { ISSEMANTIC => 0 },
	'=' => { ISSEMANTIC => 0 },
	'>' => { ISSEMANTIC => 0 },
	'>=' => { ISSEMANTIC => 0 },
	'@' => { ISSEMANTIC => 0 },
	'[' => { ISSEMANTIC => 0 },
	']' => { ISSEMANTIC => 0 },
	'and' => { ISSEMANTIC => 0 },
	'div' => { ISSEMANTIC => 0 },
	'else' => { ISSEMANTIC => 0 },
	'err' => { ISSEMANTIC => 0 },
	'every' => { ISSEMANTIC => 0 },
	'except' => { ISSEMANTIC => 0 },
	'for' => { ISSEMANTIC => 0 },
	'if' => { ISSEMANTIC => 0 },
	'in' => { ISSEMANTIC => 0 },
	'let' => { ISSEMANTIC => 0 },
	'mod' => { ISSEMANTIC => 0 },
	'or' => { ISSEMANTIC => 0 },
	'return' => { ISSEMANTIC => 0 },
	'satisfies' => { ISSEMANTIC => 0 },
	'some' => { ISSEMANTIC => 0 },
	'then' => { ISSEMANTIC => 0 },
	'to' => { ISSEMANTIC => 0 },
	'with' => { ISSEMANTIC => 0 },
	'{' => { ISSEMANTIC => 0 },
	'|' => { ISSEMANTIC => 0 },
	'}' => { ISSEMANTIC => 0 },
	DOLLAR_INT => { ISSEMANTIC => 1 },
	DOLLAR_QNAME => { ISSEMANTIC => 1 },
	FUNCTION_NAME => { ISSEMANTIC => 1 },
	LITERAL => { ISSEMANTIC => 1 },
	MPY => { ISSEMANTIC => 1 },
	NCNAME => { ISSEMANTIC => 1 },
	NUMBER => { ISSEMANTIC => 1 },
	QNAME => { ISSEMANTIC => 1 },
	XMLNS => { ISSEMANTIC => 1 },
	error => { ISSEMANTIC => 0 },
},
    yyFILENAME  => 'engine-parser.eyp',
    yystates =>
[
	{#State 0
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"let" => 26,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		DEFAULT => -4,
		GOTOS => {
			'absolute_location_path' => 3,
			'equality_expr' => 4,
			'ns_expr' => 5,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-1' => 9,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'statement' => 13,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'for_expr' => 24,
			'additive_expr' => 27,
			'unary_expr' => 28,
			'with_expr' => 29,
			'quant_expr' => 30,
			'let_expr' => 33,
			'node_test' => 31,
			'relational_expr' => 34,
			'statements' => 36,
			'relative_location_path' => 38,
			'expr' => 42,
			'if_expr' => 46,
			'err_expr' => 47,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'multiplicative_expr' => 55,
			'PLUS-4' => 54
		}
	},
	{#State 1
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 56,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'plist' => 18
		}
	},
	{#State 2
		ACTIONS => {
			'QNAME' => 49,
			"*" => 12,
			"{" => 44
		},
		GOTOS => {
			'node_test' => 57
		}
	},
	{#State 3
		DEFAULT => -70
	},
	{#State 4
		DEFAULT => -35
	},
	{#State 5
		DEFAULT => -7
	},
	{#State 6
		DEFAULT => -62
	},
	{#State 7
		DEFAULT => -87,
		GOTOS => {
			'STAR-7' => 58,
			'predicates' => 59
		}
	},
	{#State 8
		ACTIONS => {
			"|" => 60
		},
		DEFAULT => -63
	},
	{#State 9
		ACTIONS => {
			";" => 61
		},
		DEFAULT => -3
	},
	{#State 10
		DEFAULT => -77
	},
	{#State 11
		DEFAULT => -9
	},
	{#State 12
		DEFAULT => -110
	},
	{#State 13
		DEFAULT => -2
	},
	{#State 14
		DEFAULT => -64
	},
	{#State 15
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 63,
			'location_path' => 14,
			'axis_name' => 16,
			'list' => 62,
			'plist' => 18,
			'PLUS-5' => 64,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 16
		ACTIONS => {
			"/" => 66,
			"//" => 65
		}
	},
	{#State 17
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 67,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 18
		DEFAULT => -103
	},
	{#State 19
		ACTIONS => {
			"(" => 25
		},
		DEFAULT => -99,
		GOTOS => {
			'opt_plist' => 69,
			'OPTIONAL-10' => 71,
			'PAREN-9' => 72,
			'plist' => 70
		}
	},
	{#State 20
		ACTIONS => {
			"except" => 74,
			"and" => 73
		},
		DEFAULT => -33
	},
	{#State 21
		DEFAULT => -101
	},
	{#State 22
		DEFAULT => -8
	},
	{#State 23
		ACTIONS => {
			'DOLLAR_QNAME' => 75
		},
		GOTOS => {
			'for_var' => 78,
			'PLUS-3' => 77,
			'for_vars' => 76
		}
	},
	{#State 24
		DEFAULT => -11
	},
	{#State 25
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 63,
			'location_path' => 14,
			'axis_name' => 16,
			'list' => 79,
			'plist' => 18,
			'PLUS-5' => 64,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 26
		ACTIONS => {
			'XMLNS' => 81,
			'DOLLAR_QNAME' => 80
		}
	},
	{#State 27
		ACTIONS => {
			".." => 88,
			"-" => 82,
			"to" => 83,
			"<" => 84,
			"+" => 89,
			">=" => 85,
			"!=" => 90,
			"=" => 91,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -45
	},
	{#State 28
		DEFAULT => -55
	},
	{#State 29
		DEFAULT => -13
	},
	{#State 30
		DEFAULT => -12
	},
	{#State 31
		DEFAULT => -83
	},
	{#State 32
		DEFAULT => -81
	},
	{#State 33
		DEFAULT => -6
	},
	{#State 34
		DEFAULT => -38
	},
	{#State 35
		DEFAULT => -82
	},
	{#State 36
		ACTIONS => {
			'' => 92
		}
	},
	{#State 37
		ACTIONS => {
			'DOLLAR_QNAME' => 75
		},
		GOTOS => {
			'for_var' => 78,
			'PLUS-3' => 77,
			'for_vars' => 93
		}
	},
	{#State 38
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -69
	},
	{#State 39
		DEFAULT => -105
	},
	{#State 40
		ACTIONS => {
			"::" => 96
		}
	},
	{#State 41
		ACTIONS => {
			"(" => 97
		}
	},
	{#State 42
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -5
	},
	{#State 43
		DEFAULT => -106
	},
	{#State 44
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 100,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 45
		ACTIONS => {
			"\@" => 2,
			"*" => 12,
			"." => 32,
			".." => 35,
			'NCNAME' => 68,
			"{" => 44,
			'QNAME' => 49
		},
		DEFAULT => -71,
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 101,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 46
		DEFAULT => -10
	},
	{#State 47
		DEFAULT => -14
	},
	{#State 48
		DEFAULT => -102
	},
	{#State 49
		DEFAULT => -108
	},
	{#State 50
		DEFAULT => -87,
		GOTOS => {
			'STAR-7' => 58,
			'predicates' => 102
		}
	},
	{#State 51
		ACTIONS => {
			'DOLLAR_QNAME' => 75
		},
		GOTOS => {
			'for_var' => 78,
			'PLUS-3' => 77,
			'for_vars' => 103
		}
	},
	{#State 52
		DEFAULT => -59
	},
	{#State 53
		DEFAULT => -104
	},
	{#State 54
		ACTIONS => {
			"or" => 104
		},
		DEFAULT => -34
	},
	{#State 55
		ACTIONS => {
			"mod" => 105,
			"div" => 106,
			'MPY' => 107
		},
		DEFAULT => -52
	},
	{#State 56
		DEFAULT => -60
	},
	{#State 57
		DEFAULT => -85
	},
	{#State 58
		ACTIONS => {
			"[" => 108
		},
		DEFAULT => -88,
		GOTOS => {
			'predicate' => 109
		}
	},
	{#State 59
		DEFAULT => -80
	},
	{#State 60
		ACTIONS => {
			".." => 35,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 110,
			'axis' => 7,
			'step' => 10,
			'primary_expr' => 50,
			'location_path' => 14,
			'tuple' => 53,
			'axis_name' => 16,
			'node_test' => 31,
			'plist' => 18
		}
	},
	{#State 61
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"let" => 26,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		DEFAULT => -4,
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'ns_expr' => 5,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 42,
			'statement' => 111,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'let_expr' => 33,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 62
		ACTIONS => {
			"]" => 112
		}
	},
	{#State 63
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -43
	},
	{#State 64
		ACTIONS => {
			"," => 113
		},
		DEFAULT => -44
	},
	{#State 65
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 114,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 66
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 115,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 67
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -73
	},
	{#State 68
		ACTIONS => {
			"::" => 116
		}
	},
	{#State 69
		DEFAULT => -107
	},
	{#State 70
		DEFAULT => -97
	},
	{#State 71
		DEFAULT => -100
	},
	{#State 72
		DEFAULT => -98
	},
	{#State 73
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 117,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 118,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'relational_expr' => 34,
			'multiplicative_expr' => 55
		}
	},
	{#State 74
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 119,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 118,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'relational_expr' => 34,
			'multiplicative_expr' => 55
		}
	},
	{#State 75
		ACTIONS => {
			"in" => 120
		}
	},
	{#State 76
		ACTIONS => {
			"return" => 121
		}
	},
	{#State 77
		ACTIONS => {
			"," => 122
		},
		DEFAULT => -28
	},
	{#State 78
		DEFAULT => -27
	},
	{#State 79
		ACTIONS => {
			")" => 123
		}
	},
	{#State 80
		ACTIONS => {
			":=" => 124
		}
	},
	{#State 81
		ACTIONS => {
			":=" => 125
		}
	},
	{#State 82
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'multiplicative_expr' => 126,
			'plist' => 18
		}
	},
	{#State 83
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 127,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 84
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 128,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 85
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 129,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 86
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 130,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 87
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 131,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 88
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 132,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 89
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'multiplicative_expr' => 133,
			'plist' => 18
		}
	},
	{#State 90
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 134,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 91
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'additive_expr' => 135,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 92
		DEFAULT => 0
	},
	{#State 93
		ACTIONS => {
			"satisfies" => 136
		}
	},
	{#State 94
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 137,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 95
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 138,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 96
		ACTIONS => {
			'QNAME' => 49,
			"*" => 12,
			"{" => 44
		},
		DEFAULT => -76,
		GOTOS => {
			'node_test' => 139
		}
	},
	{#State 97
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 140,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 98
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'PLUS-2' => 143,
			'relative_location_path' => 142,
			'expr_set_list' => 144,
			'expr_set' => 141,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 99
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 145,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 100
		ACTIONS => {
			"}" => 146,
			"with" => 98,
			"err" => 99
		}
	},
	{#State 101
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -72
	},
	{#State 102
		ACTIONS => {
			"//" => 148,
			"/" => 149
		},
		DEFAULT => -66,
		GOTOS => {
			'segment' => 147
		}
	},
	{#State 103
		ACTIONS => {
			"satisfies" => 150
		}
	},
	{#State 104
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 151,
			'additive_expr' => 118,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 105
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 152,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'plist' => 18
		}
	},
	{#State 106
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 153,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'plist' => 18
		}
	},
	{#State 107
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'primary_expr' => 50,
			'unary_expr' => 154,
			'location_path' => 14,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'axis_name' => 16,
			'plist' => 18
		}
	},
	{#State 108
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 155,
			'expr' => 157,
			'location_path' => 14,
			'PLUS-8' => 158,
			'axis_name' => 16,
			'plist' => 18,
			'num_expr' => 159,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'num_list' => 160,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 156,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 109
		DEFAULT => -86
	},
	{#State 110
		DEFAULT => -61
	},
	{#State 111
		DEFAULT => -1
	},
	{#State 112
		DEFAULT => -41
	},
	{#State 113
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 161,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 114
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -75
	},
	{#State 115
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -74
	},
	{#State 116
		ACTIONS => {
			'QNAME' => 49,
			"*" => 12,
			"{" => 44
		},
		GOTOS => {
			'node_test' => 139
		}
	},
	{#State 117
		DEFAULT => -36
	},
	{#State 118
		ACTIONS => {
			"-" => 82,
			"<" => 84,
			"+" => 89,
			">=" => 85,
			"!=" => 90,
			"=" => 91,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -45
	},
	{#State 119
		DEFAULT => -37
	},
	{#State 120
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 162,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 121
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 163,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 122
		ACTIONS => {
			'DOLLAR_QNAME' => 75
		},
		GOTOS => {
			'for_var' => 164
		}
	},
	{#State 123
		DEFAULT => -96
	},
	{#State 124
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 165,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 125
		ACTIONS => {
			'LITERAL' => 166
		}
	},
	{#State 126
		ACTIONS => {
			"mod" => 105,
			"div" => 106,
			'MPY' => 107
		},
		DEFAULT => -54
	},
	{#State 127
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -51
	},
	{#State 128
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -46
	},
	{#State 129
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -49
	},
	{#State 130
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -48
	},
	{#State 131
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -47
	},
	{#State 132
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -50
	},
	{#State 133
		ACTIONS => {
			"mod" => 105,
			"div" => 106,
			'MPY' => 107
		},
		DEFAULT => -53
	},
	{#State 134
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -40
	},
	{#State 135
		ACTIONS => {
			"-" => 82,
			"+" => 89
		},
		DEFAULT => -39
	},
	{#State 136
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 167,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 137
		DEFAULT => -79
	},
	{#State 138
		DEFAULT => -78
	},
	{#State 139
		DEFAULT => -84
	},
	{#State 140
		ACTIONS => {
			"with" => 98,
			"err" => 99,
			")" => 168
		}
	},
	{#State 141
		DEFAULT => -18
	},
	{#State 142
		ACTIONS => {
			":=" => 169,
			"/" => 95,
			"//" => 94
		}
	},
	{#State 143
		ACTIONS => {
			"," => 170
		},
		DEFAULT => -19
	},
	{#State 144
		DEFAULT => -16
	},
	{#State 145
		ACTIONS => {
			"with" => 98
		},
		DEFAULT => -15
	},
	{#State 146
		DEFAULT => -109
	},
	{#State 147
		DEFAULT => -65
	},
	{#State 148
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 171,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 149
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 172,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 150
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 173,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 151
		ACTIONS => {
			"except" => 74,
			"and" => 73
		},
		DEFAULT => -32
	},
	{#State 152
		DEFAULT => -58
	},
	{#State 153
		DEFAULT => -57
	},
	{#State 154
		DEFAULT => -56
	},
	{#State 155
		ACTIONS => {
			"," => -90
		},
		DEFAULT => -9
	},
	{#State 156
		ACTIONS => {
			".." => 88,
			"-" => 82,
			"to" => 83,
			"<" => 84,
			"+" => 89,
			"," => -89,
			">=" => 85,
			"!=" => 90,
			"=" => 91,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -45
	},
	{#State 157
		ACTIONS => {
			"with" => 98,
			"err" => 99,
			"]" => 174
		}
	},
	{#State 158
		ACTIONS => {
			"," => 175
		},
		DEFAULT => -93
	},
	{#State 159
		DEFAULT => -92
	},
	{#State 160
		ACTIONS => {
			"]" => 176
		}
	},
	{#State 161
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -42
	},
	{#State 162
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -29
	},
	{#State 163
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -25
	},
	{#State 164
		DEFAULT => -26
	},
	{#State 165
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -21
	},
	{#State 166
		DEFAULT => -22
	},
	{#State 167
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -31
	},
	{#State 168
		ACTIONS => {
			"then" => 177
		}
	},
	{#State 169
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 178,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 170
		ACTIONS => {
			".." => 35,
			'QNAME' => 49,
			"*" => 12,
			"\@" => 2,
			"{" => 44,
			'NCNAME' => 68,
			"." => 32
		},
		GOTOS => {
			'step' => 10,
			'relative_location_path' => 142,
			'expr_set' => 179,
			'node_test' => 31,
			'axis' => 7
		}
	},
	{#State 171
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -68
	},
	{#State 172
		ACTIONS => {
			"//" => 94,
			"/" => 95
		},
		DEFAULT => -67
	},
	{#State 173
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -30
	},
	{#State 174
		DEFAULT => -94
	},
	{#State 175
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'range_expr' => 180,
			'step' => 10,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'num_expr' => 182,
			'additive_expr' => 181,
			'unary_expr' => 28,
			'primary_expr' => 50,
			'union_expr' => 52,
			'tuple' => 53,
			'node_test' => 31,
			'multiplicative_expr' => 55
		}
	},
	{#State 176
		DEFAULT => -95
	},
	{#State 177
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 183,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 178
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -20
	},
	{#State 179
		DEFAULT => -17
	},
	{#State 180
		DEFAULT => -90
	},
	{#State 181
		ACTIONS => {
			".." => 88,
			"-" => 82,
			"to" => 83,
			"+" => 89
		},
		DEFAULT => -89
	},
	{#State 182
		DEFAULT => -91
	},
	{#State 183
		ACTIONS => {
			"with" => 98,
			"else" => 184,
			"err" => 99
		},
		DEFAULT => -24
	},
	{#State 184
		ACTIONS => {
			".." => 35,
			"-" => 1,
			"every" => 37,
			"\@" => 2,
			'NCNAME' => 40,
			'LITERAL' => 39,
			"if" => 41,
			"*" => 12,
			"[" => 15,
			'NUMBER' => 43,
			"//" => 17,
			'FUNCTION_NAME' => 19,
			'DOLLAR_QNAME' => 21,
			"{" => 44,
			"/" => 45,
			"for" => 23,
			'DOLLAR_INT' => 48,
			"(" => 25,
			'QNAME' => 49,
			"some" => 51,
			"." => 32
		},
		GOTOS => {
			'absolute_location_path' => 3,
			'relative_location_path' => 38,
			'equality_expr' => 4,
			'path_expr' => 6,
			'axis' => 7,
			'PLUS-6' => 8,
			'step' => 10,
			'range_expr' => 11,
			'expr' => 185,
			'location_path' => 14,
			'axis_name' => 16,
			'plist' => 18,
			'and_expr' => 20,
			'or_expr' => 22,
			'if_expr' => 46,
			'err_expr' => 47,
			'for_expr' => 24,
			'additive_expr' => 27,
			'primary_expr' => 50,
			'unary_expr' => 28,
			'union_expr' => 52,
			'with_expr' => 29,
			'tuple' => 53,
			'quant_expr' => 30,
			'node_test' => 31,
			'PLUS-4' => 54,
			'multiplicative_expr' => 55,
			'relational_expr' => 34
		}
	},
	{#State 185
		ACTIONS => {
			"with" => 98,
			"err" => 99
		},
		DEFAULT => -23
	}
],
    yyrules  =>
[
	[#Rule _SUPERSTART
		 '$start', 2, undef
#line 6273 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-1', 3,
sub {
#line 35 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6280 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-1', 1,
sub {
#line 35 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6287 Parser.pm
	],
	[#Rule statements_3
		 'statements', 1,
sub {
#line 35 "engine-parser.eyp"
 Bamboo::Engine::Block -> new( statements => $_[1] ) }
#line 6294 Parser.pm
	],
	[#Rule statement_4
		 'statement', 0, undef
#line 6298 Parser.pm
	],
	[#Rule statement_5
		 'statement', 1, undef
#line 6302 Parser.pm
	],
	[#Rule statement_6
		 'statement', 1, undef
#line 6306 Parser.pm
	],
	[#Rule statement_7
		 'statement', 1, undef
#line 6310 Parser.pm
	],
	[#Rule expr_8
		 'expr', 1, undef
#line 6314 Parser.pm
	],
	[#Rule expr_9
		 'expr', 1, undef
#line 6318 Parser.pm
	],
	[#Rule expr_10
		 'expr', 1, undef
#line 6322 Parser.pm
	],
	[#Rule expr_11
		 'expr', 1, undef
#line 6326 Parser.pm
	],
	[#Rule expr_12
		 'expr', 1, undef
#line 6330 Parser.pm
	],
	[#Rule expr_13
		 'expr', 1, undef
#line 6334 Parser.pm
	],
	[#Rule expr_14
		 'expr', 1, undef
#line 6338 Parser.pm
	],
	[#Rule err_expr_15
		 'err_expr', 3,
sub {
#line 53 "engine-parser.eyp"
 Bamboo::Engine::Parser::ErrExpr -> new( expr => $_[1], default => $_[3] ) }
#line 6345 Parser.pm
	],
	[#Rule with_expr_16
		 'with_expr', 3,
sub {
#line 56 "engine-parser.eyp"
 Bamboo::Engine::Parser::WithExpr -> new( expr => $_[1], annotations => $_[3] ) }
#line 6352 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-2', 3,
sub {
#line 59 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6359 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-2', 1,
sub {
#line 59 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6366 Parser.pm
	],
	[#Rule expr_set_list_19
		 'expr_set_list', 1, undef
#line 6370 Parser.pm
	],
	[#Rule expr_set_20
		 'expr_set', 3,
sub {
#line 62 "engine-parser.eyp"
 Bamboo::Engine::Parser::MemSet -> new( path => $_[1], expr => $_[3] ) }
#line 6377 Parser.pm
	],
	[#Rule let_expr_21
		 'let_expr', 4,
sub {
#line 65 "engine-parser.eyp"
my $expr = $_[4]; my $name = $_[2];  Bamboo::Engine::Parser::VarSet -> new( name => $name, expr => $expr ) }
#line 6384 Parser.pm
	],
	[#Rule ns_expr_22
		 'ns_expr', 4,
sub {
#line 68 "engine-parser.eyp"
my $uri = $_[4]; my $prefix = $_[2];  $_[0] -> AddNS( prefix => $prefix, uri => $uri ) }
#line 6391 Parser.pm
	],
	[#Rule if_expr_23
		 'if_expr', 8,
sub {
#line 71 "engine-parser.eyp"
my $test = $_[3]; my $then = $_[6]; my $else = $_[8];  Bamboo::Engine::Parser::IfExpr -> new( test => $test, then => $then, else => $else ) }
#line 6398 Parser.pm
	],
	[#Rule if_expr_24
		 'if_expr', 6,
sub {
#line 72 "engine-parser.eyp"
my $test = $_[3]; my $then = $_[6];  Bamboo::Engine::Parser::IfExpr -> new( test => $test, then => $then ) }
#line 6405 Parser.pm
	],
	[#Rule for_expr_25
		 'for_expr', 4,
sub {
#line 75 "engine-parser.eyp"
my $expr = $_[4]; my $vars = $_[2];  Bamboo::Engine::Parser::ForExpr -> new( vars => $vars, expr => $expr ) }
#line 6412 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-3', 3,
sub {
#line 78 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6419 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-3', 1,
sub {
#line 78 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6426 Parser.pm
	],
	[#Rule for_vars_28
		 'for_vars', 1, undef
#line 6430 Parser.pm
	],
	[#Rule for_var_29
		 'for_var', 3,
sub {
#line 81 "engine-parser.eyp"
 [ $_[1], $_[3] ] }
#line 6437 Parser.pm
	],
	[#Rule quant_expr_30
		 'quant_expr', 4,
sub {
#line 84 "engine-parser.eyp"
 Bamboo::Engine::Parser::SomeExpr -> new( vars => $_[2], expr => $_[4] ) }
#line 6444 Parser.pm
	],
	[#Rule quant_expr_31
		 'quant_expr', 4,
sub {
#line 85 "engine-parser.eyp"
 Bamboo::Engine::Parser::EveryExpr -> new( vars => $_[2], expr => $_[4] ) }
#line 6451 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-4', 3,
sub {
#line 88 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6458 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-4', 1,
sub {
#line 88 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6465 Parser.pm
	],
	[#Rule or_expr_34
		 'or_expr', 1,
sub {
#line 88 "engine-parser.eyp"
 @{$_[1]} > 1 ? Bamboo::Engine::Parser::OrExpr -> new( exprs => $_[1] ) : $_[1] -> [0] -> simplify }
#line 6472 Parser.pm
	],
	[#Rule and_expr_35
		 'and_expr', 1,
sub {
#line 91 "engine-parser.eyp"
 Bamboo::Engine::Parser::AndExpr -> new( expr => $_[1] ) }
#line 6479 Parser.pm
	],
	[#Rule and_expr_36
		 'and_expr', 3,
sub {
#line 92 "engine-parser.eyp"
 $_[1] -> add_and( $_[3] ) }
#line 6486 Parser.pm
	],
	[#Rule and_expr_37
		 'and_expr', 3,
sub {
#line 93 "engine-parser.eyp"
 $_[1] -> add_except( $_[3] ) }
#line 6493 Parser.pm
	],
	[#Rule equality_expr_38
		 'equality_expr', 1, undef
#line 6497 Parser.pm
	],
	[#Rule equality_expr_39
		 'equality_expr', 3,
sub {
#line 97 "engine-parser.eyp"
my $left = $_[1]; my $right = $_[3];  Bamboo::Engine::Parser::EqExpr -> new( left => $left, right => $right ) }
#line 6504 Parser.pm
	],
	[#Rule equality_expr_40
		 'equality_expr', 3,
sub {
#line 98 "engine-parser.eyp"
my $left = $_[1]; my $right = $_[3];  Bamboo::Engine::Parser::NeqExpr -> new( left => $left, right => $right ) }
#line 6511 Parser.pm
	],
	[#Rule tuple_41
		 'tuple', 3,
sub {
#line 101 "engine-parser.eyp"
 Bamboo::Engine::Parser::Tuple -> new( values => $_[2] ) }
#line 6518 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-5', 3,
sub {
#line 104 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6525 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-5', 1,
sub {
#line 104 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6532 Parser.pm
	],
	[#Rule list_44
		 'list', 1,
sub {
#line 104 "engine-parser.eyp"
 Bamboo::Engine::Parser::ListExpr -> new( expr => $_[1] ) }
#line 6539 Parser.pm
	],
	[#Rule relational_expr_45
		 'relational_expr', 1, undef
#line 6543 Parser.pm
	],
	[#Rule relational_expr_46
		 'relational_expr', 3,
sub {
#line 108 "engine-parser.eyp"
 Bamboo::Engine::Parser::LtExpr -> new( left => $_[1], right => $_[3] ) }
#line 6550 Parser.pm
	],
	[#Rule relational_expr_47
		 'relational_expr', 3,
sub {
#line 109 "engine-parser.eyp"
 Bamboo::Engine::Parser::LtExpr -> new( right => $_[1], left => $_[3] ) }
#line 6557 Parser.pm
	],
	[#Rule relational_expr_48
		 'relational_expr', 3,
sub {
#line 110 "engine-parser.eyp"
 Bamboo::Engine::Parser::LteExpr -> new( left => $_[1], right => $_[3] ) }
#line 6564 Parser.pm
	],
	[#Rule relational_expr_49
		 'relational_expr', 3,
sub {
#line 111 "engine-parser.eyp"
 Bamboo::Engine::Parser::LteExpr -> new( right => $_[1], left => $_[3] ) }
#line 6571 Parser.pm
	],
	[#Rule range_expr_50
		 'range_expr', 3,
sub {
#line 114 "engine-parser.eyp"
 Bamboo::Engine::Parser::RangeExpr -> new( begin => $_[1], end => $_[3] ) }
#line 6578 Parser.pm
	],
	[#Rule range_expr_51
		 'range_expr', 3,
sub {
#line 115 "engine-parser.eyp"
 Bamboo::Engine::Parser::RangeExpr -> new( begin => $_[1], end => $_[3] ) }
#line 6585 Parser.pm
	],
	[#Rule additive_expr_52
		 'additive_expr', 1, undef
#line 6589 Parser.pm
	],
	[#Rule additive_expr_53
		 'additive_expr', 3,
sub {
#line 119 "engine-parser.eyp"
 Bamboo::Engine::Parser::AddExpr -> new( left => $_[1], right => $_[3] ) }
#line 6596 Parser.pm
	],
	[#Rule additive_expr_54
		 'additive_expr', 3,
sub {
#line 120 "engine-parser.eyp"
 Bamboo::Engine::Parser::SubExpr -> new( left => $_[1], right => $_[3] ) }
#line 6603 Parser.pm
	],
	[#Rule multiplicative_expr_55
		 'multiplicative_expr', 1, undef
#line 6607 Parser.pm
	],
	[#Rule multiplicative_expr_56
		 'multiplicative_expr', 3, undef
#line 6611 Parser.pm
	],
	[#Rule multiplicative_expr_57
		 'multiplicative_expr', 3, undef
#line 6615 Parser.pm
	],
	[#Rule multiplicative_expr_58
		 'multiplicative_expr', 3, undef
#line 6619 Parser.pm
	],
	[#Rule unary_expr_59
		 'unary_expr', 1, undef
#line 6623 Parser.pm
	],
	[#Rule unary_expr_60
		 'unary_expr', 2,
sub {
#line 130 "engine-parser.eyp"
 Bamboo::Engine::Parser::NegateExpr -> new( expr => $_[2] ) }
#line 6630 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-6', 3,
sub {
#line 133 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6637 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-6', 1,
sub {
#line 133 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6644 Parser.pm
	],
	[#Rule union_expr_63
		 'union_expr', 1,
sub {
#line 133 "engine-parser.eyp"
 @{$_[1]} > 1 ? Bamboo::Engine::Parser::UnionExpr -> new( set => $_[1] ) : $_[1] -> [0] }
#line 6651 Parser.pm
	],
	[#Rule path_expr_64
		 'path_expr', 1, undef
#line 6655 Parser.pm
	],
	[#Rule path_expr_65
		 'path_expr', 3,
sub {
#line 137 "engine-parser.eyp"
 (defined($_[2]) || defined($_[3])) ? Bamboo::Engine::Parser::PathExpr -> new( primary => $_[1], predicates => $_[2], segment => $_[3] ) : $_[1] }
#line 6662 Parser.pm
	],
	[#Rule segment_66
		 'segment', 0, undef
#line 6666 Parser.pm
	],
	[#Rule segment_67
		 'segment', 2,
sub {
#line 141 "engine-parser.eyp"
 Bamboo::Engine::Parser::ChildSegment -> new( path => $_[2] ) }
#line 6673 Parser.pm
	],
	[#Rule segment_68
		 'segment', 2,
sub {
#line 142 "engine-parser.eyp"
 Bamboo::Engine::Parser::DescendentSegment -> new( path => $_[2] ) }
#line 6680 Parser.pm
	],
	[#Rule location_path_69
		 'location_path', 1, undef
#line 6684 Parser.pm
	],
	[#Rule location_path_70
		 'location_path', 1, undef
#line 6688 Parser.pm
	],
	[#Rule absolute_location_path_71
		 'absolute_location_path', 1,
sub {
#line 149 "engine-parser.eyp"
 Bamboo::Engine::Parser::Root -> new() }
#line 6695 Parser.pm
	],
	[#Rule absolute_location_path_72
		 'absolute_location_path', 2,
sub {
#line 150 "engine-parser.eyp"
 Bamboo::Engine::Parser::ChildSegment -> new( path => $_[2], root => 'data' ) }
#line 6702 Parser.pm
	],
	[#Rule absolute_location_path_73
		 'absolute_location_path', 2,
sub {
#line 151 "engine-parser.eyp"
 Bamboo::Engine::Parser::DescendentSegment -> new( path => $_[2], root => 'data' ) }
#line 6709 Parser.pm
	],
	[#Rule absolute_location_path_74
		 'absolute_location_path', 3,
sub {
#line 152 "engine-parser.eyp"
 Bamboo::Engine::Parser::ChildSegment -> new( path => $_[3], root => $_[1] ) }
#line 6716 Parser.pm
	],
	[#Rule absolute_location_path_75
		 'absolute_location_path', 3,
sub {
#line 153 "engine-parser.eyp"
 Bamboo::Engine::Parser::DescendentSegment -> new( path => $_[3], root => $_[1] ) }
#line 6723 Parser.pm
	],
	[#Rule axis_name_76
		 'axis_name', 2,
sub {
#line 156 "engine-parser.eyp"
 $_[1] }
#line 6730 Parser.pm
	],
	[#Rule relative_location_path_77
		 'relative_location_path', 1, undef
#line 6734 Parser.pm
	],
	[#Rule relative_location_path_78
		 'relative_location_path', 3,
sub {
#line 160 "engine-parser.eyp"
 Bamboo::Engine::Parser::ChildStep -> new( path => $_[1], step => $_[3] ) }
#line 6741 Parser.pm
	],
	[#Rule relative_location_path_79
		 'relative_location_path', 3,
sub {
#line 161 "engine-parser.eyp"
 Bamboo::Engine::Parser::DescendentStep -> new( path => $_[1], step => $_[3] ) }
#line 6748 Parser.pm
	],
	[#Rule step_80
		 'step', 2,
sub {
#line 164 "engine-parser.eyp"
 Bamboo::Engine::Parser::Step -> new( step => $_[1], predicates => $_[2] ) }
#line 6755 Parser.pm
	],
	[#Rule step_81
		 'step', 1,
sub {
#line 165 "engine-parser.eyp"
 Bamboo::Engine::Parser::CurrentContext -> new() }
#line 6762 Parser.pm
	],
	[#Rule step_82
		 'step', 1,
sub {
#line 166 "engine-parser.eyp"
 Bamboo::Engine::Parser::ParentofContext -> new() }
#line 6769 Parser.pm
	],
	[#Rule axis_83
		 'axis', 1,
sub {
#line 169 "engine-parser.eyp"
 Bamboo::Engine::Parser::NodeTest -> new( name => $_[1] ) }
#line 6776 Parser.pm
	],
	[#Rule axis_84
		 'axis', 3, undef
#line 6780 Parser.pm
	],
	[#Rule axis_85
		 'axis', 2,
sub {
#line 171 "engine-parser.eyp"
 Bamboo::Engine::Parser::AttributeTest -> new( name => $_[2] ) }
#line 6787 Parser.pm
	],
	[#Rule _STAR_LIST
		 'STAR-7', 2,
sub {
#line 174 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6794 Parser.pm
	],
	[#Rule _STAR_LIST
		 'STAR-7', 0,
sub {
#line 174 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 6801 Parser.pm
	],
	[#Rule predicates_88
		 'predicates', 1,
sub {
#line 174 "engine-parser.eyp"
 @{$_[1]} ? Bamboo::Engine::Parser::Predicates -> new( predicates => $_[1] ) : undef }
#line 6808 Parser.pm
	],
	[#Rule num_expr_89
		 'num_expr', 1, undef
#line 6812 Parser.pm
	],
	[#Rule num_expr_90
		 'num_expr', 1, undef
#line 6816 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-8', 3,
sub {
#line 181 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_TX1X2 }
#line 6823 Parser.pm
	],
	[#Rule _PLUS_LIST
		 'PLUS-8', 1,
sub {
#line 181 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6830 Parser.pm
	],
	[#Rule num_list_93
		 'num_list', 1,
sub {
#line 181 "engine-parser.eyp"
 Bamboo::Engine::Parser::NumericSet -> new( values => $_[1] ) }
#line 6837 Parser.pm
	],
	[#Rule predicate_94
		 'predicate', 3,
sub {
#line 184 "engine-parser.eyp"
 Bamboo::Engine::Parser::FunctionalPredicate -> new( expr => $_[2] ) }
#line 6844 Parser.pm
	],
	[#Rule predicate_95
		 'predicate', 3,
sub {
#line 185 "engine-parser.eyp"
 Bamboo::Engine::Parser::IndexPredicate -> new( list => $_[2] ) }
#line 6851 Parser.pm
	],
	[#Rule plist_96
		 'plist', 3,
sub {
#line 188 "engine-parser.eyp"
 $_[2] }
#line 6858 Parser.pm
	],
	[#Rule _PAREN
		 'PAREN-9', 1,
sub {
#line 191 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforParenthesis}
#line 6865 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-10', 1,
sub {
#line 191 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 6872 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-10', 0,
sub {
#line 191 "engine-parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 6879 Parser.pm
	],
	[#Rule opt_plist_100
		 'opt_plist', 1, undef
#line 6883 Parser.pm
	],
	[#Rule primary_expr_101
		 'primary_expr', 1, undef
#line 6887 Parser.pm
	],
	[#Rule primary_expr_102
		 'primary_expr', 1, undef
#line 6891 Parser.pm
	],
	[#Rule primary_expr_103
		 'primary_expr', 1, undef
#line 6895 Parser.pm
	],
	[#Rule primary_expr_104
		 'primary_expr', 1, undef
#line 6899 Parser.pm
	],
	[#Rule primary_expr_105
		 'primary_expr', 1,
sub {
#line 198 "engine-parser.eyp"
 Bamboo::Engine::Parser::Literal -> new( value => $_[1] ) }
#line 6906 Parser.pm
	],
	[#Rule primary_expr_106
		 'primary_expr', 1,
sub {
#line 199 "engine-parser.eyp"
 Bamboo::Engine::Parser::Literal -> new( value => $_[1] ) }
#line 6913 Parser.pm
	],
	[#Rule primary_expr_107
		 'primary_expr', 2, undef
#line 6917 Parser.pm
	],
	[#Rule node_test_108
		 'node_test', 1, undef
#line 6921 Parser.pm
	],
	[#Rule node_test_109
		 'node_test', 3, undef
#line 6925 Parser.pm
	],
	[#Rule node_test_110
		 'node_test', 1, undef
#line 6929 Parser.pm
	]
],
#line 6932 Parser.pm
    yybypass       => 0,
    yybuildingtree => 0,
    yyprefix       => 'Bamboo::Engine::Parser::',
    yyaccessors    => {
   },
    yyconflicthandlers => {}
,
    @_,
  );
  bless($self,$class);

  $self->make_node_classes('TERMINAL', '_OPTIONAL', '_STAR_LIST', '_PLUS_LIST', 
         '_SUPERSTART', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'statements_3', 
         'statement_4', 
         'statement_5', 
         'statement_6', 
         'statement_7', 
         'expr_8', 
         'expr_9', 
         'expr_10', 
         'expr_11', 
         'expr_12', 
         'expr_13', 
         'expr_14', 
         'err_expr_15', 
         'with_expr_16', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'expr_set_list_19', 
         'expr_set_20', 
         'let_expr_21', 
         'ns_expr_22', 
         'if_expr_23', 
         'if_expr_24', 
         'for_expr_25', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'for_vars_28', 
         'for_var_29', 
         'quant_expr_30', 
         'quant_expr_31', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'or_expr_34', 
         'and_expr_35', 
         'and_expr_36', 
         'and_expr_37', 
         'equality_expr_38', 
         'equality_expr_39', 
         'equality_expr_40', 
         'tuple_41', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'list_44', 
         'relational_expr_45', 
         'relational_expr_46', 
         'relational_expr_47', 
         'relational_expr_48', 
         'relational_expr_49', 
         'range_expr_50', 
         'range_expr_51', 
         'additive_expr_52', 
         'additive_expr_53', 
         'additive_expr_54', 
         'multiplicative_expr_55', 
         'multiplicative_expr_56', 
         'multiplicative_expr_57', 
         'multiplicative_expr_58', 
         'unary_expr_59', 
         'unary_expr_60', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'union_expr_63', 
         'path_expr_64', 
         'path_expr_65', 
         'segment_66', 
         'segment_67', 
         'segment_68', 
         'location_path_69', 
         'location_path_70', 
         'absolute_location_path_71', 
         'absolute_location_path_72', 
         'absolute_location_path_73', 
         'absolute_location_path_74', 
         'absolute_location_path_75', 
         'axis_name_76', 
         'relative_location_path_77', 
         'relative_location_path_78', 
         'relative_location_path_79', 
         'step_80', 
         'step_81', 
         'step_82', 
         'axis_83', 
         'axis_84', 
         'axis_85', 
         '_STAR_LIST', 
         '_STAR_LIST', 
         'predicates_88', 
         'num_expr_89', 
         'num_expr_90', 
         '_PLUS_LIST', 
         '_PLUS_LIST', 
         'num_list_93', 
         'predicate_94', 
         'predicate_95', 
         'plist_96', 
         '_PAREN', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'opt_plist_100', 
         'primary_expr_101', 
         'primary_expr_102', 
         'primary_expr_103', 
         'primary_expr_104', 
         'primary_expr_105', 
         'primary_expr_106', 
         'primary_expr_107', 
         'node_test_108', 
         'node_test_109', 
         'node_test_110', );
  $self;
}

#line 208 "engine-parser.eyp"


  #| NUMBER
use lib './blib/lib';
use Bamboo::Engine::Block;
use Bamboo::Engine::Parser::BinExpr;
use Bamboo::Engine::Parser::Literal;
use Bamboo::Engine::Parser::RangeExpr;
use Bamboo::Engine::Parser::IfExpr;
use Bamboo::Engine::Parser::AndExpr;
use Data::Dumper;

#sub _Error {
#  my($self, @stuff) = @_;
#
#  warn "Error: " . join(" : ", @stuff) . "\n";
#}

my $SIMPLE_TOKENS = qr{\.\.|::|!=|>=|<=|\/\/|:=|\.|@|\*|\(|\)|\[|\]|\{|\}|\/|\||\+|-|=|>|<|&|,|;};
my $NCNAME = qr/[a-zA-Z_][-a-zA-Z0-9_.]*/;
my $QNAME = qr/(?:${NCNAME}:)?${NCNAME}/;
my $XMLNS = qr/xmlns:${NCNAME}/;

my %reserved_words = map { $_ => $_ } qw(
  for   
  return
  in    
  let   
  except
  every 
  some  
  satisfies
  if    
  then  
  else
  with 
  err  
  and  
  or   
  to   
  mod  
  div  
);

sub _Lexer {
  my($parser, $last) = @_;

  my($white_space, $new_line) = ();

  for($parser -> {_src}) {
    while( m/^(\s|\(:)/ ) {
      while( s/^\s// ) {
        if( s/^\n// ) {
          $new_line += 1;
          $parser -> {_line} += 1;
          $parser -> {_col} = 1;
        }
        else {
          $parser -> {_col} += 1;
        }
        $white_space += 1;
      }

      # skip comments delimited by (: :)
      # comments can be nested
      if( s/^\(:// ) {

        my $comment_depth = 1;
        $parser -> {_col} += 2;
        while( $comment_depth > 0 && $_ ne '' ) {
          if( s/^\(:// ) {
            $comment_depth += 1;
            $parser -> {_col} += 2;
          }
          if( s/^:\)// ) {
            $comment_depth -= 1;
            $parser -> {_col} += 2;
          }
          if( s/^\n// ) {
            $parser -> {_col} = 1;
            $parser -> {_line} += 1;
          }
          elsif( s/^.// ) {
            $parser -> {_col} += 1;
          }
        }

        if( $comment_depth > 0 ) {
          die "Unbalanced comment delimiters at line @{[$parser -> {_line}]}\n";
        }

        $white_space += 1;
      }
    }

    return ( '', undef ) if $_ =~ /^\s*$/;
    #$_ eq '' and return ('', undef);

    if( $white_space ) {
      s/^\*// and return ('MPY', '*');
    }
    if(/^(${NCNAME})(?![\[\/])/ && $reserved_words{$1}) {
      my $rw = $1;
      s/^$rw//;
      return ($rw, $rw);
    }
    s/^(-?\d+(?:\.\d+)?|\.\d+)// and return ('NUMBER', $1);
    s/^($SIMPLE_TOKENS)// and return ($1, $1);
    s/^\$($QNAME)// and return ('DOLLAR_QNAME', $1);
    s/^(\$\d+)// and return ('DOLLAR_INT', $1);
    s/^(${QNAME}\??\*?\s*(?=\([^:]))// and return ('FUNCTION_NAME', $1);
    s/^(${XMLNS})// and return ('XMLNS', $1);
    s/^(${QNAME})// and return ('QNAME', $1);
    s/^(${NCNAME})// and return ('NCNAME', $1);
  }
}

sub line { $_[0] -> { _line } }

sub parse {
  my($self, $src, $debug) = @_;
  my $last = [ ];

  $self -> { _line } = 1;
  $self -> { _col } = 1;
  $self -> { _src } = " " . $src;

  return $self -> YYParse(
    yylex => sub { $last = [_Lexer(shift, $last)]; @$last; },
#    yyerror => \&_Error,
    yydebug => $debug,
  );
}

sub Run { my $parser = shift;
  $parser -> parse(${$parser -> {INPUT}});
}


=for None

=cut


#line 7204 Parser.pm



1;
