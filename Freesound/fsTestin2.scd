Server.local.boot;
// Token Authentication
// https://www.freesound.org/docs/api/authentication.html#token-authentication
// After obtaining the API key, this is the only thing you need to do for authenticating with the token method:

Freesound.authType = "token";// default, only needed if you changed it
Freesound.token="bfa791a021762f7c6cb70088c720855a0c5f8f49";

// Oauth2 Authentication
// https://www.freesound.org/docs/api/authentication.html#oauth2-authentication
// Slightly more involved, here's the recommended procedure:
// 1. Obtain the API key (note that old APIv1 keys will not work)
// 2. Get the authorization URL:

Freesound.clientId="f2880da706c6d92d7ce3";
Freesound.clientSecret = "bfa791a021762f7c6cb70088c720855a0c5f8f49";
Freesound.authType = "oauth2";
Freesound.getAuthorizationPage

// 3. Open the URL that shows in the post window in a web browser
// 4. Within the nex 10 minutes, request your first token:
Freesound.getToken("f9d981718d607f8dd5875b50c6493600a142a7e5")
// This will save the token in a file besides the Freesound class file (you can change this path if you need to manage multiple tokens). This token will last 24h. From then on you can renew it e.g. each time you start a session:

(
Freesound.clientId = "f2880da706c6d92d7ce3";
Freesound.clientSecret = "bfa791a021762f7c6cb70088c720855a0c5f8f49";
Freesound.authType = "oauth2";
Freesound.refreshToken;
)




/////

// some synths to help us play buffers
(

SynthDef("help_mp3_01", { |bufnum = 0|
	var son = DiskIn.ar(1, bufnum);
	FreeSelfWhenDone.kr(son);
	Out.ar(0, son!2);
}).load(s);


SynthDef("help_mp3_02", { |bufnum = 0|
	var son = DiskIn.ar(2, bufnum);
	FreeSelfWhenDone.kr(son);
	Out.ar(0, son!2);
}).load(s);



)



///
// let's download the mp3 file then play it
(
FSSound.textSearch(
	query: "snare",
	filter: "duration:[0 TO 10]",
	params:('page':1),
	action: {|p|

	var snd = p[0]; // first result

	p.postln;

	snd.name.postln;
	snd.channels.asInteger.postln;

	snd.retrievePreview("/tmp/", {

		// remove and rename with correct extention
		m = MP3("/tmp/" ++ snd.name.splitext[0] ++ ".mp3");
		m.start;


			// since can't alloc buffer channels at runtime need to switch
			switch(snd.channels.asInteger,
				1, {
					"1".postln;
					b = Buffer.cueSoundFile(s, m.fifo, 0, 1);
					x = Synth("help_mp3_01", [\bufnum, b.bufnum], addAction:\addToTail);

				},
				2, {
					"2".postln;
					b = Buffer.cueSoundFile(s, m.fifo, 0, 2);
					x = Synth("help_mp3_02", [\bufnum, b.bufnum], addAction:\addToTail);

				}
			);



	},"hq","mp3");

});
)


(
x.free;
b.close; b.free;

m.finish;
s.freeAll

)
s.queryAllNodes;
s.plotTree;

