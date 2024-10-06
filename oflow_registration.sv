/*------------------------------------------------------------------------------
 * File          : oflow_registration.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/


`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


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
		
		
		
		
		
		//IDs
		output logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD],
		
		//core
		input logic ready_new_frame,
		
		
		
		//from interface between buffer
		input logic [`ROW_LEN-1:0] row_sel_to_pe, // aka row_sel_to_pe
	

	//fsm registration
	// core
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic  start_registration,
	input logic not_start_registration,
	output logic done_registration, 
	output logic done_score_calc,
	
	//PE
	input logic [`PE_LEN-1:0] num_of_pe,
	output logic [`FEATURE_OF_PREV_LEN-1:0] data_out_pe,
	
	//Cr
	//interface between pe to cr
	input logic [`ROW_LEN-1:0] row_sel_to_pe_from_cr,  //which row to read from score board
	input logic  write_to_pointer_to_pe , //for write to score_board
	input logic  data_to_score_board_to_pe, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
	input logic [`ROW_LEN-1:0] row_to_change_to_pe, //for write to score_board
	output logic [`SCORE_LEN-1:0] score_to_cr_from_pe ,  
	output logic [`ID_LEN-1:0] id_to_cr_from_pe  
	
	
);
		
		
		
		
		
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  
// out of oflow score calc
	logic [`SCORE_LEN-1:0] min_score_0; // min_score_0
	 logic [`ID_LEN-1:0] min_id_0; // id_0 of min score_0 
	 logic [`SCORE_LEN-1:0] min_score_1; // min_score_1
	 logic [`ID_LEN-1:0] min_id_1; // id_1 of min score_1
	// logic done_score_calc;
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
	logic [`ROW_LEN-1:0] addr;
	logic we;
	
	//logic oe_0;
	logic [`FEATURE_EXTRACTION_ONLY-1:0] data_in;
	logic [`FEATURE_EXTRACTION_ONLY-1:0] data_out;
	//logic [`FEATURE_OF_PREV_LEN-1:0] data_out_1;
	
	
	// fe registers
	 logic [`CM_CONCATE_LEN-1:0] cm_concate_cur_reg;
	 logic [`POSITION_CONCATE_LEN-1:0] position_concate_cur_reg;
	 logic [`WIDTH_LEN-1:0] width_cur_reg;
	 logic [`HEIGHT_LEN-1:0] height_cur_reg;
	 logic [`COLOR_LEN-1:0] color1_cur_reg;
	 logic [`COLOR_LEN-1:0] color2_cur_reg;
			
// -----------------------------------------------------------       
//				Assignments
// ----------------------------------------------------------- 

assign min_score_0_to_score_board = (frame_num) ? min_score_0 : 0; 
assign min_id_0_to_score_board = (frame_num) ? min_id_0 : id_first_frame;
assign min_score_1_to_score_board = (frame_num) ? min_score_1 : 0; 
assign min_id_1_to_score_board = (frame_num) ? min_id_1 : 0;

assign data_out_pe = {data_out, id_to_buffer};
assign data_in = {cm_concate_cur_reg, position_concate_cur_reg, width_cur_reg, height_cur_reg,
		color1_cur_reg, color2_cur_reg};

//assign we = start_registration;
assign we = start_score_board;
//assign oe_0 = ~we; 					
				
assign addr = (we) ? row_sel_by_set : row_sel_to_pe;	

assign done_registration = done_score_board;			


//--------------------cm_concate_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) cm_concate_cur_reg <= #1 0;
	else  if( start_registration) cm_concate_cur_reg <= #1 cm_concate_cur ;
	
 end	

//--------------------position_concate_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) position_concate_cur_reg <= #1 0;
	else  if( start_registration) position_concate_cur_reg <= #1 position_concate_cur ;
	
 end		
//--------------------width_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) width_cur_reg <= #1 0;
	else  if( start_registration) width_cur_reg <= #1 width_cur ;
	
 end		
//--------------------height_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) height_cur_reg <= #1 0;
	else  if( start_registration) height_cur_reg <= #1 height_cur ;
	
 end		
//--------------------color1_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) color1_cur_reg <= #1 0;
	else  if( start_registration) color1_cur_reg <= #1 color1_cur ;
	
 end	
//--------------------color2_cur---------------------------------	

always_ff @(posedge clk or negedge reset_N) begin
	if (!reset_N ) color2_cur_reg <= #1 0;
	else  if( start_registration) color2_cur_reg <= #1 color2_cur ;
	
 end	
// -----------------------------------------------------------       
//				Instantiation
// ----------------------------------------------------------- 
 
oflow_score_calc oflow_score_calc (
	.clk(clk),
	.reset_N(reset_N),
	.start_score_calc(start_score_calc),
	.cm_concate_cur(cm_concate_cur_reg),
	.position_concate_cur(position_concate_cur_reg),
	.width_cur(width_cur_reg),
	.height_cur(height_cur_reg),
	.color1_cur(color1_cur_reg),
	.color2_cur(color2_cur_reg),
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
	.data_from_cr(data_to_score_board_to_pe),
	.row_sel_from_cr(row_sel_to_pe_from_cr),
	.row_to_change(row_to_change_to_pe),
	.write_to_pointer(write_to_pointer_to_pe),
	.score_to_cr(score_to_cr_from_pe),
	.id_to_cr(id_to_cr_from_pe),
	.id_to_buffer(id_to_buffer),
	.id_out(id_out),
	.ready_new_frame(ready_new_frame),
	.row_sel_to_pe (row_sel_to_pe)
);


oflow_registration_fsm oflow_registration_fsm (
	.clk(clk),
	.reset_N(reset_N),
	.frame_num(frame_num),
	.num_of_sets(num_of_sets),
	.start_registration(start_registration),
	.not_start_registration(not_start_registration),
	.done_score_calc(done_score_calc),
	.start_score_calc(start_score_calc),
	.done_score_board(done_score_board),
	.start_score_board(start_score_board),
	.num_of_pe(num_of_pe),
	.row_sel_by_set(row_sel_by_set),
	.id_first_frame(id_first_frame)
);

oflow_registration_feature_extraction_reg_sb oflow_registration_feature_extraction_reg_sb(
	.clk(clk),
	.reset_N(reset_N),
	.data_in(data_in),
	.data_out(data_out),
	.addr(addr),
	.we(we),
	.ready_new_frame(ready_new_frame)

);

/*
mem #(
		.DATA_WIDTH(`FEATURE_OF_PREV_LEN-`ID_LEN),
		.ADDR_WIDTH(`ROW_LEN)
	)
	oflow_registration_fe_mem(.clk(clk),
	.reset_N(reset_N),
	.address_0(addr),
	.address_1(0),
	.data_in(data_in),
	.data_in_1(0),
	.data_out(data_out),
	.data_out_1(data_out_1),
	.cs_0(1'b1),
	.cs_1(1'b0),
	.we(we),
	.we_1(1'b0),
	.oe_0(oe_0),
	.oe_1(1'b0)
);
*/
	
endmodule