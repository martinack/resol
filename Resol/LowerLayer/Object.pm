package Resol::LowerLayer::Object;

our @ISA = qw(UNIVERSAL);

use FindBin;
use File::Basename;
use File::Spec::Functions;

#
# @author Martin Ackermann
#
# This is a basic object which provides a "instanceOf" method.
#

BEGIN {
	my $libBasePath = File::Spec::Functions::rel2abs(File::Basename::dirname(__FILE__)) . "/../lib";
	$libBasePath =~ s/\\/\//g;

	push(@INC, "$libBasePath/Scalar-List-Utils-1.35/lib");
}

use Scalar::Util;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub instanceof {
	my $this = shift;
	my $class = shift;
	
	return $this->isa($class);
}

1;
