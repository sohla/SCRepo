(
	var sfv,sf;
	var path = PathName.new("~/Music/SCSamples/discustingMelody.wav").asAbsolutePath;
w=Window().layout_(


	GridLayout.rows(
		[
			[sfv = SoundFileView(), columns:2]
		],
		[
			Button().minHeight_(100).states_([["Play"]]),

			VLayout(
			CheckBox().string_("auto-fade"),
			CheckBox().string_("loop")
			)


		],[
			[Slider().orientation_(\horizontal).maxHeight_(100),columns:2]
		]
	)



).front;

	sf = SoundFile.new;
	sf.openRead(path);
	sfv.soundfile = sf;
sfv.read(0,sf.numFrames);

)



