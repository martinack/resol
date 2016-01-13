package Resol::ServiceLayer::ServiceContext;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;
use Resol::ServiceLayer::ConfigurationService;

our $registry = {};
our $initialized = 0;

use Data::Dumper;
local $Data::Dumper::Terse = 1;

use constant SINGLETON => "singleton";
use constant PROPERTY => "property";
use constant DEFAULT_CONFIG => "default.properties";

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	

	my $cfg = shift;
	if (!$initialized) {
	
		my $defaultCfg = $this->getRootDir() . DEFAULT_CONFIG;
		my $configurationService = new Resol::ServiceLayer::ConfigurationService();
		my $config;
		$registry->{configurationService} = $configurationService;

		$configurationService->readProperties($defaultCfg);
		
		$config = $configurationService->getMatchingProperties("^service\..*");

		$this->initServices($config);
	
		if (defined($cfg)) {
			$configurationService->readProperties($cfg);
			
			$config = $configurationService->getMatchingProperties("^service\..*");
			$this->initServices($config);			
		}
		
		$initialized = 1;
	}
	
	return $this;
}

sub initServices {
	my $this = shift;
	my $config = shift;
	

	foreach my $propName (keys %$config) {
		if (!($propName =~ m/.*\.scope/)) {
			my $serviceName = $config->{$propName};
			my $serviceClass = $propName;
			if (!defined($this->getService($serviceName, true))) {
				$serviceClass =~ s/service\.//g;
				$serviceClass =~ s/\./::/g;
				$registry->{$serviceName} = $serviceClass->new();
			}
		}
	}
}

sub addService {
	my $this = shift;
	my $service = shift;
	my $name = shift;
	
	if (!defined($name)) {
		$name = Scalar::Util::blessed($service);
	}
	
	if (!defined(ServiceContext->getService($serviceClass))) {
		$registry->{$name} = $service;
	}
}

sub getService {

	my $this = shift;
	my $serviceToGet = shift;
	my $supressErrors = shift;

	if (defined($supressErrors)) {
		$supressErrors = false;
	}
	
	my @matches = ();
	foreach my $serviceName (keys %{$registry}) {
		if ($serviceName eq $serviceToGet) {
			push(@matches, $registry->{$serviceName});
			next;
		}
		my $serviceClass = Scalar::Util::blessed($registry->{$serviceName});
		if ($serviceClass eq $serviceToGet) {
			push(@matches, $registry->{$serviceName});
		}
	}
	

	my $matchCount = @matches;
	my $ret;
	
	if ($matchCount == 0) {
		print("ERROR: No service for '$serviceToGet' found, check your service definitions.");
	} elsif ($matchCount > 1) {
		print("ERROR: More then one service for '$serviceToGet' found, check your service definitions.");
	} else {
		my $service = @matches[0];
		my $propClass = Scalar::Util::blessed($service);
		$propClass =~ s/::/\./g;
		my $scope = $registry->{configurationService}->getProperty("service.$propClass.scope", SINGLETON);
		if ($scope eq SINGLETON) {
			$ret = @matches[0];
		} else {
			my $serviceClass = Scalar::Util::blessed($service);
			$ret = $serviceClass->new();
		}
	}
	
	return $ret;
}

1;
