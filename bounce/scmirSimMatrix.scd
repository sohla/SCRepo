//self similarity demo

a = FloatArray[0.05,0.1,0.5,0.8,1.2,1.4]; 

m = SCMIRSimilarityMatrix(1,a); //1 dimensional data, stored in a

m.sequence1 //a
m.sequence2 //also a
m.self //1 = self similarity matrix
m.columns //size of a
m.rows    //also size of a
m.dimensions    //1

m.calculate(1,1); //create matrix of unit 1, metric 1 = Manhattan

m.matrix

m.plot(100); 

m.dtw    //should get back diagonal as cheapest path



//two sequences
a = [0.0,0.1,0.5,0.8,1.2,1.4]; 
b = [0.03,0.05,0.3,0.7,0.8,1.1,1.38,0.4,1.1]; 

//comparison
m = SCMIRSimilarityMatrix(1,a,b); //1 dimensional data, stored in a and b

//note how order swapped since first array should have largest size
m.sequence1 //converted to FloatArray internally (required for file writing for invoking calculation externals)
m.sequence2 //converted to FloatArray internally (required for file writing for invoking calculation externals)

m.calculate(1,1); //create matrix, won't be square since a and b are different lengths

m.matrix

m.matrix.plot //as linear array; order is d(a(0), b(0)), d(a(0, b(1))... d(a(1),b(0))...d(a(last),b(last))

m.plot(100) //built in matrix plotting, stretch factor of 10 here

m.dtw; //get best path and distance of the path


//

//two sequences
a = [0.0,0.5,1.0,1.5]; 
b = [0.1,0.2,0.3,0.4]; 

//comparison
m = SCMIRSimilarityMatrix(1,a,b); //1 dimensional data, stored in a and b

//note how order swapped since first array should have largest size
m.sequence1.plot //converted to FloatArray internally (required for file writing for invoking calculation externals)
m.sequence2.plot //converted to FloatArray internally (required for file writing for invoking calculation externals)

m.calculate(1,1); //create matrix, won't be square since a and b are different lengths

m.matrix

m.matrix.plot //as linear array; order is d(a(0), b(0)), d(a(0, b(1))... d(a(1),b(0))...d(a(last),b(last))

m.plot(100) //built in matrix plotting, stretch factor of 10 here

m.dtw; //get best path and distance of the path



//use with SCMIRAudioFile

e = SCMIRAudioFile("sounds/a11wlk01.wav", [[MFCC, 13], [Chromagram, 12]]);

//shortcut versions also work, defaults will be applied for MFCC (10 coeffs) and Chromagram (12TET)
//e = SCMIRAudioFile("/Applications/SuperCollider/SuperCollider3.4/sounds/a11wlk01.wav",[MFCC,Chromagram]);

e.extractFeatures(); //wait for me to finish

e.numframes

m = e.similarityMatrix(1,0);  //m is an SCMIRSimilarityMatrix object

m.matrix.size.sqrt //184

m.plot(2) //built in matrix plotting, stretch factor of 10 here

a = m.dtw

m.plot(2,path:a)    //plot with best dtw path 

m.reducedcolumns
m.reducedrows

m.matrix.postcs




//comparison of two audio files



(
~files = ["/data/audio/mirdata/pixiesivebeentired.wav","/data/audio/mirdata/Yellow Submarine.wav"]; 

~audio = ~files.collect{|filename,i|     
    
e = SCMIRAudioFile(filename, [MFCC,Loudness]);
    
e.extractFeatures();
        
};

m = ~audio[0].similarityMatrix(40,0,other:~audio[1]);
)

~audio[0].numfeatures
(~audio[0].numframes).div(40)
(~audio[1].numframes).div(40)

m.reducedcolumns //194
m.reducedrows    //172

d = m.dtw

m.plot(2,1, path:d)    //show path on the similarity matrix plot



//very minimal test

//SCMIR.setTempDir("/Users/nickcollins/Desktop/"); 

a = FloatArray[0.05,0.1,0.9]; 

m = SCMIRSimilarityMatrix(1,a); //1 dimensional data, stored in a

m.calculate(1,2); //create matrix

m.matrix

d = m.dtw    //should get back diagonal as cheapest path

m.plot(100,path:d)



//check alternative options in similaritymatrix2 external

a = FloatArray[0.05,0.1,0.9]; 

m = SCMIRSimilarityMatrix(1,a); //1 dimensional data, stored in a

m.calculate(1,2,0,0); //create matrix, max within segments rather than mean

m.matrix

d = m.dtw    //should get back diagonal as cheapest path

m.plot(100,path:d)

m.calculate(1,2,1,0); //create matrix, max within segments rather than mean, post calculate (make large similarity matrix then reduce)

m.matrix    //same results

d = m.dtw    //should get back diagonal as cheapest path

m.plot(100,path:d)




//check that post reduction also works on larger scale
e = SCMIRAudioFile("/Applications/SuperCollider/SuperCollider3.4/sounds/a11wlk01.wav", [[MFCC, 13], [Chromagram, 12]]);

e.extractFeatures();

m = e.similarityMatrix(2,0,1,0);  //m is an SCMIRSimilarityMatrix object

m.matrix.size.sqrt //92

m.plot(2) //built in matrix plotting, stretch factor of 10 here

a = m.dtw

m.plot(2,path:a)    //plot with best dtw path 


//directly create a SCMIRSimilarityMatrix object with existing matrix data

//16 element array, 4 by 4 matrix
a = SCMIRSimilarityMatrix.newFromMatrix([0.1,0.3,0.5,0.2,0.3,0.1,0.0,0.7,0.3,0.5,0.0,1.0,0.1,0.4,0.7,0.3],4,4)
//data is in form col1, col2, col3, ... where each column starts from the bottom row and goes to the top

a.plot(100)

a.novelty(2).plot
