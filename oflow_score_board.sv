/*------------------------------------------------------------------------------
 * File          : oflow_score_board.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/


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
			input logic  data_from_cr_pointer, // pointer
			input logic [(`ID_LEN)-1:0] data_from_cr_id, // id ( new bbox)
			input logic [`ROW_LEN-1:0] row_sel_from_cr,
			input logic [`ROW_LEN-1:0] row_to_change, // for change the pointer	
			input logic write_to_pointer,//flag indicate we need to write to pointer
			input logic write_to_id,//flag indicate we need to write to id (new bbox)
			output logic [(`SCORE_LEN)-1:0] score_to_cr,// we insert score0&score1
			output logic [(`ID_LEN)-1:0] id_to_cr,// we insert id0&id1
			
			//buffer
			output logic [(`ID_LEN)-1:0] id_to_buffer,
			
			//IDs
			output logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD],
			
			//core
			input logic ready_new_frame,
			
			
			
			//from interface
			input logic [`ROW_LEN-1:0] row_sel_to_pe

			);	
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	
	logic [(`SCORE_LEN*2)-1:0] scores_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert score0&score1
	logic [(`ID_LEN*2)-1:0] ids_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert id0&id1
	logic pointers_reg [`MAX_ROWS_IN_SCORE_BOARD];// will help us to choose id0 or id1
	//logic done_score_board;
	/*//conflict resolve
	logic [(`SCORE_LEN*2)-1:0] score_to_cr;
	logic [(`ID_LEN*2)-1:0] id_to_cr;*/
		
	
// -----------------------------------------------------------       
//                 synchronous procedural block.	
// -----------------------------------------------------------


// -----------------------------------------------------------       
//						write to internal regs
// -----------------------------------------------------------

	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) begin 
			//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin scores_reg[i] <= #1 '0; end
			 scores_reg <= #1 '{default: 0};
		end	
		else begin  
			if ( ready_new_frame) begin 
				//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin scores_reg[i] <= #1 '0; end
				scores_reg <= #1 '{default: 0};
			end
			 else if  (start_score_board)  scores_reg[row_sel_by_set] <= #1 {min_score_0,min_score_1}; 
		end 
		
	end	
			
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) begin 
			//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin ids_reg[i] <= #1 '0; end
			ids_reg <= #1 '{default: 0};
		end	
		else begin 
			if (ready_new_frame) begin 
				//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin ids_reg[i] <= #1 '0; end
				ids_reg <= #1 '{default: 0};
			end
			else if  (start_score_board)  ids_reg[row_sel_by_set] <= #1 {min_id_0,min_id_1};
			else if (write_to_id) ids_reg[row_to_change] <= #1 {data_from_cr_id,min_id_1};
		end 
		
	end	
	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) begin 
			//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin pointers_reg[i] <= #1 '0; end
			pointers_reg <= #1 '{default: 0};
		end	
		else begin 
			if (ready_new_frame) begin 
				//for (int i=0; i<`MAX_ROWS_IN_SCORE_BOARD; i+=1) begin pointers_reg[i] <= #1 '0; end
				pointers_reg <= #1 '{default: 0};
			end	
			else if  (write_to_pointer)  pointers_reg[row_to_change] <= #1 data_from_cr_pointer;
		end 
		
		
		
	end	
	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N ) begin 
			done_score_board <= #1 1'b0; 
		end
		else begin
			
			
			if (ready_new_frame|| done_score_board) begin 
				done_score_board <= #1 1'b0; 
			end
			else if  (start_score_board )  done_score_board <= #1 1'b1 ;

			
		end
		
		
		
		
		
		
		
	end	
	
	

// -----------------------------------------------------------       
//						read from reg
// -----------------------------------------------------------	
	//cr
	assign score_to_cr = (pointers_reg[row_sel_from_cr]) ? scores_reg[row_sel_from_cr][`SCORE_LEN-1:0] : scores_reg[row_sel_from_cr][`SCORE_LEN*2-1:`SCORE_LEN];	
	assign id_to_cr =  (pointers_reg[row_sel_from_cr]) ? ids_reg[row_sel_from_cr][`ID_LEN-1:0] : ids_reg[row_sel_from_cr][`ID_LEN*2-1:`ID_LEN];
	
	//buffer
	assign id_to_buffer = (pointers_reg[row_sel_to_pe]) ? ids_reg[row_sel_to_pe][`ID_LEN-1:0] : ids_reg[row_sel_to_pe][`ID_LEN*2-1:`ID_LEN];
	
	
	//IDs
	genvar i;
	generate 
		for  ( i=0; i < `MAX_ROWS_IN_SCORE_BOARD; i+=1) begin :row
			assign id_out[i] = (pointers_reg[i]) ? ids_reg[i][`ID_LEN-1:0] : ids_reg[i][`ID_LEN*2-1:`ID_LEN];
		end
	endgenerate

	




endmodule