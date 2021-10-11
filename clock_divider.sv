 module clock_divider(
	input logic reset,
	input logic clk,
	input logic reds_on_flag,
	input logic need_white2Tminus_flag,
	input logic need_green2yellow_flag,
	input logic need_red_flag,
	
	output logic white2Tminus_flag,
	output logic green2yellow_flag,
	output logic red_flag
);
logic [2:0] state;

parameter initial_state = 3'b000;
parameter wait4signals  = 3'b001;
parameter white2Tminus  = 3'b010;
parameter green2yellow  = 3'b011;
parameter yellow2red    = 3'b100;

logic [3:0] counter1 ; //this delay is for white2Tminus and red_flag
logic [3:0] counter2 ; // this delay is for green2yellow
logic [3:0] counter ;


always @(posedge clk) begin 
	if(reset)begin
		state <= initial_state;
		counter <= 0;
		counter1 <= 0;
		counter2 <= 0;
	end
	else begin
	case(state)	
	initial_state: state <= wait4signals;

	wait4signals: begin
		if(need_white2Tminus_flag) begin
			state <= white2Tminus;
		end
		else if(need_green2yellow_flag) begin
			state <= green2yellow;
		end
		else if(need_red_flag) begin
			state <= yellow2red;
		end
		else state <= wait4signals;
		end
	white2Tminus: begin
		if(counter < 10) begin
			counter <= counter + 1;
			state <= white2Tminus;
		end
		else begin
			counter <= 0;
			state <= wait4signals;
		end
	end
	green2yellow: begin
		if(counter1 < 10) begin
			counter1 <= counter1 + 1;
			state <= green2yellow;
		end
		else begin
			counter1 <= 0;
			state <= wait4signals;
		end
	end
	yellow2red: begin
		if(counter2 < 10) begin
			counter2 <= counter2 + 1;
			state <= yellow2red;
		end
		else begin
			counter2 <= 0;
			state <= wait4signals;
		end
	end
	default state <= initial_state;
	endcase
end
end

always_comb begin
	if(state == initial_state)begin
		white2Tminus_flag <= 0;
		green2yellow_flag <= 0;
		red_flag <= 0;
	end
	
	if(state == wait4signals)begin
		white2Tminus_flag <= 0;
		green2yellow_flag <= 0;
		red_flag <= 0;

	end

	if(state == white2Tminus)begin
		white2Tminus_flag <= 1;
		green2yellow_flag <= 0;
		red_flag <= 0;

	end

	if(state == green2yellow)begin
		white2Tminus_flag <= 0;
		green2yellow_flag <= 1;
		red_flag <= 0;

	end

	if(state == yellow2red)begin
		white2Tminus_flag <= 0;
		green2yellow_flag <= 0;
		red_flag <= 1;

	end
end

endmodule 
