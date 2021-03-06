module fsmachine
(	
	input clk,
	input sclk, //clk edge
	input cs, //conditioned
	input rw, //shift register output[0]
	output reg misobuff, //MISO enable
	output reg dm, //data memory write enable
	output reg addr, //address latch enable
	output reg sr //shift register write enable
);

reg [3:0] state;
reg [3:0] count;

parameter Get = 0;
parameter Got = 1;
parameter Read = 2;
parameter Read1 = 3;
parameter Read2 = 4;
parameter Write = 5;
parameter Write2 = 6;
parameter Done = 7;

initial begin
	state <= 0;
	count <= 0;

	misobuff <= 0;
	dm <= 0;
	addr <= 0;
	sr <= 0;
end

always @(posedge clk) begin
//always @(posedge sclk) begin
	count <= count + 1;
		misobuff <= 0;
		dm <= 0;
		addr <= 0;
		sr <= 0;

	//reset counter and state when cs is de-asserted
	if (cs) begin
		state <= 0;
		count <= 0;


	end

	else begin
		case(state)

			Get: begin
				if (count < 8 && sclk) begin
					state <= Get;
				end
				else if (count >=8 && sclk) begin
					state <= Got;
				end
			end

			Got: begin
				addr <= 1;
				sr <= 0;
				count <= 0;
				if (rw) begin
					state <= Read;
				end
				else begin
					state <= Write;
				end
			end

			Read: begin 
				state <= Read1;
			end

			Read1: begin
				sr <= 1;
				state <= Read2;
			end

			Read2: begin
				misobuff <= 1;
				if (count >= 8) begin
					state <= Done;
				end
				else if (sclk) begin
					count <= count + 1;
					state <= Read2;
				end
			end

			Write: begin
				if (count >= 8) begin
					state <= Write2;
				end
				else if (sclk) begin
					count <= count + 1;
				end
			end

			Write2: begin
				dm <= 1;
				state <= Done;
			end

			Done: begin //Done
				count <= 0;
			end

			default: begin
			end
		endcase
	end

end

endmodule
