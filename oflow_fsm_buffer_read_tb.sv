/*------------------------------------------------------------------------------
 * File          : oflow_fsm_buffer_read_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Aug 28, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_fsm_buffer_read_tb #() ();


// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

		   

 logic clk;
 logic reset_N ;
// global inputs
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
//from fsm mem in wrapper mem
 logic [`ADDR_WIDTH-1:0] end_pointers [5];
//from fsm in core
 logic start_read;
//from similarity metric will pass througth core
 logic similarity_metric_flag_ready_to_read_new_line;//only after the similarity metric finish to process one line 


 logic done_read;
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_to_read;
 logic [`OFFSET_WIDTH-1:0] offset_0;
 logic [`OFFSET_WIDTH-1:0] offset_1;
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface;

 //logic we;//i saw this was in comment in the wrapper fsm buffer



// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

 oflow_fsm_read oflow_fsm_read (.*);



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
	repeat(20) 
	begin
		read_data ();
	end
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
	#10
	reset_N	= 1'b1;
	
	frame_num = `TOTAL_FRAME_NUM_WIDTH'd12;
	num_of_history_frames = `NUM_OF_HISTORY_FRAMES_WIDTH'd5;
	end_pointers = '{default: `ADDR_WIDTH'b0};
	#10
	end_pointers[0] = `ADDR_WIDTH'd9; //will include the num of bbox in the frame ,if we choose 4 history frame we will have the ability to save only 32 bbox in each frame
	end_pointers[1] = `ADDR_WIDTH'd3;
	end_pointers[2] = `ADDR_WIDTH'd5;
	similarity_metric_flag_ready_to_read_new_line = 1'b0;
	
	@(negedge clk);
	start_read = 1'b1;
	@(posedge clk);
	start_read = 1'b0;  
	  end
endtask




task read_data ();
begin
	repeat(3) @(posedge clk);
	similarity_metric_flag_ready_to_read_new_line = 1'b1;
	@(posedge clk);//the data will be written and we will pass to offset mode
	similarity_metric_flag_ready_to_read_new_line = 1'b0;
	//$display("write: data_in_0: %d, data_in_1: %d ",O1,O2 );
end
endtask	



endmodule