/*------------------------------------------------------------------------------
 * File          : oflow_registration.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

module  oflow_registration( 
			input logic clk,
			input logic reset_N	,
		
		
		
//score calc
	
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
	
//score board 
		
		
		//conflict resolve
		input logic  data_from_cr, // pointer
		input logic [`ROW_LEN-1:0] row_sel_from_cr,
		input logic [`ROW_LEN-1:0] row_to_change, // for change the pointer
		input logic write_to_pointer,//flag indicate we need to write to pointer
		output logic [(`SCORE_LEN*2)-1:0] score_to_cr,// we insert score0&score1
		output logic [(`ID_LEN*2)-1:0] id_to_cr,// we insert id0&id1
		
		
		
		//IDs
		output logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD],
		
		//core
		input logic ready_new_frame,
		
		
		
		//from interface
		input logic [`ROW_LEN-1:0] row_sel, // aka row_sel_to_pe
	

	//fsm registration
	// core
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic  start_registration,
	output logic done_registration, 
	
	//PE
	input logic [`PE_LEN-1:0] num_of_pe,
	output logic [`FEATURES_OF_PREV_LEN-1:0] data_out_pe

	
	
);
		
		
		
		
		
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
// out of oflow score calc
	logic [`SCORE_LEN-1:0] min_score_0; // min_score_0
	 logic [`ID_LEN-1:0] min_id_0; // id_0 of min score_0 
	 logic [`SCORE_LEN-1:0] min_score_1; // min_score_1
	 logic [`ID_LEN-1:0] min_id_1; // id_1 of min score_1
	 logic done_score_calc;
	 logic start_score_calc;
	 


//registration fsm
	 logic  start_score_board;
	 logic [`ROW_LEN-1:0] row_sel_by_set;
	 logic [`ID_LEN-1:0] id_first_frame;

//score board
	 logic done_score_board;
	 logic [`SCORE_LEN-1:0] min_score_0_to_score_board; // min_score_0
	 logic [`ID_LEN-1:0] min_id_0_to_score_board; // id_0 of min score_0 
	 logic [`SCORE_LEN-1:0] min_score_1_to_score_board; // min_score_1
	 logic [`ID_LEN-1:0] min_id_1_to_score_board; // id_1 of min score_1

//buffer
	logic [(`ID_LEN)-1:0] id_to_buffer;
	
// fe_mem
	logic [`ROW_LEN-1:0] addr_0;
	logic we_0;
	logic oe_0;
	logic [`FEATURES_OF_PREV_LEN-1:0] data_in_0;
	logic [`FEATURES_OF_PREV_LEN-1:0] data_out_0;
	logic [`FEATURES_OF_PREV_LEN-1:0] data_out_1;
	
// -----------------------------------------------------------       
//				Assignments
// ----------------------------------------------------------- 

assign min_score_0_to_score_board = (frame_num) ? min_score_0 : 0; 
assign min_id_0_to_score_board = (frame_num) ? min_id_0 : id_first_frame;
assign min_score_1_to_score_board = (frame_num) ? min_score_1 : 0; 
assign min_id_1_to_score_board = (frame_num) ? min_id_1 : 0;

assign data_out_pe = {data_out_0, id_to_buffer};
assign data_in_0 = {cm_concate_cur, position_concate_cur, width_cur, height_cur,
                    color1_cur, color2_cur};

assign we_0 = start_registration;
assign oe_0 = ~we_0; 					
				
assign addr_0 = (we_0) ? row_sel_by_set : row_sel;	

assign done_registration = done_score_board;			
// -----------------------------------------------------------       
//				Instanciation
// ----------------------------------------------------------- 
 
oflow_score_calc oflow_score_calc (
	.clk(clk),
	.reset_N(reset_N),
	.start_score_calc(start_score_calc),
	.cm_concate_cur(cm_concate_cur),
	.position_concate_cur(position_concate_cur),
	.width_cur(width_cur),
	.height_cur(height_cur),
	.color1_cur(color1_cur),
	.color2_cur(color2_cur),
	.done_read(done_read),
	.data_to_similarity_metric_0(data_to_similarity_metric_0),
	.data_to_similarity_metric_1(data_to_similarity_metric_1),
	.control_for_read_new_line(control_for_read_new_line),  // This output should be connected to relevant logic in the top module
	.iou_weight(iou_weight),
	.w_weight(w_weight),
	.h_weight(h_weight),
	.color1_weight(color1_weight),
	.color2_weight(color2_weight),
	.dhistory_weight(dhistory_weight),
	.min_score_0(min_score_0),
	.min_id_0(min_id_0),
	.min_score_1(min_score_1),
	.min_id_1(min_id_1),
	.done_score_calc(done_score_calc)
);


oflow_score_board oflow_score_board (
	.clk(clk),
	.reset_N(reset_N),
	.start_score_board(start_score_board),
	.row_sel_by_set(row_sel_by_set),
	.done_score_board(done_score_board),
	.min_score_0(min_score_0_to_score_board),
	.min_id_0(min_id_0_to_score_board),
	.min_score_1(min_score_1_to_score_board),
	.min_id_1(min_id_1_to_score_board),
	.data_from_cr(data_from_cr),
	.row_sel_from_cr(row_sel_from_cr),
	.row_to_change(row_to_change),
	.write_to_pointer(write_to_pointer),
	.score_to_cr(score_to_cr),
	.id_to_cr(id_to_cr),
	.id_to_buffer(id_to_buffer),
	.id_out(id_out),
	.ready_new_frame(ready_new_frame),
	.row_sel(row_sel)
);


oflow_registration_fsm oflow_registration_fsm (
	.clk(clk),
	.reset_N(reset_N),
	.frame_num(frame_num),
	.num_of_sets(num_of_sets),
	.start_registration(start_registration),
	.done_score_calc(done_score_calc),
	.start_score_calc(start_score_calc),
	.done_score_board(done_score_board),
	.start_score_board(start_score_board),
	.num_of_pe(num_of_pe),
	.row_sel_by_set(row_sel_by_set),
	.id_first_frame(id_first_frame)
);


mem #(
        .DATA_WIDTH(`FEATURES_OF_PREV_LEN-`ID_LEN),
        .ADDR_WIDTH(`ROW_LEN)
    )
	oflow_registration_fe_mem(.clk(clk),
	.reset_N(reset_N),
	.address_0(addr_0),
	.address_1(0),
	.data_in_0(data_in_0),
	.data_in_1(0),
	.data_out_0(data_out_0),
	.data_out_1(data_out_1),
	.cs_0(1'b1),
	.cs_1(1'b0),
	.we_0(we_0),
	.we_1(1'b0),
	.oe_0(oe_0),
	.oe_1(1'b0)
);
	
endmodule
