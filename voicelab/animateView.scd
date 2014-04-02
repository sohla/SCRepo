(
var width= 400, height= 400;
var xspeed= 4, yspeed= 5;
var x= width*0.5, y= height*0.5;
var win= Window("bouncing ball", Rect(100, 200, width, height));
var usr= UserView(win, Rect(0, 0, width, height));
win.view.background= Color.black;
usr.drawFunc= {
        if(x<0 or:{x>width}, {xspeed= 0-xspeed});
        if(y<0 or:{y>height}, {yspeed= 0-yspeed});
        x= x+xspeed;
        y= y+yspeed;
        Pen.fillColor= Color.white;
        Pen.fillOval(Rect.aboutPoint(Point(x, y), 8, 8));
};
win.front;
CmdPeriod.doOnce({win.close});
// usr.animate= true;
)



(
var width= 400, height= 400;
var win= Window("bouncing ball", Rect(100, 200, width, height));
var usr= UserView(win, Rect(0, 0, 200, 200));
var x= 100, y= 100;
var scale = 1.0;
var delta = 0.04;

win.view.background= Color.black;


usr.drawFunc= {

	if(scale < 1.0 or:{scale > 1.3}, {delta = delta * -1.0});


	scale = scale + delta;
        Pen.fillColor= Color.white;
        Pen.fillOval(Rect.aboutPoint(Point(x, y), 50*scale, 50*scale));
};
win.front;
CmdPeriod.doOnce({win.close});
usr.animate= true;
)
