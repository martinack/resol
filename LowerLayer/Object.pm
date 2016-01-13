package Resol::LowerLayer::Object;

our @ISA = qw(UNIVERSAL);

use FindBin;
use File::Basename;
use File::Spec::Functions;

use Data::Dumper;
local $Data::Dumper::Terse = 1;

BEGIN {
	my $libBasePath = File::Spec::Functions::rel2abs(File::Basename::dirname(__FILE__)) . "/../lib";
	$libBasePath =~ s/\\/\//g;

	#push(@INC, "$libBasePath/Log-Dispatch-2.41/lib");
	#push(@INC, "$libBasePath/Log-Log4perl-1.43/lib");
	#push(@INC, "$libBasePath/Time-HiRes-1.9726");
	push(@INC, "$libBasePath/Scalar-List-Utils-1.35/lib");
}

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
