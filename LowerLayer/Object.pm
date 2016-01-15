package Resol::LowerLayer::Object;

our @ISA = qw(UNIVERSAL);

use FindBin;
use File::Basename;
use File::Spec::Functions;

#
# @author Martin Ackermann
#
# This is a basic object which provides a "instanceOf" method, and access to a global service context.
#

BEGIN {
	my $libBasePath = File::Spec::Functions::rel2abs(File::Basename::dirname(__FILE__)) . "/../lib";
	$libBasePath =~ s/\\/\//g;

	push(@INC, "$libBasePath/Scalar-List-Utils-1.35/lib");
}

#@TODO: is this method needed?
sub getRootDir {
	my $ret = File::Spec::Functions::rel2abs(File::Basename::dirname(__FILE__)) . "/../";
	$ret =~ s/\\/\//g;
	return $ret;
}

use Resol::ServiceLayer::ServiceContext;
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

sub getServiceContext {
	my $this = shift;
	
	if (!defined($this->{_serviceContext})) {
		$this->{_serviceContext} = new Resol::ServiceLayer::ServiceContext();
	}
	
	return $this->{_serviceContext};
}

sub getService {
	my $this = shift;
	my $serviceName = shift;
	return $this->getServiceContext()->getService($serviceName);
}

1;
