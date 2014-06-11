(
var w;

w = Window("a gui");
w.layout_(
	VLayout(
		Button().maxHeight_(100).states_(["New Session"]),
		Button().maxHeight_(100),
		Button().maxHeight_(100))
	);
w.front;
w.onClose = {  };
)

