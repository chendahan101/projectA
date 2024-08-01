/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`define SET_LEN 4 //The maximum sets: 256/PE_NUM=11, need 4 bits: 2^4 = 16 > 11
`define PE_NUM 24

module oflow_core_fsm_read #() (


	input logic clk,
	input logic reset_N,
	
	// global inputs
	
	
	//fsm_core_top
	input logic [`SET_LEN-1:0] num_of_sets, // for stop_counter
	input logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes, // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	
	
	//control signals
	input logic done_read, // from fsm buffer read
	input logic done_registration, // from registration (after set done)
	input logic start_read_mem_for_first_set, //its not enough to know that this is the first set of the frame, we also need to know that the similarity_metric is starting
	input logic control_for_read_new_line [`PE_NUM],//from all similarity_metrics (to read new line)

	
	output logic start_read, // send from fsm core to fsm buffer read
	output logic read_new_line //send from fsm core to fsm buffer read
	
	// core_fsm_registration
	input logic [`SET_LEN-1:0] counter_set_registration;
	
);





// -----------------------------------------------------------       
//                  logics & Wires
// -----------------------------------------------------------  

logic [`SET_LEN-1:0] counter_set;
logic [`SET_LEN-1:0] stop_counter;

	
typedef enum {idle_st,start_read_st, end_read_st} sm_type; //select_pe0_st is that the remainder with 4 of the #bboxes%22 is 0, ...
sm_type current_state;
sm_type next_state;




// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter_set---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_set <= #1 0;
		 else if (next_state == end_read_st && cur_state == start_read_st) counter_set <= #1 counter_set + 1;
		 
	  end

// ----------------start_read----------------------------------
	  always_ff @(posedge clk or negedge reset_N) begin 
	  
		 if (next_state == start_read_st && (cur_state == idle_st || cur_state == end_read) ) start_read <= #1 1;
		 else start_read <= #1 0;
		 
	  end
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	// start_read = 0; // send to fsm buffer

	 case (current_state)
		 idle_st: begin
			 //start_read = start_read_mem_for_first_set  ? 1: 0;	
			 next_state = start_read_mem_for_first_set  ? start_read_st: idle_st;	
			 
		 end
		 
		 start_read_st: begin
			 
			 if( done_read )	next_state = end_read;

		 end
		 
 
		end_read_st: begin 
		
			stop_counter = num_of_sets;
			 if (counter_set < stop_counter && done_registration) begin 
				 next_state = start_read_st;
			end
			else if(counter_set == stop_counter) next_state = idle_st;			

		 end
		 
	 endcase
 end
	  
// assignments
	always_comb begin
		if( counter_set_registration == num_of_sets - 1 )
					read_new_line = ( {`PE_NUM{1'b1}}[counter_of_remain_bboxes-1:0] == control_for_read_new_line[counter_of_remain_bboxes-1:0]);
		else read_new_line = ( control_for_read_new_line == {`PE_NUM{1'b1}} );	
	end
	
	 
	 
endmodule
