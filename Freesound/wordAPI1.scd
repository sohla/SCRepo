"ls".unixCmd;

//118164b29d33fac8f94755fd0a0dabb7291bb079f36c717e3952875e

"CURL % %".format(1,2.3)





curl -X POST \
    -H "x-textrazor-key: YOUR_API_KEY" \
    -d "extractors=entities,entailments" \
    -d "text=Spain's stricken Bankia expects to sell off its vast portfolio of industrial holdings that includes a stake in the parent company of British Airways and Iberia." \
    https://api.textrazor.com/


(


	var apiKey = "118164b29d33fac8f94755fd0a0dabb7291bb079f36c717e3952875e";
	var cmd =  "curl -X POST -H 'x-textrazor-key:%'";
	var tmpFile = PathName.tmp ++ "wordsAPI_" ++ UniqueID.next ++ ".txt";

	cmd = format(cmd, apiKey);

	cmd = cmd + "-d 'extractors=words'";

	cmd = cmd + "-d 'text=Once upon a time, the was a dragon that lived in a cave by the sea.'";

	cmd = cmd + "https://api.textrazor.com/";


	cmd = cmd + "> '%'";

	cmd = format(cmd, tmpFile);


	cmd.unixCmd({|res, pid|

		 var tokenObj = File(tmpFile,"r").readAllString.parseYAML;
		tokenObj.postln;

		// get the word from index
	// tokenObj["response"]["sentences"][0]["words"][0]["token"].postln;
	// tokenObj["response"]["sentences"][0]["words"][0]["partOfSpeech"].postln;


		tokenObj["response"]["sentences"][0]["words"].do({|word|


		//(word["token"] + ":" + word["partOfSpeech"]).postln;



		if(word["partOfSpeech"].find("NN") != nil,{
			word.postln;

		},{});

		});

	});

)




