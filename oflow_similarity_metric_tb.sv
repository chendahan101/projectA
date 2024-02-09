/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_similarity_metric_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// -----------------------------------------------------------  
	
		logic clk;
		logic reset_N;
		logic [21:0] cm_concate_cur;
		 logic [43:0] position_concate_cur;
		logic [10:0] width_cur;
		 logic [10:0] height_cur;
		 logic [23:0] color1_cur;
		 logic [23:0] color2_cur;
		 logic [7:0] d_history_cur; 
			
		logic [155:0] features_of_prev;
		
		logic [31:0] iou_weight;
		 logic [31:0] w_weight;
		 logic [31:0] h_weight;
		logic [31:0] color1_weight;
		 logic [31:0] color2_weight;
		logic [31:0] dhistory_weight;
		//input logic wr,
		//input logic [7:0] addr,
		//input logic  EN,
		
		 logic [31:0] score;
		 logic [11:0] id;
   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

	oflow_similarity_metric  oflow_similarity_metric(   .clk	(clk),
		.reset_N (reset_N)	,
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
  
	
	fe_enable = 1'b1;
   #100 $finish; 
//   #100000  $finish;
   
end
   



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 5ns)
// ----------------------------------------------------------------------

   
 always begin
	#2.5 clk = ~clk;
	
  end
 /*always begin
	 #2.5 apb_oflow_pclk =~ apb_oflow_pclk;
 end */
// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b0; 
		reset_N = 1'b0;
		cm_concate_cur = 0;
		position_concate_cur = 0;
		width_cur = 0;
		height_cur = 0;
		color1_cur = 0;
		olor2_cur = 0;
		d_history_cur = 0; 
		   
	    features_of_prev = 156'b00000000001_00000000010__00000000001_00000000010_00000000001_00000000010__00000000001__00000000010_000000000000000000000000__000000000000000000000000__00000000__000000000000;
	   
	    iou_weight = 0;
		w_weight = 0;
		h_weight = 0;
	    color1_weight = 0;
		color2_weight = 0;
	    dhistory_weight = 0;	
	  
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task check;
	begin
		
		// ---------------T1------------
		@(posedge oflow_clk); 
		
		cm_concate_cur = 22'b00000000001_00000000010;
		position_concate_cur = 0;
		width_cur = 0;
		height_cur = 0;
		color1_cur = 0;
		olor2_cur = 0;
		d_history_cur = 0; 
		   
		features_of_prev = 0;
	   
		iou_weight = 0;
		w_weight = 0;
		h_weight = 0;
		color1_weight = 0;
		color2_weight = 0;
		dhistory_weight = 0;	
		// ---------------T2------------
		@(posedge oflow_clk);  
		#1
		apb_oflow_penable = 1'b1;	
		// ---------------T3------------
		 @(posedge oflow_clk);
		 #1
		  //apb_oflow_pwrite    = 1'b0;
		 apb_oflow_psel 		  = 1'b1;
		 //apb_oflow_address  = 13'h0;
		// apb_oflow_pwdata  = 31'h0;
		 apb_oflow_penable = 1'b0;	
		 $display("Writing Data \n");
	end
 endtask	
 
 

 
endmodule
