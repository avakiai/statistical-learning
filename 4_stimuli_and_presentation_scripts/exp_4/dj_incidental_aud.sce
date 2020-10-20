

#-----------------------------------------------------------------------------------#
# 		Incidental Learning Session for Statistical Learning/Interval Perception Study
# 												  Ava Kiai
# 
# 3/2/2019
#-----------------------------------------------------------------------------------#
scenario          = "DJ_incidental";
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
	stimulus_event {
		picture {
			text { 
				caption = "Let's begin the study...\n In this section, you will listen to sequences of syllables. \n 
Please listen attentively to the sequences while keeping your eyes fixated on the cross. \n\n 

Before you hear each sequence, you will hear a particular sound and see it written on the screen. \n
During the sequence that follows, your task is to press the space bar as quickly as you can whenever \n
you hear that particular sound. \n \n

Each time a new sequence starts, you will have a new sound to detect. \n \n 
If you are ready to begin, press the space bar. Please ask the experimenter if you have any questions."; 
				} Txt_instruct; # PCL | DE/EN
				x = 0; y = 0;
		} P_incidental_instruct;
		code = "instruct";
	} E_instruct;
	} T_incidental_instruct;
	
trial {
	trial_duration = stimuli_length;	
	
	picture P_incidental_instruct;
	
	stimulus_event {	
		sound { 
			wavefile {
				filename = "be.wav"; # will be changed in PCL
				preload = true;
				} Wav_example; 
		} Sound_example; 
		time = 1000; 
		code = ""; 
	} E_trial_notes; 
	
	stimulus_event {
		sound { 
			wavefile {
				filename = "be.wav"; # will be changed in PCL
				preload = true;
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
			text { caption = "..."; # PCL | DE/EN
			} Txt_break;
			x = 0; y = 0;
		} P_break;
	code = "break";
	} T_break;
	
trial {
	trial_duration = 2000;
	trial_type = fixed;
		picture {
			text { caption = "You've completed this section of the experiment!"; # PCL | DE/EN
			} Txt_end_section; 
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
		filename = "be.wav"; # will be changed in PCL for each trial 
		preload = true;
		} Wav_stim; 
} Sound_stim; 

trial {
	stimulus_event {
		picture P_fix_white;
		code = "fixation";
	} E_fix;
} T_fix;

# The Main Trial
trial {
	trial_type = fixed;
	trial_duration = stimuli_length;
		stimulus_event {
			sound Sound_stim; 
			code = ""; 	
			time = 35; # IMPORTANT! THIS IS THE ISI WE'VE CHOSEN... 
		} E_stim; 
} T_listen;


begin_pcl; 
# --------------------------------------------------------------------------- #
#                                 PCL
# --------------------------------------------------------------------------- #
# Initialize Participant
preset string subj = "SubjectCode"; 
preset string sess = "s";
preset string lang = "de";
string session; 
if sess == "s" then
	session = "struct";
elseif sess == "r" then
	session = "rand";
end;
	
#------------------------- Global Variables ------------------------------- # 
# Global Variables
int  V_Trial_Counter = 1; 
int    V_Max_Trials = 12; 

#------------------------- Volume Control -------------------------------- # 
#input_file Aud_Thresh_File = new input_file;
#int 					  V_N_Hz = 2; # there's two Hz values tested
#array<double> A_Thresholds[2];

#Aud_Thresh_File.open("data\\" + subj + "_thresholds.txt");
#term.print("Loading threshold file " + subj + "_thresholds.txt" + "...\n");

#Aud_Thresh_File.get_line(); # remove header
# Get the auditory thresholds for all tested Hz levels
#loop int i = 1; until i > V_N_Hz begin 
#	Aud_Thresh_File.set_delimiter('\t');
#	string V_Hz = Aud_Thresh_File.get_line(); # get string to first tab | Description of test Hz
#	Aud_Thresh_File.get_int(); # speaker code | will be 3
#	A_Thresholds[i] = Aud_Thresh_File.get_double(); # get volume delta
#	term.print("Subject " + subj + ". Tone " + V_Hz + ". Threshold " + string(A_Thresholds[i]) + "...\n");
#	i = i + 1;
#end;
#Aud_Thresh_File.close();
# average among them to get threshold
#double V_Threshold = (A_Thresholds[1]+A_Thresholds[2])/V_N_Hz;
#term.print("Subject " + subj + ". Avg. threshold " + string(V_Threshold) + "...\n");

# Attempt #1: Set volume to be full volume - threshold (as percentage of system volume) + a bit more. This can work if we find the right number, but it's not that simple because...

# - Not directly translated to dB/100.
# - The units of set_volume are not the same as the computer's 0-100. 
# - Despite the fact that thresholding script returns the threshold value supposedly = silence for the participant, when we set the volume, nothing less than 0.65 or so is audible (to me). 

#double V_Volume = (1-V_Threshold)+0.10; 

# Problem:
# if threshold < .5, then vol > .5, + .1 | most people are here... brings the value typically in the .7-.9 range, but in the wrong direction viz. their sensitivity...
# if threshold > .5, then vol < .5, + .1 | they need it to be louder... but this logic doesn't help them

# Dirty fix: you want volume to be between around .9 and .7. | NEED TO FIGURE OUT HOW TO SCALE THIS.
#if V_Volume > 0.9 then
#	V_Volume = 0.9;
#elseif V_Volume < 0.6 then
#	V_Volume = 0.6;
#end;

# UNTIL THEN, USE A STANDARD
### --------------------------
double V_Volume = 0.79;
### --------------------------

term.print("Volume set to " + string(V_Volume) + "* of system volume...\n");

#------------------------- Stimulus Control -------------------------------- # 
# Stimulus Template File
input_file F_Syll_Loop_File = new input_file;

# Initialize Stimulus Variables
array<string>   A_Syllable_Loop[216]; # to get syllable names
string 	         S_Current_Syllable; 
string  	          S_Target_Syllable; 
string  	 S_Target_Syllable_Filename; 
string	                S_ClearLine;
array<int>A_File_Order[V_Max_Trials] = {1,2,3,4,5,6,7,8,9,10,11,12};
A_File_Order.shuffle();

#------------------------- Begin Experiment -------------------------------- # 
E_instruct.set_event_code("Instructions. Volume set to " + string(V_Volume) + "* system volume.");

if lang == "de" then
	Txt_instruct.set_caption("Beginnen wir mit der Studie... \n" + 
	"In diesem Abschnitt werden Sie eine Sequenz an Silben hören. \n" + 
	"Bitte hören Sie sich die Sequenzen aufmerksam an, während Sie auf das Kreuz auf dem Bildschirm schauen. \n\n" + 
	"Bevor sie die Silbensequenz hören, werden Sie eine spezifische Silbe hören, die Ihnen auf dem Bildschirm angezeigt wird. \n" +
	"Während der darauffolgenden Sequenz wird Ihre Aufgabe sein, so schnell wie möglich die Leertaste zu drücken, \n" +
	"wann immer Sie die spezifische Silbe in der Silbensequenz hören. \n\n" +
	"Jedes Mal, wenn eine neue Sequenz startet, werden sie eine neue spezifische Silbe erkennen müssen. \n\n" +
	"Sollten Sie noch Fragen haben, wenden Sie sich bitte an die Versuchsleiterin. Wenn Sie breite sind zu beginnen, drücken Sie die Leertaste.");
	Txt_instruct.redraw();
end;
T_incidental_instruct.present(); 

wait_until(2000);
 
loop V_Trial_Counter until V_Trial_Counter > V_Max_Trials begin; 
		term.print("Trial # " + string(V_Trial_Counter) + "...\n"); 
		int V_Current_File_N = A_File_Order[V_Trial_Counter];
		string F_Syll_Loop_Filename = "incidental_" + session + "_seq_A_" + string(V_Current_File_N) + ".txt";
		term.print("Loading file " + F_Syll_Loop_Filename + "...\n");
		F_Syll_Loop_File.open(F_Syll_Loop_Filename);
		# opt. 1 
		#S_Target_Syllable = F_Syll_Loop_File.get_string();
		#S_ClearLine  = F_Syll_Loop_File.get_line();
		
		loop int i = 1; until i > A_Syllable_Loop.count() begin  # opt. 1: i = 2; opt. 2: i = 1; 
				string V_Curr_Syll = F_Syll_Loop_File.get_string();
				string V_ClearLine = F_Syll_Loop_File.get_line();
				A_Syllable_Loop[i] = V_Curr_Syll;
				i = i + 1; 
		end;
		# opt. 2: 
		S_Target_Syllable = A_Syllable_Loop[1];
		
		S_Target_Syllable_Filename = S_Target_Syllable; 
		S_Target_Syllable_Filename.append(".wav");
		term.print("Target Syllable: " + S_Target_Syllable + "...\n");

		Wav_example.set_filename(S_Target_Syllable_Filename);
		Wav_example.load();
		Wav_example2.set_filename(S_Target_Syllable_Filename);
		Wav_example2.load();
		E_cue.set_event_code("Target: " + S_Target_Syllable);
		E_trial_notes.set_event_code("Trial #" + string(V_Trial_Counter) + " " + F_Syll_Loop_Filename);
		
		if lang == "de" then
			Txt_instruct.set_caption("Drücken Sie die Leertaste, sobald Sie können, jedes Mal Sie sich den folgenden Ton hören: \n \n " + S_Target_Syllable);
		elseif lang == "en" then
			Txt_instruct.set_caption("Hit the space bar as soon as you can each time you hear the sound: \n\n " + S_Target_Syllable); 
		end;
		Txt_instruct.redraw();
		
		Sound_example.set_attenuation(1-V_Volume);
		Sound_example2.set_attenuation(1-V_Volume);
		T_example.present(); # written and auditory cue
		T_fix.present();
		
		# opt. 2: 
		loop int j = 2; until j > A_Syllable_Loop.count() begin # opt. 1: j = 1;, once 1st line (target) has been cleared

				S_Current_Syllable = A_Syllable_Loop[j];
				Wav_stim.set_filename(S_Current_Syllable + ".wav");
				Wav_stim.load();
				E_stim.set_event_code(S_Current_Syllable);

				#Sound_stim.set_volume(V_Volume);
			# attentuate (ramp up) over 5 syllables (roughly 1.5-2 secs)
			if j == 2        then Sound_stim.set_attenuation((1-V_Volume)+0.31); E_stim.set_event_code(S_Current_Syllable + " * 0.31");	
				elseif j == 3 then Sound_stim.set_attenuation((1-V_Volume)+0.22); E_stim.set_event_code(S_Current_Syllable + " * 0.22");
				elseif j == 4 then Sound_stim.set_attenuation((1-V_Volume)+0.16); E_stim.set_event_code(S_Current_Syllable + " * 0.16");
				elseif j == 5 then Sound_stim.set_attenuation((1-V_Volume)+0.08); E_stim.set_event_code(S_Current_Syllable + " * 0.08");
				elseif j == 6 then Sound_stim.set_attenuation((1-V_Volume)+0.03); E_stim.set_event_code(S_Current_Syllable + " * 0.03");
				# attentuate (ramp down) over 5 syllables (roughly 1.5-2 secs)
				elseif j == 212 then Sound_stim.set_attenuation((1-V_Volume)+0.03); E_stim.set_event_code(S_Current_Syllable + " * 0.03");# A_Syllable_Loop.count()-5
				elseif j == 213 then Sound_stim.set_attenuation((1-V_Volume)+0.08); E_stim.set_event_code(S_Current_Syllable + " * 0.08");# A_Syllable_Loop.count()-4
				elseif j == 214 then Sound_stim.set_attenuation((1-V_Volume)+0.16); E_stim.set_event_code(S_Current_Syllable + " * 0.16");# A_Syllable_Loop.count()-3
				elseif j == 215 then Sound_stim.set_attenuation((1-V_Volume)+0.22); E_stim.set_event_code(S_Current_Syllable + " * 0.22");# A_Syllable_Loop.count()-2
				elseif j == 216 then Sound_stim.set_attenuation((1-V_Volume)+0.31); E_stim.set_event_code(S_Current_Syllable + " * 0.31");# A_Syllable_Loop.count()-1
				else			   		Sound_stim.set_attenuation(1-V_Volume);
			end;
		
			# set response active stimulus event only if the syllable is a target syllable
			# that way, we can fetch hits (inshallah) automatically?
			
			if S_Current_Syllable == S_Target_Syllable then
				E_stim.set_target_button(1);
				E_stim.set_stimulus_time_in(0); # valid responses are between syllable onset
				E_stim.set_stimulus_time_out(1200); # and 1.2 seconds after onset
			end; 
			# Question: does this make the trial stall until a response or the time_out window is reached? 
			# Well, it doesn't seem to make anything stall, but check files after full test to see if it's at all useful. 
				#Sound_stim.set_volume(V_Volume);
				T_listen.present();

				#response_data_file.print(string(V_Trial_Counter) + "\t" + F_Syll_Loop_Filename + "\t" + S_Target_Syllable + "\t" + S_Current_Syllable + "\t"); 
				#int detect = response_manager.last_response(); # 1 or 0 
				#double RT = response_manager.last_response_data().time_double()-stimulus_manager.last_stimulus_data().time_double(); 
				#response_data_file.print(string(detect) + "\t" + string(RT) + "\n"); 
				Wav_stim.unload();
				j = j + 1; 
		end; # syllable end

	# Record some metadata
		#int nResponses = response_manager.total_response_count();
		#response_data_file.print(string(V_Block) + "\t" + string(V_Trial) + "\t" + S_CurrSeq + "\t" + S_Target_Syllable + "\t" + string(V_Tgt_Pos) + "\t" + string(nResponses) + "\n");
	
	# sequence end
	Wav_example.unload();
	Wav_example2.unload();

# Trial breaks
	if V_Trial_Counter == V_Max_Trials then
		if lang == "de" then
			Txt_end_section.set_caption("Sie haben diesen Abschnitt des Experiments abgeschlossen!");
		end;
			T_end_section.present(); 
	elseif V_Trial_Counter < V_Max_Trials then
		if lang == "de" then
			Txt_break.set_caption("Versuch " + string(V_Trial_Counter) + " von " + string(V_Max_Trials) + 
			" abgeschlossen! \n\n Bitte die Leertaste drücken, um fortzufahren.");
		elseif lang == "en" then
			Txt_break.set_caption("Trial " + string(V_Trial_Counter) + " of " + string(V_Max_Trials) + 
			" complete! \n\n Press the space bar to continue.");
		end;	
			Txt_break.redraw();
			T_break.present();
	end;
	
	F_Syll_Loop_File.close();
	V_Trial_Counter = V_Trial_Counter + 1;
end; # end trial 

wait_until(500);

			# Method 2 - Using waveform data objects -- more complicated.
			#	asg::waveform_data WavData_stim = Wav_stim.get_channel(1); # get loaded data
			#	asg::line ramp_up = new asg::line(WavData_stim.duration(), 0.3, 0.6); # create template 
			#	WavData_stim.multiply( ramp_up, WavData_stim.duration());
			#	Wav_stim = new wavefile( WavData_stim );	
