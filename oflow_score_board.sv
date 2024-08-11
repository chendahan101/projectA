/*------------------------------------------------------------------------------
 * File          : oflow_score_board.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module  oflow_score_board( 
			input logic clk,
			input logic reset_N	,
			
			
			
			//registration fsm
			input logic  start_score_board,
			input logic [`ROW_LEN-1:0] row_sel_by_set,
			output logic done_score_board,

			//registration
			input logic [`SCORE_LEN-1:0] min_score_0, // min_score_0
			input logic [`ID_LEN-1:0] min_id_0, // id_0 of min score_0 
			input logic [`SCORE_LEN-1:0] min_score_1, // min_score_1
			input logic [`ID_LEN-1:0] min_id_1, // id_1 of min score_1
			
			
			//conflict resolve
			input logic  data_from_cr, // pointer
			input logic [`ROW_LEN-1:0]row_sel_from_cr,
			input logic write_to_pointer,//flag indicate we need to write to pointer
			output logic [(`SCORE_LEN*2)-1:0] score_to_cr,// we insert score0&score1
			output logic [(`ID_LEN*2)-1:0] id_to_cr,// we insert id0&id1
			
			//buffer
			output logic [(`ID_LEN)-1:0] id_to_buffer,
			
			//IDs
			output logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD],
			
			//core
			input logic ready_new_frame,
			
			
			
			//from interface
			input logic [`ROW_LEN-1:0] row_sel

			);
			

			

			



			
			
			

			
		
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
	logic [(`SCORE_LEN*2)-1:0] scores_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert score0&score1
	logic [(`ID_LEN*2)-1:0] ids_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert id0&id1
	logic pointers_reg [`MAX_ROWS_IN_SCORE_BOARD];// will help us to choose id0 or id1
	logic done_score_board;
	/*//conflict resolve
	logic [(`SCORE_LEN*2)-1:0] score_to_cr;
	logic [(`ID_LEN*2)-1:0] id_to_cr;*/
	
	
	
	
	
// -----------------------------------------------------------       
//                 synchronous procedural block.	
// -----------------------------------------------------------


// -----------------------------------------------------------       
//						write to internal reg
// -----------------------------------------------------------

	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N || ready_new_frame) begin 
			for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin scores_reg[0] <= #1 0; end
		else if  (start_score_board)  scores_reg[row_sel_by_set] <= #1 {min_score_0,min_score_1};
	end	
			
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N || ready_new_frame) begin 
			for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin ids_reg[0] <= #1 0; end
		else if  (start_score_board)  ids_reg[row_sel_by_set] <= #1 {min_id_0,min_id_1};
	end	
	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N || ready_new_frame) begin 
			for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin pointers_reg[0] <= #1 0; end
		else if  (write_to_pointer)  pointers_reg[row_sel_from_cr] <= #1 data_from_cr ;
	end	
	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N || ready_new_frame|| done_score_board) begin done_score_board <= #1 1'b0; end
		else if  (start_score_board )  done_score_board <= #1 1'b1 ;
	end	
	
	

// -----------------------------------------------------------       
//						read from reg
// -----------------------------------------------------------	
	//cr
	assign score_to_cr = scores_reg[row_sel_from_cr];
	assign id_to_cr = id_reg[row_sel_from_cr];
	
	//buffer
	assign id_to_buffer = id_out[row_sel];
    
	
	//IDs
	genvar i;
	generate 
		for  ( i=0; i < `MAX_ROWS_IN_SCORE_BOARD; i+=1) begin :row
			assign id_out[i] = (pointers_reg[i]) ? ids_reg[i][`ID_LEN-1:0] :ids_reg[i][`ID_LEN*2-1:`ID_LEN];
			
		end
	endgenerate

	




endmodule