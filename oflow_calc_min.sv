/*------------------------------------------------------------------------------
 * File          : oflow_calc_min.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jul 28, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

	 

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`define MAX_SCORE {`SCORE_LEN{1'b1}} 


module oflow_calc_min #() (
	//inputs
	input logic clk,
	input logic reset_N,
	
	input logic start_score_calc, 
	
	input logic start_calc_min, 
	output logic done_calc_min,

	// oflow_similarity_metric IF
	input logic [`SCORE_LEN-1:0] score_0, // score from similarity_metric_0
	input logic [`ID_LEN-1:0] id_0, // id_0
	input logic [`SCORE_LEN-1:0] score_1, // score from similarity_metric_1
	input logic [`ID_LEN-1:0] id_1, // id_1

	 
	// oflow_score_board
	output logic [`SCORE_LEN-1:0] min_score_0, // min_score_0
	output logic [`ID_LEN-1:0] min_id_0, // id_0 of min score_0 
	output logic [`SCORE_LEN-1:0] min_score_1, // min_score_1
	output logic [`ID_LEN-1:0] min_id_1 // id_1 of min score_1 
);

// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

logic [`SCORE_LEN-1:0] min_score_0_reg; // min_score_0
logic [`ID_LEN-1:0] min_id_0_reg; // id_0 of min score_0 
logic [`SCORE_LEN-1:0] min_score_1_reg; // min_score_1 (will be the maximum between min_score_0_reg and min_score_1_reg)
logic [`ID_LEN-1:0] min_id_1_reg; // id_1 of min score_1 (will be the id of the maximum between min_score_0_reg and min_score_1_reg)
logic [1:0] min1 ,min0;
logic put_0_in_0 ,put_1_in_0 ,put_0_in_1 ,put_1_in_1  , put_min_0_in_1, dont_change_0, dont_change_1 ;




typedef enum {idle_st, calc_min_st} sm_type; 
sm_type current_state;
sm_type next_state;


// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
	
	
	//--------------------done_calc_min---------------------------------	
	always_ff @(posedge clk or negedge reset_N) begin
	   if (!reset_N ) done_calc_min <= #1 1'b0;
	   else if(current_state == calc_min_st && next_state == idle_st)	done_calc_min <= #1 1'b1;
	   else done_calc_min <= #1 1'b0;   
	end	
//--------------------min_score_0_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) min_score_0_reg <= #1  `MAX_SCORE;
		else begin 
		
			if (start_score_calc) min_score_0_reg <= #1  `MAX_SCORE;
			else if(put_0_in_0 )	min_score_0_reg <= #1 score_0;
			else if(put_1_in_0 )  min_score_0_reg <= #1 score_1;
			else if (dont_change_0) min_score_0_reg <= #1 min_score_0_reg;
		
		end
		
		
		
		
		
	
	 end
//--------------------min_score_1_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) min_score_1_reg <= #1 `MAX_SCORE ;
		else begin 
			if (start_score_calc) min_score_1_reg <= #1 `MAX_SCORE ;
			else if(put_0_in_1 )	min_score_1_reg <= #1 score_0;
			else if(put_1_in_1 )  min_score_1_reg <= #1 score_1;
			else if(put_min_0_in_1 )  min_score_1_reg <= #1 min_score_0_reg;
			else if(dont_change_1)	min_score_1_reg <= #1 min_score_1_reg;
		
		end
	 end
	 
	//--------------------min_id_0_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) min_id_0_reg <= #1 0 ;
		else begin 
			if (start_score_calc) min_id_0_reg <= #1 0 ;
			else if(put_0_in_0 )	min_id_0_reg <= #1 id_0;
			else if(put_1_in_0 )  min_id_0_reg <= #1 id_1;
		end 
	 end
//--------------------min_id_1_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) min_id_1_reg <= #1 0 ;
		else begin 
			if (start_score_calc) min_id_1_reg <= #1 0 ;
			else if(put_0_in_1 )	min_id_1_reg <= #1 id_0;
			else if(put_1_in_1 )  min_id_1_reg <= #1 id_1;
			else if(put_min_0_in_1 )  min_id_1_reg <= #1 min_id_0_reg;
		end 
	 end
	 
	  
	 
	 
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 
	 //done_calc_min = 1'b0;
	 
	 min0 = 2'b00;
	 min1 = 2'b00;
	 
	 put_0_in_0 = 1'b0;
	 put_1_in_0 = 1'b0;
	 put_0_in_1 = 1'b0;	
	 put_1_in_1 = 1'b0 ;
	 put_min_0_in_1 = 1'b0;
	 
	 dont_change_0 = 1'b0;
	 dont_change_1 = 1'b0;
	 
	 case (current_state)
		idle_st: begin
			 next_state = start_calc_min ? calc_min_st: idle_st;	
			 
		 end
		 
		 calc_min_st: begin

			// score_0-00 score_1-01 min_score_0_reg-10
			 if (score_0 < min_score_0_reg && score_1 < min_score_0_reg) begin
				 if(score_0 <= score_1) begin
				     min0 = 2'b01;
				   	 min1 = 2'b10;                                   // before this was <= instead of =
				 end
				 else begin
					 min0 = 2'b10;
					 min1 = 2'b01;                                  
				 end
			 end
		 
			 else if (score_0 < min_score_0_reg && score_1 >= min_score_0_reg) begin
						min0 = 2'b01;
						min1 = 2'b11;  
			 end
			 
			 else if (score_0 >= min_score_0_reg && score_1 < min_score_0_reg) begin
						min0 = 2'b10;
						min1 = 2'b11;
			 end
			 
			 else if ( (score_0 >= min_score_0_reg && score_0 < min_score_1_reg) && (score_1 >= min_score_0_reg && score_1 < min_score_1_reg)) begin
						 if(score_0 <= score_1) begin
							 min0 = 2'b00;
							 min1 = 2'b01;
						 end
						 else begin
							 min0 = 2'b00;
							 min1 = 2'b10;                                  
						 end
			 end
			 
			 else if ( (score_0 >= min_score_0_reg && score_0 < min_score_1_reg) &&  score_1 >= min_score_1_reg) begin
					 min0 = 2'b00;
					 min1 = 2'b01;
			 end
			 
			 else if (  score_0 >= min_score_1_reg && (score_1 >= min_score_0_reg && score_1 < min_score_1_reg)) begin
				 	 min0 = 2'b00;
					 min1 = 2'b10;                                  
			 end	
			 
			 else if (  score_0 >= min_score_1_reg && score_1 >= min_score_1_reg) begin
				 min0 = 2'b00;
				 min1 = 2'b00;   
			 end	
			 										
						
			put_0_in_0 = (min0==2'b01);
			put_1_in_0 = (min0==2'b10);
			
			put_0_in_1 = (min1==2'b01);
			put_1_in_1 = (min1==2'b10);
			put_min_0_in_1 = (min1==2'b11);
			
			dont_change_0 = (min0==2'b00);
			dont_change_1 = (min1==2'b00);
			
			next_state = idle_st;
			//done_calc_min = 1;
			
		 end
		 
		 
	 endcase
	 
 end
 
 // -----------------------------------------------------------       
 //             Assignments
 // -----------------------------------------------------------  
	  
	assign min_score_0 = min_score_0_reg;
	assign min_score_1 = min_score_1_reg;
	assign min_id_0 = min_id_0_reg;
	assign min_id_1 = min_id_1_reg ;

	 
	 
	 
endmodule























































