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

























































