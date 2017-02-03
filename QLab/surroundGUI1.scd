(
// use shift-click to keep a node selected
w = Window("envelope",
	Rect(0 , 0, 500,500).center_(Window.availableBounds.center)
).front;
w.view.decorator = FlowLayout(w.view.bounds);

b = EnvelopeView(w, Rect(0, 0, 500, 500))
    .drawLines_(false)
    .selectionColor_(Color.red)
    .drawRects_(true)
    .resize_(5)
    .step_(0.005)
    .action_({arg b; [b.index, b.value].postln})
    .thumbSize_(20)

    .value_([[0.5, 0.5, 0.15, 0.85, 0.15, 0.85],[0.5,0.9,0.9,0.9,0.1,0.1]]);


b.setString(0,"Listener");
b.setFillColor(0,Color.green);

b.setString(1,"Source");
b.setFillColor(1,Color.red);

b.setString(2,"L");
b.setFillColor(2,Color.grey);

b.setString(3,"R");
b.setFillColor(3,Color.grey);


b.setString(4,"BL");
b.setFillColor(4,Color.grey);

b.setString(5,"BR");
b.setFillColor(5,Color.grey);

w.front;
)
