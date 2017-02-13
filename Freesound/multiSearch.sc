(


	var searchA = {|term,filter,responseFunc|

		//send of to get a result
		var result = ["A1","A2","A3","A4"];

		responseFunc.(result);
	};

	var searchB = {|term,filter,responseFunc|

		//send of to get a result
		var result = ["B1","B2","B3","B4"];

		responseFunc.(result);
	};



	var mySearch = searchB;


	mySearch.("a","asdasd",{|response|		
		response.do({|a,i|
			[i,a].postln;
		});


});

)