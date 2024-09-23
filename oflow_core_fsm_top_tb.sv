/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_top_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 20, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_core_fsm_top_tb #() ();


 		logic clk;
		 logic reset_N;
		
		// globals inputs and outputs
		 logic start;// from top
		 logic new_set_from_dma;// dma ready with new feature extraction set
		 logic new_frame_from_dma;
		 logic ready_new_set;// fsm_core_top ready for new_set from DMA
		 logic ready_new_frame; // fsm_core_top ready for new_frame_from_dma from DMA
		
		
		// oflow_reg_file
		 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frames;
		 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
		//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255; We converted this to counter
		// input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255 ; we add ready_new_frame, change the FSM

		//oflow_core_fsm_fe
		 logic [`SET_LEN-1:0] counter_set_fe; // for counter_of_remain_bboxes in core_fsm_top
		 logic start_pe;
		 logic new_set; // will help to know if new_set in the frame is waiting
		
		//oflow_core_fsm_registration
		 logic done_pe;
		
		 logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes; // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
		 logic [`SET_LEN-1:0] num_of_sets; 
		 //input logic [`PE_LEN-1:0] num_of_bbox_in_last_set, // for stop_counter
		  logic [`PE_LEN-1:0] num_of_bbox_in_last_set_div_4; // for stop_counter
		  logic [`PE_LEN-1:0] num_of_bbox_in_last_set_remainder_4; // for stop_counter
		
		// oflow_MEM_buffer_wrapper
		 logic done_write;
		 logic rnw_st;
		 logic start_write_mem;
		 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num; // counter for frame_num
		
		//oflow_conflict_resolve
		 logic done_cr; // cr: conflict resolve
		 logic conflict_counter_th;
		 logic start_cr;
		
		
		// write_score
		 logic start_write_score;

		//IDs
		 logic valid_id;
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

		 oflow_core_fsm_top oflow_core_fsm_top (.*);



// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
	// initiate	
	initiate_all ();   // Initiates all input signals to '0' and open necessary files
	#50
	@(posedge clk);
	#1
	two_frames_with_th_conflicts ();

	
	#50 $finish;  
end




// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 8ns)
// ----------------------------------------------------------------------


always begin
	#2.5 clk = ~clk;
end

// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------



task initiate_all ();        // sets all oflow inputs to '0'.
 begin   
	clk = 1'b0;
	reset_N = 1'b0;
	
	// globals inputs and outputs
	 start = 1'b0; // from top
	 new_set_from_dma = 1'b0; // dma ready with new feature extraction set
	 new_frame_from_dma =1'b0;
	
	// oflow_reg_file
	 num_of_history_frames = 0;
	 num_of_bbox_in_frame = 0; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

	//oflow_core_fsm_fe
	counter_set_fe = 0; // for counter_of_remain_bboxes in core_fsm_top

	//oflow_core_fsm_registration
	done_pe = 1'b0;
	
	// oflow_MEM_buffer_wrapper
	done_write = 1'b0;

	//oflow_conflict_resolve
	done_cr = 1'b0;
	conflict_counter_th = 1'b0;

	

	#10
	reset_N = 1'b1;
   
   
  end  
endtask


task two_frames_without_th_conflicts ();
begin
	
	// first frame : frame_num == 0
	start = 1'b1;
	new_frame_from_dma = 1'b1;
	num_of_history_frames = 3;
	num_of_bbox_in_frame = 3;
	@(posedge clk);
	#1
	start = 1'b0;
	new_frame_from_dma = 1'b0;
	repeat (3) @(posedge clk);
	new_set_from_dma = 1'b1;
	
	@(posedge clk);
	new_set_from_dma = 1'b0;
	
	repeat (3) @(posedge clk);
	
	done_pe = 1'b1;
	@(posedge clk);
	done_pe = 1'b0;
	repeat (3) @(posedge clk);
	done_write = 1'b1;
	@(posedge clk);
	done_write = 1'b0;


	// second frame : frame_num == 1
	//start = 1'b1;
	new_frame_from_dma = 1'b1;
	num_of_history_frames = 3;
	num_of_bbox_in_frame = 36;
	@(posedge clk);
	start = 1'b0;
	new_frame_from_dma = 1'b0;
	repeat (3) @(posedge clk);
	new_set_from_dma = 1'b1;
	@(posedge clk);
	counter_set_fe = 0;
	new_set_from_dma = 1'b0;
	repeat (26) @(posedge clk);
	new_set_from_dma = 1'b1;
	@(posedge clk);
	counter_set_fe = 1;
	new_set_from_dma = 1'b0;
	repeat (26) @(posedge clk);
	counter_set_fe = 2;
	@(posedge clk);
	counter_set_fe = 0;
	done_pe = 1'b1;
	@(posedge clk);
	done_pe = 1'b0;
	repeat (20) @(posedge clk);
	done_cr = 1'b1;
	@(posedge clk);
	done_cr = 1'b0;
	
	repeat (20) @(posedge clk);
	done_write = 1'b1;
	@(posedge clk);
	done_write = 1'b0;
   
		
end  
endtask


task two_frames_with_th_conflicts ();
	begin
		
		// first frame : frame_num == 0
		start = 1'b1;
		new_frame_from_dma = 1'b1;
		num_of_history_frames = 3;
		num_of_bbox_in_frame = 3;
		@(posedge clk);
		#1
		start = 1'b0;
		new_frame_from_dma = 1'b0;
		repeat (3) @(posedge clk);
		new_set_from_dma = 1'b1;
		
		@(posedge clk);
		new_set_from_dma = 1'b0;
		
		repeat (3) @(posedge clk);
		
		done_pe = 1'b1;
		@(posedge clk);
		done_pe = 1'b0;
		repeat (3) @(posedge clk);
		done_write = 1'b1;
		@(posedge clk);
		done_write = 1'b0;


		// second frame : frame_num == 1
		//start = 1'b1;
		new_frame_from_dma = 1'b1;
		num_of_history_frames = 3;
		num_of_bbox_in_frame = 36;
		@(posedge clk);
		start = 1'b0;
		new_frame_from_dma = 1'b0;
		repeat (3) @(posedge clk);
		new_set_from_dma = 1'b1;
		@(posedge clk);
		counter_set_fe = 0;
		new_set_from_dma = 1'b0;
		repeat (26) @(posedge clk);
		new_set_from_dma = 1'b1;
		@(posedge clk);
		counter_set_fe = 1;
		new_set_from_dma = 1'b0;
		repeat (26) @(posedge clk);
		counter_set_fe = 2;
		@(posedge clk);
		counter_set_fe = 0;
		done_pe = 1'b1;
		@(posedge clk);
		done_pe = 1'b0;
		repeat (15) @(posedge clk);
		conflict_counter_th = 1'b1;
		done_cr = 1'b1;
		@(posedge clk);
		conflict_counter_th = 1'b0;
		done_cr = 1'b0;
		
		repeat (20) @(posedge clk);
		done_write = 1'b1;
		@(posedge clk);
		done_write = 1'b0;
	   
		
		
	end  
	endtask

endmodule