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
	// initiate: num_of_history_frame	
  initiate_all(5); // Initiates all input signals to '0' and open necessary files
  //  Write: data_in_0, data_in_1, frame_num, offset_0, offset_1
  //write_data( 290'd0, 290'd0, 0, 0, 0);
  #50
  @(posedge clk); 
  //  Write: data_in_0, data_in_1, frame_num, offset_0, offset_1
  write_data( {22'd50,44'd70,8'd10,8'd100,24'd200,24'd250,12'd5,22'd50,44'd70,8'd10,8'd100,24'd201,24'd250,12'd6}, 
		  		{22'd50,44'd70,8'd10,8'd100,24'd200,24'd251,12'd7,22'd50,44'd70,8'd10,8'd100,24'd200,24'd250,12'd9}, 6, 34, 35);
	#10
  //  Read: frame_num, offset_0, offset_1
  read_data(  6,  34, 35);
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

 
 task initiate_all (input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] a);        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b1; 
		reset_N = 1'b0;
		
		frame_num = 0;
		num_of_history_frames = a;
		
		data_in_0 = 0;
		data_in_1 = 0;
		offset_0 = 0;
		offset_1 = 0; 
		we = 0;  
		 
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task write_data ( input logic [`DATA_WIDTH-1:0] a, input logic [`DATA_WIDTH-1:0] b,  input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] c,
						input logic [`OFFSET_WIDTH-1:0] d,input logic [`OFFSET_WIDTH-1:0] e);
	begin
		data_in_0 = a;
		data_in_1 = b;
		frame_num = c;
	
		offset_0 = d;
		offset_1 = e;
		#5
		we = 1'b1;
		#5
		we = 1'b0;		
		$display("write: data_in_0: %d, data_in_1: %d ",data_in_0, data_in_1);
	end
 endtask	

 task read_data (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] a, 
				input logic [`OFFSET_WIDTH-1:0] b,input logic [`OFFSET_WIDTH-1:0] c);
	begin
		
	frame_num = a;
	
	offset_0 = b;
	offset_1 = c;
	we = 1'b0;
	$display("read: data_out_0: %d, data_out_1: %d ",data_out_0, data_out_1);
	end
endtask	
 
 

endmodule