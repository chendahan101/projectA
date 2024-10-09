/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_fe.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 20, 2024
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
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,
	//output logic [`SET_LEN] counter_set_fe - need to check if need this because we draw it in module but we forgot
	output logic [`SET_LEN-1:0] counter_set_fe, // for counter_of_remain_bboxes in core_fsm_top
	
	//oflow_core_fsm_registration
	input logic done_registration,
	input logic done_score_calc,
	output logic done_fe, // done_fe of all fe's in use
	
	
	// pe's
	input logic [`PE_NUM-1:0] done_fe_i,
	output logic [`PE_NUM-1:0] start_fe_i,
	output logic [`PE_NUM-1:0] not_start_fe_i,
	output logic ready_new_set,
	output logic control_ready_new_set,
	
	output logic flg_for_sampling_last_set // for sampling the outputs of feature_extraction to be stable while registration
	
);



// -----------------------------------------------------------       
//                  logics
// -----------------------------------------------------------  

logic [`PE_NUM-1:0] num_of_bbox_to_compare;
logic generate_done_fe;
//logic control_ready_new_set;
logic flg_for_sampling_last_set_prev;
	
typedef enum {idle_st,fe_st,wait_st} sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign done_fe = generate_done_fe;

//assign flg_for_sampling_last_set = (current_state == idle_st);

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
		 else if (current_state ==  wait_st && next_state == fe_st) counter_set_fe <= #1 counter_set_fe + 1;
		 
	  end

 //--------------------ready_new_set---------------------------------	

 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N ) ready_new_set <= #1 1'b0;
	//	 else if (( current_state ==  set_variables_st && next_state == pe_st) || ( counter_set_fe != counter_set_fe_prev && counter_of_remain_bboxes >= `PE_NUM)) ready_new_set <= #1 1'b1;
		 else if (( control_ready_new_set && counter_of_remain_bboxes >= `PE_NUM)) ready_new_set <= #1 1'b1;
		 else ready_new_set <= #1 1'b0;  
	 end
	 
 //--------------------flg_for_sampling_last_set_prev---------------------------------	

 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  idle_st && next_state == fe_st) flg_for_sampling_last_set_prev <= #1 1'b0;
		 else if (current_state ==  wait_st && next_state == idle_st) flg_for_sampling_last_set_prev <= #1   1'b1;
		 
	  end

 //--------------------flg_for_sampling_last_set---------------------------------	

	 
		 always_ff @(posedge clk or negedge reset_N) begin
			 if (!reset_N) flg_for_sampling_last_set <= #1 1'b0;
			 else  flg_for_sampling_last_set <= #1  flg_for_sampling_last_set_prev;
			 
		  end
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 generate_done_fe = 1'b0; 
	 start_fe_i = 0;
	 not_start_fe_i = 0;
	 control_ready_new_set = 1'b0;
	 case (current_state)
		 idle_st: begin
			 next_state = start_pe ? fe_st: idle_st;	
			 
		 end
		 
		 fe_st: begin
			 
			 if((counter_set_fe < num_of_sets)&& (new_set || counter_set_fe==0) ) begin
				
				//if( counter_of_remain_bboxes < `PE_NUM )
				if( counter_set_fe == num_of_sets - 1 ) begin
					start_fe_i = {`PE_NUM{1'b1}} >> (`PE_NUM-counter_of_remain_bboxes);
					not_start_fe_i = ~ start_fe_i;
				end	
				else begin 
					start_fe_i = {`PE_NUM{1'b1}};
					//not_start_fe_i = {`PE_NUM{1'b0}};
				end	
				next_state = wait_st;
			end
		
			else if(counter_set_fe == num_of_sets) next_state = idle_st;
			
		 end
		 
 
		wait_st: begin 
			
				if( counter_set_fe == num_of_sets - 1 ) begin
					num_of_bbox_to_compare = {`PE_NUM{1'b1}} >> (`PE_NUM-counter_of_remain_bboxes);
					generate_done_fe = (num_of_bbox_to_compare == done_fe_i);
					if (generate_done_fe) begin 				
						next_state = idle_st;
					 end 
					//generate_done_fe = (start_fe_i[counter_of_remain_bboxes-1:0] == done_fe_i[counter_of_remain_bboxes-1:0]);
				end	
				else begin	
					generate_done_fe = ( done_fe_i == {`PE_NUM{1'b1}} );
					if ( (generate_done_fe && ( ( (done_registration&&frame_num==0)||(done_score_calc&&frame_num!=0) )  || counter_set_fe == 0))) begin
						control_ready_new_set =1'b1;
						next_state = fe_st;
					 end
				end
				
		end
		
		 
	 endcase
 end
		 
	 
endmodule