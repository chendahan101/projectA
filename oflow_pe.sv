/*------------------------------------------------------------------------------
 * File          : oflow_pe.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/
//`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
//`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module  oflow_pe( 
			input logic clk,
			input logic reset_N	,
			
			
			// reg_file
			input logic [`WEIGHT_LEN-1:0] iou_weight,
			input logic [`WEIGHT_LEN-1:0] w_weight,
			input logic [`WEIGHT_LEN-1:0] h_weight,
			input logic [`WEIGHT_LEN-1:0] color1_weight,
			input logic [`WEIGHT_LEN-1:0] color2_weight,
			input logic [`WEIGHT_LEN-1:0] dhistory_weight,
			

			// dma
			input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_from_dma,

			// core
			input logic[`PE_LEN-1:0] num_of_pe,
			// core_fsm
			input logic ready_new_frame,
			input logic ready_new_set,
			input logic flg_for_sampling_last_set,
			input logic [`SET_LEN-1:0] num_of_sets, 
			input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,
			input logic start_fe,
			input logic not_start_fe,
			
			input logic start_registration,
			input logic not_start_registration,
			input logic done_pe,
			output logic done_fe,
			output logic done_registration,
			output logic done_score_calc,
			output logic control_for_read_new_line, // the similarity_metric will update this to AND of similarity_metric_0 & similarity_metric_1 in the registration
			

			// interface between buffer&pe
			input logic done_read_to_pe, 	
			input logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_0,// we will change the d_history_field
			input logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_1,// we will change the d_history_field
			input logic [`ROW_LEN-1:0] row_sel_to_pe,
			output logic [`FEATURE_OF_PREV_LEN-1:0] data_out_pe ,
			
			// conflict_resolve

			//IDs
			output logic [`ID_LEN-1:0] id_out [`MAX_ROWS_IN_SCORE_BOARD-1:0],
			
			
			//interface between pe to cr
			output logic [`SCORE_LEN-1:0] score_to_cr_from_pe ,  
			output logic [`ID_LEN-1:0] id_to_cr_from_pe,  
			input logic [`ROW_LEN-1:0] row_sel_to_pe_from_cr,  //which row to read from score board
			input logic  write_to_pointer_to_pe , //for write to score_board
			input logic write_to_id_to_pe, //flag indicate we need to write to id (new bbox)
			input logic [(`ID_LEN)-1:0] data_from_cr_id_to_pe, // id ( new bbox)
			input logic  data_from_cr_pointer_to_pe, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
			input logic [`ROW_LEN-1:0] row_to_change_to_pe //for write to score_board

	
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
	// for registration
	 logic [`CM_CONCATE_LEN-1:0] cm_concate;
	 logic [`POSITION_CONCATE_LEN-1:0] position_concate;
	 logic [`WIDTH_LEN-1:0] width;
	 logic [`HEIGHT_LEN-1:0] height;
	 logic [`COLOR_LEN-1:0] color1;
	 logic [`COLOR_LEN-1:0] color2;
	// logic [`D_HISTORY_LEN-1:0] d_history; 
	
	
	


// -----------------------------------------------------------       
//				Instantiation
// -----------------------------------------------------------  
oflow_feature_extraction oflow_feature_extraction(
		
	.clk (clk),
	.reset_N (reset_N),
	
	.done_pe(done_pe),
	.start_fe (start_fe), // feature_extraction enable 
	.not_start_fe(not_start_fe), // for not full sets
	.done_fe   (done_fe),
	
	// dma
	.bbox (bboxes_from_dma),
 
	// outputs to registration
	.cm_concate(cm_concate),
	.position_concate(position_concate),
	.width(width),
	.height(height),
	.color1(color1),
	.color2(color2)
	//.d_history(d_history)
	);


oflow_registration oflow_registration( 
	.clk(clk),
	.reset_N(reset_N), 
	

	// reg_file
	.iou_weight(iou_weight),
	.w_weight(w_weight),
	.h_weight(h_weight),
	.color1_weight(color1_weight),
	.color2_weight(color2_weight),
	.dhistory_weight(dhistory_weight),

	//core
	.num_of_pe(num_of_pe),
	// core_fsm
	.ready_new_frame(ready_new_frame),
	.ready_new_set(ready_new_set),
	.flg_for_sampling_last_set(flg_for_sampling_last_set),
	.num_of_sets(num_of_sets),
	.frame_num(frame_num),
	.done_fe(done_fe),
	.start_registration(start_registration),
	.not_start_registration(not_start_registration),
	.done_registration(done_registration), 
	.done_score_calc(done_score_calc),
	.control_for_read_new_line(control_for_read_new_line), // we want to start read new line after 2 cycles before the end

	// interface between buffer&pe
	.done_read (done_read_to_pe),
	.data_to_similarity_metric_0(data_to_pe_0),// we will change the d_history_field 
	.data_to_similarity_metric_1(data_to_pe_1),// we will change the d_history_field
	.row_sel_to_pe(row_sel_to_pe),
	.data_out_pe(data_out_pe), // for write to mem the features
	
	// inputs from feature_extraction
	.cm_concate_cur(cm_concate),
	.position_concate_cur(position_concate),
	.width_cur(width),
	.height_cur(height),
	.color1_cur(color1),
	.color2_cur(color2),
	//.d_history(d_history), 

	//IDs
	.id_out(id_out),
	
	
		
	//cr
	.score_to_cr_from_pe(score_to_cr_from_pe) ,  
	.id_to_cr_from_pe(id_to_cr_from_pe),  
	.row_sel_to_pe_from_cr(row_sel_to_pe_from_cr),  //which row to read from score board
	.write_to_pointer_to_pe(write_to_pointer_to_pe) , //for write to score_board the pointer
	.write_to_id_to_pe(write_to_id_to_pe), //for write to score_board the id
	.data_from_cr_pointer_to_pe(data_from_cr_pointer_to_pe), // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	.data_from_cr_id_to_pe(data_from_cr_id_to_pe),
	.row_to_change_to_pe(row_to_change_to_pe) //for write to score_board
	
	);



endmodule