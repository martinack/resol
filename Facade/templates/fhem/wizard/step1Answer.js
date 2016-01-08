function() {
	var addresses = [%addresses%];
	
	var actionContainer = jQuery('.actionContainer');
	var container = actionContainer.find('.networkDeviceContainer');
	if (addresses.length > 0) {
		var template = container.find('.template');
		
		for (var i = 0; i<addresses.length; i++) {
			var deviceEntry = template.clone(true);
			deviceEntry.removeClass('template').addClass('device');
			deviceEntry.find('legend').text(addresses[i].split(':')[2]);
			deviceEntry.find('#hostname').val(addresses[i].split(':')[0]);
			deviceEntry.find('#port').val(addresses[i].split(':')[1]);
			deviceEntry.find('#name').val(addresses[i].split(':')[2]);
			deviceEntry.appendTo(container);
		}
		
		template.remove();
		actionContainer.find('.failure').remove();
		actionContainer.show();
	
	} else {
		actionContainer.find('.success').remove();
		actionContainer.show();
	}
}