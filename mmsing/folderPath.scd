(
var defaultPath = PathName.new("~/Music/SCSamples/mmsingloops1");
var soundsPath = defaultPath;

var openFolderDialog, onFolderPath;

onFolderPath = ({|path|
	path.postln;
});


openFolderDialog = ({|onSuccess|

FileDialog.new(
	okFunc:{ |paths| onSuccess.(paths.first)},
	fileMode:2);
});

soundsPath.isNil.if(
	{openFolderDialog.(onFolderPath)},
	{onFolderPath.(defaultPath)}
);


)
