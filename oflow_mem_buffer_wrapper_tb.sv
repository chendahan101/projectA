/*------------------------------------------------------------------------------
 * File          : oflow_mem_buffer_wrapper_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 1, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_mem_buffer_wrapper_tb #() ();

 logic clk;
 logic reset_N;
// control signal from core fsm
 logic read_new_line; //only after the similarity metric finish to process one line 	
 logic start_read;
 logic start_write;
// data in from pe
 logic [`DATA_WIDTH-1:0] data_in_0;
 logic [`DATA_WIDTH-1:0] data_in_1;
//global variable
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//control signal for core fsm
 logic rnw_st;
 logic ready_from_core;	
 logic done_read;
 logic done_write;
//data out for pe
 logic [`DATA_WIDTH-1:0] data_out_0;
 logic [`DATA_WIDTH-1:0] data_out_1;

//data out for interface
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface;



 logic [`DATA_WIDTH-1:0] data_in_0_reg [2];
 logic [`DATA_WIDTH-1:0] data_in_1_reg [2];


 // ----------------------------------------------------------------------
 //                   Instantiation
 // ----------------------------------------------------------------------

 oflow_mem_buffer_wrapper oflow_mem_buffer_wrapper (.*);



 // ----------------------------------------------------------------------
 //                   Test Pattern
 // ----------------------------------------------------------------------


 initial 
 begin
	 // initiate	
	 initiate_all ();   // Initiates all input signals to '0' and open necessary files
	 #50
	 
	 // write: 
	rnw_st = 1'b0;
	data_in_0_reg  = {`DATA_WIDTH'd5, `DATA_WIDTH'd90} ;
	data_in_1_reg  = {`DATA_WIDTH'd6, `DATA_WIDTH'd91} ;
	write_mode (`TOTAL_FRAME_NUM_WIDTH'd0, `NUM_OF_BBOX_IN_FRAME_WIDTH'd8, data_in_0_reg, data_in_1_reg, 2 );
			
	 //read :
	 #50
	 rnw_st = 1'b1;
	 read_mode (`TOTAL_FRAME_NUM_WIDTH'd1 , 3 );// cause we don't start read when we on frame=0 
	 
	 //write :
	 #50
	 rnw_st = 1'b0;
	 data_in_0_reg  = {`DATA_WIDTH'd77, `DATA_WIDTH'd99} ;
	 data_in_1_reg  = {`DATA_WIDTH'd88, `DATA_WIDTH'd85} ;
	 write_mode (`TOTAL_FRAME_NUM_WIDTH'd1, `NUM_OF_BBOX_IN_FRAME_WIDTH'd8, data_in_0_reg, data_in_1_reg, 2 );
	 
	 //read :
	 #50
	 rnw_st = 1'b1;
	 read_mode (`TOTAL_FRAME_NUM_WIDTH'd2 , 7 );// cause we don't start read when we on frame=0 
	 
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
	 rnw_st = 1'b1;
	 ready_from_core = 1'b0;
	 read_new_line = 1'b0;
	 num_of_history_frames = `NUM_OF_HISTORY_FRAMES_WIDTH'd3;
   end  
 endtask



task write_mode (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg ,input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame_arg ,input logic [`DATA_WIDTH-1:0] data_in_0_reg_arg [2],input logic [`DATA_WIDTH-1:0] data_in_1_reg_arg [2],int repeat_num);
begin
	frame_num = frame_num_arg;
	num_of_bbox_in_frame = num_of_bbox_in_frame_arg;
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;  
	 //repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
	 
	 for(int i =0; i<repeat_num ; i++) begin
		 data_in_0 = data_in_0_reg_arg[i];
		 data_in_1 = data_in_1_reg_arg[i];
		 @(posedge clk);
		 ready_from_core = 1'b1;
		 @(posedge clk);
		 ready_from_core = 1'b0;
		 repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		 //ready_from_core = 1'b0;
	end

end
endtask



task read_mode (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg , int repeat_num);
	begin
		frame_num = frame_num_arg;
		@(posedge clk);
		start_read = 1'b1;
		@(posedge clk);
		start_read = 1'b0;  
		 //repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		 
		repeat(8) @(posedge clk);// it will take 3 cycle to data until it will arrive
		read_new_line = 1'b1;
		@(posedge clk);
		read_new_line = 1'b0;
		
		for(int i =0; i<repeat_num ; i++) begin
			 read_new_line = 1'b0;
			 repeat(10) @(posedge clk);// it will take 3 cycle to data until it will arrive
			 read_new_line = 1'b1;
			 @(posedge clk);
			 read_new_line = 1'b0;
		end

end
endtask




endmodule