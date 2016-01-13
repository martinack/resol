package Resol::Facade::FhemResolFacade;

our @ISA = qw(Resol::Facade::ResolFacade);

use Resol::Facade::ResolFacade;

use Data::Dumper;
local $Data::Dumper::Terse = 1;

use constant MASTER_TEMPLATE => "fhem/master.html";
use constant AJAX_ANSWER => "fhem/answer.json";
use constant TEMPLATE_DIR => "fhem/";

sub new
{
	my $class = shift;
	my $this = {
		_templateMapping => {
			Resol::Facade::ResolFacade::NOT_INITIALIZED => "fhem/notInitialized.html"
		}
	};
	bless $this, $class;
	new Resol::ServiceLayer::ServiceContext();
	return $this;
}

sub getOverview
{
	my $this = shift;
	my $globalResolModule = shift;
	my $allResolModules = shift;
	
	my $ret = "";
	
	#$this->getLogger()->debug("will generate overview for state '" . $globalResolModule->{STATE} . "'");
	
	my $content = $this->buildContent($globalResolModule, $allResolModules);
	
	$ret = $this->renderTemplate(MASTER_TEMPLATE, $content);
	
	
	return $ret;
}

sub getTemplateForState {
	my $this = shift;
	my $state = shift;
	
	#$this->getLogger()->debug("looking up template for state '$state'");
	
	return $this->{_templateMapping}->{$state};
}

sub buildContent {
	my $this = shift;
	my $globalResolModule = shift;
	my $allResolModules = shift;
	
	my $ret = {
		content => $this->renderTemplate($this->getTemplateForState($globalResolModule->{STATE}))
	};
	
	return $ret;
}

sub delegateAjax {
	my $this = shift;
	my $params = shift;
	my $globalResolModule = shift;
	
	my $ret;
	my $answer;
	
	if (defined($params->{"wizard"})) {
		my $wizardStep = $params->{"wizard"};
		
		my $devices = $this->getNetworkDevicesByFhemModule($globalResolModule);
		
		my $renderedDeviceTemplates = "";
		my $renderedChannelTemplates = "";
		
		foreach my $deviceName (keys $devices) {
			my $device = $devices->{$deviceName};
			$renderedDeviceTemplates .= $this->renderTemplate(TEMPLATE_DIR . "wizard/wizardDevice" . $wizardStep . ".html", $device);
			if (defined($device->getChannels())) {
				foreach my $channel (@{$device->getChannels()}) {
					$renderedChannelTemplates .= $this->renderTemplate(TEMPLATE_DIR . "wizard/wizardChannel" . $wizardStep . ".html", $channel);
				}
			}
		}
		
		my $wizardContext = {
			devices => $renderedDeviceTemplates,
			channels => $renderedChannelTemplates
		};
		
		my $wizardContent = $this->renderTemplate(TEMPLATE_DIR . "wizard/wizard" . $wizardStep . ".html", $wizardContext);
		
		$answer = {
			newContent => $wizardContent
		};
		
	} elsif (defined($params->{"action"})) {
		my $action = $params->{"action"};
		
		if ($action eq "searchNetworkDeviceAddresses") {
		
			my $addrString = "";
			
			foreach my $address (@{$this->getNetworkDeviceAddresses()}) {
				$addrString .= "'" . $address . "',";
			}
		
			chop($addrString);
		
			#$this->getLogger()->debug("found addresses: $addrString");
			my $addr = {
				addresses => $addrString
			};
		
			$answer = {
				action => $this->renderTemplate(TEMPLATE_DIR . "wizard/step1Answer.js", $addr)
			};
		
		} elsif ($action eq "createNetworkDevice") {
			
			$this->createNetworkDevice($params->{"name"}, $params->{"hostname"}, $params->{"port"}, $params->{"password"});

		} elsif ($action eq "getCommunicationChannels") {
		
			my $channelString = "";
			
			foreach my $channel (@{$this->getCommunicationChannels($params->{"deviceName"})}) {
				$channelString .= "'" . $channel->getName() . "',";
			}
		
			chop($channelString);
			
			my $channels = {
				channels => $channelString
			};
			
			$answer = {
				action => $this->renderTemplate(TEMPLATE_DIR . "wizard/step2Answer.js", $channels)
			};

		} elsif ($action eq "getAChannelFrame") {
		
			my $channelName = $params->{"channel"};
			my $frame = $this->getDataForChannel($channelName);
		
			#$this->getLogger()->debug(Dumper($frame));
		
			my $frameHexString = "";
			my $frameTemperatureString = "";
			my $frameBitmaskString = "";
			my $framePercentString = "";
			my $frameTriggerString = "";
			
			my $converter = $this->getService("converterService");
			
			for my $i (0..($frame->getDataFrameCount() - 1)) {
				$frame->getDataFrame($i)->asHexString();
				$frameTemperatureString .= $converter->toTemperature($frame->getDataFrame($i));
				$frameBitmaskString .= $converter->toBitmask($frame->getDataFrame($i));
				$framePercentString .= $converter->toPercent($frame->getDataFrame($i));
				$frameTriggerString .= $converter->toTrigger($frame->getDataFrame($i));
				$frameHexString .= $converter->toHex($frame->getDataFrame($i));
			}
			
			my $frameData = {
				asHex => $frameHexString,
				asTemp => $frameTemperatureString,
				asPercent => $framePercentString,
				asBits => $frameBitmaskString,
				asTrigger => $frameTriggerString
			};
		
			$answer = {
				action => $this->renderTemplate(TEMPLATE_DIR . "wizard/step3Answer.js", $frameData)
			}
		}
	} elsif (defined($params->{"tooltip"})) {
		
		$answer = {
			newContent => $this->renderTemplate(TEMPLATE_DIR . "tooltip/" . $params->{"tooltip"} . ".html")
		};
	}
	
	$answer = $this->wrapAnswer($answer);
	
	$ret = $this->renderTemplate(AJAX_ANSWER, $answer);
	return $ret;
}

sub wrapAnswer {
	my $this = shift;
	my $answer = shift;
	
	if (!defined($answer->{action})) {
		$answer->{action} = "\"\"";
	}
	
	if (!defined($answer->{newContent})) {
		$answer->{newContent} = "";
	} else {
		$answer->{newContent} =~ s/"/\\"/g;
		$answer->{newContent} =~ s/\n//g;
		$answer->{newContent} =~ s/\r//g;
		$answer->{newContent} =~ s/\t//g;
	}
	
	return $answer;
}

sub getNetworkDevicesByFhemModule {
	my $this = shift;
	my $globalResolModule = shift;
	
	my $ret = {};
	
	#$this->getLogger()->debug("searching in fhem module for network devices. fhem module: " . Dumper($globalResolModule));
	
	foreach my $paramName (keys %{$globalResolModule}) {
		if ($paramName =~ m/^device\./) {
			my @splittedParam = split(/\./, $paramName);
			my $deviceName = @splittedParam[1];
			if (!defined($ret->{$deviceName})) {
				$ret->{$deviceName} = $this->getService("deviceProvider")->getNetworkDevice($deviceName);
			}
		}
	}
	
	return $ret;
}

1;
