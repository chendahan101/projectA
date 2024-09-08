/*------------------------------------------------------------------------------
 * File          : oflow_registration_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 8, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_registration_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// ----------------------------------------------------------- 

logic clk;
logic reset_N;

//score calc

//feature_extraction
 logic [`CM_CONCATE_LEN-1:0] cm_concate_cur;
 logic [`POSITION_CONCATE_LEN-1:0] position_concate_cur;
 logic [`WIDTH_LEN-1:0] width_cur;
 logic [`HEIGHT_LEN-1:0] height_cur;
 logic [`COLOR_LEN-1:0] color1_cur;
 logic [`COLOR_LEN-1:0] color2_cur;

//buffer	
 logic done_read;	
 logic [`DATA_TO_PE_WIDTH -1:0] data_to_similarity_metric_0;// we will change the d_history_field
 logic [`DATA_TO_PE_WIDTH -1:0] data_to_similarity_metric_1;
 logic control_for_read_new_line; // will be 1 one after both of similarity metrics done 2 cycles before the end, so we can read new line from the buffer that will be ready when we start new similarity_metric
// we sure that the new line we read will not change the similarity calc before we end similarity because we have register of the score in the output

//reg file
 logic [`WEIGHT_LEN-1:0] iou_weight;
 logic [`WEIGHT_LEN-1:0] w_weight;
 logic [`WEIGHT_LEN-1:0] h_weight;
 logic [`WEIGHT_LEN-1:0] color1_weight;
 logic [`WEIGHT_LEN-1:0] color2_weight;
 logic [`WEIGHT_LEN-1:0] dhistory_weight;

//score board 
	
	
	
	
	
	//IDs
	 logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD];
	
	//core
	 logic ready_new_frame;
	
	
	
	//from interface between buffer
	 logic [`ROW_LEN-1:0] row_sel_to_pe; // aka row_sel_to_pe


//fsm registration
// core
 logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num; // counter for frame_num
 logic [`SET_LEN-1:0] num_of_sets; 
 logic  start_registration;
 logic done_registration;

//PE
 logic [`PE_LEN-1:0] num_of_pe;
 logic [`FEATURE_OF_PREV_LEN-1:0] data_out_pe;

//Cr
//interface between pe to cr
 logic [`ROW_LEN-1:0] row_sel_to_pe_from_cr;  //which row to read from score board
 logic  write_to_pointer_to_pe; //for write to score_board
 logic  data_to_score_board_to_pe; // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
 logic [`ROW_LEN-1:0] row_to_change_to_pe; //for write to score_board
 logic [`SCORE_LEN-1:0] score_to_cr_from_pe; 
 logic [`ID_LEN-1:0] id_to_cr_from_pe;  

  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

 oflow_registration oflow_registration(.*);
		  

	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	
  #50

 
 
  
  
  @(posedge clk); 
  
  frame_0(2, 0);
  
  repeat(5) 
  begin
	  @(posedge clk); 
  end
  
  frame_x(2, 1, 0);
  
  
  repeat(10) 
  begin
	  @(posedge clk); 
  end
  
  done_read = 1'b1;
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
		ready_new_frame = 0;
		frame_num = 0;
		num_of_sets = 0;
		
		insert_curr_data(0,0,0,0,0,0); 
		//iou_weight w_weight h_weight color1_weight color2_weight dhistory_weight 
		insert_weight(10'b1000000000,10'b0010000000,10'b0010000000,10'b0001010101,10'b0001010101,10'b0001010101);	
		
		row_sel_to_pe = 0;
		data_to_similarity_metric_0 =0; 
		data_to_similarity_metric_1 = 0;
		
		done_read = 0;
	  
		 
		 row_sel_to_pe_from_cr = 0;
		 row_to_change_to_pe = 0;
		 data_to_score_board_to_pe = 0;
			write_to_pointer_to_pe = 0;

		
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task insert_curr_data ( input logic [`CM_CONCATE_LEN-1:0] a, input logic [`POSITION_CONCATE_LEN-1:0] b,input logic [`WIDTH_LEN-1:0] c,
						input logic [`HEIGHT_LEN-1:0] d,input logic [`COLOR_LEN-1:0] e, input logic [`COLOR_LEN-1:0] f);
	begin
				
		cm_concate_cur = a;
		position_concate_cur = b;
		width_cur = c;
		height_cur = d;
		color1_cur = e;
		color2_cur = f;
		
	end
 endtask	

 task insert_prev_data_0 ( input logic [`CM_CONCATE_LEN-1:0] a, input logic [`POSITION_CONCATE_LEN-1:0] b,input logic [`WIDTH_LEN-1:0] c,
						 input logic [`HEIGHT_LEN-1:0] d,input logic [`COLOR_LEN-1:0] e, input logic [`COLOR_LEN-1:0] f,
						 input logic [`D_HISTORY_LEN-1:0] g, input logic [`ID_LEN-1:0] h);
	 begin
		 data_to_similarity_metric_0 = {a,b,c,d,e,f,g,h};
		
	 end
	 
 endtask
 
 task insert_prev_data_1 ( input logic [`CM_CONCATE_LEN-1:0] a, input logic [`POSITION_CONCATE_LEN-1:0] b,input logic [`WIDTH_LEN-1:0] c,
		 input logic [`HEIGHT_LEN-1:0] d,input logic [`COLOR_LEN-1:0] e, input logic [`COLOR_LEN-1:0] f,
		 input logic [`D_HISTORY_LEN-1:0] g, input logic [`ID_LEN-1:0] h);
begin
	data_to_similarity_metric_1 = {a,b,c,d,e,f,g,h};

end

endtask
 
 
 task insert_weight ( input logic [`WEIGHT_LEN-1:0] a, input logic [`WEIGHT_LEN-1:0] b,input logic [`WEIGHT_LEN-1:0] c,
						 input logic [`WEIGHT_LEN-1:0] d,input logic [`WEIGHT_LEN-1:0] e, input logic [`WEIGHT_LEN-1:0] f);
	 begin
		 iou_weight = a;
		 w_weight = b;
		 h_weight = c;
		 color1_weight = d; 
		 color2_weight =e;
		 dhistory_weight =f;
	 end
	 
 endtask
 
 task write_to_mem ( input logic [`SET_LEN-1:0] num_of_sets_arg );
	 begin
		 
		 for(int i =0; i< num_of_sets_arg; i++) begin
			 
			 row_sel_to_pe = i;
			 repeat(3) 	@(posedge clk); 
			 
		 end	
		 
	 end
 endtask
 
 task read_from_mem ();
	 begin
		 
		 insert_prev_data_0({11'd30,11'd55}, {11'd50,11'd10,11'd60,11'd110}, 10, 100, {8'd128,8'd127,8'd78}, {8'd204,8'd205,8'd209}, 1, 1);
		 insert_prev_data_1({11'd40,11'd55}, {11'd70,11'd10,11'd80,11'd110}, 10, 100, {8'd128,8'd127,8'd78}, {8'd204,8'd205,8'd209}, 1, 2);
		 
		 @(posedge clk); 
		 start_registration = 1'b1;
		
		 @(posedge clk); 
		 start_registration = 1'b0;
		 
		// repeat(9) @(posedge clk); 
		 
		 //insert_prev_data_0();
		 //insert_prev_data_1();
			 
		 repeat(10) @(posedge clk); 	
		 done_read = 1'b1;
		 @(posedge clk);
		 done_read = 1'b0;
		 
	 end
 endtask
 
 
  task frame_0 ( input logic [`SET_LEN-1:0] num_of_sets_arg, input logic [`PE_LEN-1:0] num_of_pe_arg);
	  begin
		
			
		  frame_num = 0;
		  num_of_sets = num_of_sets_arg;
		  num_of_pe = num_of_pe_arg;
		  
		
		  // set 0
		  insert_curr_data({11'd30,11'd55}, {11'd50,11'd10,11'd60,11'd110}, 10, 100, {8'd128,8'd127,8'd78}, {8'd204,8'd205,8'd209});
		  @(posedge clk); 
		   	  
		  start_registration = 1'b1;
		 
		  @(posedge clk); 
		  start_registration = 1'b0;
		 
		  
		  @(posedge clk); 
		  
		  
		  // set 1
		  insert_curr_data({11'd40,11'd55}, {11'd70,11'd10,11'd80,11'd110}, 10, 100, {8'd128,8'd127,8'd78}, {8'd204,8'd205,8'd209}); 
		  @(posedge clk); 
		  start_registration = 1'b1;
		 
		  @(posedge clk); 
		  start_registration = 1'b0;
		  
		  @(posedge clk); 
		
		  write_to_mem(num_of_sets_arg);
		  
		  @(posedge clk); 
		  ready_new_frame = 1'b1;
		  @(posedge clk); 
		  ready_new_frame = 1'b0;
		  
		  
	  end
   endtask	

   task frame_x ( input logic [`SET_LEN-1:0] num_of_sets_arg, input  logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg, input logic [`PE_LEN-1:0] num_of_pe_arg );
	   begin
				   
		  
		   frame_num = frame_num_arg;
		   num_of_sets = num_of_sets_arg;
		   num_of_pe = num_of_pe_arg;
		   
		  
		   
		   // set 0
		   insert_curr_data({11'd30,11'd55}, {11'd50,11'd10,11'd60,11'd110}, 10, 100, {8'd130,8'd127,8'd78}, {8'd210,8'd205,8'd209});
		  
		   
		   @(posedge clk); 
		   
		   read_from_mem();
		   
		   
		   repeat(2) @(posedge clk); 	
		
		   
		   // set 1
		   insert_curr_data({11'd30,11'd55}, {11'd50,11'd10,11'd60,11'd110}, 10, 100, {8'd120,8'd127,8'd78}, {8'd200,8'd205,8'd209}); 	
		 
		  // @(posedge clk); 
		  // @(posedge clk); 
		   read_from_mem();
		   
		   //write_to_mem(num_of_sets_arg);
		   
		   repeat(12) @(posedge clk); 
		   
		   
		   @(posedge clk); 
		   ready_new_frame = 1'b1;
		   @(posedge clk); 
		   ready_new_frame = 1'b0;
		   
		   
		   
	   end
   endtask
   
 

 
endmodule