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
	my $this = {};
	bless $this, $class;
	
	my $cfg = shift;
	if (!$initialized) {
	
		my $defaultCfg = $this->getRootDir() . DEFAULT_CONFIG;
		my $configurationService = new Resol::ServiceLayer::ConfigurationService();
		my $config;
		$registry->{configurationService} = $configurationService;
	
		#Log::Log4perl->init($defaultCfg);
		#$this->getLogger()->info("initializing default service context...");
		$configurationService->readProperties($defaultCfg);
		
		$config = $configurationService->getMatchingProperties("^service\..*");
		$this->initServices($config);
	
		if (defined($cfg)) {
			#Log::Log4perl->init($cfg);
			#$this->getLogger()->info("initializing custom service context...");
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
	
	foreach my $propName (keys $config) {
		if (!($propName =~ m/.*\.scope/)) {
			my $serviceName = $config->{$propName};
			my $serviceClass = $propName;
			if (!defined($this->getService($serviceName, true))) {
				$serviceClass =~ s/service\.//g;
				$serviceClass =~ s/\./::/g;
				#$this->getLogger()->info("registering service '$serviceName' of class '$serviceClass'...");
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
	
	#$this->getLogger()->debug("searching for service '$serviceToGet'...");
	
	my @matches = ();
	foreach my $serviceName (keys %{$registry}) {
		#$this->getLogger()->trace("checking service '$serviceName'...");
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
		#if (!$supressErrors) {
		#	$this->getLogger()->error("No service for '$serviceToGet' found, check your service definitions.");
		#}
	} elsif ($matchCount > 1) {
		#if (!$supressErrors) {
		#	$this->getLogger()->error("More then one service for '$serviceToGet' found, check your service definitions.");
		#}
	} else {
		my $service = @matches[0];
		my $propClass = Scalar::Util::blessed($service);
		$propClass =~ s/::/\./g;
		my $scope = $registry->{configurationService}->getProperty("service.$propClass.scope", SINGLETON);
		#$this->getLogger()->debug("scope of service '$propClass' is '$scope'");
		if ($scope eq SINGLETON) {
			$ret = @matches[0];
		} else {
			my $serviceClass = Scalar::Util::blessed($service);
			#$this->getLogger()->debug("will create a new instance of '$propClass'");
			#@FIXME: for some reasons new $serviceClass() causing a compile error, but $serviceClass->new() isn't beauty :(
			$ret = $serviceClass->new();
		}
	}
	
	return $ret;
}

1;
