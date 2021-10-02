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
clk, reds_on_flag,need_white2Tminus_flag,need_green2yellow_flag,
need_red_flag,white2Tminus_flag,green2yellow_flag,red_flag
);

endmodule


module top_tb();


reg clk;
reg reset;
reg start;
	
reg [7:0] pass_key;
reg mess_traffic_flag;
reg daytime_flag;

wire white2Tminus_flag;
wire green2yellow_flag;
wire red_flag;

	
wire need_white2Tminus_flag;
wire need_green2yellow_flag;
wire need_red_flag;
wire reds_on_flag;


wire [2:0] EW_straight_lights_flag;
wire [2:0] SN_straight_lights_flag;
wire ES_turning_lights_flag;
wire WN_turning_lights_flag;
wire SW_turning_lights_flag;
wire NE_turning_lights_flag;
wire [2:0] EWS_passenger_flag;
wire [2:0] EWN_passenger_flag;
wire [2:0] SNE_passenger_flag;
wire [2:0] SNW_passenger_flag; 
wire [28:0] state;

assign state = DUT.control_fsm.state;
assign need_white2Tminus_flag = DUT.need_white2Tminus_flag;
assign need_green2yellow_flag = DUT.need_green2yellow_flag;
assign need_red_flag = DUT.need_red_flag;
assign reds_on_flag = DUT.reds_on_flag;
assign white2Tminus_flag = DUT.white2Tminus_flag;
assign green2yellow_flag = DUT.green2yellow_flag;
assign red_flag = DUT.red_flag;

top_interface DUT (clk,
reset,
start,
	
pass_key,
mess_traffic_flag,
daytime_flag,

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

always #5 clk = ~clk; //clk generator

initial begin

clk = 1'b1;
start = 0;
reset = 0;

#10;

reset = 1;
#10;
reset = 0; 
pass_key = 8'b00000000;
mess_traffic_flag = 0;
daytime_flag = 0; //set all initial values
#10;
start = 1;
#10;
start = 0;
mess_traffic_flag = 1;

#100;  // here is for testing the system when it not in day time

daytime_flag = 1;
pass_key = 8'b00000001; //when it is daytime in rush hours, button is disabled, the system runing in a specific logic

#1000;

mess_traffic_flag = 0;// when it s in off-peak hours, passengers can control the system by pressing buttons.

#1000;

$stop;
end
endmodule
