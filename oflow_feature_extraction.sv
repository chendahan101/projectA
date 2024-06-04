/*------------------------------------------------------------------------------
 * File          : oflow_feature_extraction.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"

module oflow_features_extraction (

	// inputs
	input logic clk,
	input logic reset_N,
	input logic [`BBOX_VECTOR_SIZE-1:0] bbox,
	input logic fe_enable, // feature_extraction enable                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         nable
	
	//outputs
	output logic [`CM_CONCATE_LEN-1:0] cm_concate,
	output logic [`POSITION_CONCATE_LEN-1:0] position_concate,
	output logic [`WIDTH_LEN-1:0] width,
	output logic [`HEIGHT_LEN-1:0] height,
	output logic [`COLOR_LEN-1:0] color1,
	output logic [`COLOR_LEN-1:0] color2,
	output logic [`D_HISTORY_LEN-1:0] d_history );

//-----------------------------------------
//				Wire
//-----------------------------------------								
	logic [`CM_LEN-1:0] x_cm;
	logic [`CM_LEN-1:0] y_cm;
	logic [`POSTION_TL_LEN-1:0] position_tl;
	logic [`POSTION_BR_LEN-1:0] position_br;
	logic [`WIDTH_LEN-1:0] width_tmp;
	logic [`HEIGHT_LEN-1:0] height_tmp;
	logic [`COLOR_LEN-1:0] color1_tmp;
	logic [`COLOR_LEN-1:0] color2_tmp;
	logic [`D_HISTORY_LEN:0] d_history_tmp;
	
	logic [`CM_CONCATE_LEN-1:0] cm_concate_tmp;
	logic [`POSITION_CONCATE_LEN-1:0] position_concate_tmp;
	
	
//-----------------------------------------
//				out
//-----------------------------------------


	
//-----------------------------------------
//				comb_logic
//-----------------------------------------

	assign width_tmp = bbox[`WIDTH_MSB_IN_BBOX-1:`WIDTH_MSB_IN_BBOX-`WIDTH_LEN];
	assign height_tmp = bbox[`HEIGHT_MSB_IN_BBOX-1:`HEIGHT_MSB_IN_BBOX-`HEIGHT_LEN];
	
	always_comb 
	begin
	 position_tl = bbox[`BBOX_VECTOR_SIZE-1:`BBOX_VECTOR_SIZE-`POSTION_TL_LEN];
	 position_br = {position_tl[`POSTION_TL_LEN-1:`POSTION_TL_LEN-`CM_LEN] + width_tmp, position_tl[`POSTION_TL_LEN-`CM_LEN-1:0] + height_tmp};
	 x_cm = position_br[`POSTION_BR_LEN-1:`POSTION_BR_LEN-`CM_LEN] >> 1;
	 y_cm = position_br[`POSTION_BR_LEN-`CM_LEN-1:0] >> 1;
	 position_concate_tmp = {position_tl, position_br} ;
	 cm_concate_tmp = {x_cm, y_cm};
	end	
	
	assign color1_tmp = bbox[`COLOR1_MSB_IN_BBOX-1:`COLOR1_MSB_IN_BBOX-`COLOR_LEN];
	assign color2_tmp = bbox[`COLOR2_MSB_IN_BBOX-1:`COLOR2_MSB_IN_BBOX-`COLOR_LEN];
	assign d_history_tmp = bbox[`D_HISTORY_LEN-1:0];




//-----------------------------------------
//        instantiation
//-----------------------------------------

	
//-----------------------------------------
//				FF
//-----------------------------------------
	


	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N)  cm_concate <= #1 22'd0;	
		else if(fe_enable)  cm_concate <= #1 cm_concate_tmp;	 
	end  

	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) position_concate <= #1 44'd0;	
		else if(fe_enable)  position_concate <= #1 position_concate_tmp;
	end  
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) width <= #1 8'd0;	
		else if(fe_enable)	width <= #1 width_tmp;	 
	end  
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) height <= #1 8'd0;	
		else if(fe_enable) height <= #1 height_tmp;
	end 

	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if (!reset_N) color1 <= #1 24'd0;	
		else if(fe_enable) color1 <= #1 color1_tmp;
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin   
		if (!reset_N) color2 <= #1 24'd0;	
		else if(fe_enable) color2 <= #1 color2_tmp; 
	end 	
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) d_history <= #1 3'd0;	
		else if(fe_enable) d_history <= #1 d_history_tmp;
	end 	
   



endmodule  // 