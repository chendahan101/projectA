/*------------------------------------------------------------------------------
 * File          : oflow_score_calc_calc_min_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
//`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"



module oflow_score_calc_calc_min_fsm #() (


	input logic clk,
	input logic reset_N ,
	
	// calc_min
	input logic done_calc_min, 
	output logic start_calc_min, 
	
	//buffer
	input logic done_read,

	//score_calc
	output logic done_score_calc,
	
	// similarity metric
	input logic done_similarity_metric
	
);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

logic last;
logic done_similarity_metric_reg;
	
typedef enum {idle_st,calc_min_st} sm_type; 
sm_type current_state;
sm_type next_state;

// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  




// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) done_similarity_metric_reg <= #1 0;
		else done_similarity_metric_reg <= #1 done_similarity_metric;             /////////////////////////
	
	end

// -----------------------------------------------------------       
//                			last REG	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) last <= #1 0;
		else if (done_read) last <= #1 1;
		else if (done_calc_min && last ) last <= #1 0;
	end

// -----------------------------------------------------------       
//                		done_score_calc
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) done_score_calc <= #1 0;
		else if(done_calc_min && last) done_score_calc <= #1 1;
		else  done_score_calc <= #1 0;
	end
			
 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	start_calc_min = 1'b0;
	//done_score_calc = 1'b0;
	case (current_state)
		idle_st: begin
			next_state = done_similarity_metric ? calc_min_st : idle_st;
		 end
		 
		calc_min_st: begin
			if (done_similarity_metric_reg) 
				start_calc_min = 1'b1;
			if(done_calc_min && last) begin
				//done_score_calc = 1'b1;
				next_state = idle_st;
			end
			else if(done_calc_min && ~last)
				next_state = idle_st;
		 end
		
		
		 
	 endcase
 end
		 
	 
endmodule