(

	var sessionPath = PathName.new("~/Music/VoiceLab");

	// generate session dir name
	var date = Date.getDate;
	var sessionTitle = date.format("%A_%d:%m:%Y_%R:%S");

	// create all the dirs
	var sessionDir = File.mkdir(sessionPath.asAbsolutePath+/+sessionTitle);
	var quesiotnsDir = File.mkdir(sessionPath.asAbsolutePath+/+sessionTitle+/+"Questions");
	var answersDir = File.mkdir(sessionPath.asAbsolutePath+/+sessionTitle+/+"Answers");

)