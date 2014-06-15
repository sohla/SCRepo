
(
	
	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------

	
	var sessionData = Dictionary.new;
	var date = Date.getDate;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle,broadcaster;

	var say;

	var playQuestion;
	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var createSession, loadTemplate,loadSession;
	var getNextNoteNumber, addQuestion;


	var initGUI, refreshGUI;



	// contect locally so we can send msgs
	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup dummy datastore
	sessionData.put("keyPaths",Dictionary.new);





	//------------------------------------------------------
	// SESSION
	//------------------------------------------------------

	//------------------------------------------------------
	loadTemplate = { |path|

		// load a template (json)
		var jsonFile = File(appPath.asAbsolutePath+/+"template.json","r");
		var templateData = jsonFile.readAllString.parseYAML;

		jsonFile.close;

		templateData.writeArchive(path);

		//get list of template sounds
		SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

			var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";

			SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:true);


		};
		
		// load  session data 
		sessionData = Object.readArchive(path);
		
		// return
		path;

	};
	
	//------------------------------------------------------
	loadSession = { |path,completefunc|
		

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
				loadSession.value(path);
				
			});
		},{
			// cancel file open dialog
		});
		
		
		// return
		path;
	};
	
	//------------------------------------------------------
	createSession = {

		var genTitle= date.format("%A_%d:%m:%Y_%H_%M_%S");
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
		difference(a,b).first;

	};

	//------------------------------------------------------
	addQuestion = { |path,num|

		// we have to copy the dict since parseYAML returns an unmutable collection!!
		n = Dictionary.newFrom(sessionData["keyPaths"]);

		// insert new question into datastore
		n.put(path.basename,num.asString);
		sessionData["keyPaths"]  = n;

		p = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";
		sessionData.writeArchive(p);
		sessionData = Object.readArchive(p);

	};

	//------------------------------------------------------
	// COMMANDS
	//------------------------------------------------------

	playQuestion = ({ |path, completionFunc|
			
		a = Synth(\playBuffer,[\buffer,Buffer.read(s, path)]);
		//pluginSynth = Synth.tail(nil,pluginName);

		s.queryAllNodes;
		a.onFree({
			s.queryAllNodes;
			{
				completionFunc.value;
			}.defer;
		});
			
	});

	//------------------------------------------------------
	// GUI
	//------------------------------------------------------



	//------------------------------------------------------
	initGUI = ({
		
		var window, mainView;
		var loadView, sessionView, errorView, errorText;
		var onPlayLevel;
		
		var scale = 1.0;
		var listView;
		//------------------------------------------------------
		errorView = ({
			View().layout_( VLayout(
	
				StaticText().string_("Error").align_(\center).font_(Font(size:48)),
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
//						errorText.string = "oh no, you did something weird!"; 
						
						say.value("Open Voice Lab Session");
						loadSession.value(createSession.value,{
							mainView.index = 1;
							refreshGUI.value;
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
					})
					.minWidth_(400)
					.minHeight_(70)
					, align:\center]
		
				)
			);

		});


		//------------------------------------------------------
		sessionView = ({

			var btnHeight = 180, playButton;
			
			
			View().layout_( HLayout(
				listView = ListView()
					.maxHeight_(900)
					.font_(Font("Helvetica", 44)),
		
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
						.states_([["Import"]])
				        .action_({ arg butt;

							File.openDialog("Select an awesome new question",{|path|

								// copy this file to our questions dir
								var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
								SoundFile.normalize(path,newPath+/+path.basename);
								// generate a unique note number

								addQuestion.value(path,getNextNoteNumber.value());
								
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

							}),
							

					Button()
						.maxHeight_(btnHeight)
						.states_([["Record"]])
					],[
		
					UserView(),
					UserView()
						.drawFunc_({
							Pen.fillColor_( Color.grey( 0.0, 0.1 ));
							Pen.fillRect( Rect( 0, 0, 120, 120));
							Pen.fillColor= Color.new255(226, 49, 140);
							Pen.strokeColor= Color.new255(226, 49, 140);
							Pen.fillOval(Rect.aboutPoint(Point(60, 55), 20*scale, 20*scale));
						})
						.animate_(true)
						.clearOnRefresh_(false),
	
		
					Button()
						.maxHeight_(btnHeight)
						.states_([["Exit"]])
						.action_({|b| mainView.index = 0})
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
					errorView.value
	
				);
			))

			.toFrontAction_({
				say.value("welcome to, voicelab");

				})
			.front;
		
		window.onClose = ({
			onPlayLevel.free;

		});

			
	});


	//------------------------------------------------------

//	buildSession.value;
	initGUI.value;

)
