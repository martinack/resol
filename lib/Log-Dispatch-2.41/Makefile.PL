
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;
check_conflicts();



my %WriteMakefileArgs = (
  "ABSTRACT" => "Dispatches messages to one or more outputs",
  "AUTHOR" => "Dave Rolsky <autarch\@urth.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "Dist::CheckConflicts" => "0.02",
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Log-Dispatch",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "Log::Dispatch",
  "PREREQ_PM" => {
    "Class::Load" => 0,
    "Dist::CheckConflicts" => "0.02",
    "Params::Validate" => "0.15",
    "Sys::Syslog" => "0.25"
  },
  "TEST_REQUIRES" => {
    "File::Temp" => 0,
    "Test::More" => "0.88"
  },
  "VERSION" => "2.41",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);




sub check_conflicts {
    if ( eval { require 'lib/Log/Dispatch/Conflicts.pm'; 1; } ) {
        if ( eval { Log::Dispatch::Conflicts->check_conflicts; 1 } ) {
            return;
        }
        else {
            my $err = $@;
            $err =~ s/^/    /mg;
            warn "***\n$err***\n";
        }
    }
    else {
        print <<'EOF';
***
    Your toolchain doesn't support configure_requires, so Dist::CheckConflicts
    hasn't been installed yet. You should check for conflicting modules
    manually by examining the list of conflicts in Log::Dispatch::Conflicts once the installation
    finishes.
***
EOF
    }

    return if $ENV{AUTOMATED_TESTING} || $ENV{NONINTERACTIVE_TESTING};

    # More or less copied from Module::Build
    return if $ENV{PERL_MM_USE_DEFAULT};
    return unless -t STDIN && ( -t STDOUT || !( -f STDOUT || -c STDOUT ) );

    sleep 4;
}
