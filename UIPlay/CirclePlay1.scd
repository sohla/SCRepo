(
var window, view;
var updateView, drawCircleAt;
var xx = 0,yy = 0 , dx = 0.01;

//------------------------------------------------------

updateView = {|view|

	xx = xx + dx;
	yy = 0;


	x = EaseInQuad.(xx) * 200;

	drawCircleAt.(view.bounds.center);
	drawCircleAt.(view.bounds.center.translate(x@yy),"rain",1.0);


	if(xx > 1,{ dx = dx * -1;},{});
	if(xx < 0,{ dx = dx * -1;},{});

};
//------------------------------------------------------

drawCircleAt = {|atPoint,string="hello world",alpha = 0.4|

	Pen.use{
		r = Rect.aboutPoint(atPoint,50,50);
		Pen.fillColor_(Color.green(0.7,alpha));
		Pen.fillOval(r);
		string.drawCenteredIn(r,Font("Nanum Pen Script",16),Color.blue(0.8));
	};
};
//------------------------------------------------------

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.background_(Color.white)
	.front;

window.layout = HLayout();
window.layout.margins_([0,0,0,0]);

window.layout.add(
	view = UserView()
	.drawFunc_(updateView)
	.animate_(true)

);



window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)





