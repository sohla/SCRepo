a = [{"1".postln;},{"2".postln;}]
b = a[0]
b.()

//------------------------------------------------------


c = 0
c.addUniqueMethod(\test,{|a| "hi %".format(a)});
c.test

d = c.shallowCopy
d = 1


//------------------------------------------------------


n = Proto({
	~mul = { |x, y| [x, y, x * y] };
});
n.mul(5, 4);

p = n.copy

q = n.clone({
	~mul = { |x, y| [x, y, (x * x) + (y * y)] };
});

p.mul(3,2);

q.mul(5,4);



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
	};

});

~localDiskProto = ~serviceProto.clone({
	~basePath = "local disk";

});



~freesoundProto.searchWithText("e",
	{|itr|
	},
	{|result|
	}
);
)