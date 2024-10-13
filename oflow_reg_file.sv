/*------------------------------------------------------------------------------
 * File          : oflow_reg_file.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_reg_file_define.sv"

module oflow_reg_file #() (
	// inputs
	input logic clk,    			          
	input logic reset_N	,
	
	
	// APB Interface	
	// inputs
	input logic [31:0] apb_pwdata,		
	input logic apb_pwrite,
	input logic apb_psel, 
	input logic apb_penable,
	input logic[`ADDR_LEN-1:0] apb_addr,

	

	// outputs
	output logic apb_pready,      
	output logic[31:0] apb_prdata, 
	output logic [`WEIGHT_LEN-1:0] iou_weight,
	output logic [`WEIGHT_LEN-1:0] w_weight,
	output logic [`WEIGHT_LEN-1:0] h_weight, 
	output logic [`WEIGHT_LEN-1:0] color1_weight, 
	output logic [`WEIGHT_LEN-1:0] color2_weight,
	output logic [`WEIGHT_LEN-1:0] dhistory_weight,
	output logic [`SCORE_LEN-1:0] score_th_for_new_bbox,
	output logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frames
	);


// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

   logic [`WEIGHT_LEN-1:0] w_iou_reg;
   logic [`WEIGHT_LEN-1:0] w_w_reg; 
   logic [`WEIGHT_LEN-1:0] w_h_reg; 
   logic [`WEIGHT_LEN-1:0] w_color1_reg; 
   logic [`WEIGHT_LEN-1:0] w_color2_reg;
   logic [`WEIGHT_LEN-1:0] w_dhistory_reg;
   
   logic [`SCORE_LEN-1:0] score_th_for_new_bbox_reg;
   logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frame_reg;
   
   //logic [31:0] apb_prdata_reg;
   
   logic time_to_write, time_to_read; 

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

	assign time_to_write = apb_pwrite && apb_psel && apb_penable ;
	assign time_to_read = !apb_pwrite && apb_psel && apb_penable ;
	assign apb_pready = (time_to_write || time_to_read) && (apb_addr == `W_IOU_ADDR || apb_addr == `W_WIDTH_ADDR || apb_addr == `W_HEIGHT_ADDR ||  apb_addr == `W_COLOR1_ADDR ||apb_addr == `W_COLOR2_ADDR || 
						 apb_addr == `NUM_OF_HISTORY_FRAMES_ADDR || apb_addr == `W_HISTORY_ADDR)  ;
	
	assign iou_weight = w_iou_reg;
	assign w_weight = w_w_reg;
	assign h_weight = w_h_reg;
	assign color1_weight = w_color1_reg;
	assign color2_weight = w_color2_reg;
	assign dhistory_weight = w_dhistory_reg;
	
	assign score_th_for_new_bbox = score_th_for_new_bbox_reg;
	assign num_of_history_frames = num_of_history_frame_reg;

	//assign apb_prdata = apb_prdata_reg;
// -----------------------------------------------------------       
//            APB - Write to Registers 
// -----------------------------------------------------------  

	
	
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_iou_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_IOU_ADDR)) w_iou_reg <= #1 apb_pwdata; 
	end  
	  
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_w_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_WIDTH_ADDR)) w_w_reg <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_h_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_HEIGHT_ADDR)) w_h_reg <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_color1_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_COLOR1_ADDR)) w_color1_reg <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_color2_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_COLOR2_ADDR)) w_color2_reg <= #1 apb_pwdata; 
		
	end 
	
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_dhistory_reg <= #1 0; 
		else if(time_to_write && (apb_addr == `W_HISTORY_ADDR)) w_dhistory_reg <= #1 apb_pwdata; 
	end 
		

	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) score_th_for_new_bbox_reg <= #1 3'd0; 
		else if(time_to_write && (apb_addr == `SCORE_TH_FOR_NEW_BBOX_ADDR)) score_th_for_new_bbox_reg <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) num_of_history_frame_reg <= #1 3'd0; 
		else if(time_to_write && (apb_addr == `NUM_OF_HISTORY_FRAMES_ADDR)) num_of_history_frame_reg <= #1 apb_pwdata; 
	end 
		
	
// -----------------------------------------------------------       
//            APB - Read from Registers 
// -----------------------------------------------------------  
	
	 /*
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) apb_prdata <= #1 0; 
		else if(time_to_write && (apb_addr == `iou_weight)) apb_prdata <= #1 ()*iou_weight + ()*w_m+
	 */ 
	 
/*
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) apb_prdata_reg <= #1 0; 
		else if(time_to_read) 
			 begin 
				case (apb_addr)
					`W_IOU_ADDR: apb_prdata_reg <= #1 w_iou_reg;
					`W_WIDTH_ADDR: apb_prdata_reg <= #1  w_w_reg;
					`W_HEIGHT_ADDR: apb_prdata_reg <= #1 w_h_reg;
					`W_COLOR1_ADDR: apb_prdata_reg <= #1 w_color1_reg;
					`W_COLOR2_ADDR:  apb_prdata_reg <= #1 w_color2_reg;
					`W_HISTORY_ADDR: apb_prdata_reg <= #1 w_dhistory_reg;
					`NUM_OF_HISTORY_FRAMES_ADDR: apb_prdata_reg <= #1  num_of_history_frame_reg;
					
				endcase	
			 end
	end	
	
*/


	always_comb 
	begin 
		//apb_prdata = num_of_history_frame_reg;
		 if(time_to_read) 
			 begin 
				case (apb_addr)
					`W_IOU_ADDR: apb_prdata = w_iou_reg;
					`W_WIDTH_ADDR: apb_prdata=  w_w_reg;
					`W_HEIGHT_ADDR: apb_prdata= w_h_reg;
					`W_COLOR1_ADDR: apb_prdata= w_color1_reg;
					`W_COLOR2_ADDR:  apb_prdata= w_color2_reg;
					`W_HISTORY_ADDR: apb_prdata= w_dhistory_reg;
					`NUM_OF_HISTORY_FRAMES_ADDR: apb_prdata = score_th_for_new_bbox_reg;
					`NUM_OF_HISTORY_FRAMES_ADDR: apb_prdata =  num_of_history_frame_reg;
					default: apb_prdata = num_of_history_frame_reg; 	
				endcase	
			end
	end	
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
  /*
  typedef enum bit[1:0] {Setup_st=2'b00, Access_st=2'b01, W_R_st=2'b10} STATE;
  STATE CUR_ST;
  STATE NEXT_ST;
  
  always_ff @(posedge clk or negedge reset_N)   
  begin 
	  if (!reset_N) CUR_ST <= #1 Setup_st; 
	  else 		   CUR_ST <= #1 NEXT_ST;   
  end  
	  

always_comb 
	begin
		apb_pready = 1'b0;
		NEXT_ST=CUR_ST;
		case(CUR_ST)
			Setup_st:
			begin
				NEXT_ST = Setup_st;
			
				if(apb_psel && !apb_penable  && valid_add)
					begin
						NEXT_ST = Access_st;
					end
			end
			Access_st:
			begin
				if(apb_penable)
					begin
						apb_pready = 1'b1;
					end	
				NEXT_ST = Access_st;
				if(apb_psel && apb_penable  && valid_add)
					begin
						NEXT_ST = W_R_st;
					end
				else if (!apb_psel)
					begin
						NEXT_ST = Setup_st;
					end
			end
			W_R_st:
			begin
				 
				 if(!apb_psel)
				 begin
					 NEXT_ST = Setup_st;
				 end
			 else if (!apb_penable)
				 begin
					 NEXT_ST = Access_st;
				 end

				
			end
		endcase
	end
// -----------------------------------------------------------       
//            Write logic 
// -----------------------------------------------------------  
   
always_ff @(posedge clk or negedge reset_N)   
begin 
	case(NEXT_ST)
		W_R_st:	
		begin
			
			case(apb_addr)
				
			   `iou_weight: if (apb_pwrite)  iou_weight <= apb_pwdata; else apb_prdata <=  iou_weight; 
			   `w_weight: if (apb_pwrite)  w_weight <= apb_pwdata; else apb_prdata <=  w_weight;
			   `h_weight:if  (apb_pwrite)  h_weight <= apb_pwdata; else apb_prdata <=  h_weight;
			   `color1_weight:if  (apb_pwrite)  color1_weight <= apb_pwdata; else  apb_prdata <=  color1_weight;
			   `color2_weight: if (apb_pwrite)  color2_weight <= apb_pwdata ;else  apb_prdata <=  color2_weight;
			   `dhistory_weight:if  (apb_pwrite)  dhistory_weight <= apb_pwdata; else  apb_prdata <=  dhistory_weight;
			   `TH_conflict_counter:if  (apb_pwrite)  th_conflict_counter <= apb_pwdata; else apb_prdata <=  th_conflict_counter;
			   `num_of_history_frames:if (apb_pwrite)  num_of_history_frames <= apb_pwdata ;else  apb_prdata <=  num_of_history_frames;
			   `DONE_for_dma: if (apb_pwrite)  done_for_dma <= apb_pwdata; else apb_prdata <=  done_for_dma;
			   
			endcase  
		end
		
	endcase
end  	

*/

  




endmodule