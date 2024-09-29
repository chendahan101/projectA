/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

//`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

`define R_CHANNEL_BITS 7:0
`define G_CHANNEL_BITS 15:8
`define B_CHANNEL_BITS 23:16

//`define FRACTION_RANGE 19:0
//`define INTEGER_RANGE `AVG_SIMILARITY_METRIC_LEN-1:20
//`define FRACTION_SIZE_AFTER_OF 21
//`define INTEGER_SIZE_AFTER_OF 25






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
			
				
			input logic [`DATA_TO_PE_WIDTH-1:0] features_of_prev,
			
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
			output logic control_for_read_new_line, // we want to start read new line after 2 cycles before the end
	
			output logic [`SCORE_LEN-1:0] score, // q26.6
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
	
	logic [`AVG_WIDTH_AFTER_OF-1:0] avg_similarity_metric;

	logic [`COUNTER_SIZE-1:0] counter;
	logic [`SCORE_LEN-1:0] score_reg;
	logic [`ID_LEN-1:0] id_reg;

	logic [`AVG_WIDTH_AFTER_OF-1:0] color1_mult;
	logic [`AVG_WIDTH_AFTER_OF-1:0] color2_mult;
	logic [`AVG_WIDTH_AFTER_OF-1:0] iou_mult;
	logic [`AVG_WIDTH_AFTER_OF-1:0] w_mult;
	logic [`AVG_WIDTH_AFTER_OF-1:0] h_mult;
	logic [`AVG_WIDTH_AFTER_OF-1:0] history_mult;
	



	
	
	

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

	assign score = score_reg;
	assign id = id_reg ;
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
		if (!reset_N || current_state == idle_st) counter <= #1 4'd0;
		else if(next_state != current_state )	counter <= #1 4'd0;
		else counter <= #1 counter + 1;
		
	end
	
//--------------------score_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) score_reg <= #1 0;
		 else if(valid)	score_reg <= #1 avg_similarity_metric[`AVG_INDEX];	// q  26.6
	end			
//--------------------id_reg---------------------------------	
	 always_ff @(posedge clk or negedge reset_N) begin
		 if (!reset_N) id_reg <= #1 0;
		 else if(current_state == calc_st)	id_reg <= #1 		features_of_prev[`ID_LEN-1:0];	// q  26.6
	end		 
 /*//--------------------start iou---------------------------------	
		  always_ff @(posedge clk or negedge reset_N) begin
			  if (!reset_N) start_iou <= #1 1'b0;
			  else if(start && current_state == idle_st)	start_iou <= #1 1'b1;
			  else start_iou <= #1 1'b0;
		 end
		 */	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	control_for_read_new_line = 1'b0;
	start_iou = 1'b0;
	valid = 1'b0; //of similarity
	//score = 0;
	case (current_state)
		idle_st: begin
			start_iou = start ? 1:0;
			next_state = start ? calc_st:idle_st;	
				
		end
		
		calc_st: begin
				iou_metric = iou;
				w_metric = l1_distance(width_prev,width_cur);
				h_metric = l1_distance(height_prev,height_cur);
				color1_metric = l1_distance_for_rgb(color1_prev,color1_cur);
				color2_metric = l1_distance_for_rgb(color2_prev,color2_cur);
				d_history_metric = 1 << d_history_prev;
			
			if(valid_iou)
				next_state = avg_st;
		end
		
		avg_st: begin 
			iou_mult = iou_weight*iou_metric_pad;
			color1_mult = color1_weight*color1_metric_pad;
			color2_mult = color2_weight*color2_metric_pad;
			w_mult = w_weight*w_metric_pad;
			h_mult = h_weight*h_metric_pad;
			history_mult = dhistory_weight*d_history_metric_pad;
			
			avg_similarity_metric = iou_mult+color1_mult+color2_mult+w_mult+h_mult+history_mult;
				
				if (counter == 4'd2) begin // COUNTER OF THE ABOVE CALC OF THE sum_similarity_metric,avg_similarity_metric
					control_for_read_new_line = 1'b1; // we want to start read new line after 2 cycles before the end
				end
				if (counter == 4'd4) begin // COUNTER OF THE ABOVE CALC OF THE sum_similarity_metric,avg_similarity_metric
					// score = avg_similarity_metric[`AVG_INDEX];
					valid = 1;
					next_state = idle_st;	
				end
		end
		
		
	endcase
end

	
function [`WIDTH_LEN-1:0] l1_distance (input [`WIDTH_LEN-1:0] a,input [`WIDTH_LEN-1:0] b);
	l1_distance = (a>b) ? (a-b):(b-a);
endfunction

function [`COLOR_LEN-1:0] l1_distance_for_rgb (input [`COLOR_LEN-1:0] a,input [`COLOR_LEN-1:0] b);
	l1_distance_for_rgb = l1_distance(a[`R_CHANNEL_BITS],b[`R_CHANNEL_BITS]) + l1_distance(a[`G_CHANNEL_BITS],b[`G_CHANNEL_BITS])
	+ l1_distance(a[`B_CHANNEL_BITS],b[`B_CHANNEL_BITS]);
endfunction
	
	
	
endmodule