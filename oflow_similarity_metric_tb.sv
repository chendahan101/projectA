/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"

module oflow_similarity_metric_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// -----------------------------------------------------------  
	
		logic clk;
		logic reset_N;
		logic start;
		logic [`CM_CONCATE_LEN-1:0] cm_concate_cur;
		logic [`POSITION_CONCATE_LEN-1:0] position_concate_cur;
		logic [`WIDTH_LEN-1:0] width_cur;
		logic [`HEIGHT_LEN:0] height_cur;
		logic [`COLOR_LEN-1:0] color1_cur;
		logic [`COLOR_LEN-1:0] color2_cur;
		logic [`D_HISTORY_LEN-1:0] d_history_cur; 
			
		logic [`FEATURE_OF_PREV_LEN-1:0] features_of_prev;
		
		logic [`WEIGHT_LEN-1:0] iou_weight;
		logic [`WEIGHT_LEN-1:0] w_weight;
		logic [`WEIGHT_LEN-1:0] h_weight;
		logic [`WEIGHT_LEN-1:0] color1_weight;
		logic [`WEIGHT_LEN-1:0] color2_weight;
		logic [`WEIGHT_LEN-1:0] dhistory_weight;
		//input logic wr,
		//input logic [7:0] addr,
		//input logic  EN,
		logic valid ;
		logic [`SCORE_LEN-1:0] score;
		logic [`ID_LEN-1:0] id;
		   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	oflow_similarity_metric  oflow_similarity_metric(  
		.clk(clk),
		.reset_N (reset_N)	,
		.start(start),
		.cm_concate_cur (cm_concate_cur),
		.position_concate_cur (position_concate_cur) ,
		.width_cur (width_cur),
		.height_cur (height_cur),
		.color1_cur (color1_cur),
		.color2_cur (color2_cur),
		.d_history_cur (d_history_cur), 
			
		.features_of_prev (features_of_prev),
		
		.iou_weight (iou_weight),
		.w_weight (w_weight),
		.h_weight (h_weight),
		.color1_weight (color1_weight),
		.color2_weight (color2_weight),
		.dhistory_weight (dhistory_weight),
		//input logic wr,
		//input logic [7:0] addr,
		//input logic  EN,
		.valid(valid),
		.score (score),
		.id (id)
			);
		 
		  


	
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	
  #50
  @(posedge clk); 
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0][`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] [`D_HISTORY_LEN-1:0]
  insert_curr_data({11'd30,11'd55},{11'd50,11'd10,11'd60,11'd110},10,100,50,60,0); 
  //  [`CM_CONCATE_LEN-1:0] [`POSITION_CONCATE_LEN-1:0] [`WIDTH_LEN-1:0]  [`HEIGHT_LEN-1:0][`COLOR_LEN-1:0]  [`COLOR_LEN-1:0] [`D_HISTORY_LEN-1:0] [`ID_LEN-1:0]
  insert_prev_data({11'd31,11'd54},{11'd52,11'd8,11'd62,11'd108},10,100,40,70,1,12);
  //iou_weight w_weight h_weight color1_weight color2_weight dhistory_weight 
  insert_weight(10'b0100000000,10'b0100000000,10'b0100000000,10'b0001010101,10'b0001010101,10'b0001010101);
  #10 start = 1;
  #10 start = 0;
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
		start = 1'b0;
		cm_concate_cur = 0;
		position_concate_cur = 0;
		width_cur = 0;
		height_cur = 0;
		color1_cur = 0;
		color2_cur = 0;
		d_history_cur = 0; 
		   
	    features_of_prev =0; 
				
	    iou_weight = 0;
		w_weight = 0;
		h_weight = 0;
	    color1_weight = 0;
		color2_weight = 0;
	    dhistory_weight = 0;	
	  
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task insert_curr_data ( input logic [`CM_CONCATE_LEN-1:0] a, input logic [`POSITION_CONCATE_LEN-1:0] b,input logic [`WIDTH_LEN-1:0] c,
		 				input logic [`HEIGHT_LEN-1:0] d,input logic [`COLOR_LEN-1:0] e, input logic [`COLOR_LEN-1:0] f,
						input logic [`D_HISTORY_LEN-1:0] g);
	begin
				
		cm_concate_cur = a;
		position_concate_cur = b;
		width_cur = c;
		height_cur = d;
		color1_cur = e;
		color2_cur = f;
		d_history_cur = g;
	end
 endtask	

 task insert_prev_data ( input logic [`CM_CONCATE_LEN-1:0] a, input logic [`POSITION_CONCATE_LEN-1:0] b,input logic [`WIDTH_LEN-1:0] c,
						 input logic [`HEIGHT_LEN-1:0] d,input logic [`COLOR_LEN-1:0] e, input logic [`COLOR_LEN-1:0] f,
						 input logic [`D_HISTORY_LEN-1:0] g, input logic [`ID_LEN-1:0] h);
	 begin
		 features_of_prev = {a,b,c,d,e,f,g,h};
		
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
