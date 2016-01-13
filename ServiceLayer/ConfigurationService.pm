package Resol::ServiceLayer::ConfigurationService;

our @ISA = qw(Resol::LowerLayer::Object);

use constant READ => "<";

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub readProperties {

	my $this = shift;
	my $propFile = shift;
	
	my $ret = {};
	
	#$this->getLogger()->debug("reading properties '$propFile'");
	
	my $fileContent = $this->readFile($propFile);
	my @propLines = split(/\n/, $fileContent);
	
	foreach my $propLine (@propLines) {
		my ($propName, $propVal) = split(/=/, $propLine);
		if ($propName ne "" && !($propName =~ m/^#.*/)){
			#$this->getLogger()->trace("found property [name='$propName', value='$propVal']");
			$ret->{$propName} = $propVal;
			$this->{_properties}->{$propName} = $propVal;
		}
	}
	
	$this->{_properties} = $ret;
	
	return $ret;
}

sub getMatchingProperties {
	my $this = shift;
	my $regExp = shift;

	my $ret = {};
	
	foreach my $propName (%{$this->{_properties}}) {
		if ($propName =~ m/$regExp/) {
			$ret->{$propName} = $this->{_properties}->{$propName};
		}
	}
	
	return $ret;
}

sub readFile {
	my $this = shift;
	my $filePath = shift;
	
	my $ret = "";
	
	open FILE, READ . $filePath;
	while (<FILE>) {
		$ret .= $_;
	}
	close(FILE);
	
	return $ret;
}

sub getProperty {
	my $this = shift;
	my $propName = shift;
	my $defaultRet = shift;
	
	my $ret = $this->{_properties}->{$propName};
	
	if (!defined($ret) && defined($defaultRet)) {
		$ret = $defaultRet;
	}
	
	return $ret;
}

1;
