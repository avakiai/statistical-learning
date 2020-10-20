
#-----------------------------------------------------------------------------------#
# 		Incidental Learning Session for Statistical Learning/Rate Perception Study
# 												  Ava Kiai
# 
# Log
# 12/5/18 - v.0.0
# 2/4/19  - v.0.1
# 7/16/19 - v.2.0 
#-----------------------------------------------------------------------------------#
scenario          = "_RPSL_incidental";
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
response_logging = log_active;	# log only the active buttons																								
response_matching = simple_matching;

# Responses
active_buttons	=	1;																
button_codes	=	1;		
		# 1 = Space

# Scenario Params
scenario_type	=	trials; 		

begin;
# --------------------------------------------------------------------------- #
#                          Message Trials
# --------------------------------------------------------------------------- #
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
		picture {
			text { 
				caption = "Let's begin the study...\n In this section, you will listen to brief sequences of sounds from an alien language. \n 
Please listen attentively to the sequences while keeping your eyes fixated on the cross. \n\n 
Before you hear each sequence, you will hear a particular sound and see it written on the screen. \n
During the sequence that follows, your task is to press the space bar as quickly as you can whenever \n
you hear that particular sound. \n \n
Each time a new sequence starts, you will have a new sound to detect. \n \n 
If you are ready to begin, press the space bar. Please ask the experimenter if you have any questions."; 
				} Txt_instruct;
				x = 0; y = 0;
		} P_incidental_instruct;
	code = "instruct";
	#port_code = 255; 
	} T_incidental_instruct;
	
trial {
	trial_duration = stimuli_length;
#	trial_type = specific_response;
#	terminator_button = 1;		
		picture P_incidental_instruct;
		
		sound { 
			wavefile {
				filename = "fe.wav"; # will be changed in PCL
				preload = false;
				} Wav_example; 
		} Sound_example; 
		time = 1000; 
		
	stimulus_event {
		sound { 
			wavefile {
				filename = "fe.wav"; # will be changed in PCL
				preload = false;
				} Wav_example2; 
		} Sound_example2; 
		deltat = 2500;
		code = "";
	} E_cue; 
	} T_example;

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
	trial_type = fixed;
		picture {
			text { caption = "Part 2/4 Complete.";
			}; 
			x = 0; y = 0;
		} P_end_section;
	code = "section_end";
	} T_end_section;
# --------------------------------------------------------------------------- #
#                            Objects & Main Trial
# --------------------------------------------------------------------------- #
# Fixation
picture { 
	text { 
		caption = "+"; 
		font_size = 40; 
		font_color = 255, 255, 255; 
		trans_src_color = 0,0,0;
	} Txt_fix; 
	x = 0; y = 0; 
} P_fix_white; 

sound { 
	wavefile {
		filename = "new_seq_A_1.wav"; # will be changed in PCL for each trial 
		preload = false;
		} Wav_stim; 
	cue_events = true; 
} Sound_stim; 

# The Main Trial
trial {
	trial_type = fixed;
	trial_duration = stimuli_length;
		stimulus_event { 
			picture P_fix_white;
		} E_fix;
		
		stimulus_event {
			sound Sound_stim; 
			target_button = 1;
			code = ""; 		
		} E_stim; 
} T_listen;


begin_pcl; 
# --------------------------------------------------------------------------- #
#                                 PCL
# --------------------------------------------------------------------------- #
# Initialize Participant
preset string subj = "SubjectCode"; #5-character max subject ID
preset string rand = "Randomization number";
preset string lang = "Language (A or B)";
preset string sess = "Session (W or R)";
preset string sex = "Sex";
preset string age = "Age";
preset string handedness = "Handedness";

# Initialize Section Parameters
string Name_Of_Experiment = "RPSL_incidental";
string section = "incidental";
	
# Safety
if file_exists(logfile_directory + subj + "_RPSL_incidental.txt") then
    exit("Logfile already exists!");
end;

# Set up logfile
# Header
output_file response_data_file = new output_file;
response_data_file.open(subj + "RPSL_incidental.txt", true);
response_data_file.print("#Experiment: " + Name_Of_Experiment + "\n");
response_data_file.print("#Section: " + section + "\n");
response_data_file.print("#Session: " + sess + " (W = Word, R = Random)\n");
response_data_file.print("#Language: " + lang + "\n");
response_data_file.print("#DateTime: " + date_time() + "\n");
response_data_file.print("#Subject: " + subj + "\n");
response_data_file.print("#Sex: " + sex + "\n");
response_data_file.print("#Age: " + age + "\n");
response_data_file.print("\n");
response_data_file.print("\n");
response_data_file.print("Block" + "\t" + "Sequence" + "\t" + "Target Syllable" + "\t" + "Total Detections" + "\n");

# Global Variables
int trial_counter = 1; 
int    max_trial = 24; 
int           V_Trial; # trial num
int 			 V_SeqNum; # get which sequence is to be presented
string 		S_CurrSeq; # wavfile name
string  S_Target_Word; # target name
int         V_Tgt_Pos;
int           V_Block;
#int block_counter = 1;
#int     max_block = 8;
string	V_ClearTrial; # allows clearing of randomization file data for a given trial

# Fetch Trial Params
input_file Randomization = new input_file;
Randomization.open(rand + "_incidental_lang_A.txt");
string V_Header = Randomization.get_line(); # Remove header

#------------------------- Begin Experiment -------------------------------- # 
T_incidental_instruct.present(); 

wait_until(2000);
 
loop trial_counter until trial_counter > max_trial begin; 

		V_Trial = Randomization.get_int(); 
		V_SeqNum = Randomization.get_int(); 
		S_CurrSeq = Randomization.get_string(); 
		S_Target_Word = Randomization.get_string();
		V_Tgt_Pos = Randomization.get_int(); 
		V_Block = Randomization.get_int(); 
		V_ClearTrial = Randomization.get_line(); # clear line (trial)

		# Initialize wavefiles
		string S_Target_Word_Filename = S_Target_Word; 
		S_Target_Word_Filename.append(".wav");

		Wav_example.set_filename(S_Target_Word_Filename);
		Wav_example.load();
		Wav_example2.set_filename(S_Target_Word_Filename);
		Wav_example2.load();
		E_cue.set_event_code(S_Target_Word);
		Wav_stim.set_filename(S_CurrSeq);
		Wav_stim.load();
		E_stim.set_event_code(S_CurrSeq);
		
		Txt_instruct.set_caption("Sound to detect: \n\n " + S_Target_Word); 
		Txt_instruct.redraw();
		

	# MAIN TRIAL -------------------------
		T_example.present(); # written and auditory cue
		T_listen.present();

	# Record some metadata
		int nResponses = response_manager.total_response_count();
		response_data_file.print(string(V_Block) + "\t" + string(V_Trial) + "\t" + S_CurrSeq + "\t" + S_Target_Word + "\t" + string(V_Tgt_Pos) + "\t" + string(nResponses) + "\n");
	
	Wav_example.unload();
	Wav_example2.unload();
	Wav_stim.unload();

# Block breaks
	if trial_counter == max_trial then
			T_end_section.present(); 
	elseif trial_counter < max_trial then
			Txt_break.set_caption("Sequence " + string(trial_counter) + "/" + string(max_trial) + " complete! \n\n Press the space bar to continue to next sequence.");
			Txt_break.redraw();
			T_break.present();
	end;
	trial_counter = trial_counter + 1;
end;

#response_data_file.print("#See logfile for reponses to repetitions.");
#response_data_file.print("#DateTime: " + date_time() + "\n");
wait_until(500);

