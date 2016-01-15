package Resol::ServiceLayer::ConfigurationService;

our @ISA = qw(Resol::LowerLayer::Object);

use constant READ => "<";

#
# @author Martin Ackermann
#
# This service can be used to read and process property files.
#

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

#
# This method reads the given property-file.<br />
# Afterwards the properties are available via the method #getProperty
#
# @param propFile
#	- path to the property file.
#
sub readProperties {

	my $this = shift;
	my $propFile = shift;
	
	my $ret = {};
	
	my $fileContent = $this->readFile($propFile);
	my @propLines = split(/\n/, $fileContent);
	
	foreach my $propLine (@propLines) {
		my ($propName, $propVal) = split(/=/, $propLine);
		if ($propName ne "" && !($propName =~ m/^#.*/)){
			$ret->{$propName} = $propVal;
			$this->{_properties}->{$propName} = $propVal;
		}
	}
	
	$this->{_properties} = $ret;
	
	return $ret;
}

#
# Gets all properties which match the given regex.
#
# @param regExp
#	- the given regular expression.
#
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

#
# Gets the value for the given property. Returns either the property value or the given default value.
#
# @param propName
#	- The name of the property.
# @param defaultRet
#	- the given default value - this is returned when there is no property for the given name.
#
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

1;
