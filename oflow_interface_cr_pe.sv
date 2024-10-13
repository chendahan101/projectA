/*------------------------------------------------------------------------------
 * File          : interface_cr_pe.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
//`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"



module interface_cr_pe #() (


	input logic clk,
	input logic reset_N ,
	
//pe

		input logic [`SCORE_LEN-1:0] score_to_cr_from_pe [`PE_NUM],  
		input logic [`ID_LEN-1:0] id_to_cr_from_pe [`PE_NUM],  
		output logic [`ROW_LEN-1:0] row_sel_to_pe,  //which row to read from score board
		output logic  write_to_pointer_to_pe [`PE_NUM], //for write to score_board
		output logic  write_to_id_to_pe [`PE_NUM], //for write to score_board
		output logic  data_from_cr_pointer_to_pe, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
		output logic [`ID_LEN-1:0] data_from_cr_id_to_pe,
		output logic [`ROW_LEN-1:0] row_to_change_to_pe, //for write to score_board


//Conflict_resolve
		input logic [`ROW_LEN-1:0] row_sel_from_cr ,  //which row to read from score board
		input logic [`PE_LEN-1:0] pe_sel_from_cr, //for read from score_board
		input logic [`ROW_LEN-1:0] row_to_change, //for write to score_board
		input logic [`PE_LEN-1:0] pe_to_change, //for write to score_board
		input logic  data_to_score_board_from_cr_pointer, // for write to score_board. *****if we_lut will want to change the fallbacks we_lut need to change the size of this signal*******
		input logic  write_to_pointer_from_cr, //for write to score_board the pointer
		input logic [`ID_LEN-1:0] data_to_score_board_from_cr_id,
		input logic  write_to_id_from_cr, //for write to score_board the id
		output logic [`SCORE_LEN-1:0] score_to_cr, //arrives from score_board
		output logic [`ID_LEN-1:0] id_to_cr //arrives from score_board

);
 
 // -----------------------------------------------------------       
 //						 Async Logic
 // -----------------------------------------------------------	
 
 

assign score_to_cr = score_to_cr_from_pe[pe_sel_from_cr];
assign id_to_cr = id_to_cr_from_pe[pe_sel_from_cr];

assign row_to_change_to_pe = row_to_change;
assign row_sel_to_pe = row_sel_from_cr;
assign data_from_cr_pointer_to_pe = data_to_score_board_from_cr_pointer;
assign data_from_cr_id_to_pe = data_to_score_board_from_cr_id;
	 
//d-mux for pointer to pe
 always_comb begin
	write_to_pointer_to_pe = '{default: 1'b0};
	write_to_pointer_to_pe[pe_to_change] = write_to_pointer_from_cr ;
 end
 //d-mux for id to pe
 always_comb begin
	write_to_id_to_pe = '{default: 1'b0};
	write_to_id_to_pe[pe_to_change] = write_to_id_from_cr ;
 end
 
 
 
endmodule