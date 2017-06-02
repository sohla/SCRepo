(
    var width = 500, height = 400, rate = 0.005;
    var w, u;
	var t = (1.0 + (5.0).sqrt) / 2.0;
	var p1,p2,p3,ico,sel,norm;

	var subtract3V = {|a,b|
		var out = [0,0,0];
	    out[0] = a[0] - b[0];
	    out[1] = a[1] - b[1];
	    out[2] = a[2] - b[2];
	    out
	};

	var cross3V = {|a,b|
		var out = [0,0,0];
   		 var ax = a[0], ay = a[1], az = a[2],bx = b[0], by = b[1], bz = b[2];

	    out[0] = ay * bz - az * by;
	    out[1] = az * bx - ax * bz;
	    out[2] = ax * by - ay * bx;
	    out
	};

	var normalize3V = {|a|
		var out = [0,0,0];
    	var x = a[0], y = a[1], z = a[2];
    	var len = x*x + y*y + z*z;
	    if (len > 0, {
	        //TODO: evaluate use of glm_invsqrt here?
	        len = 1 / len.sqrt;
	        out[0] = a[0] * len;
	        out[1] = a[1] * len;
	        out[2] = a[2] * len;
	    });
	};

    w = Window("3d canvas demo", Rect(128, 64, width, height), false)
        .front;

    u = Canvas3D(w, Rect(0, 0, width, height))
        .background_(Color.black)
        .scale_(200)
        .perspective_(0.4)
        .distance_(2);


    // add cube
    u.add(p1 = Canvas3DItem.grid(2)
        .color_(Color.red)
        .width_(2)
		.transform(Canvas3D.mScale(1,t,1))
		//.transform(Canvas3D.mRotateY(pi/2))
    );
   u.add(p2 = Canvas3DItem.grid(2)
        .color_(Color.green)
        .width_(2)
		.transform(Canvas3D.mScale(t,1,1))
		.transform(Canvas3D.mRotateY(pi/2))
    );
   u.add(p3 = Canvas3DItem.grid(2)
        .color_(Color.blue)
        .width_(2)
		.transform(Canvas3D.mScale(t,1,t))
		.transform(Canvas3D.mRotateX(pi/2))
    );


    u.add(ico = Canvas3DItem()
        .color_(Color.grey.alpha_(0.2))
        .width_(3)
		//.fill_(true)
		.paths_([
			[p1.paths[0][0],p1.paths[0][1],p2.paths[0][1]],
 			[p2.paths[0][1],p3.paths[0][0],p1.paths[0][0]],
		    [p1.paths[0][1],p3.paths[0][1],p2.paths[0][1]],
		   	[p1.paths[0][0],p2.paths[0][0],p1.paths[0][1]],
	    	[p1.paths[0][1],p3.paths[1][1],p2.paths[0][0]],
    		[p1.paths[0][0],p3.paths[1][0],p2.paths[0][0]],

		   	[p1.paths[1][0],p2.paths[1][0],p1.paths[1][1]],
    		[p1.paths[1][1],p3.paths[1][1],p2.paths[1][0]],
		    [p1.paths[1][0],p3.paths[1][0],p2.paths[1][0]],
		    [p1.paths[1][0],p2.paths[1][1],p1.paths[1][1]],
	    	[p1.paths[1][1],p3.paths[0][1],p2.paths[1][1]],
	    	[p1.paths[1][0],p3.paths[0][0],p2.paths[1][1]],

		    [p2.paths[0][1],p3.paths[0][0],p2.paths[1][1]],
		    [p2.paths[0][1],p3.paths[0][1],p2.paths[1][1]],

		    [p2.paths[0][0],p3.paths[1][1],p2.paths[1][0]],
		    [p2.paths[0][0],p3.paths[1][0],p2.paths[1][0]],

		    [p3.paths[0][0],p1.paths[1][0],p3.paths[1][0]],
		    [p3.paths[0][0],p1.paths[0][0],p3.paths[1][0]],

		    [p3.paths[0][1],p1.paths[1][1],p3.paths[1][1]],
		    [p3.paths[0][1],p1.paths[0][1],p3.paths[1][1]],
		])
    );
	t = 0;

	n = cross3V.(
		subtract3V.(ico.paths[t][1],ico.paths[t][0]),
		subtract3V.(ico.paths[t][2],ico.paths[t][0]),
		subtract3V.(ico.paths[t][1],ico.paths[t][0]),
		
	);



	u.add(norm =Canvas3DItem()
        .color_(Color.yellow)
        .width_(2)
		.paths_([[[
				(ico.paths[t][0][0]+ico.paths[t][1][0]+ico.paths[t][2][0])/3,
				(ico.paths[t][0][1]+ico.paths[t][1][1]+ico.paths[t][2][1])/3,
				(ico.paths[t][0][2]+ico.paths[t][1][2]+ico.paths[t][2][2])/3
				],normalize3V.(n)]
		])
	);

	u.add(sel=Canvas3DItem()
        .color_(Color.yellow.alpha_(0.5))
        .width_(2)
		.fill_(true)
		.paths_([
				[ico.paths[t][0],ico.paths[t][1],ico.paths[t][2]]
			])
	);


    // spin canvas on mouse move
    u.mouseMoveAction = {|v,x,y|
        ico.transforms = [
            Canvas3D.mRotateY(x / -200 % 2pi),
            Canvas3D.mRotateX(y / 200 % 2pi)
        ];
		//p1.transforms=p2.transforms=
		p1.transforms=ico.transforms;
		p2.transforms=ico.transforms;
		p3.transforms=ico.transforms;
		sel.transforms=ico.transforms;
		norm.transforms=ico.transforms;

        u.refresh;
    };

    u.mouseMoveAction.value(nil, 50, 50); // initial rotation
)







MIDIClient.init;
MIDIClient.destinations;
m = MIDIOut(0);
m.noteOn(1, 8

