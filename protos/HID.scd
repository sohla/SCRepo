GeneralHID.buildDeviceList;

(
HIDDeviceService.devices.do({arg dev;
	[dev.manufacturer, dev.product, dev.vendorID, dev.productID, dev.locID].postln;
	dev.elements.do({arg ele;
		[ele.type, ele.usage, ele.cookie, ele.min, ele.max].postln;
	});
});
)

HIDDeviceService.devices.at(0).queueDevice;

(
HIDDeviceService.action_({arg productID, vendorID, locID, cookie, val;
		[productID, vendorID, locID, cookie, val].postln;
});
)

HIDDeviceService.runEventLoop;

HIDDeviceService.stopEventLoop;
