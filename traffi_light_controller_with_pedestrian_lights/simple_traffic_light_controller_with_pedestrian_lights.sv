module simple_traffic_light_controller_with_pedestrian_lights
(
	input clk_27, debug, reset,
	output northbound_red, northbound_amber, northbound_green,
	output southbound_red, southbound_amber, southbound_green,
	output eastbound_red, eastbound_amber, eastbound_green,
	output westbound_red, westbound_amber, westbound_green,

	input free_left_sensor,
	output [1:0] southbound_free_left,
	
	input [1:0] walk_request_button, // bit 0: East and West; bit 1: north and south
	output [5:0] northbound_crossing, southbound_crossing, eastbound_crossing, westbound_crossing
);

wire clk;
reg [5:0] timer;

// variables for 4 signals (Lab 5a)
reg staying_in_state_1, staying_in_state_2, staying_in_state_3, staying_in_state_4, staying_in_state_5, staying_in_state_6;

reg entering_state_1, entering_state_2, entering_state_3, entering_state_4, entering_state_5, entering_state_6;
reg exiting_state_1, exiting_state_2, exiting_state_3, exiting_state_4, exiting_state_5, exiting_state_6;

reg state_1_d, state_2_d, state_3_d, state_4_d, state_5_d, state_6_d;
reg state_1, state_2, state_3, state_4, state_5, state_6;

// variables for state_4a (Lab 5b)
reg staying_in_state_4a, entering_state_4a, exiting_state_4a, state_4a_d, state_4a;
reg left_turn_sensed;

// variables for pedestrian crossings (Lab 6)
reg staying_in_state_1w, staying_in_state_1fd, staying_in_state_1d,
		staying_in_state_4w, staying_in_state_4fd, staying_in_state_4d;

reg entering_state_1w, entering_state_1fd, entering_state_1d,
		entering_state_4w, entering_state_4fd, entering_state_4d;

reg exiting_state_1w, exiting_state_1fd, exiting_state_1d,
		exiting_state_4w, exiting_state_4fd, exiting_state_4d;

reg state_1w_d, state_1fd_d, state_1d_d,
		state_4w_d, state_4fd_d, state_4d_d;

reg state_1w, state_1fd, state_1d,
		state_4w, state_4fd, state_4d;

reg [1:0] pedestrian_requested;

// slower "clk" obtained from much faster 27 MHz clock, "clk_27"
reg [23:0] clock_divider_counter, clock_divider_constant;

always @ *
	if (debug == 1'd1)
		clock_divider_constant <= 24'd1_350_000; //10Hz
		//clock_divider_constant <= 24'd1; //uncomment to make 13.5MHz clk
	else
		clock_divider_constant <= 24'd13_500_000; //1Hz

always @ (posedge clk_27)
	if (reset == 1'd0)
		clock_divider_counter <= 24'd1;
	else if (clock_divider_counter == 24'd1)
		clock_divider_counter <= clock_divider_constant;
	else
		clock_divider_counter <= clock_divider_counter - 24'd1;

always @ (posedge clk_27)
	if (clock_divider_counter == 24'd1)
		clk <= ~clk;
	else
		clk <= clk;	

// real-time timer for the whole system
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		timer <= 6'd60; // timer for state 1
	else if (entering_state_1w == 1'b1)
		timer <= 6'd10; // timer for state 1w
	else if (entering_state_1fd == 1'b1)
		timer <= 6'd20; // timer for state 1fd
	else if (entering_state_1d == 1'b1)
		timer <= 6'd30; // timer for state 1d
	else if (entering_state_1 == 1'b1)
		timer <= 6'd60; // timer for state 1
	else if (entering_state_2 == 1'b1)
		timer <= 6'd6; // timer for state 2
	else if (entering_state_3 == 1'b1)
		timer <= 6'd2; // timer for state 3
	else if (entering_state_4a == 1'b1)
		timer <= 6'd20; // timer for state 4a
	else if (entering_state_4w == 1'b1)
		timer <= 6'd10; // timer for state 4w
	else if (entering_state_4fd == 1'b1)
		timer <= 6'd20; // timer for state 4fd
	else if (entering_state_4d == 1'b1)
		timer <= 6'd30; // timer for state 4d
	else if (entering_state_4 == 1'b1)
		timer <= 6'd60; // timer for state 4
	else if (entering_state_5 == 1'b1)
		timer <= 6'd6; // timer for state 5
	else if (entering_state_6 == 1'b1)
		timer <= 6'd2; // timer for state 6
	else if (timer == 6'd1)
		timer <= timer; // never decrement/count below 1
	else
		timer <= timer - 6'd1; // "count down" timer

// for free left turn
always @ (posedge clk)
	if (free_left_sensor == 1'b0)
		left_turn_sensed = 1'b1;
	else
		left_turn_sensed = 1'b0;

//// for pedestrian crossings
//always @ (posedge clk or negedge walk_request_button[0] or negedge walk_request_button[1] or negedge reset)
//	if (reset == 1'b0)
//		pedestrian_requested  = 1'b0;
//	else if (walk_request_button[0] == 1'b0)
//		pedestrian_requested = 1'b1;
//	else if (walk_request_button[1] == 1'b0)
//		pedestrian_requested = 1'b1;
//	else if ((state_1w == 1'b1) && (timer == 6'd10))
//		pedestrian_requested = 1'b0;
//	else if ((state_4w == 1'b1) && (timer == 6'd10))
//		pedestrian_requested = 1'b0;
//	else
//		pedestrian_requested = pedestrian_requested;

//// make signal of key 3 to go throgh d flip flop so it can work on clock 
//always @ (posedge clk)
//	if (walk_request_button[0] == 1'b0)
//		pedestrian_requested[0] = 1'b1 ;
//	else 
//		pedestrian_requested[0] = 1'b0 ;
//
//// make signal of key 3 to go throgh d flip flop so it can work on clock 
//always @ (posedge clk)
//	if (walk_request_button[1] == 1'b0)
//		pedestrian_requested[1] = 1'b1 ;
//	else 
//		pedestrian_requested[1] = 1'b0 ;

always @ (posedge CLK)
        if (reset == 1'b0) // keys are active low
            WALK_4_D <= 1'b0;

        else if (WALK_4_REQUEST == 1'b0)
            WALK_4_D <= 1'b1;

        else if (entering_state_4w == 1'b1 && (timer == 6'd10))
            WALK_4_D <= 1'b0;

        else 
            WALK_4_D <= WALK_4_D;

always @ (posedge CLK)
        if (reset == 1'b0) // keys are active low
            WALK_4_D <= 1'b0;

        else if (WALK_4_REQUEST == 1'b0)
            WALK_4_D <= 1'b1;

        else if (entering_state_4w == 1'b1 && (timer == 6'd10))
            WALK_4_D <= 1'b0;

        else 
            WALK_4_D <= WALK_4_D;

//-------------------------------------------------------------------------------- State 1w
// make the state 1w flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_1w <= 1'b1;
	else
		state_1w <= state_1w_d;

// logic for entering state 1w
always @ *
	if ((state_6 == 1'b1) && (timer == 6'd1) && (pedestrian_requested[0] == 1'b1))
		entering_state_1w <= 1'b1;
	else
		entering_state_1w <= 1'b0;

// logic for staying in state 1w
always @ *
	if ((state_1w == 1'b1) && (timer != 6'd1))
		staying_in_state_1w <= 1'b1;
	else
		staying_in_state_1w <= 1'b0;

// make the d_input for state 1w flip flop
always @ *
	if (entering_state_1w == 1'b1)
		// enter state 1w on next posedge clk
		state_1w_d <= 1'b1;
	else if (staying_in_state_1w == 1'b1)
		// stay in state 1w on next posedge clk
		state_1w_d <= 1'b1;
	else
		// not in state 1w on the next posedge clk
		state_1w_d <= 1'b0;

//-------------------------------------------------------------------------------- State 1fd
// make the state 1fd flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_1fd <= 1'b1;
	else
		state_1fd <= state_1fd_d;

// logic for entering state 1fd
always @ *
	if ((state_1w == 1'b1) && (timer == 6'd1))
		entering_state_1fd <= 1'b1;
	else
		entering_state_1fd <= 1'b0;

// logic for staying in state 1fd
always @ *
	if ((state_1fd == 1'b1) && (timer != 6'd1))
		staying_in_state_1fd <= 1'b1;
	else
		staying_in_state_1fd <= 1'b0;

// make the d_input for state 1fd flip flop
always @ *
	if (entering_state_1fd == 1'b1)
		// enter state 1fd on next posedge clk
		state_1fd_d <= 1'b1;
	else if (staying_in_state_1fd == 1'b1)
		// stay in state 1fd on next posedge clk
		state_1fd_d <= 1'b1;
	else
		// not in state 1fd on the next posedge clk
		state_1fd_d <= 1'b0;

//-------------------------------------------------------------------------------- State 1d
// make the state 1d flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_1d <= 1'b1;
	else
		state_1d <= state_1d_d;

// logic for entering state 1d
always @ *
	if ((state_1fd == 1'b1) && (timer == 6'd1))
		entering_state_1d <= 1'b1;
	else
		entering_state_1d <= 1'b0;

// logic for staying in state 1d
always @ *
	if ((state_1d == 1'b1) && (timer != 6'd1))
		staying_in_state_1d <= 1'b1;
	else
		staying_in_state_1d <= 1'b0;

// make the d_input for state 1d flip flop
always @ *
	if (entering_state_1d == 1'b1)
		// enter state 1d on next posedge clk
		state_1d_d <= 1'b1;
	else if (staying_in_state_1d == 1'b1)
		// stay in state 1d on next posedge clk
		state_1d_d <= 1'b1;
	else
		// not in state 1d on the next posedge clk
		state_1d_d <= 1'b0;

//-------------------------------------------------------------------------------- State 1
// make the state 1 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_1 <= 1'b1;
	else
		state_1 <= state_1_d;

// logic for entering state 1
always @ *
	if ((state_6 == 1'b1) && (timer == 6'd1) && (pedestrian_requested[0] == 1'b0))
		entering_state_1 <= 1'b1;
	else
		entering_state_1 <= 1'b0;

// logic for staying in state 1
always @ *
	if ((state_1 == 1'b1) && (timer != 6'd1))
		staying_in_state_1 <= 1'b1;
	else
		staying_in_state_1 <= 1'b0;

// make the d_input for state 1 flip flop
always @ *
	if (entering_state_1 == 1'b1)
		// enter state 1 on next posedge clk
		state_1_d <= 1'b1;
	else if (staying_in_state_1 == 1'b1)
		// stay in state 1 on next posedge clk
		state_1_d <= 1'b1;
	else
		// not in state 1 on the next posedge clk
		state_1_d <= 1'b0;

//-------------------------------------------------------------------------------- State 2
// make the state 2 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_2 <= 1'b0;
	else
		state_2 <= state_2_d;

// logic for entering state 2
always @ *
	if (((state_1 == 1'b1) || (state_1d == 1'b1)) && (timer == 6'd1))
		entering_state_2 <= 1'b1;
	else
		entering_state_2 <= 1'b0;

// logic for staying in state 2
always @ *
	if ((state_2 == 1'b1) && (timer != 6'd1))
		staying_in_state_2 <= 1'b1;
	else
		staying_in_state_2 <= 1'b0;

// make the d_input for state 2 flip flop
always @ *
	if (entering_state_2 == 1'b1)
		// enter state 2 on next posedge clk
		state_2_d <= 1'b1;
	else if (staying_in_state_2 == 1'b1)
		// stay in state 2 on next posedge clk
		state_2_d <= 1'b1;
	else
		// not in state 2 on the next posedge clk
		state_2_d <= 1'b0;

//-------------------------------------------------------------------------------- State 3
// make the state 3 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_3 <= 1'b0;
	else
		state_3 <= state_3_d;

// logic for entering state 3
always @ *
	if ((state_2 == 1'b1) && (timer == 6'd1))
		entering_state_3 <= 1'b1;
	else
		entering_state_3 <= 1'b0;

// logic for staying in state 3
always @ *
	if ((state_3 == 1'b1) && (timer != 6'd1))
		staying_in_state_3 <= 1'b1;
	else
		staying_in_state_3 <= 1'b0;

// make the d_input for state 3 flip flop
always @ *
	if (entering_state_3 == 1'b1)
		// enter state 3 on next posedge clk
		state_3_d <= 1'b1;
	else if (staying_in_state_3 == 1'b1)
		// stay in state 3 on next posedge clk
		state_3_d <= 1'b1;
	else
		// not in state 3 on the next posedge clk
		state_3_d <= 1'b0;

//-------------------------------------------------------------------------------- State 4a
// make the state 4a flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_4a <= 1'b0;
	else
		state_4a <= state_4a_d;

// logic for entering state 4a
always @ *
	if ((state_3 == 1'b1) && (timer == 6'd1) && (left_turn_sensed == 1'b1))
		entering_state_4a <= 1'b1;
	else
		entering_state_4a <= 1'b0;

// logic for staying in state 4a
always @ *
	if ((state_4a == 1'b1) && (timer != 6'd1))
		staying_in_state_4a <= 1'b1;
	else
		staying_in_state_4a <= 1'b0;

// make the d_input for state 4a flip flop
always @ *
	if (entering_state_4a == 1'b1)
		// enter state 4a on next posedge clk
		state_4a_d <= 1'b1;
	else if (staying_in_state_4a == 1'b1)
		// stay in state 4a on next posedge clk
		state_4a_d <= 1'b1;
	else
		// not in state 4a on the next posedge clk
		state_4a_d <= 1'b0;

//-------------------------------------------------------------------------------- State 4w
// make the state 4w flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_4w <= 1'b1;
	else
		state_4w <= state_4w_d;

// logic for entering state 4w
always @ *
	if (((state_3 == 1'b1) || (state_4a == 1'b1)) && (timer == 6'd1) && (pedestrian_requested[1] == 1'b1))
		entering_state_4w <= 1'b1;
	else
		entering_state_4w <= 1'b0;

// logic for staying in state 4w
always @ *
	if ((state_4w == 1'b1) && (timer != 6'd1))
		staying_in_state_4w <= 1'b1;
	else
		staying_in_state_4w <= 1'b0;

// make the d_input for state 4w flip flop
always @ *
	if (entering_state_4w == 1'b1)
		// enter state 4w on next posedge clk
		state_4w_d <= 1'b1;
	else if (staying_in_state_4w == 1'b1)
		// stay in state 4w on next posedge clk
		state_4w_d <= 1'b1;
	else
		// not in state 4w on the next posedge clk
		state_4w_d <= 1'b0;

//-------------------------------------------------------------------------------- State 4fd
// make the state 4fd flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_4fd <= 1'b1;
	else
		state_4fd <= state_4fd_d;

// logic for entering state 4fd
always @ *
	if ((state_4w == 1'b1) && (timer == 6'd1))
		entering_state_4fd <= 1'b1;
	else
		entering_state_4fd <= 1'b0;

// logic for staying in state 4fd
always @ *
	if ((state_4fd == 1'b1) && (timer != 6'd1))
		staying_in_state_4fd <= 1'b1;
	else
		staying_in_state_4fd <= 1'b0;

// make the d_input for state 4fd flip flop
always @ *
	if (entering_state_4fd == 1'b1)
		// enter state 4fd on next posedge clk
		state_4fd_d <= 1'b1;
	else if (staying_in_state_4fd == 1'b1)
		// stay in state 4fd on next posedge clk
		state_4fd_d <= 1'b1;
	else
		// not in state 4fd on the next posedge clk
		state_4fd_d <= 1'b0;

//-------------------------------------------------------------------------------- State 4d
// make the state 4d flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_4d <= 1'b1;
	else
		state_4d <= state_4d_d;

// logic for entering state 4d
always @ *
	if ((state_4fd == 1'b1) && (timer == 6'd1))
		entering_state_4d <= 1'b1;
	else
		entering_state_4d <= 1'b0;

// logic for staying in state 4d
always @ *
	if ((state_4d == 1'b1) && (timer != 6'd1))
		staying_in_state_4d <= 1'b1;
	else
		staying_in_state_4d <= 1'b0;

// make the d_input for state 4d flip flop
always @ *
	if (entering_state_4d == 1'b1)
		// enter state 4d on next posedge clk
		state_4d_d <= 1'b1;
	else if (staying_in_state_4d == 1'b1)
		// stay in state 4d on next posedge clk
		state_4d_d <= 1'b1;
	else
		// not in state 4d on the next posedge clk
		state_4d_d <= 1'b0;

//-------------------------------------------------------------------------------- State 4
// make the state 4 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_4 <= 1'b0;
	else
		state_4 <= state_4_d;

// logic for entering state 4
always @ *
	if (((state_3 == 1'b1) && (timer == 6'd1) && (free_left_sensor == 1'b1) && ((pedestrian_requested[1] == 1'b1)) || (state_4a == 1'b1) && (timer == 6'd1) && (pedestrian_requested[1] == 1'b1)))
		entering_state_4 <= 1'b1;
	else
		entering_state_4 <= 1'b0;

// logic for staying in state 4
always @ *
	if ((state_4 == 1'b1) && (timer != 6'd1))
		staying_in_state_4 <= 1'b1;
	else
		staying_in_state_4 <= 1'b0;

// make the d_input for state 4 flip flop
always @ *
	if (entering_state_4 == 1'b1)
		// enter state 4 on next posedge clk
		state_4_d <= 1'b1;
	else if (staying_in_state_4 == 1'b1)
		// stay in state 4 on next posedge clk
		state_4_d <= 1'b1;
	else
		// not in state 4 on the next posedge clk
		state_4_d <= 1'b0;

//-------------------------------------------------------------------------------- State 5
// make the state 5 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_5 <= 1'b0;
	else
		state_5 <= state_5_d;

// logic for entering state 5
always @ *
	if (((state_4 == 1'b1) && (timer == 6'd1)) || ((state_4d == 1'b1) && (timer == 6'd1)))
		entering_state_5 <= 1'b1;
	else
		entering_state_5 <= 1'b0;

// logic for staying in state 5
always @ *
	if ((state_5 == 1'b1) && (timer != 6'd1))
		staying_in_state_5 <= 1'b1;
	else
		staying_in_state_5 <= 1'b0;

// make the d_input for state 5 flip flop
always @ *
	if (entering_state_5 == 1'b1)
		// enter state 5 on next posedge clk
		state_5_d <= 1'b1;
	else if (staying_in_state_5 == 1'b1)
		// stay in state 5 on next posedge clk
		state_5_d <= 1'b1;
	else
		// not in state 5 on the next posedge clk
		state_5_d <= 1'b0;

//-------------------------------------------------------------------------------- State 6
// make the state 6 flip flop
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		state_6 <= 1'b0;
	else
		state_6 <= state_6_d;

// logic for entering state 6
always @ *
	if ((state_5 == 1'b1) && (timer == 6'd1))
		entering_state_6 <= 1'b1;
	else
		entering_state_6 <= 1'b0;

// logic for staying in state 6
always @ *
	if ((state_6 == 1'b1) && (timer != 6'd1))
		staying_in_state_6 <= 1'b1;
	else
		staying_in_state_6 <= 1'b0;

// make the d_input for state 6 flip flop
always @ *
	if (entering_state_6 == 1'b1)
		// enter state 6 on next posedge clk
		state_6_d <= 1'b1;
	else if (staying_in_state_6 == 1'b1)
		// stay in state 6 on next posedge clk
		state_6_d <= 1'b1;
	else
		// not in state 6 on the next posedge clk
		state_6_d <= 1'b0;

// northbound states
always @ *
	if ((state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_4a | state_6) == 1'b1)
		northbound_red <= 1'b0;
	else
		northbound_red <= 1'b1;

always @ *
	if ((state_5) == 1'b1)
		northbound_amber <= 1'b0;
	else
		northbound_amber <= 1'b1;

always @ *
	if ((state_4w | state_4fd | state_4d | state_4) == 1'b1)
		northbound_green <= 1'b0;
	else
		northbound_green <= 1'b1;

// southbound states
always @ *
	if ((state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_6) == 1'b1)
		southbound_red <= 1'b0;
	else
		southbound_red <= 1'b1;

always @ *
	if ((state_5 == 1'b1) || (state_4a == 1'b1))
		southbound_amber <= 1'b0;
	else
		southbound_amber <= 1'b1;

always @ *
	if ((state_4 | state_4w | state_4fd | state_4d) == 1'b1)
		southbound_green <= 1'b0;
	else
		southbound_green <= 1'b1;

// eastbound states
always @ *
	if ((state_3 | state_4a | state_4 | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		eastbound_red <= 1'b0;
	else
		eastbound_red <= 1'b1;

always @ *
	if ((state_2) == 1'b1)
		eastbound_amber <= 1'b0;
	else
		eastbound_amber <= 1'b1;

always @ *
	if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
		eastbound_green <= 1'b0;
	else
		eastbound_green <= 1'b1;

// westbound states
always @ *
	if ((state_3 | state_4a | state_4 | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		westbound_red <= 1'b0;
	else
		westbound_red <= 1'b1;

always @ *
	if ((state_2) == 1'b1)
		westbound_amber <= 1'b0;
	else
		westbound_amber <= 1'b1;

always @ *
	if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
		westbound_green <= 1'b0;
	else
		westbound_green <= 1'b1;

// free left state
always @ *
	if (state_4a == 1'b1)
		southbound_free_left <= 2'd0;
	else
		southbound_free_left <= 2'd3;

// northbound crossing
always @ *
	if ((state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_5 | state_6) == 1'b1)
		northbound_crossing <= 6'b100000;
	else if (state_4w == 1'b1)
		// northbound ped_req
		northbound_crossing <= 6'b011111;
	else if (state_4fd == 1'b1 && clk == 1'b1) 
		// flashing northbound don't walk
		northbound_crossing <= 6'b100000;
	else
		northbound_crossing <= 6'b111111;

// southbound crossing
always @ *
	if ((state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_5 | state_6) == 1'b1)
		southbound_crossing <= 6'b100000;
	else if (state_4w == 1'b1)
		// southbound ped_req
		southbound_crossing <= 6'b011111;
	else if (state_4fd == 1'b1 && clk == 1'b1) 
		// flashing southbound don't walk
		southbound_crossing <= 6'b100000;
	else
		southbound_crossing <= 6'b111111;

// eastbound crossing
always @ *
	if ((state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_4w | state_4fd | state_5 | state_6) == 1'b1)	
		eastbound_crossing <= 6'b100000;
	else if (state_1w == 1'b1)
		// eastbound ped_req
		eastbound_crossing <= 6'b011111;
	else if (state_1fd == 1'b1 && clk == 1'b1) 
		// flashing eastbound don't walk
		eastbound_crossing <= 6'b100000;
	else
		eastbound_crossing <= 6'b111111;

// westbound crossing
always @ *
	if ((state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_4w | state_4fd | state_5 | state_6) == 1'b1)	
		westbound_crossing <= 6'b100000;
	else if (state_1w == 1'b1)
		// westbound ped_req
		westbound_crossing <= 6'b011111;
	else if (state_1fd == 1'b1 && clk == 1'b1) 
		// flashing westbound don't walk
		westbound_crossing <= 6'b100000;
	else
		westbound_crossing <= 6'b111111;

endmodule
