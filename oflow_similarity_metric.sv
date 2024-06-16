/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"


module  oflow_similarity_metric( 
			input logic clk,
			input logic reset_N	,
			input logic start	,
			
			input logic [`CM_CONCATE_LEN-1:0] cm_concate_cur,
			input logic [`POSITION_CONCATE_LEN-1:0] position_concate_cur,
			input logic [`WIDTH_LEN-1:0] width_cur,
			input logic [`HEIGHT_LEN-1:0] height_cur,
			input logic [`COLOR_LEN-1:0] color1_cur,
			input logic [`COLOR_LEN-1:0] color2_cur,
			input logic [`D_HISTORY_LEN-1:0] d_history_cur, 
				
			input logic [`FEATURE_OF_PREV_LEN-1:0] features_of_prev,
			
			input logic [`WEIGHT_LEN-1:0] iou_weight,
			input logic [`WEIGHT_LEN-1:0] w_weight,
			input logic [`WEIGHT_LEN-1:0] h_weight,
			input logic [`WEIGHT_LEN-1:0] color1_weight,
			input logic [`WEIGHT_LEN-1:0] color2_weight,
			input logic [`WEIGHT_LEN-1:0] dhistory_weight,
			//input logic wr,
			//input logic [7:0] addr,
			//input logic  EN,
			
			output logic valid ,
			output logic [`SCORE_LEN-1:0] score,
			output logic [`ID_LEN-1:0] id
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
	
	logic [`CM_CONCATE_LEN-1:0] cm_concate_prev;
	logic [`POSITION_CONCATE_LEN-1:0] position_concate_prev;
	logic [`WIDTH_LEN-1:0] width_prev;
	logic [`HEIGHT_LEN-1:0] height_prev;
	logic [`COLOR_LEN-1:0] color1_prev;
	logic [`COLOR_LEN-1:0] color2_prev;
	logic [`D_HISTORY_LEN-1:0] d_history_prev;

	logic [`IOU_LEN-1:0] iou_metric; //q0.22
	logic [`WIDTH_LEN-1:0] w_metric; // the maximum difference will be 200 so we want also 8 bits: q8.0
	logic [`HEIGHT_LEN-1:0] h_metric; // the maximum difference will be 200 so we want also 8 bits  q8.0
	logic [`COLOR_LEN-1:0] color1_metric; //q24.0
	logic [`COLOR_LEN-1:0] color2_metric; //q24.0
	logic [`D_HISTORY_METRIC-1:0] d_history_metric; // the len of metric will be +1 the feature:
	
	
// padding vector for fixed point of 10 fractinal bit q*.10
	logic [`IOU_PAD_LEN-1:0] iou_metric_pad; //q0.10
	logic [`WIDTH_PAD_LEN-1:0] w_metric_pad; // the maximum difference will be 200 so we want also 8 bits: q8.10
	logic [`HEIGHT_PAD_LEN-1:0] h_metric_pad; // the maximum difference will be 200 so we want also 8 bits  q8.10
	logic [`COLOR_PAD_LEN-1:0] color1_metric_pad; //q24.10
	logic [`COLOR_PAD_LEN-1:0] color2_metric_pad; //q24.10
	logic [`D_HISTORY_METRIC_PAD-1:0] d_history_metric_pad; // the len of metric will be +1 the feature:q6.10

	logic valid_iou;
	logic start_iou;
	logic [`IOU_LEN-1:0] iou;
	
	logic [`AVG_SIMILARITY_METRIC_LEN-1:0] avg_similarity_metric;

	logic [`COUNTER_SIZE-1:0] counter;

	typedef enum {idle_st,calc_st,avg_st,iou_st} sm_type;
	sm_type current_state;
	sm_type next_state;
	
// -----------------------------------------------------------       
//				Assignments
// ----------------------------------------------------------- 	

	
	
	assign cm_concate_prev = features_of_prev[`CM_CONCATE_INDEX];
	assign position_concate_prev = features_of_prev[`POSITION_CONCATE_PREV_INDEX];
	assign width_prev = features_of_prev[`WIDTH_PREV_INDEX];
	assign height_prev = features_of_prev[`HEIGHT_PREV_INDEX];
	assign color1_prev = features_of_prev[`COLOR1_PREV_INDEX];
	assign color2_prev = features_of_prev[`COLOR2_PREV_INDEX];
	assign d_history_prev = features_of_prev[`D_HISTORY_PREV_INDEX]; 

	assign iou_metric_pad = iou_metric[`IOU_PAD_INDEX]; //q0.10
	assign w_metric_pad = {w_metric, {10{1'b0}}}; // the maximum difference will be 200 so we want also 8 bits: q8.10
	assign h_metric_pad = {h_metric, {10{1'b0}}}; // the maximum difference will be 200 so we want also 8 bits  q8.10
	assign color1_metric_pad = {color1_metric, {10{1'b0}}}; //q24.10
	assign color2_metric_pad = {color2_metric, {10{1'b0}}};//q24.10
	assign d_history_metric_pad = {d_history_metric, {10{1'b0}}}; // the len of metric will be +1 the feature:q6.10	

// -----------------------------------------------------------       
//				Instantiation
// -----------------------------------------------------------  
oflow_calc_iou oflow_calc_iou( 
		.clk(clk),
		.reset_N(reset_N),
		.start(start_iou),
		.bbox_position_frame_k(position_concate_cur),   // {X_TL, Y_TL, X_BR, Y_BR}
		.bbox_position_frame_history(position_concate_prev), // {X_TL, Y_TL, X_BR, Y_BR}
		.bbox_w_frame_k(width_cur),
		.bbox_h_frame_k(height_cur),
		.bbox_w_frame_history(width_prev),
		.bbox_h_frame_history(height_prev),
		
		.valid_iou (valid_iou),
		.iou(iou)  ); 
				

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) current_state <= #1 idle_st;
		else current_state <= #1 next_state;
	
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) counter <= #1 4'd0;
		else if(current_state == avg_st)	counter <= #1 4'd0;
		else counter <= #1 counter + 1;
		
	end
	
	
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	valid = 1;//of similarity
	start_iou = 0;
	score = 0;
	case (current_state)
		idle_st: begin
			next_state = start ? calc_st:idle_st;	
			start_iou = start ? 1:0;	
		end
		
		calc_st: begin
				iou_metric = iou;
				w_metric = l1_distance(width_prev,width_cur);
				h_metric = l1_distance(height_prev,height_cur);
				color1_metric = l1_distance(color1_prev,color1_cur);
				color2_metric = l1_distance(color2_prev,color2_cur);
				d_history_metric = 1 << d_history_prev;
			
			if(valid_iou)
				next_state = avg_st;
		end
		
		avg_st: begin 
				
				avg_similarity_metric = iou_weight*iou_metric_pad + w_weight*w_metric_pad+h_weight*h_metric_pad+color1_weight*color1_metric_pad+
										color2_weight*color2_metric_pad+ dhistory_weight*d_history_metric_pad;
					
				score = avg_similarity_metric[`AVG_INDEX];
				
				if (counter == 4'd10) begin // COUNTER OF THE ABOVE CALC OF THE sum_similarity_metric,avg_similarity_metric
					next_state = idle_st;
					valid = 1;
				end
		end
		
		
	endcase
end

	
function [`COLOR_LEN-1:0] l1_distance (input [`COLOR_LEN-1:0] a,input [`COLOR_LEN-1:0] b);
	l1_distance = (a>b) ? (a-b):(b-a);
endfunction
	
endmodule