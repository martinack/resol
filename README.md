# resol4perl
Perl based lib to connect to resol vbus

## Example usage:

```
#!/usr/bin/perl

use Resol::Facade::ResolFacade;

#Creating the facade
my $resol = new Resol::Facade::ResolFacade();

#Creating a device
$resol->createNetworkDevice("deviceName", "192.168.178.58", "7053", "password");

#Creating a chanel (can be determined via $resol->getCommunicationChannels("deviceName"))
$resol->createChannelForDevice("deviceName", "channelName", "001", "711", "11");

#Receiving valid data
my $data = $resol->getDataForChannel("channelName");

#Extracting the data
my $highByte = $data->getDataFrame(0)->getDataByteAsHexString(0);
my $lowByte = $data->getDataFrame(0)->getDataByteAsHexString(0);

#Format the data
my $tempSensor1 = hex($lowByte . $highByte);

print("Temperature of sensor1: $tempSensor1\n");
```
