
(
	
	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------

	
	var sessionData = Dictionary.new;
	var date = Date.getDate;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle,broadcaster;
	var recordSynth,recordBuffer;
	var micInputSynth;
	var micSynth,recorderSynth,recBuffer;
	
	var say;

	var playQuestion;
	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var createSession, loadTemplate,loadSession;
	var getNextNoteNumber, addQuestion;

	var killRecorder;
	var initGUI, refreshGUI;
	var startRecordingQuestion,stopRecordingQuestion;


	// contect locally so we can send msgs
	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup dummy datastore
	sessionData.put("keyPaths",Dictionary.new);





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

				SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:true);


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
	loadSession = { |path,completefunc,errorfunc|
		

		File.openDialog("Select a VoiceLab Session ",{|p|

			if(p.basename.splitext[1] == "vls",{

				// load archive from found path
				var templateData = Object.readArchive(p);
				var sourceDirPath = p.dirname;
			
				// save data as achive inside session dir
				templateData.writeArchive(path);

				p.basename.splitext[1].postln;
			
			
				SoundFile.collect(sourceDirPath.asAbsolutePath+/+"Questions/*").do{ |f,i|

					var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";

					SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:true);
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
			// cancel file open dialog
		});
		
		
		// return
		path;
	};
	
	//------------------------------------------------------
	createSession = {

		var genTitle= date.format("%A_%d:%m:%Y-[%H_%M_%S]");
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

		SoundFile.normalize(path,newPath,threaded:false);


		// we have to copy the dict since parseYAML returns an unmutable collection!!
		n = Dictionary.newFrom(sessionData["keyPaths"]);

		// insert new question into datastore
		n.put(newPath.basename,num.asString);
		sessionData["keyPaths"]  = n;

		p = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";
		sessionData.writeArchive(p);
		sessionData = Object.readArchive(p);

	};

	//------------------------------------------------------
	killRecorder = ({
		if(recordBuffer.class == Buffer,{
			recordBuffer.close;
			recordBuffer.free;
			recordBuffer = nil;
			recordSynth.free;
		});
		
		
	});
	
	//------------------------------------------------------
	playQuestion = ({ |path, completionFunc|
			
		a = Synth(\playBuffer,[\buffer,Buffer.read(s, path)]);

		killRecorder.value;
		
		s.queryAllNodes;
		a.onFree({
			s.queryAllNodes;
			{
				completionFunc.value;
				
				// record kid
				recordBuffer = Buffer.alloc(s,65536,1);
				recordSynth = Synth.new(\recordInput,["bufnum", recordBuffer.bufnum]);

				g = Date.getDate.format("%H_%M_%S");
				t = path.basename.splitext[0];
				t = "AnswerTo["++t++"]_At_["++g++"].wav";
				path = appPath.asAbsolutePath+/+sessionTitle+/+"Answers";

				recordBuffer.write(path+/+t,"wav","int16", 0, 0, true);

				("Recording "++t).postln;
				s.queryAllNodes;
				
				
			}.defer;
		});
			
	});



	//------------------------------------------------------
	startRecordingQuestion = ({ |title|
	
		micSynth = Synth.new(\micInput);
		recBuffer.postln;
		recBuffer = Buffer.alloc(s,65536,1);
		
		p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
		
		recBuffer.write(p+/+title,"wav","int16", 0, 0, true);
		recorderSynth = Synth.tail(nil,\diskOut, ["bufnum", recBuffer.bufnum]);
		("Recording "++title).postln;
		s.queryAllNodes;
	
	});
	
	//------------------------------------------------------
	stopRecordingQuestion = ({ 
	
		recorderSynth.free;
		micSynth.free;

		recBuffer.close;
		recBuffer.postln;
		recBuffer.free;
		recBuffer.postln;
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
						
						textField.object.value.postln;
						
						p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
						
						t = textField.object.value;
						n = textField.string++".wav";
						
//						SoundFile.normalize(p+/+t,p+/+n,threaded:false);

						addQuestion.value(p+/+t,p+/+n,getNextNoteNumber.value);
						("Finished recording "++p+/+n).postln;

						// delete the old temp recording
						File.delete(p+/+t);

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
					.action_({|b|
						say.value("Open Voice Lab Session");
						loadSession.value(createSession.value,{
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
					.action_({|b| 
						say.value("Creating Voice Lab Session from Template");
						loadTemplate.value(createSession.value,{
							mainView.index = 1;
							refreshGUI.value;
						},{
								errorText.string = "Can't seem to find template files."; 
								mainView.index = 2;
							
						})
						
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
			var recordedQuestionTitle;
			
			View().layout_( HLayout(
				listView = ListView()
					.maxHeight_(900)
					.font_(Font("Helvetica", 44))
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
							window.view.enabled = false;
				
				            listView.value.postln;
							t = listView.items.at(listView.value);
							p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;

							playQuestion.value(p,{
								if(listView.value + 1 < listView.items.size,{listView.value = listView.value + 1});
								window.view.enabled = true;
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
//							["Level Check",bgColor:Color.green],
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
								},
								2,{
									
								},
								);
							
						}),
					Button()
						.maxHeight_(btnHeight)
						.states_([["Import"]])
				        .action_({ arg butt;

							File.openDialog("Select an awesome new question",{|path|

								// copy this file to our questions dir
								var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
//								SoundFile.normalize(path,newPath+/+path.basename);
								// generate a unique note number

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
								
										micInputSynth.free;
								},
								1,{
									
									micInputSynth = Synth.new(\micInput);

								});
						}),
					UserView()
						.drawFunc_({
							if(recordBuffer.class == Buffer,{
								Pen.fillColor_( Color.red);
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
						.mouseDownAction_({ killRecorder.value }),
		
					Button()
						.maxHeight_(btnHeight)
						.states_([["Exit"]])
						.action_({|b| 
							listView.items = Array.newClear;
							killRecorder.value;
							s.freeAll;
							s.queryAllNodes;
							mainView.index = 0;
							
						})
					])
	
	
				).minWidth_(400)

			))

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

  			}.defer;

		}, '/onPlayLevel');
		//------------------------------------------------------

		window = Window("",Rect(0, 800, 1200, 400))
			.layout_( VLayout(
				mainView = StackLayout(

					loadView.value,
					sessionView.value,
					errorView.value,
					textFieldView.value
	
				);
			))

			.toFrontAction_({
				say.value("welcome to, voicelab");

				})
			.front;
			
//		window.drawFunc = {
//			Pen.addRect(window.view.bounds);
//			Pen.fillAxialGradient(window.view.bounds.leftTop, window.view.bounds.rightBottom, Color.rand, Color.rand);
//		};
		
		window.onClose = ({
			onPlayLevel.free;

		});

			
	});


	//------------------------------------------------------

	initGUI.value;

)
