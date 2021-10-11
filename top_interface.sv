//this is just a simple interface to give input signals to the fsm to let the light control system working

module top_interface(
	input logic clk,
	input logic reset,
	input logic start,
	
	input logic [7:0] pass_key,
	input logic mess_traffic_flag,
	input logic daytime_flag,

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

//internal flag signals to control the length of each state
logic white2Tminus_flag;
logic green2yellow_flag;
logic red_flag;

logic need_white2Tminus_flag;
logic need_green2yellow_flag;
logic need_red_flag;
logic reds_on_flag;


// module instantiate
fsm control_fsm(
clk,
reset,
start,
pass_key,
mess_traffic_flag,
daytime_flag,
white2Tminus_flag,
green2yellow_flag,
 red_flag,
 need_white2Tminus_flag,
need_green2yellow_flag,
need_red_flag,
reds_on_flag,
EW_straight_lights_flag,
SN_straight_lights_flag,
ES_turning_lights_flag,
 WN_turning_lights_flag,
SW_turning_lights_flag,
NE_turning_lights_flag,
EWS_passenger_flag,
EWN_passenger_flag,
SNE_passenger_flag,
SNW_passenger_flag
);

clock_divider control_delay(
reset, clk, reds_on_flag,need_white2Tminus_flag,need_green2yellow_flag,
need_red_flag,white2Tminus_flag,green2yellow_flag,red_flag
);

endmodule


