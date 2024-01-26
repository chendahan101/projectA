/*------------------------------------------------------------------------------
 * File          : oflow_core.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_core_2 #() (
	//inputs
	input logic clk,
	input logic reset_N,
	
	 input logic [99:0] bbox,			//size 
	 
	 input logic [31:0] w_iou,
	 input logic [31:0] w_w,
	 input logic [31:0] w_h, 
	 input logic [31:0] w_color1, 
	 input logic [31:0] w_color2,
	 input logic [31:0] w_dhistory,
	 input logic [2:0]  num_of_history_frame,
	 input logic  	   done_for_dma, 
	 
	 input logic [31:0] apb_prdata,
	 
	 // outputs		 
	 output logic [4:0] th_conflict_counter,
	 output logic th_conflict_counter_wr,
	 output logic [255:0][20:0] ids   );



// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  


oflow_features_extraction  oflow_features_extraction(   .clk		(clk),
	.reset_N		(reset_N),
	
	.bbox (bbox),
	.fe_enable (fe_enable),
	
	.cm_concate (cm_concate),
	.position_concate  (position_concate),
	.width (width),
	.height (height),
	.color1 (color1),
	.color2(color2),
	.d_history (d_history)
  
	
);

endmodule