(
var scroll = ScrollView(bounds:Rect(0,0,500,300).center_(Window.availableBounds.center));
var canvas = View();
var layout;
var i = 0;

var makeEntry = {
    var view = View().background_(Color.rand).layout_(
        HLayout(
			StaticText().string_( ("This is number " + i.asString) ).minWidth_(250),
            Button().states_([["Delete"]]).action_({view.remove; i = i - 1;}),
			Button().states_([["Play"]]).action_({"PLAY".postln;})
        )
    );
    i = i + 1;
    view;
};


canvas.layout = VLayout();
30.do { canvas.layout.add( makeEntry.() ) };
//canvas.layout.add(nil); // stretch remaining empty space

scroll.canvas = canvas;
scroll.front;
)