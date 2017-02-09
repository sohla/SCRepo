b = NetAddr.new("10.1.1.3", 53000);

b.sendMsg("/select/1", "");
b.sendMsg("/cue/1/start", "");
b.sendMsg("/cue/1/stop", "");

b.sendMsg("/cue/2/start", "");


b.sendMsg("/cue/2/sliderLevel/2", -4.0);


// connect to QLab, start a cue and change volume
(
b = NetAddr.new("10.1.1.3", 53000);
b.sendMsg("/cue/1/start", "");
b.sendMsg("/cue/1/stop", "");

r = Routine({|in|
	var f;
	    loop {
		f = thisThread.beats.fold(1,10) * 5;
		b.sendMsg("/cue/1/sliderLevel/0", f.neg);
		0.01.yield;
    }
});

TempoClock.default.sched(0, r);
)

// stop the above
(
r.stop;
b.sendMsg("/cue/1/stop", "");
b.sendMsg("/cue/1/sliderLevel/0", 0);
)

// send via gui
(
b = NetAddr.new("10.1.1.3", 53000);

w = Window.new.front;
c = NumberBox(w, Rect(20, 20, 150, 20));
d = ControlSpec(-60, 0, \linear, 1);

a = Slider(w, Rect(20, 60, 150, 20))
    .action_({
	        c.value_(d.map(a.value));
	b.sendMsg("/cue/2/sliderLevel/2", d.map(a.value));
        });
a.action.value;
)



OSCFunc.trace(true,true);
OSCFunc.trace(false);

s.reboot
s.quit
s.unmute
s.dumpOSC(1)


// local info
NetAddr.localAddr
NetAddr.langPort
NetAddr.disconnectAll

// send to QLab
b = NetAddr.new("10.1.1.3", 53000);
b.sendMsg("/cue/2/start", "");
b.disconnect

// listen to reply : use defer to post!!!
o = OSCFunc({ arg msg, time, addr, recvPort;
	{
		[msg, time, addr, recvPort].postln;

	}.defer;
},"/reply/version",recvPort:53001);// qlab sends back on 53001

// send msg to get back some data
b.sendMsg("/version");
o.free;


// get the unique ID of the workspace
(
a = "/workspaces";
b = NetAddr.new("10.1.1.3", 53000);

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
//		[msg, time, addr, recvPort].postln;
		msg[0].postln;
		d = msg[1].asString.parseYAML["data"][0];
		d["workspaceID"].postln;
		o.free;

	}.defer;
},"/reply"++a,recvPort:53001);
b.sendMsg(a);
)



// list all the cues in the workspace
(
a = "/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/cueLists";
b = NetAddr.new("10.1.1.3", 53000);

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
//		[msg, time, addr, recvPort].postln;
		msg[0].postln;
		d = msg[1].asString.parseYAML["data"][0];
		d.postln;
		d["cues"].do({|o,i|
			[i,o["number"],o["name"]].postln;
		});

	}.defer;
},"/reply"++a,recvPort:53001);
b.sendMsg(a);
)
o.free;



// setup updat notification
(
a = "/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/updates";
b = NetAddr.new("10.1.1.3", 53000);

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
		msg[1].postln;

		// play selected cue within QLab
		//b.sendMsg("/cue_id/"++msg[1]++"/start", "");

	}.defer;
},"/update/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/cueList/0/playbackPosition",recvPort:53001);
b.sendMsg(a,1);
)
o.free;




// get some details of a selected cue
(
b = NetAddr.new("10.1.1.3", 53000);

 b.sendMsg("/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/cue_id/1/valuesForKeys", "[\"type\",\"sliderLevels\"]");
// b.sendMsg("/cue_id/1/sliderLevels");

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
		msg[1].postln;

		// play selected vue within QLab
		//b.sendMsg("/cue_id/"++msg[1]++"/start", "");
	
		// to execute only once, we free this function
		//o.free;
	

	}.defer;
},"/update/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/cueList/0/playbackPosition",recvPort:53001);

a = "/updates";
b.sendMsg(a,1);

)


o.free;


b = NetAddr.new("10.1.1.3", 53000);
b.sendMsg("/selectedCues");


b.sendMsg("/workspace/oscTest/select/next");
b.sendMsg("/workspace/oscTest/select/previous");

b.sendMsg("/workspace/oscTest/selectedCues");

b.sendMsg("/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/selectedCues");
	

/*

connect with QLab 


get workspaces unique id

check /reply the status is ok





*/



// listen to reply : use defer to post!!!






//------------------------------------------------------
//------------------------------------------------------


(



	var ip = "10.1.1.3";
	var netAddr = NetAddr.new(ip, 53000);

	var version;
	var workspaceName;
	var workspaceID;
	var cueID;
	var cueName;





	var appRequest;
	var onCueSelected;
	var wsNotify;

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


	// do the work....
	// everything is wrapped up in a callback

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


				appRequest.(netAddr,"/cue_id/"++cueID++"/valuesForKeys",{|result| 
					result.data.postln;
				}, "[
					\"displayName\",
					\"number\",
					\"type\",
					\"sliderLevels\"
				]");



			});


			{onCueSelected.(false,netAddr)}.defer(5);

		});

	});

)
