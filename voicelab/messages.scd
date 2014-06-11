(

	var broadcaster;
	var onRecordMsg,onPlayMsg;
	var window;
	
	var keyCommands = (
		97 : "/onRecordMsg",
		115 : "/onPlayMsg"
			
		);
		
	var commands = (
			
		onRecordMsg: (func: 0, unicode: 97),
		onPlayMsg: (func: 0, unicode: 115)
			
	);
		
	// init
	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// ui
	window = Window.new("Messages").front;
	
	window.onClose = {
		onRecordMsg.free;
	};
	
	// listeners
/*	onRecordMsg = OSCFunc({|msg, time, addr, recvPort|{
			"onRecordMsg"+[msg,time,addr,recvPort].postln;
		}.defer;
	}, keyCommands.at(97));

	onPlayMsg = OSCFunc({|msg, time, addr, recvPort|{
			"onPlayMsg"+[msg,time,addr,recvPort].postln;
		}.defer;
	},keyCommands.at(115));
*/

	commands.onRecordMsg.func = { |obj|
		[obj].postln;
	};

	commands.onPlayMsg.func = { |obj|
		[obj].postln;
	};

	//keys
	window.view.keyDownAction = { |view, char, modifiers, unicode, keycode|
		
		//keyCommands.at(unicode).postln;
//		broadcaster.sendMsg(keyCommands.at(unicode),unicode,keycode);

		commands.keysValuesDo{ |key,value|
			
			if(value.unicode == unicode,{value.func});
		};
			
	};

	
)
c = [];
a = ( func: b);
c = c.add(a);
c[0][\func] = {"hello"}
c[0].at(\func).value

a = { |a, b, c| postf("% plus % plus % is %\n", a, b, c, a + b + c); "" };
a.performMsg([\value, 1, 2, 3]);


a = ( 	
		fooA: (func: 0, unicode: 1),
		fooB: (func: 0, unicode: 2)

);

a[\fooA][\func] = {|a,b,c|[a,b,c,"YEA FOOA"].postln;};
a[\fooB][\func] = {|a,b,c|[a,b,c,"FOOB"].postln;};
\fooB

a = 5
a.addUniqueMethod(\yo,{"hi".postln});


a.fooB.func = {|a,b|[a,b].postln};
a.fooB.func(9)



a.at(\fooA).at(\func).performMsg([\value,1,2,3]);
a.at(\fooB).at(\func).performMsg([\value]);

a.keysValuesDo { |key,value| value.unicode.postln};



