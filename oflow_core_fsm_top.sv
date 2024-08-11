/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_top.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"



module oflow_core_fsm_top #() (


	input logic clk,
	input logic reset_N ,
	
	// globals inputs and outputs
	input logic start, // from top
	input logic new_set_from_dma, // dma ready with new feature extraction set
	input logic new_frame,
	output logic ready_new_set, // fsm_core_top ready for new_set from DMA
	output logic ready_new_frame, // fsm_core_top ready for new_frame from DMA
	
	
	// oflow_reg_file
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frames,
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255; We converted this to counter
	// input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255 ; we add ready_new_frame, change the FSM

	//oflow_core_fsm_fe
	input logic [`SET_LEN-1:0] counter_set_fe, // for counter_of_remain_bboxes in core_fsm_top
	output logic start_pe,
	output logic new_set, // will help to know if new_set in the frame is waiting
	
	//oflow_core_fsm_registration
	input logic done_pe,
	
	output logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes, // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	output logic [`SET_LEN-1:0] num_of_sets, 
	
	
	// oflow_MEM_buffer_wrapper
	input logic done_write,
	output logic rnw_st,
	output logic start_write_mem,
	output logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	
	//oflow_conflict_resolve
	input logic done_cr, // cr: conflict resolve
	input logic conflict_counter_th,
	output logic start_cr,
	
	
	// write_score
	output logic start_write_score,

	//IDs
	output logic valid_id

);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
typedef enum {idle_st,set_variables_st, pe_st, conflict_resolve_st, write_st } sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign new_set = new_set_from_dma;
assign rnw_st = (current_state == write_st) ? 1 : 0 ;
// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
	
//--------------------counter_set_fe_prev---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  set_variables_st ) counter_set_fe_prev <= #1 0;
		 else  if( cur_state == pe_st) counter_set_fe_prev <= #1 counter_set_fe ;
		 
	  end	
//--------------------counter_of_remain_bboxes---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || current_state ==  set_variables_st ) counter_of_remain_bboxes <= #1 num_of_bbox_in_frame;
		 else if (cur_state ==  pe_st && counter_set_fe != counter_set_fe_prev) counter_of_remain_bboxes <= #1 counter_of_remain_bboxes - `PE_NUM; 
	  end

//--------------------frame_num---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || (current_state ==  idle_st && start == 1) ) frame_num <= #1 0;
		 else if (cur_state ==  write_st && next_state == set_variables_st) frame_num <= #1 frame_num + 1;
	  end
	 	 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 start_pe = 1'b0; 
	 new_set = 1'b0;
	 ready_new_set = 1'b0;
	 start_cr = 1'b0;
	 start_write_score = 1'b0;
	 start_write_mem = 1'b0;
	 ready_new_frame = 1'b0;
	 valid_id = 1'b0;
	
	 case (current_state)
		 idle_st: begin
			 next_state = (start | new_frame) ? set_variables_st: idle_st;	
			 
		 end
		 
		 set_variables_st: begin
			 
			num_of_sets =  (num_of_bbox_in_frame%PE_NUM) ? num_of_bbox_in_frame/PE_NUM + 1: num_of_bbox_in_frame/PE_NUM;
			start_pe = 1;
			ready_new_set = 1'b1;
			next_state = idle_st;
			
		 end
		 
 
		pe_st: begin 
			
				if ( counter_set_fe != counter_set_fe_prev )
					ready_new_set = 1'b1;
				if( done_pe && frame_num == 0) begin
					start_write_mem =1'b1;
					start_write_score = 1'b1 ;
					next_state = write_st;
				end	
				else if  (done_pe && frame_num != 0) begin
					start_cr = 1'b1;
					next_state = conflict_resolve_st;
				end	

		end
		
		conflict_resolve_st: begin

			if(conflict_counter_th)
				next_state = idle_st;
			 if(done_cr) begin
				start_write_mem = 1'b1;
				start_write_score = 1'b1;
				next_state = write_st;
				valid_id = 1'b1;

			end
			
				
		end	

		write_st: begin
			
			/*done_all_frames =  (frame_num == num_of_total_frames);
			if(new_frame && done_write) begin
				next_state = set_variables_st;
			end	
			else if (done_all_frames && done_write) begin
				next_state = idle_st;
			end	
			*/
			if(done_write) begin
				ready_new_frame = 1'b1;
				next_state = idle_st;
			end	
			
		end			
		 
	 endcase
 end
		 
	 
endmodule
