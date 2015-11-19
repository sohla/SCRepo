
ColorPicker { // Class by Miguel Negrão

	*new {
		var w,r,g,b,update,color;
		w = Window.new("Color Picker",Rect(100,100,230,68),false);
		r = EZSlider(w, Rect(2,0,150,20),"R",labelWidth:20)
		.action_({ |v| update.(); });
		g = EZSlider(w, Rect(2,22,150,20),"G",labelWidth:20)
		.action_({ |v| update.(); });

		b = EZSlider(w, Rect(2,44,150,20),"B",labelWidth:20)
		.action_({ |v| update.(); });

		[r,g,b].do({|item| item.sliderView.canFocus_(false) });

		color = UserView(w,Rect(160,0,64,64))
		.background_(Color.black)
		.enabled_(true)
		.mouseDownAction_({ color.background.postln;})
		.beginDragAction_({color.background})
		.canFocus_(false);


		update = { color.background_(Color(r.value,g.value,b.value)) };

		w.front;

	}
}

GUI.cocoa

( // OSX Only

var res = 20, scrsize = 200, val, set, win, scr,col;
col = Color.red;
win = Window.new("SCColorChooser",Rect(400, 400, 2*scrsize+20, scrsize),false).front;
win.view.background_(Color.white);
scr = View.new(win,Rect(scrsize+20, 0, scrsize, scrsize));
scr.background_(Color.red);
val = Slider(win, Rect(scrsize, 0, 20, scrsize)).value_(1).action_({win.refresh});
m = View(win, Rect(0, 0, scrsize, scrsize))
	.mouseDownAction_({arg view, x, y;
	col = Color.hsv(min(0.999, (x/scrsize)), min(0.999, (y/scrsize)), val.value, 1).postln;
		scr.background_(col);
//	("Color.rgb("++(c.red)++", "++(c.green)++", "++(c.blue)++", 1)").postln;
	})
	.mouseMoveAction_({arg view, x, y;
	col = Color.hsv(min(0.999, (x/scrsize)), min(0.999, (y/scrsize)), val.value, 1).postln;
		scr.background_(col);
	//("Color.rgb("++(c.red)++", "++(c.green)++", "++(c.blue)++", 1)").postln;
	})
;



win.drawFunc = {
	res.do({ arg i;
		res.do({ arg j;
			Color.hsv(1/res*i,1/res*j, val.value, 1).set;
			Pen.fillRect(Rect((scrsize/res)*i, (scrsize/res)*j, (scrsize/res), (scrsize/res)));
			scr.background_(col);
		})
	})
};
win.front;

)
