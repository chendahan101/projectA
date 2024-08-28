/*------------------------------------------------------------------------------
 * File          : oflow_fsm_buffer_write_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Aug 28, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_fsm_buffer_write_tb #() ();


// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

		   
	 logic clk;
	 logic reset_N;
	 
	 // global inputs
	  logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
	  logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
	 //from fsm mem in wrapper mem
	  logic [`ADDR_WIDTH-1:0] end_pointers [5];
	 //from fsm in core
	  logic start_write;
	 //from similarity metric will pass througth core
	  logic ready_from_core;//only after core fsm ready to fetch us the next 2 line of data

	 
	  logic done_write; // send to fsm core
	  logic [`OFFSET_WIDTH-1:0] offset_0;
	  logic [`OFFSET_WIDTH-1:0] offset_1;
	


// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	  oflow_fsm_buffer_write oflow_fsm_buffer_write (.*);



// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
// initiate	
initiate_all ();   // Initiates all input signals to '0' and open necessary files
#50

//  Write: 
repeat (32) begin
	#5
	write_data ();
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
	start_write = 1'b0;
	#10
	reset_N	= 1'b1;
	
	frame_num = `TOTAL_FRAME_NUM_WIDTH'd12;
	num_of_history_frames = `NUM_OF_HISTORY_FRAMES_WIDTH'd4;
	end_pointers = '{default: `ADDR_WIDTH'b0};
	#10
	end_pointers[frame_num %num_of_history_frames] = `ADDR_WIDTH'd9; //will include the num of bbox in the frame ,if we choose 4 history frame we will have the ability to save only 32 bbox in each frame
	  
	ready_from_core = 1'b0;	
	@(negedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;  
	  end
endtask




task write_data ();
begin
	repeat(3) @(posedge clk);
	ready_from_core = 1'b1;
	@(posedge clk);//the data will be written and we will pass to offset mode
	ready_from_core = 1'b0;
	//$display("write: data_in_0: %d, data_in_1: %d ",O1,O2 );
end
endtask	



endmodule