/*------------------------------------------------------------------------------
 * File          : oflow_score_calc.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

module  oflow_score_calc( 
	input logic clk,
	input logic reset_N	,
	input logic [21:0] cm_concate_cur,
	input logic [43:0] position_concate_cur,
	input logic [10:0] width_cur,
	input logic [10:0] height_cur,
	input logic [23:0] color1_cur,
	input logic [23:0] color2_cur,
	input logic [7:0] d_history_cur, 
		
	input logic [155:0] features_of_prev,
	
	input logic [31:0] iou_weight,
	input logic [31:0] w_weight,
	input logic [31:0] h_weight,
	input logic [31:0] color1_weight,
	input logic [31:0] color2_weight,
	input logic [31:0] dhistory_weight,
	//input logic wr,
	//input logic [7:0] addr,
	//input logic  EN,
	
	output logic [31:0] score,
	output logic [11:0] id
	);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	//next 


// -----------------------------------------------------------       
//				Instantiation
// -----------------------------------------------------------  
oflow_similarity_metric oflow_similarity_metric_1( 
			.clk (clk),
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
			.id (id) );
			
			
oflow_similarity_metric oflow_similarity_metric_2( 
			.clk (clk),
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
			.id (id) );
	

endmodule