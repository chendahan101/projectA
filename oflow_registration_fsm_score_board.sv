/*------------------------------------------------------------------------------
 * File          : oflow_registration_fsm_score_calc.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 27, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
 
 
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_registration_fsm_score_board #() (

	input logic clk,
	input logic reset_N,
	//from core
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic  start_registration,

	//fsm score calc in  registration
	input logic [`SET_LEN-1:0] counter_of_sets,

	//score calc
	input logic done_score_calc,
	
	// score board
	input logic done_score_board,
	output logic  start_score_board,

	//to fsm in registration
	output logic [`SET_LEN-1:0] counter_first_frame_sets


);



// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
typedef enum {idle_st,score_board_st, wait_st,score_board_first_frame_st,wait_first_frame_st } sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
	
//--------------------counter_set_fe_prev---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_first_frame_sets <= #1 0;
		 else  if( current_state == wait_first_frame_st && next_state==score_board_first_frame_st) counter_first_frame_sets <= #1 counter_first_frame_sets+1 ;
		 
	  end	

		 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	next_state = current_state;
	start_score_board  = 1'b0;
	 case (current_state)
		 idle_st: begin
		 
			if (done_score_calc && frame_num != 0) begin
				next_state = score_board_st; 
				start_score_board = 1'b1; 
			end 
			else if (start_registration && frame_num == 0 ) begin 
				next_state = score_board_first_frame_st;
				//start_score_board = 1'b1;
			end 
			 
		 end
		 
		 score_board_st: begin
		
			 //start_score_board = 1'b1;		
			if (counter_of_sets == num_of_sets) next_state = idle_st;
			else next_state = wait_st;

			
		 end
		 
 
		wait_st: begin 
			
			if (done_score_calc) begin
				next_state = score_board_st; 
				start_score_board = 1'b1; 
			end
		end	
		
		score_board_first_frame_st: begin 
			start_score_board = 1'b1; 
			next_state = wait_first_frame_st;
		end
		
		wait_first_frame_st: begin 
			if (done_score_board && counter_first_frame_sets < num_of_sets-1) begin 
				//start_score_board  =1'b1;
				next_state = score_board_first_frame_st;
			end
			else if (done_score_board && counter_first_frame_sets == num_of_sets-1) next_state = idle_st;
								
		end

		
		
			
		 
	 endcase
 end
		 
	 
endmodule