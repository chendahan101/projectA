/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"



module oflow_core_fsm_fe #() (


	input logic clk,
	input logic reset_N ,
	
	//fsm_core_top
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic start_pe,
	input logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes, // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	input logic new_set, // will help to know if new_set in the frame is waiting
	//output logic [`SET_LEN] counter_set_fe - need to check if need this because we draw it in module but we forgot
	output logic [`SET_LEN-1:0] counter_set_fe; // for counter_of_remain_bboxes in core_fsm_top
	
	//oflow_core_fsm_registration
	input logic done_registration,
	output logic done_fe, // done_fe of all fe's in use
	
	
	// pe's
	input logic done_fe_i [`PE_NUM],
	output logic start_fe_i [`PE_NUM]
	
	
);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  


logic generate_done_fe;
	
typedef enum {idle_st,fe_st,wait_st} sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign done_fe = generate_done_fe;


// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter_fe---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st ) counter_set_fe <= #1 0;
		 else if (cur_state ==  wait_st && next_state == fe_st) counter_set_fe <= #1 counter_set_fe + 1;
		 
	  end

	 	 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 generate_done_fe = 1'b0; 
	 start_fe_i = 1'b0;

	 case (current_state)
		 idle_st: begin
			 next_state = start_pe ? fe_st: idle_st;	
			 
		 end
		 
		 fe_st: begin
			 
			 if((counter_set_fe < num_of_sets)&& new_set) begin
				
				//if( counter_of_remain_bboxes < `PE_NUM )
				if( counter_set_fe == num_of_sets - 1 )
					start_fe_i = {`PE_NUM{1'b1}} >> (`PE_NUM-counter_of_remain_bboxes);
				else start_fe_i = {`PE_NUM{1'b1}};
				next_state = wait_st;
			end
		
			else next_state = idle_st;
			
		 end
		 
 
		wait_st: begin 
			
				if( counter_set_fe == num_of_sets - 1 )
					generate_done_fe = (start_fe_i[counter_of_remain_bboxes-1:0] == done_fe_i[counter_of_remain_bboxes-1:0]);
				else generate_done_fe = ( done_fe_i == {`PE_NUM{1'b1}} );
				
				if ( generate_done_fe && ( done_registration || counter_set_fe == 1'b0) ) begin
			     next_state = fe_st;
				end
		end
		
		 
	 endcase
 end
		 
	 
endmodule