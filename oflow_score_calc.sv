/*------------------------------------------------------------------------------
 * File          : oflow_score_calc.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
//`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"



module oflow_score_calc #() (

	input logic clk,
	input logic reset_N,
	//registration
	input logic start_score_calc,
	
	//feature_extraction
	input logic [`CM_CONCATE_LEN-1:0] cm_concate_cur,
	input logic [`POSITION_CONCATE_LEN-1:0] position_concate_cur,
	input logic [`WIDTH_LEN-1:0] width_cur,
	input logic [`HEIGHT_LEN-1:0] height_cur,
	input logic [`COLOR_LEN-1:0] color1_cur,
	input logic [`COLOR_LEN-1:0] color2_cur,
	
	//buffer	
	input logic done_read, 	
	input logic [`DATA_TO_PE_WIDTH -1:0] data_to_similarity_metric_0,// we will change the d_history_field
	input logic [`DATA_TO_PE_WIDTH -1:0] data_to_similarity_metric_1,
	output logic control_for_read_new_line, // will be 1 one after both of similarity metrics done 2 cycles before the end, so we can read new line from the buffer that will be ready when we start new similarity_metric
	// we sure that the new line we read will not change the similarity calc before we end similarity because we have register of the score in the output
	
	//reg file
	input logic [`WEIGHT_LEN-1:0] iou_weight,
	input logic [`WEIGHT_LEN-1:0] w_weight,
	input logic [`WEIGHT_LEN-1:0] h_weight,
	input logic [`WEIGHT_LEN-1:0] color1_weight,
	input logic [`WEIGHT_LEN-1:0] color2_weight,
	input logic [`WEIGHT_LEN-1:0] dhistory_weight,
	
	// oflow_score_board
	output logic [`SCORE_LEN-1:0] min_score_0, // min_score_0
	output logic [`ID_LEN-1:0] min_id_0, // id_0 of min score_0 
	output logic [`SCORE_LEN-1:0] min_score_1, // min_score_1
	output logic [`ID_LEN-1:0] min_id_1, // id_1 of min score_1
	output logic done_score_calc
	
);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
logic start_similarity_metric_0;
logic start_similarity_metric_1;
logic done_similarity_metric_0;
logic done_similarity_metric_1;
logic [`SCORE_LEN-1:0] score_0;
logic [`ID_LEN-1:0] id_0;
logic [`SCORE_LEN-1:0] score_1;
logic [`ID_LEN-1:0] id_1;

logic [`ID_LEN-1:0] id_1_prev_frame;	
logic control_for_read_new_line_0;
logic control_for_read_new_line_1;	
	
logic done_calc_min;
logic start_calc_min;
// -----------------------------------------------------------       
//                  Assignments
// -----------------------------------------------------------  

assign id_1_prev_frame = data_to_similarity_metric_1[`ID_LEN-1:0];
assign control_for_read_new_line = (control_for_read_new_line_0 && (control_for_read_new_line_1 || ~(|id_1_prev_frame)) );

// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------


 // -----------------------------------------------------------       
 //						FSM – Async Logic
 // -----------------------------------------------------------	
 

 // -----------------------------------------------------------       
 //						instantiation
 // -----------------------------------------------------------		

//similarity_metric_0
 oflow_similarity_metric oflow_similarity_metric_0 (
		.clk(clk),
		.reset_N(reset_N),
		.start(start_similarity_metric_0),
		.cm_concate_cur(cm_concate_cur),
		.position_concate_cur(position_concate_cur),
		.width_cur(width_cur),
		.height_cur(height_cur),
		.color1_cur(color1_cur),
		.color2_cur(color2_cur),
		.features_of_prev(data_to_similarity_metric_0),
		.iou_weight(iou_weight),
		.w_weight(w_weight),
		.h_weight(h_weight),
		.color1_weight(color1_weight),
		.color2_weight(color2_weight),
		.dhistory_weight(dhistory_weight),
		.valid(done_similarity_metric_0),
		.control_for_read_new_line(control_for_read_new_line_0),
		.score(score_0),
		.id(id_0)
	);
	
	
 oflow_similarity_metric oflow_similarity_metric_1 (
		.clk(clk),
		.reset_N(reset_N),
		.start(start_similarity_metric_1),
		.cm_concate_cur(cm_concate_cur),
		.position_concate_cur(position_concate_cur),
		.width_cur(width_cur),
		.height_cur(height_cur),
		.color1_cur(color1_cur),
		.color2_cur(color2_cur),
		.features_of_prev(data_to_similarity_metric_1),
		.iou_weight(iou_weight),
		.w_weight(w_weight),
		.h_weight(h_weight),
		.color1_weight(color1_weight),
		.color2_weight(color2_weight),
		.dhistory_weight(dhistory_weight),
		.valid(done_similarity_metric_1),
	 .control_for_read_new_line(control_for_read_new_line_1),
		.score(score_1),
		.id(id_1)
	);

oflow_calc_min oflow_calc_min (
		.clk(clk),
		.reset_N(reset_N),
		.start_score_calc(start_score_calc),
		.start_calc_min(start_calc_min),
		.done_calc_min(done_calc_min),
		.score_0(score_0),
		.id_0(id_0),
		.score_1(score_1), // Assuming you have another score and id to connect here
		.id_1(id_1),       // You might need to adjust these signals based on your design
		.min_score_0(min_score_0),
		.min_id_0(min_id_0),
		.min_score_1(min_score_1),
		.min_id_1(min_id_1)
	);


 oflow_score_calc_similarity_metric_fsm oflow_score_calc_similarity_metric_fsm (
		.clk(clk),
		.reset_N(reset_N),
		.start_score_calc(start_score_calc),
		//.done_score_calc(done_score_calc),
		.done_read(done_read),
		.id_1(id_1_prev_frame),
		 .done_similarity_metric(done_similarity_metric_0 && (done_similarity_metric_1 || ~(|id_1_prev_frame)) ),
		.start_similarity_metric_0(start_similarity_metric_0),
		.start_similarity_metric_1(start_similarity_metric_1)
	);
 
oflow_score_calc_calc_min_fsm oflow_score_calc_calc_min_fsm (
	.clk(clk),
	.reset_N(reset_N) ,
	// calc_min
	.done_calc_min(done_calc_min), 
	.start_calc_min(start_calc_min),
	//buffer
	.done_read(done_read),
	//score_calc
	.done_score_calc(done_score_calc),
	// similarity metric
	.done_similarity_metric(done_similarity_metric_0 && (done_similarity_metric_1 || ~(|id_1_prev_frame)) )
 );
	 
endmodule