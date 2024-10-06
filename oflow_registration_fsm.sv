/*------------------------------------------------------------------------------
 * File          : oflow_registration_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

	 

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"



module oflow_registration_fsm #() (
	//inputs
	input logic clk,
	input logic reset_N,
	

	//from core
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num, // counter for frame_num
	input logic [`SET_LEN-1:0] num_of_sets, 
	input logic  start_registration,
	input logic not_start_registration,

	//score calc
	input logic done_score_calc,
	output logic start_score_calc,

	// score board
	input logic done_score_board,
	output logic  start_score_board,

	//from PE
	input logic [`PE_LEN-1:0] num_of_pe,
	


	//to score board
	output logic [`ROW_LEN-1:0] row_sel_by_set,
	output logic [`ID_LEN-1:0] id_first_frame
);
	


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

	 logic [`SET_LEN-1:0] counter_of_sets;
	 logic [`SET_LEN-1:0] counter_first_frame_sets;



// -----------------------------------------------------------       
//                Assign
// -----------------------------------------------------------  
	assign  row_sel_by_set = (frame_num) ? counter_of_sets  : counter_first_frame_sets;
	assign  id_first_frame  = (counter_first_frame_sets)*(`PE_NUM) + num_of_pe+1; 
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

oflow_registration_fsm_score_board oflow_registration_fsm_score_board(
	.clk(clk),
	.reset_N(reset_N),
	.frame_num(frame_num), // counter for frame_num
	.num_of_sets(num_of_sets), 
	.start_registration(start_registration),
	
	.counter_of_sets(counter_of_sets),
	
	.done_score_calc(done_score_calc),
	
	.done_score_board(done_score_board),
	.start_score_board(start_score_board),
	
	.counter_first_frame_sets(counter_first_frame_sets)
);

oflow_registration_fsm_score_calc oflow_registration_fsm_score_calc(

	.clk(clk),
	.reset_N(reset_N),
	.frame_num(frame_num), 
	.num_of_sets(num_of_sets), 
	
	.start_registration(start_registration), 
	.not_start_registration(not_start_registration),
	.done_score_calc(done_score_calc),
	.start_score_calc(start_score_calc),
	
	.counter_of_sets(counter_of_sets)
);


endmodule