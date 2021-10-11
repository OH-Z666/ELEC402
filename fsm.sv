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

reg [5:0] state;
reg D_flag; //to determine the previous lights comb condition, if the previous direction is EW, then flag value is 0, otherwise is 1


parameter initial_waiting               = 6'b000000;
parameter check_condition               = 6'b000001;
//for normal amount of traffic, straight pass first then left truning
parameter EW_strat_green_SNwhite        = 6'b000010;
parameter EW_strat_green_Swhite_Nred    = 6'b000011;
parameter EW_strat_green_Sred_Nwhite    = 6'b000100;
parameter EW_strat_green_SNred          = 6'b000101;

parameter EW_strat_green_SNTminus       = 6'b000110;
parameter EW_strat_green_STminus_Nred   = 6'b000111;
parameter EW_strat_green_Sred_NTminus   = 6'b001000;

parameter EW_strat_yellow_SNred         = 6'b001001;
parameter EW_strat_yellow_SNTminus      = 6'b001010;
parameter EW_strat_yellow_STminus_Nred  = 6'b001011;
parameter EW_strat_yellow_Sred_NTminus  = 6'b001100;

parameter EW_strat_red_red              = 6'b001101;

parameter SN_strat_green_EWwhite        = 6'b001110;
parameter SN_strat_green_Ewhite_Wred    = 6'b001111;
parameter SN_strat_green_Ered_Wwhite    = 6'b010000;
parameter SN_strat_green_EWred          = 6'b010001;

parameter SN_strat_green_EWTminus       = 6'b010010;
parameter SN_strat_green_ETminus_Wred   = 6'b010011;
parameter SN_strat_green_Ered_WTminus   = 6'b010100;

parameter SN_strat_yellow_EWred         = 6'b010101;
parameter SN_strat_yellow_EWTminus      = 6'b010110;
parameter SN_strat_yellow_ETminus_Wred  = 6'b010111;
parameter SN_strat_yellow_Ered_WTminus  = 6'b011000;

parameter SN_strat_red_red              = 6'b011001;

//for heavy traffic, one direction each time with straight and left truning
parameter ES_turn_green_Nwhite_Sred     = 6'b011010;
parameter WN_turn_green_Swhite_Nred     = 6'b011011;
parameter SW_turn_green_Ewhite_Wred     = 6'b011100;
parameter NE_turn_green_Wwhite_Ered     = 6'b011101;

parameter ES_turn_green_NTminus_Sred    = 6'b011110;
parameter WN_turn_green_STminus_Nred    = 6'b011111;
parameter SW_turn_green_ETminus_Wred    = 6'b100000;
parameter NE_turn_green_WTminus_Ered    = 6'b100001;

parameter ES_turn_yellow_NTminus_Sred   = 6'b100010;
parameter WN_turn_yellow_STminus_Nred   = 6'b100011;
parameter SW_turn_yellow_ETminus_Wred   = 6'b100100;
parameter NE_turn_yellow_WTminus_Ered   = 6'b100101;

parameter ES_turn_red_red               = 6'b100110;
parameter WN_turn_red_red               = 6'b100111;
parameter SW_turn_red_red               = 6'b101000;
parameter NE_turn_red_red               = 6'b101001;

parameter night_all_red                 = 6'b101010;





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
	default: state <= initial_waiting;


	endcase
	end
	end

always_comb begin

if(state == initial_waiting) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b0;
 SN_straight_lights_flag <= 3'b0;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b0;
 EWN_passenger_flag <= 3'b0;
 SNE_passenger_flag <= 3'b0;
 SNW_passenger_flag <= 3'b0;
end

if(state == check_condition) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b0;
 SN_straight_lights_flag <= 3'b0;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b0;
 EWN_passenger_flag <= 3'b0;
 SNE_passenger_flag <= 3'b0;
 SNW_passenger_flag <= 3'b0;
end

if(state == EW_strat_green_SNwhite) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b100;
 EWN_passenger_flag <= 3'b100;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_Swhite_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b100;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_Sred_Nwhite) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b100;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_SNred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_SNTminus) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_STminus_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_green_Sred_NTminus) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_yellow_SNred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_yellow_SNTminus) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_yellow_STminus_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_yellow_Sred_NTminus) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == EW_strat_red_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_green_EWwhite) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b100;
 SNW_passenger_flag <= 3'b100;
end

if(state == SN_strat_green_Ewhite_Wred) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b100;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_green_Ered_Wwhite) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b100;
end

if(state == SN_strat_green_EWred) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_green_EWTminus) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b010;
end

if(state == SN_strat_green_ETminus_Wred) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_green_Ered_WTminus) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b010;
end

if(state == SN_strat_yellow_EWred) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_yellow_EWTminus) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b010;
end

if(state == SN_strat_yellow_ETminus_Wred) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b001;
end

if(state == SN_strat_yellow_Ered_WTminus) begin
 D_flag <= 1;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b010;
end

if(state == SN_strat_red_red) begin
 D_flag <= 1;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == ES_turn_green_Nwhite_Sred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 1;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b100;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == WN_turn_green_Swhite_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 1;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b100;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SW_turn_green_Ewhite_Wred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 1; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b100;
 SNW_passenger_flag <= 3'b001;
end

if(state == NE_turn_green_Wwhite_Ered) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 1;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 1;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b100;
end

if(state == ES_turn_green_NTminus_Sred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 1;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == WN_turn_green_STminus_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b100;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 1;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SW_turn_green_ETminus_Wred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 1; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b001;
end

if(state == NE_turn_green_WTminus_Ered) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 1;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b100;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 1;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b010;
end

if(state == ES_turn_yellow_NTminus_Sred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b010;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == WN_turn_yellow_STminus_Nred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b010;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b010;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SW_turn_yellow_ETminus_Wred) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b010;
 SNW_passenger_flag <= 3'b001;
end

if(state == NE_turn_yellow_WTminus_Ered) begin
 D_flag <= 0;
 reds_on_flag <= 0;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 1;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b010;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b010;
end

if(state == ES_turn_red_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == WN_turn_red_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == SW_turn_red_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == NE_turn_red_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

if(state == night_all_red) begin
 D_flag <= 0;
 reds_on_flag <= 1;
 need_white2Tminus_flag <= 0;
 need_green2yellow_flag <= 0;
 need_red_flag <= 0;
 EW_straight_lights_flag <= 3'b001;
 SN_straight_lights_flag <= 3'b001;
 ES_turning_lights_flag <= 0;
 WN_turning_lights_flag <= 0;
 SW_turning_lights_flag <= 0; 
 NE_turning_lights_flag <= 0;
 EWS_passenger_flag <= 3'b001;
 EWN_passenger_flag <= 3'b001;
 SNE_passenger_flag <= 3'b001;
 SNW_passenger_flag <= 3'b001;
end

end

endmodule











