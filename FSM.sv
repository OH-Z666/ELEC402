//this is state machine module. the only function of this module is controlling the combination of signal lights
//other matters such as how long the lights will keep on or if the traffic is heavy will be determined in other modules
//therefore all the states are about the light combination.
//when the outside module finished counting, flags will be input and allow the fsm processing.

module fsm(
	input logic clk,
	input logic reset,
	input logic start,
	input logic [7:0] pass_key,
	input logic mess_traffic_flag,
	input logic daytime_flag,

	//i think that i can put the traffic counter and daytime conunter out side of the FSM so there will be not that many states.
	input logic white2Tminus_flag,
	input logic green2yellow_flag,
	input logic red_flag,

	output logic need_white2Tminus_flag,
	output logic need_green2yellow_flag,
	output logic need_red_flag,
	output logic reds_on_flag,
	output logic [2:0] EW_straight_lights_flag,
	output logic [2:0] SN_straight_lights_flag,
	output logic  ES_turning_lights_flag,
	output logic  WN_turning_lights_flag,
	output logic  SW_turning_lights_flag,
	output logic  NE_turning_lights_flag,
	output logic [2:0] EWS_passenger_flag,
	output logic [2:0] EWN_passenger_flag,
	output logic [2:0] SNE_passenger_flag,
	output logic [2:0] SNW_passenger_flag
);

reg [28:0] state;
reg D_flag; //to determine the previous lights comb condition, if the previous direction is EW, then flag value is 0, otherwise is 1

assign D_flag = start ? 1 : state[0];
assign reds_on_flag = (state[5]|state[6]|state[8]|state[9]) ? 1 : 0;
assign need_white2Tminus_flag = state[1];
assign need_green2yellow_flag = state[2];
assign need_red_flag = state[3];
assign EW_straight_lights_flag = state[6:4];
assign SN_straight_lights_flag = state[9:7];
assign ES_turning_lights_flag = state[10];
assign WN_turning_lights_flag = state[11];
assign SW_turning_lights_flag = state[12]; 
assign NE_turning_lights_flag = state[13];
assign EWS_passenger_flag = state[16:14];
assign EWN_passenger_flag = state[19:17];
assign SNE_passenger_flag = state[22:20];
assign SNW_passenger_flag = state[25:23];


//state parameters. i wanna use there states to control lights, so i arrange the array in a special way that every part of the array can carry information
//
//for parameters, i use the digits for flag information
//id/SNE_passenger_flag/SNE_passenger_flag/EWN_passenger_flag/EWS_passenger_flag/NE_turning_lights_flag/SW_turning_lights_flag/WN_turning_lights_flag/ES_turning_lights_flag/SN_straight_lights_flag/EW_straight_lights_flag/need_end_flag/need_red_flag/need_green2yellow_flag/need_white2Tminus_flag/previous direction
parameter initial_waiting               = 29'b000_000_000_000_000_0000_000_000_0_0_0_0;
parameter check_condition               = 29'b001_000_000_000_000_0000_000_000_0_0_0_0;
//for normal amount of traffic, straight pass first then left truning
parameter EW_strat_green_SNwhite        = 29'b000_001_001_100_100_0000_001_100_0_1_1_0;
parameter EW_strat_green_Swhite_Nred    = 29'b000_001_001_001_100_0000_001_100_0_1_1_0;
parameter EW_strat_green_Sred_Nwhite    = 29'b000_001_001_100_001_0000_001_100_0_1_1_0;
parameter EW_strat_green_SNred          = 29'b000_001_001_001_001_0000_001_100_0_1_0_0;

parameter EW_strat_green_SNTminus       = 29'b000_001_001_010_010_0000_001_100_0_1_0_0;
parameter EW_strat_green_STminus_Nred   = 29'b000_001_001_001_010_0000_001_100_0_1_0_0;
parameter EW_strat_green_Sred_NTminus   = 29'b000_001_001_010_001_0000_001_100_0_1_0_0;

parameter EW_strat_yellow_SNred         = 29'b000_001_001_001_001_0000_001_010_1_0_0_0;
parameter EW_strat_yellow_SNTminus      = 29'b000_001_001_010_010_0000_001_010_1_0_0_0;
parameter EW_strat_yellow_STminus_Nred  = 29'b000_001_001_001_010_0000_001_010_1_0_0_0;
parameter EW_strat_yellow_Sred_NTminus  = 29'b000_001_001_010_001_0000_001_010_1_0_0_0;

parameter EW_strat_red_red              = 29'b000_001_001_001_001_0000_001_001_0_0_0_0;

parameter SN_strat_green_EWwhite        = 29'b000_100_100_001_001_0000_100_001_0_1_1_1;
parameter SN_strat_green_Ewhite_Wred    = 29'b000_001_100_001_001_0000_100_001_0_1_1_1;
parameter SN_strat_green_Ered_Wwhite    = 29'b000_100_001_001_001_0000_100_001_0_1_1_1;
parameter SN_strat_green_EWred          = 29'b000_001_001_001_001_0000_100_001_0_1_1_1;

parameter SN_strat_green_EWTminus       = 29'b000_010_010_001_001_0000_100_001_0_1_0_1;
parameter SN_strat_green_ETminus_Wred   = 29'b000_001_010_001_001_0000_100_001_0_1_0_1;
parameter SN_strat_green_Ered_WTminus   = 29'b000_010_001_001_001_0000_100_001_0_1_0_1;

parameter SN_strat_yellow_EWred         = 29'b000_001_001_001_001_0000_010_001_1_0_0_1;
parameter SN_strat_yellow_EWTminus      = 29'b000_010_010_001_001_0000_010_001_1_0_0_1;
parameter SN_strat_yellow_ETminus_Wred  = 29'b000_001_010_001_001_0000_010_001_1_0_0_1;
parameter SN_strat_yellow_Ered_WTminus  = 29'b000_010_001_001_001_0000_010_001_1_0_0_1;

parameter SN_strat_red_red              = 29'b000_001_001_001_001_0000_001_001_0_0_0_1;

//for heavy traffic, one direction each time with straight and left truning
parameter ES_turn_green_Nwhite_Sred     = 29'b000_001_001_100_001_0001_001_100_0_1_1_0;
parameter WN_turn_green_Swhite_Nred     = 29'b000_001_001_001_100_0010_001_100_0_1_1_0;
parameter SW_turn_green_Ewhite_Wred     = 29'b000_001_100_001_001_0100_100_001_0_1_1_0;
parameter NE_turn_green_Wwhite_Ered     = 29'b000_100_001_001_001_1000_100_001_0_1_1_0;

parameter ES_turn_green_NTminus_Sred    = 29'b000_001_001_010_001_0001_001_100_0_1_0_0;
parameter WN_turn_green_STminus_Nred    = 29'b000_001_001_001_010_0010_001_100_0_1_0_0;
parameter SW_turn_green_ETminus_Wred    = 29'b000_001_010_001_001_0100_100_001_0_1_0_0;
parameter NE_turn_green_WTminus_Ered    = 29'b000_010_001_001_001_1000_100_001_0_1_0_0;

parameter ES_turn_yellow_NTminus_Sred   = 29'b001_001_001_010_001_0000_001_010_1_0_0_0;
parameter WN_turn_yellow_STminus_Nred   = 29'b001_001_001_001_010_0000_001_010_1_0_0_0;
parameter SW_turn_yellow_ETminus_Wred   = 29'b001_001_010_001_001_0000_010_001_1_0_0_0;
parameter NE_turn_yellow_WTminus_Ered   = 29'b001_010_001_001_001_0000_010_001_1_0_0_0;

parameter ES_turn_red_red               = 29'b010_001_001_001_001_0000_001_001_0_0_0_0;
parameter WN_turn_red_red               = 29'b011_001_001_001_001_0000_001_001_0_0_0_0;
parameter SW_turn_red_red               = 29'b100_001_001_001_001_0000_001_001_0_0_0_0;
parameter NE_turn_red_red               = 29'b101_001_001_001_001_0000_001_001_0_0_0_0;

parameter night_all_red                 = 29'b110_001_001_001_001_0000_001_001_0_0_0_0;





always @(posedge clk)begin

	if(reset) state <= initial_waiting;
	
	else begin
	
	case(state)

	initial_waiting: begin
	 		  if(start) begin
				state <= check_condition;
			   	    end
			  else begin
				state <= initial_waiting;
			       end
			 end

	check_condition: begin
			    if (daytime_flag)begin

				  if(mess_traffic_flag) begin
					state <= ES_turn_green_Nwhite_Sred; end //if it's weekday day time in rash hour, then ignore the pass key, directly follow the order: ES, WN, SW, NE
				  else begin
				
					 if(!D_flag) begin
						if(pass_key[0]|pass_key[7]) begin
							if(pass_key[3]|pass_key[4]) begin 
					  		state <= SN_strat_green_EWwhite; end
							else begin
					 		state <= SN_strat_green_Ered_Wwhite; end
				  		 end

				  	  	else if(pass_key[3]|pass_key[4]) begin
					  		state <= SN_strat_green_Ewhite_Wred; end
					  	else begin
							state <= SN_strat_green_EWred; end
					  end
				  

				  	  else begin
						if(pass_key[1]|pass_key[2]) begin
							if(pass_key[5]|pass_key[6]) begin 
					  		state <= EW_strat_green_SNwhite; end
							else begin
					  		state <= EW_strat_green_Sred_Nwhite; end
				  		end

				  		else if(pass_key[5]|pass_key[6]) begin
					 		state <= EW_strat_green_Swhite_Nred; end
			
				  		else begin
					  		state <= EW_strat_green_SNred; end 
				 	  end
			            end
				end
			     else begin//night
					 state <= night_all_red;
				end
			
			end
	night_all_red: begin
			if(daytime_flag) state <= check_condition;
			else state <= night_all_red;
			end
			/*    else begin//weekend no rush hours
			      if (daytime_flag)begin

				  if(pass_key[0]|pass_key[7]) begin
					if(pass_key[3]|pass_key[4]) begin 
					  state <= SN_strat_green_EWwhite; end
					else begin
					  state <= SN_strat_green_Ered_Wwhite; end
				  end

				  else if(pass_key[3]|pass_key[4]) begin
					if(pass_key[0]|pass_key[7]) begin 
					  state <= SN_strat_green_EWwhite; end
					else begin
					  state <= SN_strat_green_Ewhite_Wred; end
				  end

				  else if(pass_key[1]|pass_key[2]) begin
					if(pass_key[5]|pass_key[6]) begin 
					  state <= EW_strat_green_SNwhite; end
					else begin
					  state <= EW_strat_green_Sred_Nwhite; end
				  end

				  else if(pass_key[5]|pass_key[6]) begin
					if(pass_key[1]|pass_key[2]) begin 
					  state <= EW_strat_green_SNwhite; end
					else begin
					  state <= EW_strat_green_Swhite_Nred; end
				  end
			
				  else begin
					  state <= EW_strat_green_SNred; end 
					end
				else begin//night
				  state <= night_all_red; end		
			      end	
			end*/
		
	ES_turn_green_Nwhite_Sred: begin 
				    if(white2Tminus_flag) begin
					state <= ES_turn_green_NTminus_Sred; end
				    else begin
					state <= ES_turn_green_Nwhite_Sred; end
				   end

	ES_turn_green_NTminus_Sred: begin 
				    if(green2yellow_flag) begin
					state <= ES_turn_yellow_NTminus_Sred; end
				    else begin
					state <= ES_turn_green_NTminus_Sred; end
				    end
	ES_turn_yellow_NTminus_Sred: begin 
				     if(red_flag) begin
					state <= ES_turn_red_red; end
				     else begin
					state <= ES_turn_yellow_NTminus_Sred; end
				     end
	ES_turn_red_red: begin

			 		state <= WN_turn_green_Swhite_Nred; 

			end


	WN_turn_green_Swhite_Nred: begin 
				    if(white2Tminus_flag) begin
					state <= WN_turn_green_STminus_Nred; end
				    else begin
					state <= WN_turn_green_Swhite_Nred; end
				   end

	WN_turn_green_STminus_Nred: begin 
				    if(green2yellow_flag) begin
					state <= WN_turn_yellow_STminus_Nred; end
				    else begin
					state <= WN_turn_green_STminus_Nred; end
				    end
	WN_turn_yellow_STminus_Nred: begin 
				     if(red_flag) begin
					state <= WN_turn_red_red; end
				     else begin
					state <= WN_turn_yellow_STminus_Nred; end
				     end
	WN_turn_red_red: begin

				state <= SW_turn_green_Ewhite_Wred; end
		

	SW_turn_green_Ewhite_Wred: begin 
				    if(white2Tminus_flag) begin
					state <= SW_turn_green_ETminus_Wred; end
				    else begin
					state <= SW_turn_green_Ewhite_Wred; end
				   end

	SW_turn_green_ETminus_Wred: begin 
				    if(green2yellow_flag) begin
					state <= SW_turn_yellow_ETminus_Wred; end
				    else begin
					state <= SW_turn_green_ETminus_Wred; end
				    end
	SW_turn_yellow_ETminus_Wred: begin 
				     if(red_flag) begin
					state <= SW_turn_red_red; end
				     else begin
					state <= SW_turn_yellow_ETminus_Wred; end
				     end
	SW_turn_red_red: begin

				state <= NE_turn_green_Wwhite_Ered; end
 

	NE_turn_green_Wwhite_Ered: begin 
				    if(white2Tminus_flag) begin
					state <= NE_turn_green_WTminus_Ered; end
				    else begin
					state <= NE_turn_green_Wwhite_Ered; end
				   end

	NE_turn_green_WTminus_Ered: begin 
				    if(green2yellow_flag) begin
					state <= NE_turn_yellow_WTminus_Ered; end
				    else begin
					state <= NE_turn_green_WTminus_Ered; end
				    end
	NE_turn_yellow_WTminus_Ered: begin 
				     if(red_flag) begin
					state <= NE_turn_red_red; end
				     else begin
					state <= NE_turn_yellow_WTminus_Ered; end
				     end
	NE_turn_red_red: begin

				state <= check_condition; end

				  	
	SN_strat_green_EWwhite: begin 
				    if(white2Tminus_flag) begin
					state <= SN_strat_green_EWTminus; end
				    else begin
					state <= SN_strat_green_EWwhite; end
				   end

	SN_strat_green_EWTminus: begin 
				    if(green2yellow_flag) begin
					state <= SN_strat_yellow_EWTminus; end
				    else begin
					state <= SN_strat_green_EWTminus; end
				    end
	SN_strat_yellow_EWTminus: begin 
				     if(red_flag) begin
					state <= SN_strat_red_red; end
				     else begin
					state <= SN_strat_yellow_EWTminus; end
				     end
	SN_strat_red_red: begin

				state <= check_condition; end

	SN_strat_green_Ewhite_Wred: begin 
				    if(white2Tminus_flag) begin
					state <= SN_strat_green_ETminus_Wred; end
				    else begin
					state <= SN_strat_green_Ewhite_Wred; end
				   end

	SN_strat_green_ETminus_Wred: begin 
				    if(green2yellow_flag) begin
					state <= SN_strat_yellow_ETminus_Wred; end
				    else begin
					state <= SN_strat_green_ETminus_Wred; end
				    end
	SN_strat_yellow_ETminus_Wred: begin 
				     if(red_flag) begin
					state <= SN_strat_red_red; end
				     else begin
					state <= SN_strat_yellow_ETminus_Wred; end
				     end

	SN_strat_green_Ered_Wwhite: begin 
				    if(white2Tminus_flag) begin
					state <= SN_strat_green_Ered_WTminus; end
				    else begin
					state <= SN_strat_green_Ered_Wwhite; end
				   end

	SN_strat_green_Ered_WTminus: begin 
				    if(green2yellow_flag) begin
					state <= SN_strat_yellow_Ered_WTminus; end
				    else begin
					state <= SN_strat_green_Ered_WTminus; end
				    end
	SN_strat_yellow_Ered_WTminus: begin 
				     if(red_flag) begin
					state <= SN_strat_red_red; end
				     else begin
					state <= SN_strat_yellow_Ered_WTminus; end
				     end

	SN_strat_green_EWred: begin 
				    if(green2yellow_flag) begin
					state <= SN_strat_yellow_EWred; end
				    else begin
					state <= SN_strat_green_EWred; end
				   end

	SN_strat_yellow_EWred: begin 
				     if(red_flag) begin
					state <= SN_strat_red_red; end
				     else begin
					state <= SN_strat_yellow_EWred; end
				     end

	EW_strat_green_SNwhite: begin 
				    if(white2Tminus_flag) begin
					state <= EW_strat_green_SNTminus; end
				    else begin
					state <= EW_strat_green_SNwhite; end
				   end

	EW_strat_green_SNTminus: begin 
				    if(green2yellow_flag) begin
					state <= EW_strat_yellow_SNTminus; end
				    else begin
					state <= EW_strat_green_SNTminus; end
				    end
	EW_strat_yellow_SNTminus: begin 
				     if(red_flag) begin
					state <= EW_strat_red_red; end
				     else begin
					state <= EW_strat_yellow_SNTminus; end
				     end
	EW_strat_red_red: begin
				state <= check_condition; end


	EW_strat_green_Swhite_Nred: begin 
				    if(white2Tminus_flag) begin
					state <= EW_strat_green_STminus_Nred; end
				    else begin
					state <= EW_strat_green_Swhite_Nred; end
				   end

	EW_strat_green_STminus_Nred: begin 
				    if(green2yellow_flag) begin
					state <= EW_strat_yellow_STminus_Nred; end
				    else begin
					state <= EW_strat_green_STminus_Nred; end
				    end
	EW_strat_yellow_STminus_Nred: begin 
				     if(red_flag) begin
					state <= EW_strat_red_red; end
				     else begin
					state <= EW_strat_yellow_STminus_Nred; end
				     end

	EW_strat_green_Sred_Nwhite: begin 
				    if(white2Tminus_flag) begin
					state <= EW_strat_green_Sred_NTminus; end
				    else begin
					state <= EW_strat_green_Sred_Nwhite; end
				   end

	EW_strat_green_Sred_NTminus: begin 
				    if(green2yellow_flag) begin
					state <= EW_strat_yellow_Sred_NTminus; end
				    else begin
					state <= EW_strat_green_Sred_NTminus; end
				    end
	EW_strat_yellow_Sred_NTminus: begin 
				     if(red_flag) begin
					state <= EW_strat_red_red; end
				     else begin
					state <= EW_strat_yellow_Sred_NTminus; end
				     end

	EW_strat_green_SNred: begin 
				    if(green2yellow_flag) begin
					state <= EW_strat_yellow_SNred; end
				    else begin
					state <= EW_strat_green_SNred; end
				   end

	EW_strat_yellow_SNred: begin 
				     if(red_flag) begin
					state <= EW_strat_red_red; end
				     else begin
					state <= EW_strat_yellow_SNred; end
				     end


	endcase
	end
	end

endmodule











