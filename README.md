# Traffic-Light-Project
Verilog for the traffic light model simulation

Created by Bill Huang, Jordan Feng, Yining Wang

This is the traffic light intersection simulator system. There are four traffic lights representing each side of the intersection accompanied with pedestrian lights.

This traffic system is automated, but it also includes the option to be idle (i.e. having only blinking red or yellow lights). The pedestrian lights also blink as a warning to pedestrians that the traffic lights will soon change. This is accompanied with a buzzer that better warns pedestrians. There are also two sets of pedestrian counters to better show people how soon the lights will change, making it unsafe to cross the road.

Visuals:
	HEX[7] and HEX[6] along with HEX[5] and HEX[4] represent the counter for one set of the pedestrian lights. 
	HEX[3] and HEX[2] along with HEX[1] and HEX[0] represent the countdown for the other set of the pedestrian lights.

The traffic lights are seen on a separate unit connected by the GPIO boards and assembled on the breadboard.



Controls:
SW[17] and SW[16] controls the mode of the traffic light.
	SW[17] flipped on indicates flashing red light mode.
	SW[16] flipped on indicates normal traffic light operation.
	SW[17] and SW[16] flipped on indicates flashing yellow light mode.

SW[2] and SW[1] controls the states of the normal traffic light operations.
	SW[2] controls the states of the traffic lights .
	SW[1] resets the traffic light system to default state.
	SW[2] and SW[1] flipped on allows for normal traffic operation.

