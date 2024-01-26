/*------------------------------------------------------------------------------
 * File          : oflow_feature_extraction.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_features_extraction (

	// inputs
	input logic clk,
	input logic reset_N,
	input logic [99:0] bbox,
	input logic fe_enable,
	
	//outputs
	output logic [21:0] cm_concate,
	output logic [43:0] position_concate,
	output logic [10:0] width,
	output logic [10:0] height,
	output logic [23:0] color1,
	output logic [23:0] color2,
	output logic [7:0] d_history );

//-----------------------------------------
//				Wire
//-----------------------------------------								
	logic [10:0] x_cm;
	logic [10:0] y_cm;
	logic [21:0] position_tl;
	logic [21:0] position_br;
	logic [10:0] width_tmp;
	logic [10:0] height_tmp;
	logic [23:0] color1_tmp;
	logic [23:0] color2_tmp;
	logic [7:0] d_history_tmp;
	logic [43:0] position_concate_tmp;
	logic [21:0] cm_concate_tmp;
	
//-----------------------------------------
//				out
//-----------------------------------------


	
//-----------------------------------------
//				comb_logic
//-----------------------------------------

	assign width_tmp = bbox[77:67];
	assign height_tmp = bbox[66:56];
	
	always_comb 
	begin
	 position_tl = bbox[99:78];
	 position_br = {position_tl[21:11] + width_tmp,position_tl[10:0] + height_tmp};
	 x_cm = position_br[21:11] >> 1;
	 y_cm = position_br[10:0] >> 1;
	 position_concate_tmp = {position_tl, position_br} ;
	 cm_concate_tmp = {x_cm, y_cm};
	end	
	
	assign color1_tmp = bbox[55:32];
	assign color2_tmp = bbox[31:8];
	assign d_history_tmp = bbox[7:0];




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
		if (!reset_N) width <= #1 11'd0;	
		else if(fe_enable)	width <= #1 width_tmp;	 
	end  
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) height <= #1 11'd0;	
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
		if (!reset_N) d_history <= #1 8'd0;	
		else if(fe_enable) d_history <= #1 d_history_tmp;
	end 	
   



endmodule  // 
