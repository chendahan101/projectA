/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/
`define NUM_OF_METRICS 6

module  oflow_similarity_metric( 
			input logic clk,
			input logic reset_N	,
			input logic [21:0] cm_concate_cur,
			input logic [43:0] position_concate_cur,
			input logic [10:0] width_cur,
			input logic [10:0] height_cur,
			input logic [23:0] color1_cur,
			input logic [23:0] color2_cur,
			input logic [7:0] d_history_cur, 
				
			input logic [155:0] features_of_prev,
			
			input logic [31:0] iou_weight,
			input logic [31:0] w_weight,
			input logic [31:0] h_weight,
			input logic [31:0] color1_weight,
			input logic [31:0] color2_weight,
			input logic [31:0] dhistory_weight,
			//input logic wr,
			//input logic [7:0] addr,
			//input logic  EN,
			
			output logic [31:0] score,
			output logic [11:0] id
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
	
	logic [21:0] cm_concate_prev;
	logic [43:0] position_concate_prev;
	logic [10:0] width_prev;
	logic [10:0] height_prev;
	logic [23:0] color1_prev;
	logic [23:0] color2_prev;
	logic [7:0] d_history_prev;

	logic [31:0] iou_metric;
	logic [31:0] w_metric;
	logic [31:0] h_metric;
	logic [31:0] color1_metric;
	logic [31:0] color2_metric;
	logic [31:0] d_history_metric;

	logic [21:0] iou;
	
	logic [31:0] sum_similarity_metric;
	logic [31:0] avg_similarity_metric;

	logic [3:0] counter;

	typedef enum {idle_st,calc_st,avg_st,iou_st} sm_type;
	sm_type current_state;
	sm_type next_state;
	
// -----------------------------------------------------------       
//				Assignments
// ----------------------------------------------------------- 	
	
	assign cm_concate_prev = features_of_prev[155:134];
	assign position_concate_prev = features_of_prev[133:90];
	assign width_prev = features_of_prev[89:79];
	assign height_prev = features_of_prev[78:68];
	assign color1_prev = features_of_prev[67:44];
	assign color2_prev = features_of_prev[43:20];
	assign d_history_prev = features_of_prev[19:12]; 



// -----------------------------------------------------------       
//				Instantiation
// -----------------------------------------------------------  
oflow_calc_iou oflow_calc_iou( 
			.clk(clk),
			.reset_N(reset_N)	,

			 .bbox_position_frame_k(position_concate_cur)	,   // {X_TL, Y_TL, X_BR, Y_BR}
			 .bbox_position_frame_history(position_concate_prev), // {X_TL, Y_TL, X_BR, Y_BR}
			 .bbox_w_frame_k(width_cur),
			 .bbox_h_frame_k(height_cur),
			 .bbox_w_frame_history(width_prev),
			 .bbox_h_frame_history(height_prev),
			 
			 .iou(iou)  ); 
			

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) 
			current_state <= #1 idle_st;
		else 
			current_state <= #1 next_state;
	
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N)
			counter <= #1 4'd0;
		else if(next_state == idle_st)	
			counter <= #1 4'd0;
		else 
			counter <= #1 counter + 1;
		
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
			if(width_cur < width_prev)
				w_metric = width_prev - width_cur;
			else w_metric = width_cur - width_prev;
			if(height_cur < height_prev)
				h_metric = height_prev - height_cur;
			else h_metric = height_cur - height_prev;
			if(color1_cur < color1_prev)
				color1_metric = color1_prev - color1_cur;
			else color1_metric = color1_cur - color1_prev;
			if(color2_cur < color2_prev)
				color2_metric = color2_prev - color2_cur;
			else color2_metric = color2_cur - color2_prev;
			d_history_metric = 1 << dhistory_prev;
			
			if(counter == 4'd8)
				next_state = avg_st;
		end
		
		avg_st: begin 
				
				sum_similarity_metric = (iou_weight*iou_metric+w_weight*w_metric+h_weight*h_metric+color1_weight*color1_metric_metric+
										color2_weight*color2_metric+ dhistory_weight*dhistory_metric);
				avg_similarity_metric = sum_similarity_metric/`NUM_OF_METRICS; 
				if (counter == 4'd10)
					next_state = idle_st;
		end
		
		
	endcase
end

	
	
	
endmodule