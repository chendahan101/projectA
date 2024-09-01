/*------------------------------------------------------------------------------
 * File          : oflow_fsm_mem_buffer_in_mem_wrapper_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 1, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_fsm_mem_buffer_in_mem_wrapper_tb #() ();

 logic clk;
 logic reset_N ;
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//for fsm to fsm_write
 logic start_write;
 logic ready_from_core;	
//signal from fsm_write to mem
 logic done_write;
 logic [`OFFSET_WIDTH-1:0] offset_0_write;
 logic [`OFFSET_WIDTH-1:0] offset_1_write;

//for fsm to fsm_read
 logic similarity_metric_flag_ready_to_read_new_line;//only after the similarity metric finish to process one line 
 logic start_read;
//signal from fsm_read to mem
 logic done_read;
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_to_read;

 logic [`OFFSET_WIDTH-1:0] offset_0_read;
 logic [`OFFSET_WIDTH-1:0] offset_1_read;
//output logic we,
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface;




 // ----------------------------------------------------------------------
 //                   Instantiation
 // ----------------------------------------------------------------------

 oflow_fsm_mem_buffer_in_mem_wrapper oflow_fsm_mem_buffer_in_mem_wrapper (.*);



 // ----------------------------------------------------------------------
 //                   Test Pattern
 // ----------------------------------------------------------------------


 initial 
 begin
	 // initiate	
	 initiate_all ();   // Initiates all input signals to '0' and open necessary files
	 #50
	 
	 //  Read all frames: 
	 #5
	 write_mode (`TOTAL_FRAME_NUM_WIDTH'd0,`NUM_OF_BBOX_IN_FRAME_WIDTH'd21,22 );
	 #50
	 write_mode (`TOTAL_FRAME_NUM_WIDTH'd1,`NUM_OF_BBOX_IN_FRAME_WIDTH'd12,22 );
	 #50
	 read_mode (`TOTAL_FRAME_NUM_WIDTH'd1 , 22 );// cause we dond start read when we on frame=0 
	 #50
	 
	 
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
	 start_read = 1'b0;
	 start_write = 1'b0;
	 #10
	 reset_N	= 1'b1;
	 
	 //frame_num = `TOTAL_FRAME_NUM_WIDTH'd12;
	 num_of_history_frames = `NUM_OF_HISTORY_FRAMES_WIDTH'd3;
	 //end_pointers = '{default: `ADDR_WIDTH'b0};
	 #10
	 similarity_metric_flag_ready_to_read_new_line = 1'b0;
	 ready_from_core = 1'b0;
	
	 //end_pointers[0] = `ADDR_WIDTH'd9; //will include the num of bbox in the frame ,if we choose 4 history frame we will have the ability to save only 32 bbox in each frame
	 //end_pointers[1] = `ADDR_WIDTH'd3;
	 //end_pointers[2] = `ADDR_WIDTH'd5;
	 
   end  
 endtask



task write_mode (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg ,input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame_arg ,int repeat_num);
begin
	frame_num = frame_num_arg;
	num_of_bbox_in_frame = num_of_bbox_in_frame_arg;
	@(negedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;  
	 //repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
	 
	 for(int i =0; i<repeat_num ; i++) begin
		 @(negedge clk);
		 ready_from_core = 1'b1;
		 repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		 ready_from_core = 1'b0;
	end

end
endtask



task read_mode (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg , int repeat_num);
	begin
		frame_num = frame_num_arg;
		@(negedge clk);
		start_read = 1'b1;
		@(posedge clk);
		start_read = 1'b0;  
		 //repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		 
		 for(int i =0; i<repeat_num ; i++) begin
			 @(negedge clk);
			 similarity_metric_flag_ready_to_read_new_line = 1'b1;
			 repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
			 similarity_metric_flag_ready_to_read_new_line = 1'b0;
		end

end
endtask




endmodule