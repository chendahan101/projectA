/*------------------------------------------------------------------------------
 * File          : oflow_registration_fsm_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 8, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_registration_fsm_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// ----------------------------------------------------------- 

		logic clk;
		logic reset_N;

 		 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;// counter for frame_num
		 logic [`SET_LEN-1:0] num_of_sets;
		 logic  start_registration;

		//score calc
		 logic done_score_calc;
		 logic start_score_calc;

		// score board
		 logic done_score_board;
		 logic  start_score_board;

		//from PE
		 logic [`PE_LEN-1:0] num_of_pe;
		


		//to score board
		 logic [`ROW_LEN-1:0] row_sel_by_set;
		 logic [`ID_LEN-1:0] id_first_frame;
		   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

		 oflow_registration_fsm oflow_registration_fsm(.*);
		  
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;       // Initiates all input signals to '0' and open necessary files
	
  #50

 
  // insert first frame ids
  insert_frame_0_id(`SET_LEN'd3);
  repeat(3)  @(posedge clk); 

  //  insert second frame (number 1)
  insert_frame_x(`SET_LEN'd3, `TOTAL_FRAME_NUM_WIDTH'd1);
  
  repeat(3)  @(posedge clk); 
  
  //  insert second frame (number 2)
  insert_frame_x(`SET_LEN'd3, `TOTAL_FRAME_NUM_WIDTH'd2); 
  
  repeat(10) 
  begin
	  @(posedge clk); 
  end
  
 
  #500 $finish;  
  
//   #100000  $finish;
  
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
		start_registration = 1'b0;
		done_score_calc = 0;
		done_score_board = 0;
		frame_num = 0;
		num_of_sets = 0;
		num_of_pe = 0;
		
	  
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task insert_frame_0_id ( input logic [`SET_LEN-1:0] num_of_sets_arg);
	begin
				
		start_registration = 1'b1;
		frame_num = 0;
		num_of_sets = num_of_sets_arg;
		num_of_pe = 0;
		
		@(posedge clk); 
		start_registration = 1'b0;
		
		for(int i =0; i< num_of_sets_arg; i++) begin
			
			done_score_board = 1'b0;
			repeat(2) 	@(posedge clk); 
			done_score_board = 1'b1;
			@(posedge clk);
			
		end
		done_score_board = 1'b0;
		
	end
 endtask	

 task insert_frame_x ( input logic [`SET_LEN-1:0] num_of_sets_arg, input  logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg );
	 begin
				 
		 start_registration = 1'b1;
		 frame_num = frame_num_arg;
		 num_of_sets = num_of_sets_arg;
		 num_of_pe = 0;
		 
		 @(posedge clk); 
		 start_registration = 1'b0;
		 
		 for(int i =0; i< num_of_sets_arg; i++) begin
			 
			 done_score_calc = 1'b0;
			 repeat(20) 	@(posedge clk); 
			 done_score_calc = 1'b1;
			 @(posedge clk);
			 
		 end
		 done_score_calc = 1'b0;
		 
	 end
 endtask
 
 
endmodule
 
