#-----------------------------------------------------------------------------------#
# 		   	Pretest Session for Statistical Learning/Rate Perception Study
# 												  Ava Kiai
# 
# Log: 
# 12/3/18  - Started file
# 12/10/18 - v.0.0
# 2/7/19   - v.0.1 Completed
# 3/7/19   - v.1.0 Redesigned how trial settings are read (from file) for better control
#
# NB: Re: RNG, from Mike Blank 
# 2019-02-20 19:09 CET
# Reply : Presentation uses the date/time to seed the RNG, so it changes every time it is called.
#
# SETTINGS: 
# Responses
		# 1 = Space
		# 2 = LEFT
		# 3 = RIGHT
#
#-----------------------------------------------------------------------------------#
scenario          = "_RPSL_pretest";
# --------------------------------------------------------------------------- #
#                           Header Parameters
# --------------------------------------------------------------------------- #
# Screen
default_background_color = 0,0,0;         # black
default_font = "Microsoft PhagsPa";
default_font_size = 16;
default_text_color = 255, 255, 255;			# White text		

# Output
no_logfile	=	false;	
response_logging = log_active;																						
response_matching = simple_matching;

# Responses
active_buttons	=	3;																
button_codes	=	1,2,3;	

# Scenario Params
scenario_type	=	trials; 		
	
default_output_port = 1;

begin;
# --------------------------------------------------------------------------- #
#                      Message Trials: Intro, Break, End
# --------------------------------------------------------------------------- #
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
		picture {
			text { 
				caption = "Welcome! \n
Thank you for taking part in our study. Let's begin Part 1/4...\n\n

In this study, you will hear someone speaking in an alien language. \n

In this first section, you will hear two brief segments of the alien language. \n
For each pair, your task is to determine which segments was FASTER. \n\n

Once both snippets have been presented, the small cross at the center of the screen \n
will turn green. This means you can give your response: \n

If you think the FIRST of the two segments was faster, press the LEFT key. \n 
If you think the SECOND of the two segments was faster, press the RIGHT key. \n
If you're not sure, just make a guess. \n\n

Try to respond as soon as the cross turns green, without losing accuracy. \n
Please make sure to listen attentively to the language while keeping your eyes fixated \n
on the cross at the center of the screen. \n\n 

Please ask the experimenter if anything is unclear. \n
When you are ready to start, press the space bar to continue."; 
				};
				x = 0; y = 0;
		} P_incidental_instruct;
	code = "instruct";
	} T_pretest_instruct;

trial{
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;	
		picture {
			text { caption = ""; # see PCL
			} Txt_break;
			x = 0; y = 0;
		} P_break;
	code = "break";
	} T_break;
	
trial {
	trial_duration = 2000;
	trial_type = first_response;
		picture {
			text { caption = "Part 1/4 Complete.";
			}; 
			x = 0; y = 0;
		} P_end_section;
	code = "section_end";
	} T_end_section;

	
# --------------------------------------------------------------------------- #
#                            Picture & Sound Objects
# --------------------------------------------------------------------------- #
sound { 
	wavefile {
		filename = "2afc_wordseq_1.wav"; # will be changed in PCL for each trial
		preload = false;
		} Wav_stim1;  
} Sound_stim1; 

sound { 
	wavefile {
		filename = "2afc_rand_1.wav"; # will be changed in PCL for each trial
		preload = false; 
		} Wav_stim2;  
} Sound_stim2; 

picture { 
	text { 
		caption = "+"; 
		font_size = 40; 
		font_color = 255, 255, 255; 
		trans_src_color = 0,0,0;
		} Txt_fix_white; 
	x = 0; y = 0; 
} P_fix_white;   

picture { 
	text { 
		caption = "+"; 
		font_size = 40; 
		font_color = 1, 255, 1; 
		trans_src_color = 0,0,0;
		} Txt_fix_green; 
	x = 0; y = 0; 
} P_fix_green;   


# --------------------------------------------------------------------------- #
#                            Experimental Trials
# --------------------------------------------------------------------------- #
# 2AFC Task: Stim 1 is presented with a delay equal to ITI while fixation is on 
# the screen. Stim 2 is presented following an ISI. A green fixation cross prompting
# response follows. 
# Stim 1
trial {
	trial_duration = stimuli_length; # play until sound ends
	all_responses = false;

	stimulus_event {
		picture P_fix_white;
		time = 0; 
	} E_first_fix;

	stimulus_event { 
		sound Sound_stim1 ; 	# see PCL  
		time = 100;  	   	# see PCL - will be changed to reflect ITI
		code = "";
	} E_stim1; 
} T_stim1;

# ISI
trial {
	trial_duration = 500; 	# see PCL - will be changed to reflect ISI
	all_responses = false;
	
	stimulus_event { 
		picture P_fix_white;
		code = "ISI"; 
	} E_ISI;
} T_ISI;

# Stim 2 
trial {
	trial_duration = stimuli_length; # play until sound ends 
	all_responses = false;
	
	stimulus_event { 
		picture P_fix_white;
	} E_second_fix;

	stimulus_event { 
		sound Sound_stim2; 
	} E_stim2; 
} T_stim2;

# Response
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 2,3;	# responses that will end the trial are LEFT, RIGHT
	
	stimulus_event {
		picture P_fix_green;
		code = "Wait for response";
	} E_resp_fix;
} T_response;

begin_pcl;

# --------------------------------------------------------------------------- #
#                                 PCL
# --------------------------------------------------------------------------- #
# Initialize Participant
preset string subj = "SubjectCode";
preset string rand = "Randomization number";
preset string sex = "Sex";
preset string age = "Age";
preset string handedness = "Handedness";

# Initialize Section Parameters
string Name_Of_Experiment = "RPSL_pretest";
string section = "pretest";

# Safety
if file_exists(logfile_directory + subj + "_RPSL_pretest.txt") then
    exit("Logfile already exists!");
end;

# Set up logfile
output_file response_data_file = new output_file;
response_data_file.open(subj + "RPSL_pretest.txt", true);
# Header
response_data_file.print("#Experiment: " + Name_Of_Experiment + "\n");
response_data_file.print("#Section: " + section + "\n");
response_data_file.print("#DateTime: " + date_time() + "\n");
response_data_file.print("#Subject: " + subj + "\n");
response_data_file.print("#Sex: " + sex + "\n");
response_data_file.print("#Age: " + age + "\n");
response_data_file.print("#Handedness: " + handedness + "\n");
response_data_file.print("\n");
response_data_file.print("\n");
response_data_file.print("Block" + "\t" + "Trial" + "\t" + "Order" + "\t" + "Seq1" + "\t" + "Seq2" + "\t" + "ITI" + "\t" + "ISI" + "\t" + "Resp" + "\t" + "RT" + "\n");

# ------------------------------------------------------------------------
# Global Variables
int           V_block_counter = 1; # counts blocks
int       V_trials_from_start = 1; # counts trials from session start
int V_trials_in_block_counter = 1; # counts trials within block

int     						V_nblocks = 4; # total number of blocks
int      				    V_ntrls = 48; # total number of trials
int V_ntrlsxblock = V_ntrls/V_nblocks; # total number of trials per block
# Fetch Trial Params from Randomization file
int		     V_Block; 
int		     V_Trial; 
int		 	  V_Order;
string 	   V_WordSeq; 
string 	   V_RandSeq; 
int				 V_ITI; 
int				 V_ISI; 
string	V_ClearTrial; 
string 		  V_Stim1;
string 		  V_Stim2;
# Response Variables
int       V_subj_resp; # LEFT, RIGHT
double           V_RT; # RT

# Fetch Trial Params
input_file Randomization = new input_file;
Randomization.open(rand + "_tempo_pre_lang_A.txt");
string V_Header = Randomization.get_line(); # Remove header


# --------------------------------------------------------------------------- #
#                                 BEGIN EXPERIMENT
# --------------------------------------------------------------------------- #
T_pretest_instruct.present();
wait_until(2000);

loop V_block_counter until V_block_counter > V_nblocks begin; # BLOCK
	
	loop V_trials_in_block_counter until V_trials_in_block_counter > V_ntrlsxblock begin; # TRIAL
	
		V_Block = Randomization.get_int(); 
		V_Trial = Randomization.get_int(); 
		V_Order = Randomization.get_int();
 	   V_WordSeq = Randomization.get_string(); 
 	   V_RandSeq = Randomization.get_string(); 
		V_ITI = Randomization.get_int();		
		V_ISI = Randomization.get_int(); 	
		V_ClearTrial = Randomization.get_line(); # clear line (trial)

		if V_Order == 1 then # Word, Rand
				Wav_stim1.set_filename(V_WordSeq); # Stim 1 Define
				E_stim1.set_event_code(V_WordSeq);
				V_Stim1 = V_WordSeq;
				Wav_stim2.set_filename(V_RandSeq); # Stim 2 Define
				E_stim2.set_event_code(V_RandSeq); 
				V_Stim2 = V_RandSeq;				
		elseif V_Order == 2 then # Rand, Word
				Wav_stim1.set_filename(V_RandSeq); # Stim 1 Define
				E_stim1.set_event_code(V_RandSeq);
				V_Stim1 = V_RandSeq;
				Wav_stim2.set_filename(V_WordSeq); # Stim 2 Define
				E_stim2.set_event_code(V_WordSeq); 
				V_Stim2 = V_WordSeq;				
		end;

		# Set up trial:
		Wav_stim1.load(); # Initilaize wavefiles/sound objects
		Wav_stim2.load();			
		E_stim1.set_time(int(V_ITI)); # Initialize ITI for stim 1 onset
		T_ISI.set_duration(int(500)); # Initiliaze ISI for stim 2 onset
	
	### ------ Present -------- ###
		T_stim1.present();
		T_ISI.present();
		T_stim2.present();
		T_response.present();
		
		# Subject's Response
		V_subj_resp = response_manager.last_response(); 

		# RT = onset of response - onset of last stim i.e. "?"
		V_RT = response_manager.last_response_data().time_double()-stimulus_manager.last_stimulus_data().time_double();
				
		# Write to bespoke logfile for backup 
		response_data_file.print(string(V_block_counter) 			+ "\t" + 
										 string(V_trials_from_start)   	+ "\t" + 
										 string(V_Order)					 	+ "\t" + 
												  V_Stim1   					+ "\t" + 
												  V_Stim2   					+ "\t" + 
										 string(V_ITI)			       		+ "\t" +
										 string(V_ISI) 						+ "\t" +
										 string(V_subj_resp) 				+ "\t" + 
										 string(V_RT) 							+ "\n");
										
		# Prep for next trial
		Wav_stim1.unload();
		Wav_stim2.unload();
		V_trials_in_block_counter = V_trials_in_block_counter + 1; 
		V_trials_from_start = V_trials_from_start + 1;					  
	end; # TRIAL END
	
# Block breaks
	if V_block_counter == V_nblocks then
			T_end_section.present(); 
	elseif V_block_counter < V_nblocks then
			Txt_break.set_caption("You have reached the end of block " + string(V_block_counter) + "/" + string(V_nblocks) + ". \n\n Take a short break! \n\n Press the space bar to continue to next block.");
			Txt_break.redraw();
			T_break.present();
	end;

	V_block_counter = V_block_counter + 1; 
	V_trials_in_block_counter = 1;   
end; # BLOCK

#response_data_file.print("#DateTime: " + date_time() + "\n");
T_end_section.present();
wait_until(500);