/*------------------------------------------------------------------------------
 * File          : oflow_registration_fsm_score_calc.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 27, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
 
 
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_registration_fsm_score_calc #() (

	input logic clk,
	input logic reset_N,
	//from core
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	input logic [`SET_LEN-1:0] num_of_sets, 

	//fsm core registration
	input logic start_registration,// 
	input logic not_start_registration,
	//score calc
	input logic done_score_calc,
	output logic start_score_calc,

	//to score board
	output logic [`SET_LEN-1:0] counter_of_sets

);



// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
typedef enum {idle_st,score_calc_st, wait_st } sm_type; 
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
		 if (!reset_N ) counter_of_sets <= #1 0;
		 else begin
			if (current_state ==  idle_st ) counter_of_sets <= #1 0;
		 	else  if( current_state == wait_st && next_state==score_calc_st) counter_of_sets <= #1 counter_of_sets+1 ;
		 end 
	  end	

		 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 start_score_calc = 1'b0;
	
	 case (current_state)
		 idle_st: begin
		 
			if (start_registration && frame_num != 0) begin
				next_state = score_calc_st; 
				
			end 
			 
		 end
		 
		 score_calc_st: begin
			
			next_state = wait_st;
			start_score_calc = 1'b1; 
		 end
		 
 
		wait_st: begin 
			
			//if ( done_score_calc && counter_of_sets < num_of_sets - 1) begin 
			if (start_registration) begin
				next_state = score_calc_st;
			end
			else if ( (done_score_calc && counter_of_sets == num_of_sets - 1) || not_start_registration) begin 
					next_state = idle_st;
			end 


		end
		
			
		 
	 endcase
 end
		 
	 
endmodule