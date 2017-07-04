module control(input clock, input resetn, input change, output [3:0] out);

	reg [3:0] curr, next;

	//State A is T1 red, T2 green, p1 red, p2 green
	localparam A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101;

	begin: state_table
		case(curr)
			A: begin
				if (!change) next <= A;
				else next <= B;
			end
			B: begin
				if (!change) next <= B;
				else next <= C;	
			end
			C: begin
				if (!change) next <= C;
				else next <= D;	
			end
			D: begin
				if (!change) next <= D;
				else next <= E;	
			end
			E: begin
				if (!change) next <= E;
				else next <= F;	
			end
			F: begin
				if (!change) next <= F;
				else next <= A;	
			end
			default: next <= A;
		endcase
	end

	// WHAT DOES THIS PART DO
	always @(posedge clock)
		begin: flip_flops
			if (resetn == 1'b0)
				curr <= A;
			else
				curr <= next;
		end

	assign out = curr;

endmodule


module outputter(input state_sig, output out);
	//send signal to the breadboard
	//LEDR[1:0] P1
	//LEDR[4:2] T1
	//LEDG[1:0] P2
	//LEDG[4:2] T2
begin: on_off
	case(state_sig)
		4'b0000: begin
			// Assign T1 to be red
			assign LEDR[4] = 1;
			assign LEDR[3] = 0;
			assign LEDR[2] = 0;
			// Assign T2 to be green
			assign LEDG[4] = 0;
			assign LEDG[3] = 0;
			assign LEDG[2] = 1;
			// Assign P1 to be red
			assign LEDR[1] = 1;
			assign LEDR[0] = 0;
			// Assign P2 to be green 
			assign LEDG[1] = 0;
			assign LEDG[0] = 1;
			end
		4'b0001: begin
			// Assign T1 to be red
			assign LEDR[4] = 1;
			assign LEDR[3] = 0;
			assign LEDR[2] = 0;
			// Assign T2 to be green
			assign LEDG[4] = 0;
			assign LEDG[3] = 0;
			assign LEDG[2] = 1;
			// Assign P1 to be red
			assign LEDR[1] = 1;
			assign LEDR[0] = 0;
			// Assign P2 to be green 
			assign LEDG[1] = 0;
			assign LEDG[0] = 1;
			end

		4'b0010: begin
			// Assign T1 to be red
			assign LEDR[4] = 1;
			assign LEDR[3] = 0;
			assign LEDR[2] = 0;
			// Assign T2 to be Yellow
			assign LEDG[4] = 0;
			assign LEDG[3] = 1;
			assign LEDG[2] = 0;
			// Assign P1 to be red
			assign LEDR[1] = 1;
			assign LEDR[0] = 0;
			// Assign P2 to be Red
			assign LEDG[1] = 1;
			assign LEDG[0] = 0;
			end

		4'b0011: begin
			// Assign T1 to be green
			assign LEDR[4] = 0;
			assign LEDR[3] = 0;
			assign LEDR[2] = 1;
			// Assign T2 to be red
			assign LEDG[4] = 1;
			assign LEDG[3] = 0;
			assign LEDG[2] = 0;
			// Assign P1 to be green
			assign LEDR[1] = 0;
			assign LEDR[0] = 1;
			// Assign P2 to be red 
			assign LEDG[1] = 1;
			assign LEDG[0] = 0;
			end

		4'b0100: begin
			// Assign T1 to be green
			assign LEDR[4] = 0;
			assign LEDR[3] = 0;
			assign LEDR[2] = 1;
			// Assign T2 to be red
			assign LEDG[4] = 1;
			assign LEDG[3] = 0;
			assign LEDG[2] = 0;
			// Assign P1 to be green
			assign LEDR[1] = 0;
			assign LEDR[0] = 1;
			// Assign P2 to be red 
			assign LEDG[1] = 1;
			assign LEDG[0] = 0;
			end

		4'b0101: begin
			// Assign T1 to be yellow
			assign LEDR[4] = 0;
			assign LEDR[3] = 1;
			assign LEDR[2] = 0;
			// Assign T2 to be red
			assign LEDG[4] = 1;
			assign LEDG[3] = 0;
			assign LEDG[2] = 0;
			// Assign P1 to be red
			assign LEDR[1] = 1;
			assign LEDR[0] = 0;
			// Assign P2 to be red 
			assign LEDG[1] = 1;
			assign LEDG[0] = 0;
			end
	endcase
end
endmodule
