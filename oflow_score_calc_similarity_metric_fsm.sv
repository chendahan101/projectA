/*------------------------------------------------------------------------------
 * File          : oflow_score_calc_similarity_metric_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"



module oflow_score_calc_similarity_metric_fsm #() (


	input logic clk,
	input logic reset_N ,
	
	// registration
	input logic start_score_calc, 
	output logic done_score_calc, 

	
	// buffer
	input logic done_read,
	input logic [`ID_LEN-1:0] id_1,

	
	// similarity metric
	input logic done_similarity_metric,
	output logic start_similarity_metric_0,
	output logic start_similarity_metric_1
);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  


logic last;
	
typedef enum {idle_st,similarity_metric_st,wait_st} sm_type; 
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
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 always_comb begin
	 next_state = current_state;
	 last = 0;
	start_similarity_metric_0 = 0;
	start_similarity_metric_1 = 0;
	done_score_calc = 0;
	case (current_state)
		 idle_st: begin
			if (start_score_calc) begin 
				start_similarity_metric_0 = 1;
				start_similarity_metric_1 = |(id_1);
				next_state = similarity_metric_st;
			end 
		 end
		 
		 similarity_metric_st: begin
			next_state = wait_st;
		 end
		 
 
		wait_st: begin 
			if (done_similarity_metric && !last) begin 
				start_similarity_metric_0 = 1;
				start_similarity_metric_1 = |(id_1);
				next_state = similarity_metric_st;			
			end
			else if (done_similarity_metric && last) begin 
				last = 0;
				done_score_calc = 1;
				next_state = idle_st;			
			end

				
		end
		
		 
	 endcase
 end
		 
	 
endmodule