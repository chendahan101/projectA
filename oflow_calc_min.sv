/*------------------------------------------------------------------------------
* File          : oflow_calc_min.sv
* Project       : RTL
* Author        : epchof
* Creation date : Jul 28, 2024
* Description   :	
*------------------------------------------------------------------------------*/

	
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"



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
	output logic [`ID_LEN-1:0] min_id_1, // id_1 of min score_1 


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

logic [`SCORE_LEN-1:0] min_score_0_reg, // min_score_0
logic [`ID_LEN-1:0] min_id_0_reg, // id_0 of min score_0 
logic [`SCORE_LEN-1:0] min_score_1_reg, // min_score_1 (will be the maximum between min_score_0_reg and min_score_1_reg)
logic [`ID_LEN-1:0] min_id_1_reg, // id_1 of min score_1 (will be the id of the maximum between min_score_0_reg and min_score_1_reg)

typedef enum {idle_st, calc_min_st} sm_type; 
sm_type current_state;
sm_type next_state;




























































// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign min_score_0 = min_score_0_reg;
assign min_id_0 = min_id_0_reg;
assign min_score_1 = min_score_1_reg;
assign min_id_1 = min_id_1_reg;


// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
	
	
//--------------------min_score_0_reg and min_id_0_reg---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || start_score_calc) min_score_0_reg <= #1 `MAX_SCORE; // `MAX_SCORE can be {32{1'b1}}
		 else if (cur_state ==  calc_min_st && put_0_in_0) min_score_0_reg <= #1 score_0;
		 else if (cur_state ==  calc_min_st && put_1_in_0) min_score_0_reg <= #1 score_1;
		 
	  end
		
	always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || start_score_calc) min_id_0_reg <= #1 12'b0;
		 else if (cur_state ==  calc_min_st && put_0_in_0) min_id_0_reg <= #1 id_0;
		 else if (cur_state ==  calc_min_st && put_1_in_0) min_id_0_reg <= #1 id_1;
		
	  end	

//--------------------min_score_1_reg and min_id_1_reg---------------------------------	

	 
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || start_score_calc) min_score_1_reg <= #1 `MAX_SCORE; // `MAX_SCORE can be {32{1'b1}}
		 else if (cur_state ==  calc_min_st && put_min_0_in_1) min_score_1_reg <= #1 min_score_0_reg;
		 else if (cur_state ==  calc_min_st && put_0_in_1) min_score_1_reg <= #1 score_0;
		 else if (cur_state ==  calc_min_st && put_1_in_1) min_score_1_reg <= #1 score_1;
	  end

	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N || start_score_calc) min_id_1_reg <= #1 12'b0;
		 else if (cur_state ==  calc_min_st && put_min_0_in_1) min_id_1_reg <= #1 min_id_0_reg;
		 else if (cur_state ==  calc_min_st && put_0_in_1) min_id_1_reg <= #1 id_0;
		 else if (cur_state ==  calc_min_st && put_1_in_1) min_id_1_reg <= #1 id_1;
	  end

	  
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 //generate_done_registration = 1'b0; 
	 //start_registration_i = 1'b0;
	 
	 case (current_state)
		 idle_st: begin
			 next_state = start_calc_min ? calc_min_st: idle_st;	
			 
		 end
		 
		 calc_min_st: begin
			 
		    if(score_0 >= min_score_1_reg && score_1 >= min_score_1_reg) begin
				done_calc_min = 1'b1;
				next_state = idle_st;
			end
			if(score_0 >= min_score_1_reg && score_1 < min_score_1_reg) begin
				if (score_1 >= min_score_0_reg) begin
					put_1_in_1 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
				else begin
					put_min_0_in_1 = 1'b1;
					put_1_in_0 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
			end
			else if(score_0 < min_score_0_reg && score_0 > score_1 ) begin
				put_1_in_0 = 1'b1;
				put_0_in_1 = 1'b1;
				done_calc_min = 1'b1;
				next_state = idle_st;
			end	
			else if(score_0 < min_score_0_reg && score_0 <= score_1) begin
				if (score_1 >= min_score_1_reg) begin
					update_0_to_0 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
				else begin
					put_min_0_in_1 = 1'b1;
					put_0_in_0 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
			end	
			else if(score_0 >= min_score_0_reg && score_0 < min_score_1_reg ) begin
				if (score_1 >= min_score_1_reg) begin
					put_0_in_1 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
				else if (score_1 < min_score_0_reg) begin
					put_min_0_in_1 = 1'b1;
					put_1_in_0 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
				else if (score_0 < score_1) begin
					put_0_in_1 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
				else begin
					put_1_in_1 = 1'b1;
					done_calc_min = 1'b1;
					next_state = idle_st;
				end
			end
			
			
	 endcase
	 
 end
		  



endmodule