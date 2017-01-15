Freesound.token="8ad629f6bf67cd8916127d5cd54793f448aa4fc2";
Freesound.clientId="5b16bf3072f9b0857e03";
Freesound.clientSecret = "8ad629f6bf67cd8916127d5cd54793f448aa4fc2";
Freesound.authType = "oauth2";
Freesound.getAuthorizationPage


Freesound.getToken("5EtuuBHUw3RXkhkzFIKaeSDmAOr4cu")


FSSound.getSound(31362, {|f|
    ~snd = f;
    ~snd["name"].postln;
});


~snd.dict.keys;
~snd.name;
~snd["name"];
~snd.tags;
~snd.duration;
~snd.url;





~preview = ~snd.retrievePreview("/tmp/", {
        ~buf = Buffer.read(s, "/tmp/" ++ ~snd.previewFilename);
        "done!".postln;
});

"/tmp/" ++ ~snd.previewFilename.postln;
~buf.play;



FSSound.textSearch(query:"",action:{|p|
	p.dict.keys.postln;
});
