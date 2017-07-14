Download Merlin
---------------

Step 1: git clone https://github.com/CSTR-Edinburgh/merlin.git

Install tools
-------------

Step 2: cd merlin/tools <br/>
Step 3: ./compile_tools.sh
Step 4: install festival and HTS at merlin/tools/
	Possible help: [Issue96](https://github.com/CSTR-Edinburgh/merlin/issues/96)

Setup
-----

To setup voice: 

Take a look at ./01_setup.sh
You probably have to change the way the database is accessed, this depends on how your database is structured.
Check the lines 70-95, the comments should guide you through the process.

Demo voice
----------

To run demo voice, please follow below steps:
 
Step 5: cd merlin/egs/roger_blizzard2008/s1 <br/>
Step 6: ./run_demo_voice.sh speaker
	speaker can be bdl, slt, jmk
	The data for the speaker is downloaded from the cmu server.

Demo voice trains only on 59 utterances and shouldn't take more than 5 min.

Full voice
----------

To run full voice, please follow below steps:

Step 5: cd merlin/egs/roger_blizzard2008/s1 <br/>
Step 6: ./run_full_voice.sh speaker

Full voice utilizes the whole arctic data (1132 utterances). The training of the voice approximately takes 1 to 2 hours. 

Generate new sentences
----------------------

To generate new sentences, please follow below steps:

Step  8: Run either demo voice or full voice. <br/>
Step  9: Place the txt files containing the utterances in experiments/speaker_arctic_demo OR speaker_arctic_full/test_synthesis/txt
	 NOTE: speaker should be the speaker you used before (bdl, slt, jmk).
Step 10: ./merlin_synthesis.sh
