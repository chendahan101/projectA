/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm_write_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

module oflow_core_fsm_write_tb #() ();


logic clk;
logic reset_N ;
// global inputs
//logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//from genreal fsm in core (after conflict_resolve done)
logic start_write;
//fsm_core_top
logic [`SET_LEN-1:0] num_of_sets; // for stop_counter
//logic [`PE_LEN-1:0] num_of_bbox_in_last_set; // for stop_counter
logic [`PE_LEN-1:0] num_of_bbox_in_last_set_div_4; // for stop_counter
logic [`PE_LEN-1:0] num_of_bbox_in_last_set_remainder_4; // for stop_counter

//from buffer 
//input logic done_write_buffer,//only after core fsm ready to fetch us the next 2 line of data ; we are going to add a wait state to cure this. the wait state has to be sure the buffer is done to writes 2 rows and now we can change the PE's


logic ready_from_core; // send from fsm core to fsm buffer
logic [`REMAINDER_LEN-1:0] remainder; //if the fsm is in the remainder states
logic [`ROW_LEN-1:0] row_sel;
logic [`PE_LEN-1:0] pe_sel;

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

oflow_core_fsm_write oflow_core_fsm_write (.*);







// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
	// initiate	
	initiate_all ();   // Initiates all input signals to '0' and open necessary files
	#50
	
	//remainder_0 ();
	//remainder_0_24_bbox ();
	//remainder_0_16_bbox ();
	//remainder_3_15_bbox ();
	//remainder_0_4_bbox ();
	remainder_3_3_bbox ();


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
	num_of_sets = 0; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 0; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 0; // for stop_counter
	#10
	reset_N	= 1'b1;

	
  end  
endtask

//num of bbox=72
task remainder_0 ();
begin
	num_of_sets = `SET_LEN'd3; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 0; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 0; // for stop_counter
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;
	repeat(54)@(posedge clk);
	
end  
endtask


//num of bbox=70
task remainder_2 ();
	begin
		num_of_sets = `SET_LEN'd3; // for stop_counter
		num_of_bbox_in_last_set_div_4 = 5; // for stop_counter
		num_of_bbox_in_last_set_remainder_4 = 2; // for stop_counter
		@(posedge clk);
		start_write = 1'b1;
		@(posedge clk);
		start_write = 1'b0;
		repeat(54)@(posedge clk);
		
	end  
	endtask	

//num of bbox=24
task remainder_0_24_bbox ();
	begin
		num_of_sets = `SET_LEN'd1; // for stop_counter
		num_of_bbox_in_last_set_div_4 = 0; // for stop_counter
		num_of_bbox_in_last_set_remainder_4 = 0; // for stop_counter
		@(posedge clk);
		start_write = 1'b1;
		@(posedge clk);
		start_write = 1'b0;
		repeat(54)@(posedge clk);
		
	end  
	endtask	


//num of bbox=16
task remainder_0_16_bbox ();
	begin
	num_of_sets = `SET_LEN'd1; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 4; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 0; // for stop_counter
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;
	repeat(54)@(posedge clk);
end  
endtask	

//num of bbox=15
task remainder_3_15_bbox ();
	begin
	num_of_sets = `SET_LEN'd1; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 3; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 3; // for stop_counter
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;
	repeat(54)@(posedge clk);
end  
endtask	

//num of bbox=4
task remainder_0_4_bbox ();
	begin
	num_of_sets = `SET_LEN'd1; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 1; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 0; // for stop_counter
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;
	repeat(54)@(posedge clk);
end  
endtask	



//num of bbox=3
task remainder_3_3_bbox ();
	begin
	num_of_sets = `SET_LEN'd1; // for stop_counter
	num_of_bbox_in_last_set_div_4 = 0; // for stop_counter
	num_of_bbox_in_last_set_remainder_4 = 3; // for stop_counter
	@(posedge clk);
	start_write = 1'b1;
	@(posedge clk);
	start_write = 1'b0;
	repeat(54)@(posedge clk);
end  
endtask	


endmodule