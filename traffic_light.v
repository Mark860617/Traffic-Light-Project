
module traffic_light(input [17:0] SW, input CLOCK_50, output [35:0] GPIO, output [6:0] HEX4, output [6:0] HEX5, output [6:0] HEX6, output [6:0] HEX7, output [6:0] HEX3, output [6:0] HEX2, output [6:0] HEX1, output [6:0] HEX0);
	// The top level design for the traffic light intersection
	//Create wires for the slowed down clock signal and the timer.
	wire [7:0] ped_count1;
	wire [7:0] ped_count2;
	// Slow down the clock signal from 50 Mhz to about 1 hz
	//clock_slower(.clock(CLOCK_50), .select_time(timer), .led(new_clock));
	// Adjust the different lengths before transitions of each light. 
	//traffic_light_timer(.clock(new_clock), .resetn(SW[1]), .change(SW[2]), .timer(timer));
	// Output the desired signal through the GPIO pins into the indicated LEDs
	//traffic_light_output(.clock(new_clock), .clock2(CLOCK_50), .resetn(SW[1]), .change(SW[2]), .set1(GPIO[4:0]), .set2(GPIO[10:5]), .ped_count1(ped_count1), .ped_count2(ped_count2));
	set_traffic(.s(SW[17:16]), .clock(CLOCK_50), .resetn(SW[1]), .change(SW[2]), .set1(GPIO[4:0]), .set2(GPIO[10:5]), .ped_count1(ped_count1), .ped_count2(ped_count2), .ped_sound1(GPIO[34]), .ped_sound2(GPIO[35]));
	hex_decoder(.hex_digit(ped_count1[7:4]), .segments(HEX7));
	hex_decoder(.hex_digit(ped_count1[3:0]), .segments(HEX6));
	hex_decoder(.hex_digit(ped_count1[7:4]), .segments(HEX5));
	hex_decoder(.hex_digit(ped_count1[3:0]), .segments(HEX4));
	hex_decoder(.hex_digit(ped_count2[7:4]), .segments(HEX3));
	hex_decoder(.hex_digit(ped_count2[3:0]), .segments(HEX2));
	hex_decoder(.hex_digit(ped_count2[7:4]), .segments(HEX1));
	hex_decoder(.hex_digit(ped_count2[3:0]), .segments(HEX0));
endmodule

module set_traffic(input [1:0] s, input clock, input resetn, input change, output reg [4:0] set1, output reg [4:0] set2, output reg [7:0] ped_count1, output reg [7:0] ped_count2, output reg ped_sound1, output reg ped_sound2);
	wire [4:0] s1, s2;
	wire [7:0] p1, p2;
	wire flash_led;
	wire new_clock;
	wire timer;
	wire sound1, sound2;
	clock_slower(.clock(clock), .select_time(timer), .led(new_clock));
	traffic_light_timer(.clock(new_clock), .resetn(resetn), .change(change), .timer(timer));
	traffic_light_output(.clock(new_clock), .clock2(clock), .resetn(resetn), .change(change), .set1(s1), .set2(s2), .ped_count1(p1), .ped_count2(p2), .ped_sound1(sound1), .ped_sound2(sound2));
	flashLED(.clock(clock), .led(flash_led));
	always @(*)
	begin
		case(s[1:0])
			2'b01: begin 
				set1 <= s1; 
				set2 <= s2; 
				ped_count1 <= p1; 
				ped_count2 <= p2;
				ped_sound1 <= sound1;
				ped_sound2 <= sound2;
				end
			2'b10: begin 
				set1[4] <= flash_led;
				set1[3] <= 0;
				set1[2] <= 0;
				set1[1] <= 0;
				set1[0] <= 0;
				set2[4] <= flash_led;
				set2[3] <= 0;
				set2[2] <= 0;
				set2[1] <= 0;
				set2[0] <= 0;
				ped_count1 <= 0;
				ped_count2 <= 0;
				ped_sound1 <= 0;
				ped_sound2 <= 0;
				end
			2'b11: begin 
				set1[4] <= 0;
				set1[3] <= flash_led;
				set1[2] <= 0;
				set1[1] <= 0;
				set1[0] <= 0;
				set2[4] <= 0;
				set2[3] <= flash_led;
				set2[2] <= 0;
				set2[1] <= 0;
				set2[0] <= 0;
				ped_count1 <= 0;
				ped_count2 <= 0;
				ped_sound1 <= 0;
				ped_sound2 <= 0;
				end
			default: begin
				set1 <= 0;
				set2 <= 0;
				ped_count1 <= 0;
				ped_count2 <= 0;
				ped_sound1 <= 0;
				ped_sound2 <= 0;
				end
		endcase
	end
endmodule


module pedestrian_counter(input clock, input enable, output reg [7:0] digits);
	reg [32:0] timer = 32'd50000000; //CLOCK_50 is a clock that pulses at 50MHz or 50 millions times per second.change back to 30 mil if over 1 second
	reg [7:0] init;
	// 15 in hexadeximal or 8h'15
	// On positive clock edge
	always @(posedge clock)
	begin
		if (enable == 1) begin
			// When the timer count is not zero decrement by 1
			if (timer != 32'd0) 
				timer <= timer - 1;
			// If timer count reaches zero, reverse LED state and reset the timer.
			else if (init == 8'b0001_0000) begin
				init <= init - 4'b0111;
				timer <= 32'd50000000;
			end
			else if (init == 8'b0000_0000) begin
				init <= 8'b0001_0101;
				timer <= 32'd50000000;
			end
			else begin 
				init <= init - 1'b1;
				timer <= 32'd50000000;
			end
			
		end
		else begin
			init <= 0;
		end
		digits <= init;
	end
endmodule


module flashLED(input clock, output reg led);
	// The module for flashing the indicated LEDs
	// Set the timer to countdown from CLOCK_50
	reg [32:0] timer = 32'd25000000; //CLOCK_50 is a clock that pulses at 50MHz or 50 millions times per second.change back to 30 mil if over 1 second
	
	// On positive clock edge
	always @(posedge clock)
	begin
		// When the timer count is not zero decrement by 1
		if (timer != 32'd0) 
			timer <= timer - 1;
		// If timer count reaches zero, reverse LED state and reset the timer.
		else begin
			led <= ~led;
			timer <= 32'd25000000;
		end
	end
endmodule


module clock_slower(input clock, input select_time, output reg led);
	// The module for slowing down CLOCK_50's clock speed
	// Create registers for the desired countdown and the timer.
	reg [32:0] d;
	reg [32:0] timer;
	// On positive clock edge
	always @ (posedge clock)
		begin
		case (select_time)
			// Allocate the desired countdown interval depending on the select_time signal
			1'b0: d = 32'd405000000; // Red/ green light
			1'b1: d = 32'd1; // yellow light time interval
			default: d = 0;
		endcase
		
		// Set timer to the desired countdown interval
		timer <= d;
		
		// When the timer count is not zero decrement timer by 1
		if (timer != 32'd0) 
			timer <= timer - 1;
		// If t1'b1imer count reaches zero, reverse LED signal and set timer to desired countdown
		else begin
			led <= ~led;
			timer <= d; // 30000000
		end
	end
endmodule


module traffic_light_timer(input clock, input resetn, input change, output reg timer);
// This is the light module for assigning the proper signals to the proper output
wire [3:0] state_sig;
control(.clock(clock), .resetn(resetn), .change(change), .out(state_sig));

 // set1 is LEDR
// set2 is LEDG
	//send signal to the breadboard
	//set1[1:0] P1 (Pedestrian Light Set 1)
	//set1[4:2] T1 (Traffic Light Set 1)
	//set2[1:0] P2 (Pedestrian Light Set 2)
	//set2[4:2] T2 (Traffic Light Set 2)
always @(*)
begin: on_off
	case(state_sig)
		4'b0000: begin //T1 R T2 G 10 secs
			timer = 1'b0;
			end
		4'b0001: begin //T1 R T2 G 10 secs
			timer = 1'b0;
			end
		4'b0010: begin //T1 R T2 Y 3 secs
			timer = 1'b1;
			end

		4'b0011: begin //T1 G T2 R 10 secs
			timer = 1'b0;
			end

		4'b0100: begin //T1 G T2 R 10 secs
			timer = 1'b0;
			end

		4'b0101: begin //T1 Y T2 R 3 secs
			timer = 1'b1;
			end
	endcase
end
endmodule



module traffic_light_output(input clock, input clock2, input resetn, input change, output reg [5:0] set1, output reg [5:0] set2, output reg [7:0] ped_count1, output reg [7:0] ped_count2, output reg ped_sound1, output reg ped_sound2);
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
wire flash_ped;
wire [7:0] count;
reg enable;
wire beep;
pedestrian_counter(.clock(clock2), .enable(enable), .digits(count));
flashLED(.clock(clock2), .led(flash_ped));
flashLED(.clock(clock2), .led(beep));

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
			 // Assign ped_count1 to 0
			 ped_count1 = 1'b0;
			 ped_count2 = 1'b0;
			 enable = 1'b0;
			 ped_sound1 = 1'b0;
			 ped_sound2 = 1'b0;

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
			 // Assign P2 to be green 
			 //Flashing ped light on P2
			 set2[1] = flash_ped;
			 set2[0] = 1'b0;
			 ped_count1 = 1'b0;
			 ped_count2 = count;
			 enable = 1'b1;
			 ped_sound1 = 1'b0;
			 ped_sound2 = beep;

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
			 ped_count1 = 1'b0;
			 ped_count2 = 1'b0;
			 enable = 1'b0;
			 ped_sound1 = 1'b0;
			 ped_sound2 = 1'b0;
			end

		4'b0011: begin
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
			 ped_count1 = 1'b0;
			 ped_count2 = 1'b0;
			 enable = 1'b0;
			 ped_sound1 = 1'b0;
			 ped_sound2 = 1'b0;
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
			 set1[1] = flash_ped;
			 set1[0] = 1'b0;
			// Assign P2 to be red 
			 set2[1] = 1'b1;
			 set2[0] = 1'b0;
			 ped_count1 = count;
			 ped_count2 = 1'b0;
			 enable = 1'b1;
			 ped_sound1 = beep;
			 ped_sound2 = 1'b0;
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
			 ped_count1 = 1'b0;
			 ped_count2 = 1'b0;
			 enable = 1'b0;
			 ped_sound1 = 1'b0;
			 ped_sound2 = 1'b0;
			end
	endcase
end
endmodule



module control(input clock, input resetn, input change, output [3:0] out);
	// The fsm to determine the state of the traffic/pedestrian lights
	reg [3:0] curr, next;

	//State A is T1 red, T2 green, p1 red, p2 green
	localparam A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101;

	//The state table for the various states of the traffic lights
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
	//Set the current state to the next state if the reset is not 0
		begin: flip_flops
			if (resetn == 1'b0)
				curr <= A;
			else
				curr <= next;
		end

	assign out = curr;

endmodule

module hex_decoder(hex_digit, segments);
// The hex decoder for the pedestrian traffic lights
    input [3:0] hex_digit; 
    output reg [6:0] segments;

    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
