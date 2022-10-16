module traffic_light_controller (
 input wire clk_27, debug, reset,left_turn_request, walk_NS_request,walk_EW_request,
 output reg northbound_green,southbound_green,eastbound_green,westbound_green,northbound_amber,southbound_amber,eastbound_amber,westbound_amber,northbound_red,southbound_red,eastbound_red,westbound_red,
 output reg [1:0] southbound_left_turn,
 output reg northbound_walk_w ,southbound_walk_w,eastbound_walk_w ,westbound_walk_w,northbound_walk_fd,southbound_walk_fd,eastbound_walk_fd ,westbound_walk_fd,
 output reg [4:0] northbound_walk_d,southbound_walk_d,eastbound_walk_d ,westbound_walk_d 

 
 );
 
 
 
reg [23:0] clock_divider_counter, clock_divider_constant;
reg [5:0] timer;
reg clk, state_1_d, state_2_d, state_3_d ,state_4a_d,  state_4_d, state_5_d, state_6_d, state_1, state_2, state_3 ,state_4a ,state_4 , state_5, state_6,entering_state_1, entering_state_2, entering_state_3, entering_state_4a, entering_state_4, entering_state_5, entering_state_6,staying_in_state_1, staying_in_state_2, staying_in_state_3, staying_in_state_4a, staying_in_state_4, staying_in_state_5, staying_in_state_6;
reg left_turn_request_d, walk_NS_request_d,walk_EW_request_d;

reg state_4w, state_4w_d, state_4fd, state_4fd_d, state_4d, state_4d_d, state_1w, state_1w_d, state_1fd, state_1fd_d, state_1d, state_1d_d;
reg entering_state_4w,staying_in_state_4w,entering_state_4fd,staying_in_state_4fd,entering_state_4d,staying_in_state_4d,entering_state_1w,staying_in_state_1w,entering_state_1fd,staying_in_state_1fd,entering_state_1d,staying_in_state_1d;

// debug switch to make the clock run faster to debud
always @ *
if (debug == 1'd1)
clock_divider_constant<= 24'd1_350_000;
else 
clock_divider_constant<= 24'd13_350_000;

// rest key 0 to make the circuit run from begining again 
always @ (posedge clk_27)
if (reset == 1'b0)
clock_divider_counter<= 24'd1;
else if (clock_divider_counter == 24'd1)
clock_divider_counter<= clock_divider_constant;
else 
clock_divider_counter<= clock_divider_counter -24'd1;

always@ (posedge clk_27)
if (clock_divider_counter == 24'd1)
clk <= ~clk;
else 
clk <= clk;

// make signal of key 1 to go throgh d flip flop so it can work on clock 
always @(posedge clk)
if (left_turn_request == 1'b0)
left_turn_request_d = 1'b1 ;
else 
left_turn_request_d = 1'b0 ;

// make signal of key 2 to go throgh d flip flop so it can work on clock 
always @(posedge clk)
if (walk_EW_request == 1'b0)
walk_EW_request_d = 1'b1 ;
else 
walk_EW_request_d = 1'b0 ;


// make signal of key 3 to go throgh d flip flop so it can work on clock 
always @(posedge clk)
if (walk_NS_request == 1'b0)
walk_NS_request_d = 1'b1 ;
else 
walk_NS_request_d = 1'b0 ;



 // make the state 1w flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_1w<= 1'b0;
else
state_1w <= state_1w_d;


//logic for entering state 1w
always @ *
if( (state_6 == 1'b1) && (walk_EW_request_d == 1'd1) && (timer == 6'd1 ))
entering_state_1w <= 1'b1;
else
entering_state_1w <= 1'b0;


//logic for staying in state 1w
always @ *
if( (state_1w == 1'b1) && (timer != 6'd1) )
staying_in_state_1w <= 1'b1;
else
staying_in_state_1w <= 1'b0;


// make the d-input for state_1w flip/flop
always @ *
if( entering_state_1w == 1'b1 )           // enter state 1w on next posedge clk
state_1w_d <= 1'b1;
else if ( staying_in_state_1w== 1'b1)  // stay in state 1w on next posedge clk
state_1w_d <= 1'b1;
else                                    // not in state 1w on next posedge clk
state_1w_d <= 1'b0;
 
 
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 1fd flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_1fd<= 1'b0;
else
state_1fd <= state_1fd_d;


//logic for entering state 1fd
always @ *
if ((state_1w == 1'b1) && (timer == 6'd1) )
entering_state_1fd <= 1'b1;
else
entering_state_1fd <= 1'b0;


//logic for staying in state 1fd
always @ *
if( (state_1fd == 1'b1) && (timer != 6'd1) )
staying_in_state_1fd <= 1'b1;
else
staying_in_state_1fd <= 1'b0;


// make the d-input for state_1fd flip/flop
always @ *
if( entering_state_1fd == 1'b1 )           // enter state 4fd on next posedge clk
state_1fd_d <= 1'b1;
else if ( staying_in_state_1fd == 1'b1)  // stay in state 4fd on next posedge clk
state_1fd_d <= 1'b1;
else                                    // not in state 4fd on next posedge clk
state_1fd_d <= 1'b0;
 
 
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 1d flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_1d<= 1'b0;
else
state_1d <= state_1d_d;


//logic for entering state 1d
always @ *
if ((state_1fd == 1'b1) && (timer == 6'd1) )
entering_state_1d <= 1'b1;
else
entering_state_1d <= 1'b0;


//logic for staying in state d
always @ *
if( (state_1d == 1'b1) && (timer != 6'd1) )
staying_in_state_1d <= 1'b1;
else
staying_in_state_1d <= 1'b0;


// make the d-input for state_1d flip/flop
always @ *
if( entering_state_1d == 1'b1 )           // enter state 1d on next posedge clk
state_1d_d <= 1'b1;
else if ( staying_in_state_1d == 1'b1)  // stay in state 1d on next posedge clk
state_1d_d <= 1'b1;
else                                    // not in state 1d on next posedge clk
state_1d_d <= 1'b0;



 //////////////////////////////////////////////////////////////////////////////////////////////////
 
 // make the state 1 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_1 <= 1'b1;
else
state_1 <= state_1_d;


//logic for entering state 1
always @ *
if( (state_6== 1'b1) && (timer == 6'd1) && ( walk_EW_request == 1'b1 ))
entering_state_1 <= 1'b1;
else
entering_state_1 <= 1'b0;


//logic for staying in state 1
always @ *
if( (state_1 == 1'b1) && (timer != 6'b1) )
staying_in_state_1<= 1'b1;
else
staying_in_state_1 <= 1'b0;


// make the d-input for state_1 flip/flop
always @ *
if( entering_state_1== 1'b1 )           // enter state 1 on next posedge clk
state_1_d <= 1'b1;
else if ( staying_in_state_1== 1'b1)  // stay in state 1 on next posedge clk
state_1_d <= 1'b1;
else                                    // not in state 1 on next posedge clk
state_1_d <= 1'b0;
 
 
 
 ////////////////////////////////////////////////////////////////////////////////////////////////////
 
  // make the state 2 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_2<= 1'b0;
else
state_2 <= state_2_d;


//logic for entering state 2
always @ *
if(( (state_1 == 1'b1) || (state_1d == 1'b1)) && (timer == 6'd1) )
entering_state_2 <= 1'b1;
else
entering_state_2 <= 1'b0;


//logic for staying in state 2
always @ *
if( (state_2 == 1'b1) && (timer != 6'd1) )
staying_in_state_2<= 1'b1;
else
staying_in_state_2 <= 1'b0;


// make the d-input for state_2flip/flop
always @ *
if( entering_state_2== 1'b1 )           // enter state 2on next posedge clk
state_2_d <= 1'b1;
else if ( staying_in_state_2== 1'b1)  // stay in state 2 on next posedge clk
state_2_d <= 1'b1;
else                                    // not in state 2 on next posedge clk
state_2_d <= 1'b0;
 
 
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
   // make the state 3 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_3<= 1'b0;
else
state_3 <= state_3_d;


//logic for entering state 3
always @ *
if( (state_2 == 1'b1) && (timer == 6'd1) )
entering_state_3<= 1'b1;
else
entering_state_3 <= 1'b0;


//logic for staying in state 3
always @ *
if( (state_3 == 1'b1) && (timer != 6'd1) )
staying_in_state_3<= 1'b1;
else
staying_in_state_3 <= 1'b0;


// make the d-input for state_3flip/flop
always @ *
if( entering_state_3== 1'b1 )           // enter state 3 on next posedge clk
state_3_d <= 1'b1;
else if ( staying_in_state_3== 1'b1)  // stay in state 3 on next posedge clk
state_3_d <= 1'b1;
else                                    // not in state 3on next posedge clk
state_3_d <= 1'b0;
 
 ////////////////////////////////////////////////////////////////////////////////////////////////
  
 
   // make the state 4a flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_4a<= 1'b0;
else
state_4a <= state_4a_d;


//logic for entering state 4a
always @ *
if( (state_3 == 1'b1) && (left_turn_request_d == 6'd1) && (timer == 6'd1 ))
entering_state_4a <= 1'b1;
else
entering_state_4a <= 1'b0;


//logic for staying in state 4a
always @ *
if( (state_4a == 1'b1) && (timer != 6'd1) )
staying_in_state_4a <= 1'b1;
else
staying_in_state_4a <= 1'b0;


// make the d-input for state_4a flip/flop
always @ *
if( entering_state_4a == 1'b1 )           // enter state 4n next posedge clk
state_4a_d <= 1'b1;
else if ( staying_in_state_4a== 1'b1)  // stay in state 4on next posedge clk
state_4a_d <= 1'b1;
else                                    // not in state 4 on next posedge clk
state_4a_d <= 1'b0;

 ////////////////////////////////////////////////////////////////////////////////////////////////
  
 
   // make the state 4w flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_4w<= 1'b0;
else
state_4w <= state_4w_d;


//logic for entering state 4w
always @ *
if( ((state_3 == 1'b1) ||(state_4a == 1'b1)) && (walk_NS_request_d == 6'd1) && (timer == 6'd1 ))
entering_state_4w <= 1'b1;
else
entering_state_4w <= 1'b0;


//logic for staying in state 4w
always @ *
if( (state_4w == 1'b1) && (timer != 6'd1) )
staying_in_state_4w <= 1'b1;
else
staying_in_state_4w <= 1'b0;


// make the d-input for state_4w flip/flop
always @ *
if( entering_state_4w == 1'b1 )           // enter state 4n next posedge clk
state_4w_d <= 1'b1;
else if ( staying_in_state_4w== 1'b1)  // stay in state 4on next posedge clk
state_4w_d <= 1'b1;
else                                    // not in state 4 on next posedge clk
state_4w_d <= 1'b0;
 
 
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 4fd flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_4fd<= 1'b0;
else
state_4fd <= state_4fd_d;


//logic for entering state 4fd
always @ *
if ((state_4w == 1'b1) && (timer == 6'd1) )
entering_state_4fd <= 1'b1;
else
entering_state_4fd <= 1'b0;


//logic for staying in state 4fd
always @ *
if( (state_4fd == 1'b1) && (timer != 6'd1) )
staying_in_state_4fd <= 1'b1;
else
staying_in_state_4fd <= 1'b0;


// make the d-input for state_4fd flip/flop
always @ *
if( entering_state_4fd == 1'b1 )           // enter state 4fd on next posedge clk
state_4fd_d <= 1'b1;
else if ( staying_in_state_4fd == 1'b1)  // stay in state 4fd on next posedge clk
state_4fd_d <= 1'b1;
else                                    // not in state 4fd on next posedge clk
state_4fd_d <= 1'b0;
 
 
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 4d flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_4d<= 1'b0;
else
state_4d <= state_4d_d;


//logic for entering state 4d
always @ *
if ((state_4fd == 1'b1) && (timer == 6'd1) )
entering_state_4d <= 1'b1;
else
entering_state_4d <= 1'b0;


//logic for staying in state 4d
always @ *
if( (state_4d == 1'b1) && (timer != 6'd1) )
staying_in_state_4d <= 1'b1;
else
staying_in_state_4d <= 1'b0;


// make the d-input for state_4d flip/flop
always @ *
if( entering_state_4d == 1'b1 )           // enter state 4d on next posedge clk
state_4d_d <= 1'b1;
else if ( staying_in_state_4d == 1'b1)  // stay in state 4d on next posedge clk
state_4d_d <= 1'b1;
else                                    // not in state 4d on next posedge clk
state_4d_d <= 1'b0;
 
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 4 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_4<= 1'b0;
else
state_4 <= state_4_d;


//logic for entering state 4
always @ *
if (((state_3 == 1'b1) && (timer == 6'd1) && (left_turn_request == 6'd1) && (walk_NS_request == 1'b1))|| (((state_4a) == 1'b1)&& (walk_NS_request == 1'b1) && (timer == 6'd1)) )
entering_state_4 <= 1'b1;
else
entering_state_4 <= 1'b0;


//logic for staying in state 4
always @ *
if( (state_4 == 1'b1) && (timer != 6'd1) )
staying_in_state_4<= 1'b1;
else
staying_in_state_4 <= 1'b0;


// make the d-input for state_4flip/flop
always @ *
if( entering_state_4== 1'b1 )           // enter state 4n next posedge clk
state_4_d <= 1'b1;
else if ( staying_in_state_4== 1'b1)  // stay in state 4on next posedge clk
state_4_d <= 1'b1;
else                                    // not in state 4 on next posedge clk
state_4_d <= 1'b0;
 
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
   // make the state 5 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_5= 1'b0;
else
state_5 <= state_5_d;


//logic for entering state 5
always @ *
if(( (state_4 == 1'b1) && (timer == 6'd1) ) || (state_4d == 1'b1) && (timer == 6'd1))
entering_state_5 <= 1'b1;
else
entering_state_5 <= 1'b0;


//logic for staying in state 5
always @ *
if( (state_5 == 1'b1) && (timer != 6'd1) )
staying_in_state_5<= 1'b1;
else
staying_in_state_5<= 1'b0;


// make the d-input for state_5lip/flop
always @ *
if( entering_state_5== 1'b1 )           // enter state 5 on next posedge clk
state_5_d <= 1'b1;
else if ( staying_in_state_5== 1'b1)  // stay in state 5 on next posedge clk
state_5_d <= 1'b1;
else                                    // not in state 5 on next posedge clk
state_5_d <= 1'b0;
 
 //////////////////////////////////////////////////////////////////////////////////////////
 
 
   // make the state 6 flip flop
always @ (posedge clk or negedge reset)
if (reset == 1'b0) // keys are active low
state_6<= 1'b0;
else
state_6 <= state_6_d;


//logic for entering state 6
always @ *
if( (state_5 == 1'b1) && (timer == 6'd1) )
entering_state_6 <= 1'b1;
else
entering_state_6 <= 1'b0;


//logic for staying in state 6
always @ *
if( (state_6 == 1'b1) && (timer != 6'd1) )
staying_in_state_6<= 1'b1;
else
staying_in_state_6 <= 1'b0;


// make the d-input for state_6flip/flop
always @ *
if( entering_state_6== 1'b1 )           // enter state 6 on next posedge clk
state_6_d <= 1'b1;
else if ( staying_in_state_6== 1'b1)  // stay in state 6 on next posedge clk
state_6_d <= 1'b1;
else                                    // not in state 6 on next posedge clk
state_6_d <= 1'b0;
 
 ////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
 
 
 
 
 
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////  
 
  
 
 
 
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

 
 
 
 
 
 
 
 
 
 
 always @ (posedge clk or negedge reset)
if (reset == 1'b0)
timer <= 6'd60; // time for state 1
else if (entering_state_1w == 1'b1)
timer <= 6'd10; // time for state 1w
else if (entering_state_1fd == 1'b1)
timer <= 6'd20; // time for state 1fd
else if (entering_state_1d == 1'b1)
timer <= 6'd30; // time for state 1d
else if (entering_state_1 == 1'b1)
timer <= 6'd60; // time for state 1
else if (entering_state_2 == 1'b1)
timer <= 6'd6;// time for state 2
else if (entering_state_3 == 1'b1)
timer <= 6'd2;// time for state 3
else if (entering_state_4a == 1'b1)
timer <= 6'd20;// time for state 4a
else if (entering_state_4w == 1'b1)
timer <= 6'd10; // time for state 4w
else if (entering_state_4fd == 1'b1)
timer <= 6'd20; // time for state 4fd
else if (entering_state_4d == 1'b1)
timer <= 6'd30; // time for state 4d
else if (entering_state_4 == 1'b1)
timer <= 6'd60;// time for state 4
else if (entering_state_5== 1'b1)
timer <= 6'd6;// time for state 5
else if (entering_state_6 == 1'b1)
timer <= 6'd2;// time for state 6
else if (timer == 6'd1)
timer <= timer; // never decrement below 1
else
timer <= timer - 6'd1;
////////////////////////////////////////////////////////////////////////////
// conditions for eastbound red
always @ *
if ( (state_3 | state_4a | state_4 | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1 ) 
eastbound_red <= 1'b0;
else 
eastbound_red <= 1'b1; 
 
 // conditions for eastbound green
 always @*
 if (( state_1 | state_1w | state_1fd | state_1d)  == 1'b1)
 eastbound_green <= 1'b0;
 else
 eastbound_green <= 1'b1;

 // conditions for eastbound amber
 always @*
 if (state_2 == 1'b1)
 eastbound_amber <= 1'b0;
 else
 eastbound_amber <= 1'b1;
////////////////////////////////////////////////////////////////////////////
// conditions for west bound red
always @ *
if ( (state_3 | state_4a | state_4 | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1 ) 
westbound_red <= 1'b0;
else 
westbound_red <= 1'b1;
  
 // conditions for west bound green
 always @*
 if (( state_1 | state_1w | state_1fd | state_1d)  == 1'b1)
 westbound_green <= 1'b0;
 else
 westbound_green <= 1'b1;

 // conditions for westbound amber
 always @*
 if (state_2 == 1'b1)
 westbound_amber <= 1'b0;
 else
 westbound_amber <= 1'b1;
////////////////////////////////////////////////////////////////////////////
// conditions for north bound red
always @ *
if ( (state_1 | state_1w | state_1fd | state_1d| state_2 | state_3 | state_4a | state_6) == 1'b1 ) 
northbound_red <= 1'b0;
else 
northbound_red <= 1'b1;
  
// conditions for north bound green
always @*
if ((state_4 | state_4w | state_4fd | state_4d ) == 1'b1)
northbound_green <= 1'b0;
else
northbound_green <= 1'b1;

// conditions for north bound amber
always @*
if (state_5 == 1'b1)
northbound_amber <= 1'b0;
else
northbound_amber <= 1'b1;
////////////////////////////////////////////////////////////////////////////
// conditions for south bound red
always @ *
if ( (state_1 | state_1w | state_1fd | state_1d| state_2 | state_3 | state_6) == 1'b1 ) 
southbound_red <= 1'b0;
else 
southbound_red <= 1'b1;
  
// conditions for south bound green
always @*
if ((state_4 | state_4w | state_4fd | state_4d ) == 1'b1)
southbound_green <= 1'b0;
else
southbound_green <= 1'b1;

// conditions for south bound amber
always @*
if (state_5 == 1'b1 ||state_4a == 1'b1) 
southbound_amber <= 1'b0;
else
southbound_amber <= 1'b1;

// conditions for south bound left turn
always @*
if (state_4a == 1'b1)
southbound_left_turn  <= 2'b00;
else
southbound_left_turn  <= 2'b11;
//southbound_amber = 1'b1;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
always @*
if (state_4w == 1'b1)
	northbound_walk_w  <= 1'b0;
else 
	northbound_walk_w  <= 1'b1;
	
//always @*
//if ((state_4fd == 1'b1))
//	northbound_walk_fd  <= 1'b0;
//else 
//	northbound_walk_fd  <= 1'b1;
	
always @*
if ((state_1 | state_2 | state_3 | state_4 | state_5 | state_6 | state_1w | state_1fd | state_1d | state_4a | state_4d) == 1'b1)
	northbound_walk_d  <= 1'b0;
else if ((state_4fd == 1'b1) && (clk == 1'b1) )
	northbound_walk_d  <= 5'b0;
else 
	northbound_walk_d  <= 5'b11111;
	
////////////////////////////////////////////////////////////////////////////
always @*
if (state_1w == 1'b1)
	westbound_walk_w  <= 1'b0;
else 
	westbound_walk_w  <= 1'b1;

//always @*
//if ((state_1fd == 1'b1))
//	westbound_walk_fd  <= 1'b0;
//else 
//	westbound_walk_fd  <= 1'b1;
	
always @*
if ((state_1 | state_2 | state_3 | state_4 | state_5 | state_6 | state_4w | state_4fd | state_1d | state_4a | state_4d) == 1'b1)
	westbound_walk_d  <= 1'b0;
else if ((state_1fd == 1'b1) && (clk == 1'b1) )
	westbound_walk_d  <= 5'b0;
else 
	westbound_walk_d  <= 5'b11111;
	
////////////////////////////////////////////////////////////////////////////
always @*
if (state_1w == 1'b1)
	eastbound_walk_w  <= 1'b0;
else 
	eastbound_walk_w  <= 1'b1;

//always @*
//if ((state_1fd == 1'b1) )
//	eastbound_walk_fd  <= 1'b0;
//else 
//	eastbound_walk_fd  <= 1'b1;
	
always @*
if ((state_1 | state_2 | state_3 | state_4 | state_5 | state_6 | state_4w | state_4fd | state_1d | state_4a | state_4d) == 1'b1)
	eastbound_walk_d  <= 5'b0;
else if ((state_1fd == 1'b1) && (clk == 1'b1) )
	eastbound_walk_d  <= 5'b0;
else 
	eastbound_walk_d  <= 5'b11111;

////////////////////////////////////////////////////////////////////////////
always @*
if (state_4w == 1'b1)
	southbound_walk_w  <= 1'b0;
else 
	southbound_walk_w  <= 1'b1;

//always @*
//if ((state_4fd == 1'b1) )
//	southbound_walk_fd  <= 5'b0;
//else 
//	southbound_walk_fd  <= 1'b1;
	
always @*
if ((state_1 | state_2 | state_3 | state_4 | state_5 | state_6 | state_1w | state_1fd | state_1d | state_4a | state_4d) == 1'b1)
	southbound_walk_d  <= 5'b0;
else if ((state_4fd == 1'b1) && (clk == 1'b1) )
		southbound_walk_d  <= 5'b0;
else 
	southbound_walk_d  <= 5'b11111;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
 
 endmodule