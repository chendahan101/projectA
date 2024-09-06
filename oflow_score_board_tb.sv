/*------------------------------------------------------------------------------
 * File          : oflow_score_board_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_score_board_tb #() ();

// -----------------------------------------------------------       
//                  registers & wires
// ----------------------------------------------------------- 

		 logic clk;
		 logic reset_N;
		
		
		
		//registration fsm
		 logic  start_score_board;
		 logic [`ROW_LEN-1:0] row_sel_by_set;
		 logic done_score_board;

		//registration
		 logic [`SCORE_LEN-1:0] min_score_0; // min_score_0
		 logic [`ID_LEN-1:0] min_id_0; // id_0 of min score_0 
		 logic [`SCORE_LEN-1:0] min_score_1; // min_score_1
		 logic [`ID_LEN-1:0] min_id_1; // id_1 of min score_1
		
		
		//conflict resolve
		 logic  data_from_cr; // pointer
		 logic [`ROW_LEN-1:0] row_sel_from_cr;
		 logic [`ROW_LEN-1:0] row_to_change; // for change the pointer	
		 logic write_to_pointer;//flag indicate we need to write to pointer
		 logic [(`SCORE_LEN)-1:0] score_to_cr;// we insert score0&score1
		 logic [(`ID_LEN)-1:0] id_to_cr;// we insert id0&id1
		
		//buffer
		 logic [(`ID_LEN)-1:0] id_to_buffer;
		
		//IDs
		 logic [(`ID_LEN)-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD];
		
		//core
		 logic ready_new_frame;
		
		
		
		//from interface
		 logic [`ROW_LEN-1:0] row_sel;
  
		 logic [(`SCORE_LEN*2)-1:0] scores_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert score0&score1
		 logic [(`ID_LEN*2)-1:0] ids_reg[`MAX_ROWS_IN_SCORE_BOARD];// we insert id0&id1
		 

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

		 oflow_score_board oflow_score_board(.*);
		  


	
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
  initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	
  #50

//==========================insert data to score board==============================
  scores_reg = '{default: 0};
  scores_reg[0] = {`SCORE_LEN'd10,`SCORE_LEN'd12};                                   //first row
  scores_reg[1] = {`SCORE_LEN'd10,`SCORE_LEN'd11} ;// we insert score0&score1        //second row
  
  ids_reg = '{default: 0};  // we insert id0&id1
  ids_reg[0] = {`ID_LEN'd1,`ID_LEN'd1};  
  ids_reg[1] = {`ID_LEN'd2,`ID_LEN'd3} ;// we insert id0&id1
  
  insert_curr_data (scores_reg,ids_reg,2);


 //==========================conflict mode==============================
  conflict_resolve (1);
//==========================read data from score board==============================
 read_from_score_board (2);


 ready_new_frame = 1;
 @(posedge clk);
 ready_new_frame = 0;


  #500 $finish;  
  
//   #100000  $finish;
  
end
  



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 8ns)
// ----------------------------------------------------------------------

  
always begin
   #2.5 clk = ~clk;
 end

// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b0; 
		reset_N = 1'b0;
		start_score_board = 1'b0;
		ready_new_frame = 0;
		min_score_0 = 0;
		min_score_1 = 0;
		min_id_0 = 0;
		min_id_1 = 0;
		row_sel_by_set = 0;
		row_sel = 0; 
		row_sel_from_cr = 0;
		row_to_change =0; 
		write_to_pointer = 0;
		data_from_cr = 0;	
		#10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask







 task insert_curr_data ( input logic [(`SCORE_LEN*2)-1:0] scores_reg_arg [`MAX_ROWS_IN_SCORE_BOARD], input logic [(`ID_LEN*2)-1:0] ids_reg_arg [`MAX_ROWS_IN_SCORE_BOARD], int number_of_total_full_row );
	begin
				
		

	
	for (int i = 0; i<number_of_total_full_row;i++) begin 
		row_sel_by_set = i;
		min_score_0 = scores_reg_arg[i] [(`SCORE_LEN*2)-1-:`SCORE_LEN];
		min_score_1 = scores_reg_arg[i] [`SCORE_LEN-1:0];
		min_id_0 = ids_reg_arg[i] [(`ID_LEN*2)-1-:`ID_LEN];
		min_id_1 = ids_reg_arg[i] [`ID_LEN-1:0];
		@(posedge clk);
		start_score_board  =1'b1;
		@(posedge clk);
		start_score_board  =1'b0;
		repeat (34) @(posedge clk);//3*11 + for calc min
	end
	
	

	end
 endtask	








task read_from_score_board (int number_of_row_to_read );
begin
		 for (int i = 0; i<number_of_row_to_read;i++) begin 
			row_sel = i;
			repeat (3) @(posedge clk);//we read from score board, and write the data to mem, the write mode is 3 cycle so we will demme this action
			end
end
	 
 endtask
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 task conflict_resolve ( input logic [`ROW_LEN-1:0] row_to_change_arg);
begin

//===================first the cr need to read each line===========
	for (int i = 0; i<11;i++) begin 
		row_sel_from_cr = i;
		repeat(4) @(posedge clk);
		if (i==row_to_change_arg) begin 
			write_to_pointer = 1'b1;
			row_to_change = i;
			data_from_cr = 1'b1;
		end
	end


end

endtask
 

 
endmodule