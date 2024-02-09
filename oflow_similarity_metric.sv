/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

module  oflow_similarity_metric( 
			input logic clk,
			input logic reset_N	,
			input logic [111:0] data_in,
			input logic wr,
			input logic [7:0] addr,
			input logic  EN,
			
			
			output logic [111:0] data_out
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	logic [31:0] iou_weight;
	logic [31:0] w_weight;
	logic [31:0] h_weight;
	logic [31:0] color1_weight;
	logic [31:0] color2_weight;
	logic [31:0] dhistory_weight;
	
	logic [31:0] iou_metric;
	logic [31:0] w_metric;
	logic [31:0] h_metric;
	logic [31:0] color1_metric;
	logic [31:0] color2_metric;
	logic [31:0] dhistory_metric;
	
	logic [31:0] sum_similarity_metric;
	logic [31:0] avg_similarity_metric;

	logic [3:0] counter;

	typedef enum {idle_st,calc_st,avg_st,iou_st} sm_type;
	sm_type current_state;
	sm_type next_state;
// -----------------------------------------------------------       
//				Instansiation
// -----------------------------------------------------------  
oflow_calc_iou oflow_calc_iou( 
			.clk(clk),
			 reset_N.(reset_N)	,

			 bbox_position_frame_k.(bbox_position_frame_k)	,   // {X_TL, Y_TL, X_BR, Y_BR}
			 bbox_position_frame_history.(bbox_position_frame_history), // {X_TL, Y_TL, X_BR, Y_BR}
			 bbox_w_frame_k.(bbox_w_frame_k),
			 bbox_h_frame_k.(bbox_h_frame_k),
			 bbox_w_frame_history.(bbox_w_frame_history),
			 bbox_h_frame_history.(bbox_h_frame_history),
			 
			 iou.(iou)  ); 
			

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (reset_N == 1'b0) begin
			current_state <= #1 idle_st;
		end
		else begin
			current_state <= #1 next_state;
		end
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (reset_N == 1'b0  ) begin
			counter <= #1 4'd0;
		else if(next_state == idle_st)	
			counter <= #1 4'd0;
		end
		else begin
			counter <= #1 counter + 1;
		end
	end
	
	
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	
	case (current_state)
		idle_st: begin
				next_state = calc_st;	
		end
		
		calc_st: begin
			iou_metric = iou;
			w_metric = abs()
			h_metric = abs()
			color1_metric_metric = abs()
			color2_metric = abs()
			dhistory_metric = abs()
			
			if(counter == 4'd8)
				next_state = avg_st;
		end
		
		avg_st: begin 
				
				sum_similarity_metric = (iou_weight*iou_metric+w_weight*w_metric+h_weight*h_metric+color1_weight*color1_metric_metric+color2_weight*color2_metric+ dhistory_weight*dhistory_metric)
				avg_similarity_metric =  
				if (counter == 4'd10)
					next_state = idle_st;
		end
		
		
	endcase
end

	
	
	
endmodule


endmodule