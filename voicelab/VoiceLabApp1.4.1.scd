(

	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------


	var sessionData = Dictionary.new;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle,broadcaster;
	var recordSynth,recordBuffer;
	var micInputSynth;
	var micSynth,recorderSynth,recBuffer;
	var listenSynth;
	var arduino;
	var say;
	var pluginSynth;
	var bgFile;
	var bgSynth;

	var playQuestion;

	var pluginIndex = 0;
	var pluginNames = #["OFF","pitchme","shiftme","ringme"];

	var playbackGroup;
	var backgroundGroup;
	var childMicGroup,listenGroup;
	var micInGroup;

	var lxX=0,lxY=0,lxTask,lxUI;
	var tx=0,ty=0;
	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var createSession, loadTemplate,loadSession;
	var getNextNoteNumber, addQuestion;

	var stopRecorder,startRecorder;
	var initGUI, refreshGUI;
	var startRecordingQuestion,stopRecordingQuestion;

	var bgMusicStart, bgMusicStop, bgRoutine;

	// contect locally so we can send msgs
	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup dummy datastore
	sessionData.put("keyPaths",Dictionary.new);


	arduino = RduinoDMX(SerialPort.devices.last,115200);



	//------------------------------------------------------
	// SESSION
	//------------------------------------------------------

	//------------------------------------------------------
	loadTemplate = { |path,completefunc,errorfunc|

		// load a template (json)
		var jsonFile;
		var templateData;
		var fullPath = appPath.asAbsolutePath+/+"template.json";

		//if( File.exists(fullPath),{}{});

         if( File.exists(fullPath) , {

			jsonFile = File(fullPath,"r");

			templateData = jsonFile.readAllString.parseYAML;

			jsonFile.close;

			templateData.writeArchive(path);

			//get list of template sounds
			SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

				var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";

				SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:false);


			};

			// load  session data
			sessionData = Object.readArchive(path);

			completefunc.value;

			// return
			path;
		},{
			errorfunc.value;
		});
	};

	//------------------------------------------------------
	loadSession = { |path,cancelfunc,completefunc,errorfunc|


		File.openDialog("Select a VoiceLab Session ",{|p|

			if(p.basename.splitext[1] == "vls",{

				// load archive from found path
				var templateData = Object.readArchive(p);
				var sourceDirPath = p.dirname;

				// save data as achive inside session dir
				templateData.writeArchive(path);

				(sourceDirPath.asAbsolutePath+/+"Questions/").postln;


				SoundFile.collect(sourceDirPath.asAbsolutePath+/+"Questions/*").do{ |f,i|

					var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";
					f.postln;
					SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:false);
				};

				// load  session data
				sessionData = Object.readArchive(path);

				//refreshGUI.value();
				completefunc.value;
			},{
				// not a .vls file, so reload load dialog
				//loadSession.value(path);
				errorfunc.value;
			});
		},{
			cancelfunc.value;
		});


		// return
		path;
	};

	//------------------------------------------------------
	createSession = {

		var date = Date.getDate;
		var genTitle= date.format("%A_%d:%m:%Y-%H_%M_%S");
			// create all the dirs
		var sessionDir = File.mkdir(appPath.asAbsolutePath+/+genTitle);
		var quesiotnsDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Questions");
		var answersDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Answers");
		var sessionArchivePath = appPath.asAbsolutePath+/+genTitle+/+"session.vls";


		// create empty datastore
		var templateData = Dictionary.new;
		templateData.put("keyPaths",Dictionary.new);

		// save data as achive inside session dir
		templateData.writeArchive(sessionArchivePath);


		sessionTitle = sessionArchivePath.asRelativePath(appPath.absolutePath).dirname;

		// load  session data
		sessionData = Object.readArchive(sessionArchivePath);

		backgroundGroup = Group.new;
		childMicGroup = Group.new;
		listenGroup = Group.new;
		micInGroup  = Group.new;
		playbackGroup = Group.new;

		listenSynth = Synth.head(listenGroup,\listenToMic);
		bgMusicStart.value;

		s.queryAllNodes;


		lxTask = Task.new({ inf.do({ |i|

			{
				 tx = (lxX + (0.04 * sin(0.0001*i*(180.0/pi)))).clip(0,0.999);
				 ty = (lxY + (0.04 * cos(0.0001*i*(180.0/pi)))).clip(0,0.999);

				r = 255;
				c = Color.hsv(tx,1,ty,1);
				lxUI.background_(c);
				arduino.dmxc_(c.red*r,c.green*r,c.blue*r);

			}.defer;

			0.02.wait;

		})}).play;

		// return path
		sessionArchivePath;
	};


	//------------------------------------------------------
	// UTILS
	//------------------------------------------------------

	say = ({|s|
		if(false,{s.speak});
	});


	//------------------------------------------------------
	getNextNoteNumber = {
		a = (0..127);
		b = sessionData["keyPaths"].collect(_.asInteger);
		difference(a,b).first.postln;
		difference(a,b).first;

	};

	//------------------------------------------------------
	addQuestion = { |path,newPath,num|

		var newData,sessionPath;

		SoundFile.normalize(path,newPath,threaded:false);

		// we have to copy the dict since parseYAML returns an unmutable collection!!
		newData = Dictionary.newFrom(sessionData["keyPaths"]);

		// insert new question into datastore
		newData.put(newPath.basename,num.asString);
		sessionData["keyPaths"]  = newData;

		sessionPath = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";
		sessionData.writeArchive(sessionPath);
		sessionData = Object.readArchive(sessionPath);

	};

	//------------------------------------------------------
	stopRecorder = ({
		if(recordBuffer.class == Buffer,{
			recordBuffer.close;
			recordBuffer.free;
			recordBuffer = nil;
			recordSynth.free;
		});


	});

	//------------------------------------------------------
	startRecorder = ({ |title|

		// record kid
		recordBuffer = Buffer.alloc(s,65536,1);
		recordSynth = Synth.head(childMicGroup,\recordInput,["bufnum", recordBuffer.bufnum]);

		g = Date.getDate.format("%H_%M_%S");
		t = title;
		t = "AnswerTo["++t++"]_At_["++g++"].wav";
		p = appPath.asAbsolutePath+/+sessionTitle+/+"Answers";

		recordBuffer.write(p+/+t,"wav","int16", 0, 0, true);

		("Recording "++t).postln;
		s.queryAllNodes;


	});

	//------------------------------------------------------
	playQuestion = ({ |path, completionFunc|

	a = Synth.head(playbackGroup,\playBuffer,[\buffer,Buffer.read(s, path),\amp,0.13]);

	pluginNames[pluginIndex].postln;

		if( pluginIndex > 0, {
			pluginSynth = Synth.after(a,pluginNames[pluginIndex]);
		},{
		});

		stopRecorder.value;

		s.queryAllNodes;
		a.onFree({
			if( pluginIndex > 0, {
				pluginSynth.free;
			},{
			});

			s.queryAllNodes;
			{
				completionFunc.value;

			}.defer;
		});
	});
	//------------------------------------------------------
	startRecordingQuestion = ({ |title|

		micSynth = Synth.head(micInGroup,\micInput,["channel",1]);
		recBuffer.postln;

		if( pluginIndex > 0, {
			pluginSynth = Synth.after(micSynth,pluginNames[pluginIndex]);
		},{
		});


		recBuffer = Buffer.alloc(s,65536,1);

		p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";

		recBuffer.write(p+/+title,"wav","int16", 0, 0, true);
		recorderSynth = Synth.after(micSynth,\diskOut, ["bufnum", recBuffer.bufnum]);
		("Recording "++title).postln;
		s.queryAllNodes;

	});

	//------------------------------------------------------
	stopRecordingQuestion = ({

			if( pluginIndex > 0, {
				pluginSynth.free;
			},{
			});

		recorderSynth.free;
		micSynth.free;

		recBuffer.close;
		recBuffer.postln;
		recBuffer.free;
		recBuffer.postln;
	});

	bgMusicStart = ({

		p = "~/Music/VoiceLab/VoiceLab_audio/Backing Atmos - complex.aif".standardizePath;
		//bgSynth = Synth.head(backgroundGroup,\playBuffer,[\buffer,Buffer.read(s, p),\amp,0.1]);

	 bgFile = SoundFile.openRead(p);
	 bgRoutine = Routine { arg inval;
	 	loop {
	 		e = bgFile.cue((group:backgroundGroup,amp:0.1),playNow:true,closeWhenDone:false);
	 		bgFile.duration.wait;
	 	}
	 }.play;

	 });

	bgMusicStop = ({
	 bgRoutine.stop;
	 bgFile.close;
	//	bgSynth.free;

	});


	//------------------------------------------------------
	// GUI
	//------------------------------------------------------



	//------------------------------------------------------
	initGUI = ({

		var window, mainView;
		var loadView, sessionView, errorView, errorText, textFieldView,textFieldMessage,textField;
		var onPlayLevel;

		var scale = 1.0;
		var listView;
		//------------------------------------------------------
		textFieldView = ({
			View().layout_( VLayout(

				textFieldMessage = StaticText().string_("-").align_(\center).font_(Font(size:24)),
				[textField = TextField()
					.minWidth_(1000)
					.minHeight_(70)
					.font_(Font(size:24))
					, align:\center],

				[Button()
					.states_([["Ok"]])
					.action_({|b|
						var qpath,oldTitle,newTitle;

						textField.object.value.postln;

						qpath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";

						oldTitle = textField.object.value;
						newTitle = textField.string++".wav";

						addQuestion.value(qpath+/+oldTitle,qpath+/+newTitle,getNextNoteNumber.value);

						("Finished recording "++qpath+/+newTitle).postln;
						("Deleting recording "++qpath+/+oldTitle).postln;

						// delete the old temp recording
						File.delete(qpath+/+oldTitle);

						s.queryAllNodes;

						mainView.index = 1;
						refreshGUI.value;

					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center]
			))
		});
		//------------------------------------------------------
		errorView = ({
			View().layout_( VLayout(

				StaticText().string_("Oops").align_(\center).font_(Font(size:48)),
				errorText = StaticText().string_("-").align_(\center).font_(Font(size:24)),

				[Button()
					.states_([["Ok"]])
					.action_({|b|
						mainView.index = 0;
					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center]
			))
		});


		//------------------------------------------------------
		loadView = ({

			View().layout_( VLayout(
				StaticText().string_("Welcome to VoiceLab").align_(\center).font_(Font(size:48)),

				[Button()
					.states_([["New Session"]])
					.action_({|b|
						mainView.index = 1;
						say.value("New, Voice Lab Session");
						createSession.value;
					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center],

				[Button()
					.states_([["Open Session"]])
					.focusGainedAction_({|b|
						b.states = [["Open Session"]];
						b.refresh;
					})

					.action_({|b|
						{
						b.states = [["processing session files...",Color.new255(226, 49, 140)]];
						b.refresh;
						}.defer(1);
						say.value("Open Voice Lab Session");
						loadSession.value(createSession.value,{
							b.states = [["Open Session"]];
							b.refresh;

						},{
							mainView.index = 1;
							refreshGUI.value;
						},{
								errorText.string = "You must select Voice Lab session (.vls) file";
								mainView.index = 2;

						})
					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center],

				[Button()
					.maxHeight_(100)
					.states_([["Template Session"]])
					.focusGainedAction_({|b|
						b.states = [["Template Session"]];
						b.refresh;
					})
					.action_({|b|
						b.states = [["processing session files...",Color.new255(226, 49, 140)]];
						b.refresh;
						say.value("Creating Voice Lab Session from Template");
						{
						loadTemplate.value(createSession.value,{
							mainView.index = 1;
							refreshGUI.value;
						},{
								errorText.string = "Can't seem to find template files.";
								mainView.index = 2;

						})
						}.defer(1)

					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center]

				)
			);

		});


		//------------------------------------------------------
		sessionView = ({

			var btnHeight = 180, playButton,levelStack;
			var recordedQuestionTitle,spokenQuestionTitle;


			View().layout_( HLayout(
				listView = ListView()
					.maxHeight_(700)
					.font_(Font("Helvetica", 24))
					.enterKeyAction_({|v|
						v.items.at(v.value).postln;
					}),
				View().layout_( GridLayout.rows([

					Button()
						.maxHeight_(btnHeight)
						.states_([["PREV"]])
						.action_({|v|
							if(listView.value > 0,{listView.value = listView.value - 1});
						}),

					playButton = Button()
						.maxHeight_(btnHeight)
						.states_([["PLAY"]])
				        .action_({ arg butt;

							if(listView.items.size > 0,{
								window.view.enabled = false;

					            listView.value.postln;
								t = listView.items.at(listView.value);
								p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;

								playQuestion.value(p,{

									// check if there is another question
									// if so, move to next and start recording kid
									if(listView.value + 1 < listView.items.size,{
										listView.value = listView.value + 1;
										startRecorder.value(p.basename.splitext[0]);
									},{
										"LAST".postln;

									});
									window.view.enabled = true;

								});
							});
						}),


					Button()
						.maxHeight_(btnHeight)
						.states_([["NEXT"]])
						.action_({|v|
							listView.value.postln;
							listView.items.size.postln;
							if(listView.value + 1 < listView.items.size,{listView.value = listView.value + 1});
						})

					],[

					Button()
						.maxHeight_(btnHeight)
						.states_([
							["Record"],
							["Stop",bgColor:Color.red]
						])
						.action_({|b|

							switch(b.value,
								0,{
									{
										// stop recording
										stopRecordingQuestion.value;

										t = recordedQuestionTitle;
										n = recordedQuestionTitle.replace("Recording","Question");

										textFieldMessage.string = "Save Question as";
										textField.object = { t };
										textField.valueAction_(n.splitext[0]);
										mainView.index = 3;

									}.defer(0.4);// so we don't loose last bit of buffer

								},
								1,{
									// record

									g = Date.getDate.format("%H_%M_%S");
									recordedQuestionTitle = "Recording"++g++".wav";

									startRecordingQuestion.value(recordedQuestionTitle);
								}
							);

						}),
					Button()
						.maxHeight_(btnHeight)
						.states_([["Import"]])
				        .action_({ arg butt;

							File.openDialog("Select an awesome new question",{|path|

								// copy this file to our questions dir
								var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";

								addQuestion.value(path,newPath+/+path.basename,getNextNoteNumber.value());

								refreshGUI.value;
							},{
								// cancel file open dialog
							});
						}),


					Button()
						.maxHeight_(btnHeight)
						.states_([["Delete"]])
				        .action_({ arg butt;

							var key = listView.items.at(listView.value);
							var path = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+key;

							if(File.exists(path),{

								File.delete(path);

								sessionData["keyPaths"].removeAt(key.asString);
								p = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";

								sessionData.writeArchive(p);
								sessionData = Object.readArchive(p);

								refreshGUI.value;

							},{
									("Error : Can't find Question to delete").postln;
							});

						})



					],[

					Button()
						.maxHeight_(btnHeight)
						.states_([
							["Speak"],
							["Speak", bgColor:Color.green]
						])
						.action_({|b|
							switch(b.value,
								0,{

									stopRecordingQuestion.value;
									startRecorder.value(spokenQuestionTitle.basename.splitext[0]);
								},
								1,{
									stopRecorder.value;

									g = Date.getDate.format("%H_%M_%S");
									spokenQuestionTitle = "SpokenQuestion"++g++".wav";

									startRecordingQuestion.value(spokenQuestionTitle);

								}
							);
						}),
					UserView()
						.drawFunc_({
							if(recordBuffer.class == Buffer,{
								Pen.fillColor_( Color.red(0.5,1.0));
							},{
								Pen.fillColor_( Color.grey( 0.0, 0.1 ));
							});
							Pen.fillRect( Rect( 0, 0, 120, 120));
							Pen.fillColor= Color.new255(226, 49, 140);
							Pen.strokeColor= Color.new255(226, 49, 140);
							Pen.fillOval(Rect.aboutPoint(Point(60, 55), 20*scale, 20*scale));
						})
						.animate_(true)
						.clearOnRefresh_(false)
						.mouseDownAction_({ stopRecorder.value }),


					Button()
						.maxHeight_(btnHeight)
						.states_([["Exit"]])
						.action_({|b|
							listView.items = Array.newClear;
//							stopRecordingQuestion.value;
							stopRecorder.value;
							bgMusicStop.value;
							//listenSynth.free;
							lxTask.stop;
							lxTask.free;

						backgroundGroup.free;
						childMicGroup.free;
						micInGroup.free;
						listenGroup.free;
						playbackGroup.free;

							s.freeAll;
							s.queryAllNodes;
							mainView.index = 0;


						})
					],[
				UserView(),
					PopUpMenu()
					.items_(pluginNames)
					.action_({|menu|
						pluginIndex = menu.value;
					}),
					UserView()
				])


				).minWidth_(400),

				View().layout_(VLayout(

					lxUI= Slider2D()
						.background_(Color.black())
			        	.action_({|sl|
							lxX = sl.x;
							lxY = sl.y;
						});



					));

			));



		});
		//------------------------------------------------------
		refreshGUI = {
			// clear listView
			listView.items = Array.newClear;

			if(sessionData["keyPaths"].isEmpty == false,{
				sessionData["keyPaths"].values.collect(_.asInteger).asSortedList.postln;
				// repopulate in order of assigned midi note
				sessionData["keyPaths"].values.asSortedList.collect(_.asInteger).do({ |val|
					t = sessionData["keyPaths"].findKeyForValue(val.asString);
					listView.items = listView.items.add(t);
				});
				//t = listView.items.at(listView.value).key;
			});
		};

		//------------------------------------------------------
		onPlayLevel = OSCFunc({|msg, time, addr, recvPort|
    		{
				scale = msg[4].ampdb.linexp(-40, 0, 1, 2.0);
//				if( msg[5].ampdb.linlin(-40, 0, 0, 1) > 0.3,{
			// arduino.pw_(9,msg[5].ampdb.linexp(-40, 0, 5, 127));
//			arduino.dmxc_(msg[5].ampdb.linexp(-40, 0, 10, 255),0,0);
//				},{
//					arduino.dmxc_(30,0,0);
//				});

  			}.defer;

		}, '/onPlayLevel');
		//------------------------------------------------------

		window = Window("",Rect(0, 800, 1200, 460))
			.layout_( VLayout(
				mainView = StackLayout(

					loadView.value,
					sessionView.value,
					errorView.value,
					textFieldView.value
≥
				);
			))

			.toFrontAction_({
				say.value("welcome to, voicelab");

				})
			.front;

		window.drawFunc = {
			Pen.addRect(window.view.bounds.insetBy(2));
			Pen.fillAxialGradient(window.view.bounds.leftTop, window.view.bounds.rightBottom, Color.rand, Color.rand);
		};

		window.onClose = ({
			bgMusicStop.value;

			onPlayLevel.free;
			listenSynth.free;
			arduino.dmxc_(0,0,0);
			arduino.close;

		});


	});


	//------------------------------------------------------

	initGUI.value;

)

