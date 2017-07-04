module traffic_light(input [3:0] SW, output [5:0] LEDR, output [5:0] LEDG);
	// top level design
	traffic_light_output(.clock(SW[0]), .resetn(SW[1]), .change(SW[2]), .set1(LEDR), .set2(LEDG));
endmodule

//module counter();
//endmodule

// Have a counter that signals time for pedestrian to stop crossing.
// Also have the red pedestrian light to blink

//module multiplexer();
//endmodule

module traffic_light_output(input clock, input resetn, input change, output reg [5:0] set1, output reg [5:0] set2);
// This is the light module for assigning the proper signals to the proper output ***LED FOR TESTING ATM***
wire [3:0] state_sig;
control(.clock(clock), .resetn(resetn), .change(change), .out(state_sig));

 // set1 is LEDR
// set2 is LEDG
	//send signal to the breadboard
	//set1[1:0] P1
	//set1[4:2] T1
	//set2[1:0] P2
	//set2[4:2] T2
always @(*)
begin: on_off
	case(state_sig)
		4'b0000: begin
			// Assign T1 to be red
			set1[4] = 1'b1;
			 set1[3] = 1'b0;
			 set1[2] = 1'b0;
			// Assign T2 to be green
			 set2[4] = 1'b0;
			 set2[3] = 1'b0;
			 set2[2] = 1'b1;
			// Assign P1 to be red
			 set1[1] = 1'b1;
			 set1[0] = 1'b0;
			// Assign P2 to be green 
			 set2[1] = 1'b0;
			 set2[0] = 1'b1;
			end
		4'b0001: begin
			// Assign T1 to be red
			 set1[4] = 1'b1;
			 set1[3] = 1'b0;
			 set1[2] = 1'b0;
			// Assign T2 to be green
			 set2[4] = 1'b0;
			 set2[3] = 1'b0;
			 set2[2] = 1'b1;
			// Assign P1 to be red
			 set1[1] = 1'b1;
			 set1[0] = 1'b0;
			// 
			end
		4'b0010: begin
			// Assign T1 to be red
			 set1[4] = 1'b1;
			 set1[3] = 1'b0;
			 set1[2] = 1'b0;
			// Assign T2 to be Yellow
			 set2[4] = 1'b0;
			 set2[3] = 1'b1;
			 set2[2] = 1'b0;
			// Assign P1 to be red
			 set1[1] = 1'b1;
			 set1[0] = 1'b0;
			// Assign P2 to be Red
			 set2[1] = 1'b1;
			 set2[0] = 1'b0;
			end

		4'b0011: begin
			// Assign T1 to be green
			 set1[4] = 1'b0;
			 set1[3] = 1'b0;
			 set1[2] = 1'b1;
			// Assign T2 to be red
			 set2[4] = 1'b1;
			 set2[3] = 1'b0;
			 set2[2] = 1'b0;tate_si
			// Assign P1 to be green
			 set1[1] = 1'b0;
			 set1[0] = 1'b1;
			// Assign P2 to be red 
			 set2[1] = 1'b1;
			 set2[0] = 1'b0;
			end

		4'b0100: begin
			// Assign T1 to be green
			 set1[4] = 1'b0;
			 set1[3] = 1'b0;
			 set1[2] = 1'b1;
			// Assign T2 to be red
			 set2[4] = 1'b1;
			 set2[3] = 1'b0;
			 set2[2] = 1'b0;
			// Assign P1 to be green
			 set1[1] = 1'b0;
			 set1[0] = 1'b1;
			// Assign P2 to be red 
			 set2[1] = 1'b1;
			 set2[0] = 1'b0;
			end

		4'b0101: begin
			// Assign T1 to be yellow
			 set1[4] = 1'b0;
			 set1[3] = 1'b1;
			 set1[2] = 1'b0;
			// Assign T2 to be red
			 set2[4] = 1'b1;
			 set2[3] = 1'b0;
			 set2[2] = 1'b0;
			//Assign P1 to be red
			 set1[1] = 1'b1;
			 set1[0] = 1'b0;
			// Assign P2 to be red 
			 set2[1] = 1'b1;
			 set2[0] = 1'b0;
			end
	endcase
end
endmodule


module control(input clock, input resetn, input change, output [3:0] out);
	// The fsm to determine the state of the traffic/pedestrian lights
	reg [3:0] curr, next;

	//State A is T1 red, T2 green, p1 red, p2 green
	localparam A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101;

	always @(*)
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

	always @(posedge clock)
		begin: flip_flops
			if (resetn == 1'b0)
				curr <= A;
			else
				curr <= next;
		end

	assign out = curr;

endmodule
