 module clock_divider(

	input logic clk,
	input logic reds_on_flag,
	input logic need_white2Tminus_flag,
	input logic need_green2yellow_flag,
	input logic need_red_flag,
	
	output logic white2Tminus_flag,
	output logic green2yellow_flag,
	output logic red_flag
);

parameter cyc_10 = 4'b1010;
parameter cyc_30 = 5'b11110;

logic [3:0] counter1 = 0; //this delay is for white2Tminus and red_flag
logic [4:0] counter2 = 0; // this delay is for green2yellow
logic [4:0] counter = 0;


always_ff @(posedge clk) begin 
		if(need_white2Tminus_flag) begin 
			if(counter1 <= cyc_10)begin 
			   counter1 = counter1 + 1;
			end
			else begin
			   counter1 = 0;
			   white2Tminus_flag = 1;
			   red_flag = 0;
			end
		end
		else if(need_green2yellow_flag) begin 
			if(counter2 <= cyc_30)begin 
			   counter2 = counter2 + 1;
			end
			else begin
			   counter2 = 0;
			   green2yellow_flag = 1;
			end		
		end
		else if(need_red_flag) begin 
			if(counter <= cyc_10)begin 
			   counter = counter + 1;
			end
			else begin
			   counter = 0;
			   red_flag = 1;
			   white2Tminus_flag = 0;
			   green2yellow_flag = 0;
			   
			end		
		end
	
end

endmodule 