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
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       nable
	
	//outputs to registration
	output logic [`CM_CONCATE_LEN-1:0] cm_concate,
	output logic [`POSITION_CONCATE_LEN-1:0] position_concate,
	output logic [`WIDTH_LEN-1:0] width,
	output logic [`HEIGHT_LEN-1:0] height,
	output logic [`COLOR_LEN-1:0] color1,
	output logic [`COLOR_LEN-1:0] color2,
	
	// core_fsm
	input logic done_pe,
	input logic start_fe,
	output logic done_fe
	
	);

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
	
	
	logic [`CM_CONCATE_LEN-1:0] cm_concate_tmp;
	logic [`POSITION_CONCATE_LEN-1:0] position_concate_tmp;
	
	
	logic done;
	
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
	




//-----------------------------------------
//        instantiation
//-----------------------------------------

	
//-----------------------------------------
//				FF
//-----------------------------------------
	


	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N)  cm_concate <= #1 22'd0;	
		else if(start_fe)  cm_concate <= #1 cm_concate_tmp;	 
	end  

	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) position_concate <= #1 44'd0;	
		else if(start_fe)  position_concate <= #1 position_concate_tmp;
	end  
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) width <= #1 8'd0;	
		else if(start_fe)	width <= #1 width_tmp;	 
	end  
   
	always_ff @(posedge clk or negedge reset_N)   
	begin    
		if (!reset_N) height <= #1 8'd0;	
		else if(start_fe) height <= #1 height_tmp;
	end 

	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if (!reset_N) color1 <= #1 24'd0;	
		else if(start_fe) color1 <= #1 color1_tmp;
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin   
		if (!reset_N) color2 <= #1 24'd0;	
		else if(start_fe) color2 <= #1 color2_tmp; 
	end 	
   
   //
  
  
typedef enum {idle_st,fe_st, wait_st} sm_type; //
sm_type next_state;




// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end

 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 done_fe = 0; 

	 case (current_state)
		 idle_st: begin	
			 next_state = start_fe  ? fe_st: idle_st;	 
		 end
		 
		 
		 fe_st: begin 
			 if( !done_pe )	next_state = wait_st;
			 else next_state = idle_st;
		 end
		 
 
		wait_st: begin 
			done_fe = 1'b1;
			 if (start_fe)  next_state = fe_st;
		 end
		 
	 endcase
 end
	
	
	


endmodule  // 