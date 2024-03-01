/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/
`define NUM_OF_METRICS 6
`define Inv_NUM_OF_METRICS 7'b0_0010101   //q1.6
`define cm_concate_len_bbox 22  // concate
`define position_concate_len_bbox 44  // concate
`define w_len_bbox 8  // we want the maximum size to be 200 by 8 bits: q8.0
`define h_len_bbox 8  // we want the maximum size to be 200 by 8 bits:	q8.0
`define weight_len 10 // explenation in ipad, q1.9
`define color_len 24
`define d_history_len 3
`define features_of_prev_len 133 // the total length of the features

`define iou_len 10 // number between 0 to 1 : q1.9
`define d_history_metric_len 6 // if d_history_len is 3, 0-5, the maximum result after shift will be 2^5=32, the we need 6 bits

`define sum_similarity_metric_len 35 //explenation in ipad q26.9
`define avg_similarity_metric_len 39
`define score_len 32
`define id_len 12

'define counter_size 4

module  oflow_similarity_metric( 
			input logic clk,
			input logic reset_N	,
			input logic [cm_concate_len_bbox-1:0] cm_concate_cur,
			input logic [position_concate_len_bbox-1:0] position_concate_cur,
			input logic [w_len_bbox-1:0] width_cur,
			input logic [h_len_bbox-1:0] height_cur,
			input logic [color_len-1:0] color1_cur,
			input logic [color_len-1:0] color2_cur,
			input logic [d_history_len-1:0] d_history_cur, 
				
			input logic [features_of_prev_len-1:0] features_of_prev,
			
			input logic [weight_len-1:0] iou_weight,
			input logic [weight_len-1:0] w_weight,
			input logic [weight_len-1:0] h_weight,
			input logic [weight_len-1:0] color1_weight,
			input logic [weight_len-1:0] color2_weight,
			input logic [weight_len-1:0] dhistory_weight,
			//input logic wr,
			//input logic [7:0] addr,
			//input logic  EN,
			
			output logic [score_len-1:0] score,
			output logic [id_len-1:0] id
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
	
	logic [cm_concate_len_bbox-1:0] cm_concate_prev;
	logic [position_concate_len_bbox-1:0] position_concate_prev;
	logic [w_len_bbox-1:0] width_prev;
	logic [h_len_bbox-1:0] height_prev;
	logic [color_len-1:0] color1_prev;
	logic [color_len-1:0] color2_prev;
	logic [d_history_len-1:0] d_history_prev;

	logic [weight_len-1:0] iou_metric; //q1.9
	logic [w_len_bbox-1:0] w_metric; // the maximum difference will be 200 so we want also 8 bits: q8.0
	logic [h_len_bbox-1:0] h_metric; // the maximum difference will be 200 so we want also 8 bits  q8.0
	logic [color_len-1:0] color1_metric;
	logic [color_len-1:0] color2_metric;
	logic [d_history_metric_len-1:0] d_history_metric; // the len of metric will be +1 the feature:

	logic [iou_len-1:0] iou;
	
	logic [sum_similarity_metric_len-1:0] sum_similarity_metric;
	logic [score_len-1:0] sum_similarity_metric_tranq;
	logic [avg_similarity_metric_len-1:0] avg_similarity_metric;

	logic [counter_size-1:0] counter;

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

			 .end_iou_en (end_iou_en),
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
			
			if(end_iou_en)
				next_state = avg_st;
		end
		
		avg_st: begin 
				
				
				sum_similarity_metric = ((iou_weight*iou_metric)[19:9] + w_weight*w_metric+h_weight*h_metric+color1_weight*color1_metric+
										color2_weight*color2_metric+ dhistory_weight*dhistory_metric);
				sum_similarity_metric_tranq = sum_similarity_metric[sum_similarity_metric_len-1:3];	
				
				/*
				//@@@@@@@@@@@@@@@@@@@@@@@ we need IP for division here @@@@@@@@@@@@@@@@@@@@@@
				avg_similarity_metric = sum_similarity_metric_tranq/`NUM_OF_METRICS; 
				*/
				
				avg_similarity_metric = sum_similarity_metric_tranq * `Inv_NUM_OF_METRICS //q27.12
				
				score = avg_similarity_metric[avg_similarity_metric_len-1:7]
				
				if (counter == 4'd10)
					next_state = idle_st;
		end
		
		
	endcase
end

	
	
	
endmodule