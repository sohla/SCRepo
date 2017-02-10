(
var window;
var mainView;
var connectView;
var headerView,numberTextView,nameTextView;
var levelsView;
var speakerView;

var speakerArray;
var speakerBuffer;
var panBus, widthBus;
var speakerList;
var onLevels;
var level;
var slidersArray = [];
var levelsArray = [];

var isEditing = false;

var ip = "10.1.1.3";
var netAddr;

var version = 0;
var workspaceName = "-";
var workspaceID = -1;
 var cueID = -1;
// var cueName = "-";

var appRequest;
var onCueSelected;
var wsNotify;

var startConnection,stopConnection;
//------------------------------------------------------

	onCueSelected = {|active,address,name,resultFunc|

		active.if({
			wsNotify = OSCFunc({ arg msg, time, addr, recvPort;
				{
					//[">>",msg].postln;
					//msg[1].asString.parseYAML["status"].postln;
					resultFunc.(msg[1]);

				}.defer;
			},"/update/workspace/"++name++"/cueList/0/playbackPosition",recvPort:53001);
			"starting workspace updates...".postln;
			address.sendMsg("/updates",1);
		},{
			"stopping workspace updates".postln;
			address.sendMsg("/updates",0);
			wsNotify.free;
		});
	};




//------------------------------------------------------
	appRequest = {|address,message,resultFunc,a=nil|

		var of = OSCFunc({ arg msg, time, addr, recvPort;
			{
				msg.addUniqueMethod(\data, { |to| to[1].asString.parseYAML["data"] });
				//[">>",msg].postln;
				//msg[1].asString.parseYAML["status"].postln;
				resultFunc.(msg);
				of.free;
			}.defer;
		},"/reply"++message,recvPort:53001);

		address.sendMsg(message,a);
	};

//------------------------------------------------------

speakerList = [ [60, "R"], [0, "C"], [120, "Rs"],[-60, "L"],[-120, "Ls"],[-180, "Ll"]];

//------------------------------------------------------

mainView = {


	View().layout_(

		GridLayout.rows([
			connectView.(),
			[speakerView.(), rows:3]
		],[
			headerView.()
		],[
			levelsView.()
		],[
		]);
	);	
};



//------------------------------------------------------
speakerView = {



	var roundView;



	var widthSpec = [0,180].asSpec;
	var widthSlider;
	var x=200, y=150, targx=200, targy=150;


	widthSlider = Slider()
				.maxHeight_(30)
				.orientation_(\horizontal)
				.action_({|v|
					//widthSpec.map(v.value).postln;
					widthBus.set(widthSpec.map(v.value));
					roundView.refresh;
				});

	roundView = UserView()
		.minHeight_(400)
		.minWidth_(400)
		.canFocus_(false)
		.mouseMoveAction_({|v,inx,iny| isEditing = true; x = inx; y = iny; roundView.refresh;})
		.mouseDownAction_({|v,inx,iny| isEditing = true; x = inx; y = iny; roundView.refresh;})
		.mouseUpAction_({|v,inx,iny| isEditing = false;})
		.drawFunc_({

			var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
			var targRotate, actRotate, targPoint;
			var maxShiftPerFrame = 20, frameInterval = 0.01;
			var resched = false, count = 0;
			var actPoint;

			maxShiftPerFrame = maxShiftPerFrame * atorad;
			actPoint = Point(x, y) - Point(200, 200);

		    Color.black.set;
		    // draw the speaker layout
		    Pen.translate(200,200);
		    (((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString++"º").drawCenteredIn(Rect.aboutPoint(0@10, 40, 10), Font.new("Arial", 10), Color.grey(0.3));
		    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
		    Pen.rotate(pi);
		    speakerList.do({|spkr|
			    Color.grey(0.2).set;

		        Pen.use({
		            Pen.rotate(spkr[0] * atorad);
		            Pen.moveTo(0@170);
		            Pen.fillRect(r = Rect.aboutPoint(0@170, 10, 10));
		            if(spkr[0].abs < 90, {
		                Pen.use({
		                    Pen.translate(0, 170); 
		                    Pen.rotate(pi);
		                    spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10), 
		                        GUI.font.new("Arial", 10), Color.white);
		                });
		            },{ 
		                spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.white);
		            });
		        });
		    });

		    Pen.moveTo(0@0);

			Color.red.alpha_(0.1).set;
		    // draw the pan point
		    Pen.rotate(actPoint.theta + 0.5pi);
		    targPoint = Point(x, y) - Point(200, 200);
		    // trunc to avoid loops due to fp math
		    targRotate = (targPoint.theta - actPoint.theta).trunc(1e-15);
		    // wrap around
		    if(targRotate.abs > pi, {targRotate = (2pi - targRotate.abs) * targRotate.sign.neg}); 
		    actRotate = targRotate.clip2(maxShiftPerFrame).trunc(1e-15);
		    actPoint = actPoint.rotate(actRotate);
		    Pen.rotate(actRotate);
		    Pen.lineTo(0@150);
			Color.grey(0.5).set;
		    Pen.stroke;
		    Pen.fillOval(Rect.aboutPoint(0@150, 7, 7));
			Color.red.alpha_(0.1).set;
		    Pen.addWedge(0@0, 140, neg(widthSpec.map(widthSlider.value) * 0.5) * atorad + 0.5pi, widthSpec.map(widthSlider.value) * atorad);
		    Pen.fill;
		    Color.grey(0.8).alpha_(0.1).set;
		    Pen.addWedge(0@0, 140, neg(widthSpec.map(widthSlider.value) * 0.5) * atorad + 0.5pi, widthSpec.map(widthSlider.value) * atorad);
		    Pen.fill;

		//    if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
		    if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
		});


	panBus = Bus.control;
	widthBus = Bus.control.set(60);
	widthSlider.value_(widthSpec.unmap(60));


	(VLayout(
		widthSlider,
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		roundView
	));

	
};


//------------------------------------------------------
levelsView = {

	var count = 9;
	var layout;
	var sliders,values,levels;
	//var slidersArray = [];
	var valuesArray = [];
	var sliderLevelPair;

	sliderLevelPair = { [

		LevelIndicator(w, Rect(0, 0, 4, 100))
			.background_(Color.grey(0.5))
			.maxWidth_(4),
		Slider(w, Rect(0, 0, 10, 100))
	] } ! count ;

	sliders = {

		HLayout(*sliderLevelPair.collect { |x| HLayout(*x).spacing_(0) });
	};

	values = {
		HLayout (

			*{|i|TextField()
				.minHeight_(30)
				.maxWidth_(50)
				.background_(if (i==0){Color.grey(0.1)}{Color.grey(0.2)})
				.stringColor_(Color.grey)
				.string_("1.0")
				.align_(\center)
			}!count;
		)
	};


	layout = View().layout_( VLayout(
		sliders.(),
		values.()
	));

	slidersArray = layout.children(Slider);
	valuesArray = layout.children(TextField);
	levelsArray = layout.children(LevelIndicator);

	levelsArray.do({|o,i|
		o.value = 0.8;
	});


	slidersArray.do({|o,i|
		o.action_({|sl|
			//valuesArray[i].value = sl.value.asStringPrec(2);
		});
	});

	valuesArray.do({|o,i|
		o.action_({|vl|
			slidersArray[i].value = vl.value;
		});
	});


	layout
};
//------------------------------------------------------

headerView = {

	View().layout_( HLayout(

			numberTextView = StaticText()
				.maxHeight_(50)
				.minHeight_(50)
				.maxWidth_(50)
				.minWidth_(50)
				.string_("-")
				.align_(\center)
				.stringColor_(Color.black)
				.background_(Color.grey),

			nameTextView = StaticText()
				.maxHeight_(50)
				.string_(" _")
				.align_(\left)
				.stringColor_(Color.black)
				.background_(Color.grey),

			VLayout( 
				Button()
					.states_([["▲"]])
					.maxWidth_(30)
					.action_({
						if(netAddr != nil){
							netAddr.sendMsg("/workspace/"++workspaceID++"/select/previous");
						};
					}),

				Button()
					.states_([["▼"]])
					.maxWidth_(30)
					.action_({
						if(netAddr != nil){
							netAddr.sendMsg("/workspace/"++workspaceID++"/select/next");
						};
					}),

			)
		);	
	);

};
//------------------------------------------------------

connectView = {

	var textField;

	View().layout_( HLayout(
	textField = TextField()
		.string_(ip),
	Button()
	.maxWidth_(150)
		.states_([["Connect",Color.green(0.6)],["Disconnect",Color.red(0.6)]])
		.action_({|b|

			b.value.asBoolean.if({
				textField.enabled = false;
				"GO".postln;

				netAddr = NetAddr.new(ip, 53000);
				startConnection.();

			},{
				textField.enabled = true;
				stopConnection.();
			});
		});
	))

};

//------------------------------------------------------
window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width * 0.7,
		Window.screenBounds.height / 2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

window.layout.add(mainView.());


//------------------------------------------------------

window.onClose = ({

	
	//stopConnection.();
	if(netAddr != nil){
		"stopping workspace updates".postln;
		netAddr.sendMsg("/updates",0)
	};
	wsNotify.free;

	onLevels.free;
	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});

//------------------------------------------------------

startConnection = {


	appRequest.(netAddr,"/version",{|result| 

		version = result.data;

		appRequest.(netAddr,"/workspaces",{|result| 
			
			workspaceName = result.data[0]["displayName"];
			workspaceID = result.data[0]["uniqueID"];

			["|QLab| Version :"+version, "Workspace :"+workspaceName].postln;

			onCueSelected.(true,netAddr,workspaceID,{|result|

				
				cueID = result;
				["cue selected id",result].postln;


				// playing around with data\
				// appRequest.(netAddr,"/workspace/"++workspaceID++"/selectedCues",{|result| 
				// 	result.data[0]["workspaceID"].postln;
				// });

				// get ALL the data

				// cue was selected in QLab so update everything locally


				appRequest.(netAddr,"/cue_id/"++result++"/valuesForKeys",{|result| 
					result.data.postln;


					//• err no auto update?
					numberTextView.string_(result.data["number"]);
					nameTextView.string_(" "+result.data["displayName"]);


					9.do({ |i|
						//result.data["sliderLevels"][i].asFloat.class.postln;
						levelsArray[i].value = result.data["sliderLevels"][i].asFloat.dbamp;

					});
					


				}, "[
					\"displayName\",
					\"number\",
					\"type\",
					\"sliderLevels\"
				]");

			});

		});

	})

};


stopConnection = {
	
	onCueSelected.(false,netAddr);

};

//------------------------------------------------------

onLevels = OSCFunc({|msg, time, addr, recvPort|

	{

		level = msg[5].ampdb.linexp(-40, 12, 1, 2.0) - 1.0;
		//[msg[3],level].postln;


		if(netAddr != nil && isEditing){
		slidersArray[msg[3]+1].valueAction_(level);
			netAddr.sendMsg("/cue_id/"++cueID++"/sliderLevel/"++(msg[3]+1), ampdb(level));
		};
	}.defer;

}, '/onLevels');


//------------------------------------------------------
// VBAP
//------------------------------------------------------

speakerArray = VBAPSpeakerArray.new(2, speakerList.collect(_.first));
speakerBuffer = speakerArray.loadToBuffer;


SynthDef('VBAP 5 chan', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf|

	var panned, source;	
	var imp = Impulse.kr(10);
	var delimp = Delay1.kr(imp);

	source = SinOsc.ar([140, 204], 0, 0.2);
	azi = azi.circleRamp;
	panned = VBAP.ar(6, source, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
	// 'standard' channel order for 5.1

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 
		
		var sum = panned[0][i] + panned[1][i];

			SendReply.kr(imp, '/onLevels', [i,Amplitude.kr(sum), K2A.ar(Peak.ar(sum, delimp).lag(0, 0.1))]);

		//Out.ar(bus, panned[0][i]);

	});

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 

		//Out.ar(bus, panned[1][i])

	});



}).play(s, [vbapBuf: speakerBuffer.bufnum, azi: panBus.asMap, width: widthBus.asMap]);


)