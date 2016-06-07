(


//var dirPath = PathName.new("~/Music/*");
var dirPath = PathName.new("/Volumes/Steph2015/Samples:Loops:SFX/");


var search = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	var count = 0;

	dirPath.filesDo({|pathname|
		if(	"^.*\.(%)$".format(fileTypes).matchRegexp(pathname.fileName)){

			if(pathname.fileName.find(searchString,true) != nil){
				//		if(("(?i)"++searchString).matchRegexp(pathname.fileName.basename)){
				itrFunc.(pathname,count);
				count = count + 1;
			}
		}
	});
	completeFunc.(count);

};

search.(
	dirPath,
	"wav|wave|aif|aiff|caf|flac",
	"bird",// using '.' will give every file
	{|a,i| "% : %".format(i,a).postln},
	{|c|("sound files found"+c).postln;}
);


)


