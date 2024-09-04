/*------------------------------------------------------------------------------
 * File          : oflow_score_calc_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_score_calc_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// ----------------------------------------------------------- 

logic clk;
logic reset_N;
//registration
logic start_score_calc;

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

// oflow_score_board
 logic [`SCORE_LEN-1:0] min_score_0; // min_score_0
 logic [`ID_LEN-1:0] min_id_0;// id_0 of min score_0 
 logic [`SCORE_LEN-1:0] min_score_1; // min_score_1
 logic [`ID_LEN-1:0] min_id_1; // id_1 of min score_1
 logic done_score_calc;
		   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	oflow_score_calc oflow_score_calc(.*);
		  


	
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	
  #50

 
  //iou_weight w_weight h_weight color1_weight color2_weight dhistory_weight 
  insert_weight(10'b1000000000,10'b0010000000,10'b0010000000,10'b0001010101,10'b0001010101,10'b0001010101);
  @(posedge clk); 
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0] [`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] 
  insert_curr_data({11'd30,11'd55}, {11'd50,11'd10,11'd60,11'd110}, 10, 100, {8'd128,8'd127,8'd78}, {8'd204,8'd205,8'd209}); 
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0][`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] [`D_HISTORY_LEN-1:0] [`ID_LEN-1:0]
  insert_prev_data_0({11'd31,11'd54}, {11'd52,11'd8,11'd62,11'd108}, 10, 100, {8'd130,8'd122,8'd90}, {8'd220,8'd80,8'd200}, 1, 12);
 
  
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0][`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] [`D_HISTORY_LEN-1:0] [`ID_LEN-1:0]
  insert_prev_data_1({11'd40,11'd54}, {11'd70,11'd8,11'd80,11'd108}, 10, 100, {8'd130,8'd122,8'd90}, {8'd220,8'd80,8'd200}, 1, 14);
  
  
  @(posedge clk); 
  start_score_calc = 1'b1;
  @(posedge clk); 
  start_score_calc = 1'b0;
  
  repeat(7) 
  
  begin
	  @(posedge clk); 
  end
  
  insert_prev_data_0({11'd31,11'd54}, {11'd52,11'd8,11'd62,11'd108}, 10, 100, {8'd130,8'd122,8'd90}, {8'd220,8'd80,8'd200}, 4, 12);
  
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0][`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] [`D_HISTORY_LEN-1:0] [`ID_LEN-1:0]
  insert_prev_data_1({11'd40,11'd54}, {11'd70,11'd8,11'd80,11'd108}, 10, 100, {8'd130,8'd122,8'd90}, {8'd220,8'd80,8'd200}, 4, 14);
  
  
  @(posedge clk); 
  
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
		start_score_calc = 1'b0;
		cm_concate_cur = 0;
		position_concate_cur = 0;
		width_cur = 0;
		height_cur = 0;
		color1_cur = 0;
		color2_cur = 0;
		// d_history_cur = 0; 
		   
		data_to_similarity_metric_0 =0; 
		data_to_similarity_metric_1 = 0;
		
	
		iou_weight = 0;
		w_weight = 0;
		h_weight = 0;
		color1_weight = 0;
		color2_weight = 0;
		dhistory_weight = 0;	
	  
	  	done_read = 0;
	  
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
 
 

 
endmodule