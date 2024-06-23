/*------------------------------------------------------------------------------
 * File          : oflow_MEM_buffer_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 23, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_MEM_buffer_tb #() ();
// -----------------------------------------------------------       
//                  registers & wires
// -----------------------------------------------------------  
	
	logic clk;
	logic reset_N;
	logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
	logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
	logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL
			
	logic [`DATA_WIDTH-1:0] data_in_0;
	logic [`DATA_WIDTH-1:0] data_in_1;
	logic [`OFFSET_WIDTH-1:0] offset_0;
	logic [`OFFSET_WIDTH-1:0] offset_1;
			
	logic we;
	
	
	//input logic fe_enable,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       nable
	
	//outputs
	logic [`DATA_WIDTH-1:0] data_out_0;
	logic [`DATA_WIDTH-1:0] data_out_1;
	   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	oflow_MEM_buffer oflow_MEM_buffer(  
		.clk(clk),
		.reset_N (reset_N)	,
		
		.frame_num (frame_num),
		.num_of_history_frames (num_of_history_frames) ,
		.num_of_bbox_in_frame (num_of_bbox_in_frame),
		.data_in_0 (data_in_0),
		.data_in_1 (data_in_1),
		.offset_0 (offset_0),
		.offset_1 (offset_1), 
		.we (we),	
		.data_out_0 (data_out_0),
		.data_out_1 (data_out_1)
		
		);
		 
		  


	
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;                                 // Initiates all input signals to '0' and open necessary files
  //  Write: data_in_0, data_in_1, frame_num, num_of_history_frames, offset_0, offset_1
  write_data( 290'd0, 290'd0, 0,  5, 0, 0);
  #50
  @(posedge clk); 
  //  Write: data_in_0, data_in_1, frame_num, num_of_history_frames, offset_0, offset_1
  write_data( 290'd5454674563, 290'd5363252365, 6,  5, 34, 35);
	#10
  //  Read: frame_num, num_of_history_frames, offset_0, offset_1
  read_data(  6,  5, 34, 35);
  //iou_weight w_weight h_weight color1_weight color2_weight dhistory_weight 

  #500 $finish;  
  
//     $finish;
  
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

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b0; 
		reset_N = 1'b0;
		
		frame_num = 0;
		num_of_history_frames = 0;
		num_of_bbox_in_frame = 0;
		data_in_0 = 0;
		data_in_1 = 0;
		offset_0 = 0;
		offset_1 = 0; 
		we = 0;  
		 
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task write_data ( input logic [`DATA_WIDTH-1:0] a, input logic [`DATA_WIDTH-1:0] b,  input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] c,
						input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] d, input logic [`OFFSET_WIDTH-1:0] e,input logic [`OFFSET_WIDTH-1:0] f);
	begin
		data_in_0 = a;
		data_in_1 = b;
		frame_num = c;
		num_of_history_frames = d;
		offset_0 = e;
		offset_1 = f;
		we = 1'b1;
		$display("write: data_in_0: %d, data_in_1: %d ",data_in_0, data_in_1);
	end
 endtask	

 task read_data (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] a, input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] b,
				input logic [`OFFSET_WIDTH-1:0] c,input logic [`OFFSET_WIDTH-1:0] d);
	begin
		
	frame_num = a;
	num_of_history_frames = b;
	offset_0 = c;
	offset_1 = d;
	we = 1'b0;
	$display("read: data_out_0: %d, data_out_1: %d ",data_out_0, data_out_1);
	end
endtask	
 
 

endmodule