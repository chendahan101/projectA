/*------------------------------------------------------------------------------
 * File          : oflow_reg_file.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 15, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/oflow_define.sv"


module oflow_reg_file #() (
	// inputs
	input logic clk,    			          
	input logic reset_N	,
	
	// APB Interface							
	input logic apb_pclk, 		
	input logic apb_pwrite,
	input logic apb_psel, 
	input logic apb_penable,
	input logic[11:0] apb_addr,
	input logic [4:0]  th_conflict_counter,
	input logic   th_conflict_counter_wr,

	// outputs
	output logic apb_pready,      
	output logic[31:0] apb_prdata, 
	output logic [31:0] w_iou,
	output logic [31:0] w_w,
	output logic [31:0] w_h, 
	output logic [31:0] w_color1, 
	output logic [31:0] w_color2,
	output logic [31:0] w_dhistory,
	output logic [2:0]  num_of_history_frame,
	output logic  	   done_for_dma );


// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

   logic [31:0] w_iou_reg;
   logic [31:0] w_w_reg; 
   logic [31:0] w_h_reg; 
   logic [31:0] w_color1_reg; 
   logic [31:0] w_color2_reg;
   logic [31:0] w_dhistory_reg;
   logic [4:0]  th_conflict_counter_reg;
   logic [2:0]  num_of_history_frame_reg;
   logic  	   done_for_dma_reg;  
   
   logic time_to_write, time_to_read; 

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

    assign time_to_write = apb_pwrite && apb_psel && apb_penable ;
    assign time_to_read = !apb_pwrite && apb_psel && apb_penable ;
	assign apb_pready = (time_to_write || time_to_read) && (apb_addr == `W_Iou || apb_addr == `W_w || apb_addr == `W_h ||  apb_addr == `W_color1 ||apb_addr == `W_color2 || 
						apb_addr == `W_dhistory ||  apb_addr == `TH_conflict_counter || apb_addr == `NUM_of_history_frame || apb_addr == `DONE_for_dma) ;

// -----------------------------------------------------------       
//            APB - Write to Registers 
// -----------------------------------------------------------  

	
	
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_iou <= #1 0; 
		else if(time_to_write && (apb_addr == `W_Iou)) w_iou <= #1 apb_pwdata; 
	end  
	  
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_w <= #1 0; 
		else if(time_to_write && (apb_addr == `W_w)) w_w <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_h <= #1 0; 
		else if(time_to_write && (apb_addr == `W_h)) w_h <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_color1 <= #1 0; 
		else if(time_to_write && (apb_addr == `W_color1)) w_color1 <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_color2 <= #1 0; 
		else if(time_to_write && (apb_addr == `W_color2)) w_color2 <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) w_dhistory <= #1 0; 
		else if(time_to_write && (apb_addr == `W_dhistory)) w_dhistory <= #1 apb_pwdata; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(reset_N) th_conflict_counter_reg <= #1 5'd0; 
		else if(th_conflict_counter) th_conflict_counter_reg <= #1 th_conflict_counter; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) num_of_history_frame <= #1 3'd0; 
		else if(time_to_write && (apb_addr == `NUM_of_history_frame)) num_of_history_frame <= #1 apb_pwdata[2:0]; 
	end 
	
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) done_for_dma <= #1 1'b0; 
		else if(time_to_write && (apb_addr == `DONE_for_dma)) done_for_dma <= #1 apb_pwdata[0]; 
	end  
	
	
	
// -----------------------------------------------------------       
//            APB - Read from Registers 
// -----------------------------------------------------------  
	
	 /*
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) apb_prdata <= #1 0; 
		else if(time_to_write && (apb_addr == `W_Iou)) apb_prdata <= #1 ()*w_iou + ()*w_m+
	 */ 
	 
	always_ff @(posedge clk or negedge reset_N)   
	begin 
		if(!reset_N) apb_prdata <= #1 0; 
		else if(time_to_read) 
			 begin 
				case (apb_addr)
					`W_Iou: apb_prdata <= #1 w_iou;
					`W_w: apb_prdata <= #1  w_w;
					`W_h: apb_prdata <= #1 w_h;
					`W_color1: apb_prdata <= #1 w_color1;
					`W_color2:  apb_prdata <= #1 w_color2;
					`W_dhistory: apb_prdata <= #1 w_dhistory;
					`TH_conflict_counter: apb_prdata <= #1 { {27{1'b0}}, th_conflict_counter};
					`NUM_of_history_frame: apb_prdata <= #1 { {29{1'b0}}, num_of_history_frame};
					`DONE_for_dma: apb_prdata <= #1 { {31{1'b0}}, done_for_dma};	
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
				
			   `W_Iou: if (apb_pwrite)  w_iou <= apb_pwdata; else apb_prdata <=  w_iou; 
			   `W_w: if (apb_pwrite)  w_w <= apb_pwdata; else apb_prdata <=  w_w;
			   `W_h:if  (apb_pwrite)  w_h <= apb_pwdata; else apb_prdata <=  w_h;
			   `W_color1:if  (apb_pwrite)  w_color1 <= apb_pwdata; else  apb_prdata <=  w_color1;
			   `W_color2: if (apb_pwrite)  w_color2 <= apb_pwdata ;else  apb_prdata <=  w_color2;
			   `W_dhistory:if  (apb_pwrite)  w_dhistory <= apb_pwdata; else  apb_prdata <=  w_dhistory;
			   `TH_conflict_counter:if  (apb_pwrite)  th_conflict_counter <= apb_pwdata; else apb_prdata <=  th_conflict_counter;
			   `NUM_of_history_frame:if (apb_pwrite)  num_of_history_frame <= apb_pwdata ;else  apb_prdata <=  num_of_history_frame;
			   `DONE_for_dma: if (apb_pwrite)  done_for_dma <= apb_pwdata; else apb_prdata <=  done_for_dma;
			   
			endcase  
		end
		
	endcase
end  	

*/

  




endmodule