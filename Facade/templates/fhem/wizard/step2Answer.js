function() {
	var channels = [%channels%];
	
	if (channels.length > 0) {
		var deviceName = channels[0].split('[')[0];
		var deviceContainer = jQuery('.deviceName:contains("' + deviceName + '")').parents('li');
		var channelContainer = deviceContainer.find('ul');
		var channelFormTemplate = channelContainer.find('.template');
	
		for (var i = 0; i<channels.length; i++) {
			var channelForm = channelFormTemplate.clone(true);
			channelForm.removeClass('template').addClass('foundChannel');
			var channelName = channels[i];
			var deviceName = channelName.split('[')[0];
			var source = channelName.split('[')[1].split('->')[0];
			var destination = channelName.split('[')[1].split('->')[1].split('/')[0];
			var framecount = channelName.split('[')[1].split('->')[1].split('/')[1].replace(']', '');
			
			channelForm.find('legend').text('channel' + i);
			channelForm.find('input[name="name"]').val('channel' + i);
			channelForm.find('input[name="source"]').val(source);
			channelForm.find('input[name="destination"]').val(destination);
			channelForm.find('input[name="framecount"]').val(framecount);
			channelForm.find('input[name="device"]').val(deviceName);
			
			channelContainer.append(channelForm);
		}
		
		channelFormTemplate.remove();
		deviceContainer.find('.ajaxLoader').remove();
		channelContainer.show();
	}
}