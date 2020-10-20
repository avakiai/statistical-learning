
#-----------------------------------------------------------------------------------#
# 	     	Test Session for Statistical Learning/Interval Perception Study
# 												  Ava Kiai
# 
# 3/2/2019
#-----------------------------------------------------------------------------------#
scenario          = "DJ_test";
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
button_codes	=	1;	# 1 = Space

# Scenario Params
scenario_type	=	trials; 		

begin;
# --------------------------------------------------------------------------- #
#                      Message Trials & Elements
# --------------------------------------------------------------------------- #
# Instructions
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
	stimulus_event {
		picture {
			text { 
				caption = "In this section, you will listen to sequences of syllables, similar to what you heard in the last section. \n\n
 
				Your task is to use the three dials in front of you to make the stream sound more natural -- how you feel it should sound. \n
				It's okay if the stream doesn't sound exactly the way it did in the last section. \n\n

				You can turn the dials to the left or to the right. \n 
				Please always use your right hand to adjust each dial. \n
				Try not to move the dial too quickly. \n\n

				Once you've used all the dials to adjust the stream the way you like, hit the spacebar to confirm and move on to the next stream. \n
				If you are ready to begin, press the space bar. Please ask the experimenter if you have any questions."; 
				max_text_width = 900; 
				} Txt_instruct; # PCL | DE/EN
				x = 0; y = 0;
		} P_incidental_instruct;
		code = "instruct";
	} E_instruct;
} T_incidental_instruct;

# Trial Start Notice
trial {
   trial_duration = forever;
   trial_type = specific_response;
	terminator_button = 1;
   stimulus_event {
		picture {
			 text {caption = "..."; # PCL | DE/EN
				trans_src_color = 0,0,0;
				max_text_width = 810; 
			} Txt_Launch_New_Trial;
			 x = 0; y = 0;		  
		} P_Launch_New_Trial;
      code = "Begin Trial";       
   } E_Launch_New_Trial;
} T_Launch_New_Trial;


# Troubleshooting message - for visualizing dial values
trial {
    stimulus_event {
		picture {
			 text { caption = "..."; 
				font_size = 20; 
			} Txt_Message;
			 x = 0;
			 y = 0;
		} P_Message;
        code = "message";       
    } E_Message;
} T_Message;

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
#                         Stimulus & Timing Trials 
# --------------------------------------------------------------------------- #
trial { # displays while trial is going
	stimulus_event {
		picture { 
			text { 
				caption = "Play DJ!"; # PCL | DE/EN
				font_size = 20; 
				font_color = 255, 255, 255; 
				trans_src_color = 0,0,0;
			} Txt_fix; 
			x = 0; y = 0; 
		} P_fix;	
		code = "fixation";
	} E_fix;
} T_fix;

trial { # plays all syllables in a loop
	trial_duration = stimuli_length;	# length of syllable
	#picture P_fix;
	stimulus_event {
		sound { 
			wavefile {
				filename = "be.wav"; 
				preload = true;
				} Wav_Syll; 
		} Sound_Syll; 
		deltat = 0; 
		code = "Syll:";
	} E_Syll; 
} T_Syll;

trial { # used to insert silences between syllables, controlled in turn by each of the dials
	trial_duration = 10;	# length of ISI, changed in PCL
	#trial_duration = stimuli_length; 
	
	stimulus_event {
		nothing {}; # either show nothing and make trial_duration change in PCL... 
		#picture P_Message; # or show picture, trial_duration = stimuli_length, & change E_ISI.set_duration() 
		deltat = 0; 
		#duration = 1;
		code = "Int: (ms)";
	} E_ISI; 
} T_ISI;


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
	session = "struct"
elseif sess == "r" then
	session = "rand"
end;

# Initialize Section Parameters
string section = "dj_test_" + session;
	
# Safety
if file_exists(logfile_directory + subj + "-" + section + ".txt") then
    exit("Logfile already exists!");
end;

# Log session info
output_file response_data_file = new output_file;

response_data_file.open(subj + "_" + section + ".txt", true);
response_data_file.print("Subject: " + "\t" + subj + "\n");
response_data_file.print("Section: " + "\t" + section + "\n");
response_data_file.print("Session: " + "\t" + session + "\n");
response_data_file.print("Start_Time: " + "\t" + date_time() + "\n");
response_data_file.print("\n");
response_data_file.print(
"Block" + "\t" + "Trial" + "\t" + "Sequence" + "\t" +
"Syll" + "\t" + "Dial" + "\t" + "Prev_ISI" + "\t" + "Prev_Pos" + "\t" +
"Curr_ISI" + "\t" + "Curr_Pos" + "\t" + "ISI_Diff" + "\t" + "Pos_Diff" + "\n\n");
#------------------------- Global Variables ------------------------------- # 
int   V_Trial_Counter = 1; 
int     V_Max_Trials = 10; 
int   V_Block_Counter = 1;
int      V_Max_Blocks = 3;
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

#double V_Volume = 1-V_Threshold+0.10; # between 0.1 and 0.15 worked for me
#if V_Volume > 1 then
#	V_Volume = 1; # use full system volume 
#end;

# UNTIL WE FIGURE OUT THE SCALING, USE A STANDARD
### --------------------------
double V_Volume = 0.79;
### --------------------------

term.print("Volume set to " + string(V_Volume) + "* of system volume...\n");
#------------------------- Stimulus Control -------------------------------- # 
# Stimulus Template File
input_file F_Syll_Loop_File = new input_file;

# Initialize Stimulus Variables
array<string>  A_Syllable_Loop[336]; # to get syllable names
array<int> A_Syllable_Loop_Idx[336]; # to determine where in sequence to start
int           V_Initial_Syllable_Idx; # begins each trial 
string            S_Initial_Syllable; 
string   S_Initial_Syllable_Filename;

int           V_Current_Syllable_Idx; # sets successor syllables
string 	         S_Current_Syllable; 
string   S_Current_Syllable_Filename;

# Create syllable indexing array 
loop int i = 1; until i == A_Syllable_Loop_Idx.count() begin
	A_Syllable_Loop_Idx[i] = i; 
	i = i + 1;
end;
#------------------------- Dial Control -------------------------------- # 
# Fetch Mouse
mouse Dev_Pointer = response_manager.get_mouse(1); 

# Restrict the range of possible co-ordinate positions of the pointer device
Dev_Pointer.set_restricted(1,true);
Dev_Pointer.set_restricted(2,true);
Dev_Pointer.set_restricted(3,true);

# The range of dial positions are: 0 to 1800*(see special cases), which translates to an ISI by /3 = 0 to 600 ms 
# Means 1 click = 3 ms... 
int Trans_fct_1 = 3;  
Dev_Pointer.set_min_max(1, 0, 1800); # x-axis properties code an interval as 10
int Dial_1_fct = 3; # 1800/600 (ms max) == 3
Dev_Pointer.set_min_max(2, 0, 1800); # y-axis properties code an interval as 10
int Dial_2_fct = 3; # 1800/600 (ms max) == 3
Dev_Pointer.set_min_max(3, 0, 1800); # z-axis proprerties code an interval as 120, so Presentation scaling factor changed to 0.0833333333 to set this dial to the same range and sensitivity as the others
int Dial_3_fct = 3; # 1800/600 (ms max) == 3

#int Trans_fct_2 = 12; 
#Dev_Pointer.set_min_max(3, 0, 21600); # z-axis * Dial 19 codes 1 click as 120, so mult whatever the others do by 12
#int Dial_3_fct = 36; # 21600/600 (ms max) == 36 | scaling factor to fix dial 19's interval issues: 1 click = 120 units, whereas dials 23, 25 have 1 click = 10

# Dial Position Variables - Use to assign the dial values randomly to the ISI intervals... 
array<int> A_Dial_Order[3] = {1,2,3};
# isi arrays
array<int> A_Current_ISI[3]; # in msecs; for param and display purposes
array<int> A_Previous_ISI[3]; # in msecs; for display purposes
array<int> A_ISI_Diff[3]; # for display
# dial position arrays
array<double> A_Current_Pos[3];
array<double> A_Previous_Pos[3]; 
array<double> A_Pos_Diff[3]; # also for display purposes

int        V_Dial_Counter; # to iterate through A_Dial_Order on each loop within a trial

# Dial 1 | X
	#int    V_Initial_Dial_Position_In_Previous_Block_1; # at the end of last block, ensure different
	int    V_Initial_Dial_Position_Previous_Trial_1; # in the last trial, ensure different
	int    V_Initial_Dial_Position_1; # current trial start value
	#A_Current_Pos[1] = Dev_Pointer.position(1); # using x-axis as reading axis
	A_Current_Pos[1] = Dev_Pointer.pos(1); # version 17.2/8.11.14
	
# Dial 2 | Y 
	#int    V_Initial_Dial_Position_In_Previous_Block_2; 
	int    V_Initial_Dial_Position_Previous_Trial_2; 
	int    V_Initial_Dial_Position_2; 
	#A_Current_Pos[2] = Dev_Pointer.position(2); # using y-axis as reading axis
	A_Current_Pos[2] = Dev_Pointer.pos(2); # version 17.2/8.11.14

# Dial 3 | Z (Wheel)
	#int    V_Initial_Dial_Position_In_Previous_Block_3; 
	int    V_Initial_Dial_Position_Previous_Trial_3; 
	int    V_Initial_Dial_Position_3; 
	#A_Current_Pos[3] = Dev_Pointer.position(3); # using z-axis as reading axis
	A_Current_Pos[3] = Dev_Pointer.pos(3); # version 17.2/8.11.14

# Dial starting positions: The ISIs that constitute a block, which will be shuffled and repeated in each consecutive block.
# starting range = 10 to 590 ms | 30 to 1770 units 
array<int> A_Initial_Dial_Positions_1[10]; # at the start of each trial 
array<int> A_Initial_Dial_Positions_2[10]; # at the start of each trial 
array<int> A_Initial_Dial_Positions_3[10]; # at the start of each trial 

# --------------------------------------------------------------------------- #
#                          BEGIN EXPERIMENT
# --------------------------------------------------------------------------- #
E_instruct.set_event_code("Instructions. Volume set to " + string(V_Volume) + "* system volume.");

if lang == "de" then
	Txt_instruct.set_caption("In diesem Abschnitt hören Sie eine Abfolge von Silben, ähnlich wie im letzten Abschnitt.\n" + 
	"Ihre Aufgabe wird es nun sein, mit den drei vor Ihnen befindlichen Drehreglern die gehörte Silbensequenz so einzustellen \n" + 
	"dass diese für Sie so klingt, wie Sie es für richtig halten. \n " + 
	"Es ist in Ordnung, wenn die Silbensequenz nicht genauso klingt, wie in dem letzten Abschnitt. \n\n " + 
	"Sie können die Drehregler nach links und nach rechts drehen. \n" + 
	"Bitte benutzen Sie dazu immer die rechte Hand um die Drehregler einzustellen und stellen Sie jeweils nur einen Drehregler nach dem anderen ein. \n" + 
	"Versuchen Sie den Drehregler nicht zu schnell zu bewegen. \n\n" + 
	"Wenn Sie alle Drehregler so eingestellt haben, dass Sie der Meinung sind das der Ton richtig für Sie klingt, \n " + 
	"drücken Sie die Leertaste, um Ihre Einstellung zu bestätigen und mit der nächsten Sequenz fortzufahren. \n\n" + 
	"Sollten Sie noch Fragen haben, wenden Sie sich bitte an die Versuchsleiterin. Wenn Sie breite sind zu beginnen, drücken Sie die Leertaste.");
	Txt_instruct.redraw();
end;
T_incidental_instruct.present(); 
wait_until(2000);

loop V_Block_Counter until V_Block_Counter > V_Max_Blocks begin; 

	# 1. SELECT STARTING ISI VALUES FROM RANDOM DIST., SHUFFLE
	loop int i = 1; until i > A_Initial_Dial_Positions_1.count() begin
		 int IDP = random(0, 600); # you could also set this range to be the DIAL range...
		 IDP = IDP * Trans_fct_1; # turn from ms value to Dial Position units
		 A_Initial_Dial_Positions_1[i] = IDP;
		 i = i + 1;
	end;
	A_Initial_Dial_Positions_2 = A_Initial_Dial_Positions_1;
	A_Initial_Dial_Positions_2.shuffle();
	
	A_Initial_Dial_Positions_3 = A_Initial_Dial_Positions_1;
	#loop int i = 1; until i > A_Initial_Dial_Positions_3.count() begin 
	#	A_Initial_Dial_Positions_3[i] = A_Initial_Dial_Positions_3[i]*Trans_fct_2;
	#	i = i + 1; 
	#end;
	A_Initial_Dial_Positions_3.shuffle();
	
	V_Trial_Counter = 1;
	loop V_Trial_Counter until V_Trial_Counter > V_Max_Trials begin;
		# 2. FETCH CURRENT TRIAL'S FILE AND DUMP THE SYLLABLES INTO AN ARRAY TO BE READ SEQUENTIALLY
		term.print("Trial # " + string(V_Trial_Counter) + "... \n");
		string F_Syll_Loop_Filename = "task_" + session + "_seq_A_" + string(V_Trial_Counter) + ".txt";
		term.print("Loading file " + F_Syll_Loop_Filename + "...\n");
		F_Syll_Loop_File.open(F_Syll_Loop_Filename);
				loop int i = 1; until i > A_Syllable_Loop.count() begin  
					string V_Curr_Syll = F_Syll_Loop_File.get_string();
					string V_ClearLine = F_Syll_Loop_File.get_line();
					A_Syllable_Loop[i] = V_Curr_Syll;
					i = i + 1; 
				end;
				
		# 3. RANDOMIZE THE STARTING SYLLABLE IN EACH TRIAL 
		A_Syllable_Loop_Idx.shuffle(); # shuffle indices
		V_Initial_Syllable_Idx = A_Syllable_Loop_Idx[1]; # pick the first
		V_Current_Syllable_Idx = V_Initial_Syllable_Idx;
		S_Initial_Syllable = A_Syllable_Loop[V_Initial_Syllable_Idx]; # start syllable loop from there
		term.print("Initial Syllable: " + S_Initial_Syllable + "... \n");
		
		# 4. INITIALIZE WAVEFILE
		S_Initial_Syllable_Filename = S_Initial_Syllable; # get syllable string
		S_Initial_Syllable_Filename.append(".wav"); # get filename 
			
		# 5. LOAD SYLLABLES
		Wav_Syll.set_filename(S_Initial_Syllable_Filename);
		Wav_Syll.load();
		E_Syll.set_event_code("Syll: " + S_Initial_Syllable);
		
		# 6. SET DIAL PARAMS
		# fetch inital dial value from logic
		V_Initial_Dial_Position_1 = A_Initial_Dial_Positions_1[V_Trial_Counter];
		V_Initial_Dial_Position_2 = A_Initial_Dial_Positions_2[V_Trial_Counter];
		V_Initial_Dial_Position_3 = A_Initial_Dial_Positions_3[V_Trial_Counter];
		A_Current_Pos[1] = V_Initial_Dial_Position_1;
		A_Current_Pos[2] = V_Initial_Dial_Position_2;
		A_Current_Pos[3] = V_Initial_Dial_Position_3;

		# 7. CONVERT (BACK) TO MSECS BY DIV. BY [3] & PUT IN ARRAY SO DIALS 1,2,& 3 CAN BE SAMPLED FROM RANDOMLY
		A_Current_ISI[1] = V_Initial_Dial_Position_1/Dial_1_fct; 
		A_Current_ISI[2] = V_Initial_Dial_Position_2/Dial_2_fct; 
		A_Current_ISI[3] = V_Initial_Dial_Position_3/Dial_3_fct; 

		# 8. SET INIT. DIAL VALUES
		Dev_Pointer.set_pos(1, V_Initial_Dial_Position_1); 
		Dev_Pointer.set_pos(2, V_Initial_Dial_Position_2); 
		Dev_Pointer.set_pos(3, V_Initial_Dial_Position_3); 
	
		# 9. RANDOMIZE THE ORDER IN WHICH DIALS WILL CONTROL T_ISI & SET INIT. ISI VALUE
		V_Dial_Counter = 1; # to run through them 
		A_Dial_Order.shuffle(); # idx 1 = physical dial 1, idx 2 = physical dial 2, etc. 
										# idx value 1 = which ISI... 
		#T_ISI.set_duration(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]);
		E_ISI.set_duration(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]); 
		E_ISI.set_event_code("Dial No.: " + 				  string(A_Dial_Order[V_Dial_Counter]) + 
									" | Init. ISI: " + 			  string(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]) + " ms." +
									" | Init. Dial Position: " + string(A_Current_Pos[A_Dial_Order[V_Dial_Counter]]));		

# -------------------------------- #
#      10. GIVE TRIAL START CUE
# -------------------------------- #
	if lang == "de" then
			Txt_Launch_New_Trial.set_caption("Block " + string(V_Block_Counter) + " von " + string(V_Max_Blocks) + "\n" +
			"Versuch " + string(V_Trial_Counter) + " von " + string(V_Max_Trials) + 
			":\n\n Verwenden Sie die drei Drehknöpfe, um den Stream so einzustellen, dass er für Sie am natürlichsten klingt.\n\n Bitte die Leertaste drücken, um fortzufahren.", true);
	elseif lang == "en" then
			Txt_Launch_New_Trial.set_caption("Block " + string(V_Block_Counter) + " of " + string(V_Max_Blocks) + "\n" +
			"Trial " + string(V_Trial_Counter) + " of " + string(V_Max_Trials) + 
			":\n\n Use the three dials to adjust the stream until it sounds most natural to you.\n\n Hit the spacebar to continue.", true);
	end;
		E_Launch_New_Trial.set_event_code("Block #" + string(V_Block_Counter) + " | Trial #" + string(V_Trial_Counter) + " | " + F_Syll_Loop_Filename + 
			" | Init. Dial Pos 1: " + string(V_Initial_Dial_Position_1) + " | Init. ISI 1: " + string(A_Current_ISI[1]) +
			" | Init. Dial Pos 2: " + string(V_Initial_Dial_Position_2) + " | Init. ISI 2: " + string(A_Current_ISI[2]) +
			" | Init. Dial Pos 3: " + string(V_Initial_Dial_Position_3) + " | Init. ISI 3: " + string(A_Current_ISI[3]));
		T_Launch_New_Trial.present();	
		
		# Present fixation
		if lang == "de" then
			Txt_fix.set_caption("Spielen DJ!");
			Txt_fix.redraw();
		end;
		T_fix.present();
		
		# 11. SET VALUES OF THESE PARAMS FOR TRIAL
		A_Previous_Pos[1] = 0; A_Previous_Pos[2] = 0; A_Previous_Pos[3] = 0; 
		A_Pos_Diff[1]     = 0; A_Pos_Diff[2]     = 0; A_Pos_Diff[3]     = 0;
		A_Previous_ISI[1] = 0; A_Previous_ISI[2] = 0; A_Previous_ISI[3] = 0; 
		A_ISI_Diff[1]     = 0; A_ISI_Diff[2]     = 0; A_ISI_Diff[3]     = 0;

		# 12. RECORD SOME PARAMS BEFORE TRIALS BEGIN
		response_data_file.print(
		string(V_Block_Counter) + "\t" + string(V_Trial_Counter) + "\t" + F_Syll_Loop_Filename + "\t" + 
		S_Initial_Syllable + "\t" + string(A_Dial_Order[V_Dial_Counter]) + "\t" + 
		string(A_Previous_ISI[A_Dial_Order[V_Dial_Counter]]) + "\t" + string(A_Previous_Pos[A_Dial_Order[V_Dial_Counter]]) + "\t" +
		string(A_Current_ISI[A_Dial_Order[V_Dial_Counter]])  + "\t" + string(A_Current_Pos[A_Dial_Order[V_Dial_Counter]])  + "\t" + 
		string(A_ISI_Diff[A_Dial_Order[V_Dial_Counter]])     + "\t" + string(A_Pos_Diff[A_Dial_Order[V_Dial_Counter]])     + "\n");

# ----------------------------- #
#		13. PRESENT SYLL 
# ----------------------------- #
		Sound_Syll.set_attenuation(1-V_Volume);
		T_Syll.present(); 	
		
		# 14. POLL DEVICE CONSTANTLY UNTIL RESPONSE (SPACEBAR)
		loop int N_of_Responses = response_manager.total_response_count(1) until false begin # in other words, 0 
			# 15. ITERATE THROUGH SYLLABLE LOOP, REPEAT IF NECESSARY
			V_Current_Syllable_Idx = V_Current_Syllable_Idx + 1; 
				if V_Current_Syllable_Idx > A_Syllable_Loop.count() then
					V_Current_Syllable_Idx = 1; 
				else
					V_Current_Syllable_Idx = V_Current_Syllable_Idx; 
				end;
				
			# 16. FETCH AND INIT. NEXT SYLLABLE	
				S_Current_Syllable = A_Syllable_Loop[V_Current_Syllable_Idx];
				S_Current_Syllable_Filename = S_Current_Syllable;
				S_Current_Syllable_Filename.append(".wav");
				Wav_Syll.set_filename(S_Current_Syllable_Filename);
				Wav_Syll.load();
				E_Syll.set_event_code("Syll: " + S_Current_Syllable + " | Duration: " + string(Wav_Syll.duration()));
			
			# 17. SET NEXT ISI DURATION
				T_ISI.set_duration(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]); 
				#E_ISI.set_duration(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]); 
				E_ISI.set_event_code(
				"Dial No.: " 					 + string(A_Dial_Order[V_Dial_Counter]) + 
				" | Current ISI: " 			 + string(A_Current_ISI[A_Dial_Order[V_Dial_Counter]]) + 
				" ms. | Current Pos: "      + string(A_Current_Pos[A_Dial_Order[V_Dial_Counter]]) +
				" | Previous ISI: " 			 + string(A_Previous_ISI[A_Dial_Order[V_Dial_Counter]]) + 
				" ms. | Previous Pos: "     + string(A_Previous_Pos[A_Dial_Order[V_Dial_Counter]]) + 
				" | ISI Diff: "     			 + string(A_ISI_Diff[A_Dial_Order[V_Dial_Counter]]) + 
				" ms. | Pos Diff: "         + string(A_Pos_Diff[A_Dial_Order[V_Dial_Counter]]));
			
# ------------------------------- #
#			  18. PRESENT ISI 
# ------------------------------- #
				if A_Current_ISI[A_Dial_Order[V_Dial_Counter]] == 0 then
					T_ISI.set_duration(1); # if Dial is turned to the 0 position, and ISI must be 0, make it
					# 1 ms, because nothing stimuli cause program to freeze if trial duration of a nothing stim == 0
					# let event codes stay the same, as it is still effectively the same. uncertainty will provide
					# further information.
				end;
				T_ISI.present(); 
				# 19. ITERATE DIAL COUNTER
					V_Dial_Counter = V_Dial_Counter + 1; 
					if V_Dial_Counter > 3 then
						V_Dial_Counter = 1;
					else
						V_Dial_Counter = V_Dial_Counter; 
					end;
# ------------------------------- #
#			  19. PRESENT SYLL 
# ------------------------------- #	
				Sound_Syll.set_attenuation(1-V_Volume);
				T_Syll.present(); 
	
				# Last Position
				A_Previous_Pos[1] = A_Current_Pos[1]; 
				A_Previous_Pos[2] = A_Current_Pos[2]; 
				A_Previous_Pos[3] = A_Current_Pos[3]; 
				A_Previous_ISI[1] = A_Current_ISI[1];
				A_Previous_ISI[2] = A_Current_ISI[2]; 
				A_Previous_ISI[3] = A_Current_ISI[3]; 
				
				# 20. POLL AND FETCH NEW PARAMS	
				Dev_Pointer.poll();

				# New Position
				#A_Current_Pos[1] = Dev_Pointer.position(1);
				A_Current_Pos[1] = Dev_Pointer.pos(1); # version 17.2/8.11.14
				#A_Current_Pos[2] = Dev_Pointer.position(2);
				A_Current_Pos[2] = Dev_Pointer.pos(2); # version 17.2/8.11.14
				#A_Current_Pos[3] = Dev_Pointer.position(3);
				A_Current_Pos[3] = Dev_Pointer.pos(3); # version 17.2/8.11.14
					
				# Adjust ISI:
				A_Current_ISI[1] = int(A_Current_Pos[1]/Dial_1_fct); 
				A_Current_ISI[2] = int(A_Current_Pos[2]/Dial_2_fct); 
				A_Current_ISI[3] = int(A_Current_Pos[3]/Dial_3_fct); 
		
		# Debugging: Visual feedback about the ISI	
		#Txt_Message.set_caption("ISIs: " + "\t" + string(A_Current_ISI[1]) + "\t" + string(A_Current_ISI[2]) + "\t" + string(A_Current_ISI[3]) + "\n" +
		#								"Pos's: "+ "\t" + string(A_Current_Pos[1]) + "\t" + string(A_Current_Pos[2]) + "\t" + string(A_Current_Pos[3]), true);
		#T_Message.present();
		
				# Calculate
				A_Pos_Diff[1] = A_Current_Pos[1]-A_Previous_Pos[1];
				A_Pos_Diff[2] = A_Current_Pos[2]-A_Previous_Pos[2];
				A_Pos_Diff[3] = A_Current_Pos[3]-A_Previous_Pos[3];

				A_ISI_Diff[1] = A_Current_ISI[1]-A_Previous_ISI[1];
				A_ISI_Diff[2] = A_Current_ISI[2]-A_Previous_ISI[2]; 
				A_ISI_Diff[3] = A_Current_ISI[3]-A_Previous_ISI[3]; 				
			
			
		response_data_file.print(
		string(V_Block_Counter) + "\t" + string(V_Trial_Counter) + "\t" + F_Syll_Loop_Filename + "\t" + 
		S_Current_Syllable + "\t" + string(A_Dial_Order[V_Dial_Counter]) + "\t" + 
		string(A_Previous_ISI[A_Dial_Order[V_Dial_Counter]]) + "\t" + string(A_Previous_Pos[A_Dial_Order[V_Dial_Counter]]) + "\t" +
		string(A_Current_ISI[A_Dial_Order[V_Dial_Counter]])  + "\t" + string(A_Current_Pos[A_Dial_Order[V_Dial_Counter]])  + "\t" + 
		string(A_ISI_Diff[A_Dial_Order[V_Dial_Counter]])     + "\t" + string(A_Pos_Diff[A_Dial_Order[V_Dial_Counter]])     + "\n");

			# 21. ABORT AND SAVE FINAL PARAMS WHEN YOU GET A RESPONSE			
			if (response_manager.total_response_count(1) > N_of_Responses) then # in other words, any (1)
				
				N_of_Responses = response_manager.total_response_count(1); # increment
				
				V_Initial_Dial_Position_Previous_Trial_1 = A_Initial_Dial_Positions_1[V_Trial_Counter];
				V_Initial_Dial_Position_Previous_Trial_2 = A_Initial_Dial_Positions_2[V_Trial_Counter];
				V_Initial_Dial_Position_Previous_Trial_3 = A_Initial_Dial_Positions_3[V_Trial_Counter];
		
				# Does the A_Diffs/Prevs need to be reset here? They will be reset at the start of each trial anyway, and we only 
				# come here when there has been a response, i.e. a new trial will begin shortly...
				F_Syll_Loop_File.close(); 
				break;
			end; # (participant keypress/dial press monitor)
		end; # (dial response monitor)
		V_Trial_Counter = V_Trial_Counter + 1;
	end; #(trial)
	
	# 22. PRESENT BLOCK BREAKS OR EXIT
	if V_Block_Counter == V_Max_Blocks then
		if lang == "de" then
			Txt_end_section.set_caption("Sie haben diesen Abschnitt des Experiments abgeschlossen!");
			Txt_end_section.redraw();
		end;
		T_end_section.present(); 
	elseif V_Block_Counter < V_Max_Blocks then	
		if lang == "de" then
				Txt_break.set_caption("Block " + string(V_Block_Counter) + " von " + string(V_Max_Blocks) + 
				" abgeschlossen! \n\n Bitte die Leertaste drücken, um fortzufahren.");
		elseif lang == "en" then
				Txt_break.set_caption("Block " + string(V_Block_Counter) + " of " + string(V_Max_Blocks) + 
				" complete! \n\n Press the space bar to continue to next block.");
		end;
		Txt_break.redraw();
		T_break.present();
	end;
	
	V_Block_Counter = V_Block_Counter + 1;
end; #(block)

wait_until(500);


