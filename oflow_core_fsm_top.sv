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
	input logic new_frame_from_dma,
	//output logic ready_new_set, // fsm_core_top ready for new_set from DMA
	output logic ready_new_frame, // fsm_core_top ready for new_frame_from_dma from DMA
	
	
	// oflow_reg_file
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frames,
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255; We converted this to counter
	// input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255 ; we add ready_new_frame, change the FSM

	//oflow_core_fsm_fe
	input logic control_ready_new_set,
	input logic [`SET_LEN-1:0] counter_set_fe, // for counter_of_remain_bboxes in core_fsm_top
	output logic start_pe,
	output logic new_set, // will help to know if new_set in the frame is waiting
	
	//oflow_core_fsm_registration
	input logic done_pe,
	
	output logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes, // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	output logic [`SET_LEN-1:0] num_of_sets, 
	//input logic [`PE_LEN-1:0] num_of_bbox_in_last_set, // for stop_counter
	output logic [`PE_LEN-1:0] num_of_bbox_in_last_set_div_4, // for stop_counter
	output logic [`PE_LEN-1:0] num_of_bbox_in_last_set_remainder_4, // for stop_counter
	
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
//                  logics & Wires
// -----------------------------------------------------------  

localparam [`PE_LEN-1:0] PE_NUM_5_BITS= `PE_NUM;

logic start_DW_div_seq;
logic done_DW_div_seq;
logic done_DW_div_seq_prev;

logic divide_by_0;
logic [`SET_LEN-1:0] div_result, div_result_reg;
logic [`PE_LEN-1:0] rem_result, rem_result_reg;

logic [`SET_LEN-1:0]	counter_set_fe_prev;
logic done_DW_div_seq_derivative;

typedef enum {idle_st,set_variables_st, pe_st, conflict_resolve_st, write_st } sm_type; 
sm_type current_state;
sm_type next_state;


// -----------------------------------------------------------       
//                 Instantiations
// -----------------------------------------------------------  
   
   DW_div_seq # ( .a_width(`REMAIN_BBOX_LEN), .b_width(`PE_LEN) ) DW_div_seq ( .clk(clk) , .rst_n(reset_N), .hold(1'b0)
	   , .start(start_DW_div_seq), .a(num_of_bbox_in_frame),   .b(PE_NUM_5_BITS) , .complete(done_DW_div_seq), .divide_by_0(divide_by_0), .quotient(div_result), .remainder(rem_result) );
   
   

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

//assign start_DW_div_seq = new_frame_from_dma; // second option is to create a register that will raise to '1' for one cycle when moving from idle_st to set_variables_st
assign new_set = new_set_from_dma;
assign rnw_st = (current_state == write_st) ? 1'b0 : 1'b1 ;

assign num_of_sets = (rem_result) ? div_result_reg + 1 : div_result_reg;
assign num_of_bbox_in_last_set_div_4 = rem_result >> 2;
assign num_of_bbox_in_last_set_remainder_4 = rem_result[1:0];

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end

//--------------------done_DW_div_seq_next---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) done_DW_div_seq_prev <= #1 1'b0;
	else   done_DW_div_seq_prev <= #1 done_DW_div_seq;
	
end

//--------------------done_DW_div_seq_derivative---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) done_DW_div_seq_derivative <= #1 1'b0;
	else  if(done_DW_div_seq == 1'b1 && done_DW_div_seq_prev == 1'b0) done_DW_div_seq_derivative <= #1 1'b1;
	else done_DW_div_seq_derivative <= #1 1'b0;
	
end	

//--------------------div_result_reg---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) div_result_reg <= #1 0;
	else begin 
		if (current_state ==  idle_st ) div_result_reg <= #1 0;
		else  if( current_state == set_variables_st && next_state == pe_st) div_result_reg <= #1 div_result;
	end 
 end	

//--------------------rem_result_reg---------------------------------	

/*always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N  ) rem_result_reg <= #1 0;
	else begin 
		if (current_state ==  idle_st ) rem_result_reg <= #1 0;
		else  if( current_state == set_variables_st && next_state == pe_st) rem_result_reg <= #1 rem_result;
	end 
 end	
 
//--------------------counter_set_fe_prev---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N  ) counter_set_fe_prev <= #1 0;
		 else begin 
			 if (current_state ==  set_variables_st ) counter_set_fe_prev <= #1 0;
			 else  if( current_state == pe_st) counter_set_fe_prev <= #1 counter_set_fe ;
		 end 
	  end	
	  */
//--------------------counter_of_remain_bboxes---------------------------------	

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N  ) counter_of_remain_bboxes <= #1 num_of_bbox_in_frame;
		 else begin 
			 if (current_state ==  set_variables_st ) counter_of_remain_bboxes <= #1 num_of_bbox_in_frame;
			 else if (current_state ==  pe_st && control_ready_new_set && counter_of_remain_bboxes >= `PE_NUM) counter_of_remain_bboxes <= #1 counter_of_remain_bboxes - `PE_NUM; 
		 end 
	  end

//--------------------frame_num---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N ) frame_num <= #1 0;
		 else begin 
			 if ((current_state ==  idle_st && start == 1) || (current_state == conflict_resolve_st && next_state == idle_st)) frame_num <= #1 0;
			 else if (current_state ==  write_st  && next_state == idle_st) frame_num <= #1 frame_num + 1;
		 end 
	  end

 //--------------------start_DW_div_seq---------------------------------	

 
 always_ff @(posedge clk or negedge reset_N) begin
	 if (!reset_N ) start_DW_div_seq <= #1 1'b0;
	 else if (current_state ==  idle_st && next_state == set_variables_st) start_DW_div_seq <= #1  1'b1;
	 else start_DW_div_seq <= #1 1'b0;
  end

 /*
 //--------------------ready_new_set---------------------------------	

 
 always_ff @(posedge clk or negedge reset_N) begin
	 if (!reset_N ) ready_new_set <= #1 1'b0;
//	 else if (( current_state ==  set_variables_st && next_state == pe_st) || ( counter_set_fe != counter_set_fe_prev && counter_of_remain_bboxes >= `PE_NUM)) ready_new_set <= #1 1'b1;
	 else if (( counter_set_fe != counter_set_fe_prev && counter_of_remain_bboxes >= `PE_NUM)) ready_new_set <= #1 1'b1;
	 else ready_new_set <= #1 1'b0;  
 end
 
 //--------------------valid_id---------------------------------	

*/
 
 always_ff @(posedge clk or negedge reset_N) begin
	 if (!reset_N  ) valid_id <= #1 1'b0;
	 else begin 
		 if (current_state ==  idle_st ) valid_id <= #1 1'b0;
		 else if (current_state != write_st && next_state == write_st) valid_id <= #1  1'b1;
		 else valid_id <= #1 1'b0;  
	 end 	 
  end
		
		
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 start_pe = 1'b0; 
	 //new_set = 1'b0;
	 //ready_new_set = 1'b0;
	 start_cr = 1'b0;
	 //start_write_score = 1'b0;
	 start_write_mem = 1'b0;
	 ready_new_frame = 1'b0;
	 //valid_id = 1'b0;
	
	 case (current_state)
		 idle_st: begin
			 ready_new_frame = 1'b1;
			 next_state = (start | new_frame_from_dma) ? set_variables_st: idle_st;	
			 
		 end
		 
		 set_variables_st: begin
			 
			//num_of_sets =  (num_of_bbox_in_frame%PE_NUM) ? num_of_bbox_in_frame/PE_NUM + 1: num_of_bbox_in_frame/PE_NUM;
			//num_of_sets = (rem_result) ? div_result + 1: div_result;
			//num_of_bbox_in_last_set_div_4 = rem_result >> 2;
			//num_of_bbox_in_last_set_remainder_4 = rem_result[1:0];
			if(done_DW_div_seq_derivative) begin
				start_pe = 1;
				//ready_new_set = 1'b1;
				next_state = pe_st;
			end
			
		 end
		 
 
		pe_st: begin 
			
				//if ( counter_set_fe != counter_set_fe_prev &&  counter_of_remain_bboxes >= `PE_NUM)
					//ready_new_set = 1'b1;
				if( done_pe && frame_num == 0) begin
					start_write_mem =1'b1;
					//start_write_score = 1'b1 ;
					next_state = write_st;
					//valid_id = 1'b1;
				end	
				else if  (done_pe && frame_num != 0) begin
					start_cr = 1'b1;
					next_state = conflict_resolve_st;
				end	
 
		end
		
		conflict_resolve_st: begin

			if(conflict_counter_th)
				next_state = idle_st;
			else if(done_cr ) begin
				start_write_mem = 1'b1;
				//start_write_score = 1'b1;
				next_state = write_st;
				//valid_id = 1'b1;

			end
			
				
		end	

		write_st: begin
			
			/*done_all_frames =  (frame_num == num_of_total_frames);
			if(new_frame_from_dma && done_write) begin
				next_state = set_variables_st;
			end	
			else if (done_all_frames && done_write) begin
				next_state = idle_st;
			end	
			*/
			if(done_write) begin
				//ready_new_frame = 1'b1;
				next_state = idle_st;
			end	
			
		end			
		 
	 endcase
 end
		 
	 
endmodule