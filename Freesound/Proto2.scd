//------------------------------------------------------
(

~serviceProto = Proto({
	~basePath = "Error : need to imp.";
	~searchWithText = {|searchString, itrFunc, completeFunc|
		"searching % for % ....".format(~basePath,searchString);

	};
});

~freesoundProto = ~serviceProto.clone({
	~basePath = "freesound";

	~searchWithText = {|searchString, itrFunc, completeFunc|
		"searching % for % ....".format(~basePath,searchString);

		10.do({|i| itrFunc.(i);});

		completeFunc.("done");
	};

});

~localDiskProto = ~serviceProto.clone({
	~basePath = "local disk";

});



~freesoundProto.searchWithText("e",
	{|itr|
		itr.postln;
	},
	{|result|
		result.postln;
	}
);
)


