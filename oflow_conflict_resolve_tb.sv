/*------------------------------------------------------------------------------
 * File          : oflow_conflict_resolve_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Sep 11, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"

module oflow_conflict_resolve_tb #() ();

		
		 logic clk;
		 logic reset_N;
		
		//CR
		 logic start_cr;
		 logic done_cr;
		
		//interface_betwe_luten_conflict_resolve_and_pes
		 logic [`SCORE_LEN-1:0] score_to_cr; //arrives from score_board
		 logic [`ID_LEN-1:0] id_to_cr; //arrives from score_board
		 logic [`ROW_LEN-1:0] row_sel_from_cr; //for read from score_board
		 logic [`PE_LEN-1:0] pe_sel_from_cr; //for read from score_board
		 logic [`ROW_LEN-1:0] row_to_change; //for write to score_board
		 logic [`PE_LEN-1:0] pe_to_change; //for write to score_board
		 logic  data_to_score_board;// for write to score_board. *****if we_lut will want to change the fallbacks, we_lut need to change the size of this signal*******
		 logic  write_to_pointer;//for write to score_board
		 
		 
		 logic [`SCORE_LEN-1:0] score_reg [24][11];
		 logic [`ID_LEN-1:0] id_reg [24][11];
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

		 oflow_conflict_resolve oflow_conflict_resolve (.*);



// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
	// initiate	
	initiate_all ();   // Initiates all input signals to '0' and open necessary files
	#50
	
	cr_read_from_sb ();
	
	#50 $finish;  
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


task initiate_all ();        // sets all oflow inputs to '0'.
 begin   
	clk = 1'b0;
	reset_N = 1'b0;
	start_cr = 1'b0;
	#10
	reset_N	= 1'b1;
	score_reg = '{default: 0};
	id_reg = '{default: 0};
	
	score_reg[0] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[1] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[2] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[3] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[4] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[5] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[6] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[7] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[8] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[9] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[10] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[11] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[12] ='{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[13] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[14] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[15] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[16] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[17] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[18] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[19] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[20] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[21] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	score_reg[22] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0} ;
	score_reg[23] = '{`SCORE_LEN'd10,`SCORE_LEN'd12,0,0,0,0,0,0,0,0,0}  ;
	
	
	
	id_reg[0] =  '{`ID_LEN'd10,`ID_LEN'd12,0, 0,0,0,0,0,0,0,0}  ;
	id_reg[1] = '{`ID_LEN'd11,`ID_LEN'd13, 0,0,0,0,0,0,0,0,0}  ;
	id_reg[2] = '{`ID_LEN'd12,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[3] = '{`ID_LEN'd13,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[4] = '{`ID_LEN'd14,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[5] = '{`ID_LEN'd15,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[6] = '{`ID_LEN'd16,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[7] = '{`ID_LEN'd17,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[8] = '{`ID_LEN'd18,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[9] = '{`ID_LEN'd19,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[10] = '{`ID_LEN'd20,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[11] = '{`ID_LEN'd21,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[12] = '{`ID_LEN'd22,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[13] = '{`ID_LEN'd23,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[14] = '{`ID_LEN'd24,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[15] = '{`ID_LEN'd25,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[16] = '{`ID_LEN'd26,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[17] = '{`ID_LEN'd27,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[18] = '{`ID_LEN'd28,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[19] = '{`ID_LEN'd29,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[20] = '{`ID_LEN'd30,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[21] = '{`ID_LEN'd31,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[22] = '{`ID_LEN'd32,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	id_reg[23] = '{`ID_LEN'd33,`ID_LEN'd13,0,0,0,0,0,0,0,0,0}  ;
	
	
  end  
endtask


//conflict resolve read from dcore board
task cr_read_from_sb ();
begin
	@(posedge clk);
	start_cr = 1'b1;
	@(posedge clk);
	start_cr = 1'b0;
	@(posedge clk);
	

	for (int i=0;i<11;i++) begin 
		if(i!=0) @(posedge clk);
		for (int j=0;j<24;j++) begin 
			score_to_cr = score_reg[j][i]  ;
			id_to_cr = id_reg[j][i]  ;
			if(i==1) repeat(2) @(posedge clk);
			if(i==0) repeat(3) @(posedge clk);
		end	
	end
	
	
end  
endtask
	
	
	
	
	/*
	
   frame_num = frame_num_arg;
   num_of_bbox_in_frame = num_of_bbox_in_frame_arg;
   @(posedge clk);
   start_write = 1'b1;
   @(posedge clk);
   start_write = 1'b0;  
	//repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
	
	for(int i =0; i<repeat_num ; i++) begin
		data_in_0 = data_in_0_reg_arg[i];
		data_in_1 = data_in_1_reg_arg[i];
		@(posedge clk);
		ready_from_core = 1'b1;
		@(posedge clk);
		ready_from_core = 1'b0;
		repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		//ready_from_core = 1'b0;
   end

end
endtask



task read_mode (input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_arg , int repeat_num);
   begin
	   frame_num = frame_num_arg;
	   @(posedge clk);
	   start_read = 1'b1;
	   @(posedge clk);
	   start_read = 1'b0;  
		//repeat(3) @(posedge clk);// it will take 3 cycle to data until it will arrive
		
	   repeat(8) @(posedge clk);// it will take 3 cycle to data until it will arrive
	   read_new_line = 1'b1;
	   @(posedge clk);
	   read_new_line = 1'b0;
	   
	   for(int i =0; i<repeat_num ; i++) begin
			read_new_line = 1'b0;
			repeat(10) @(posedge clk);// it will take 3 cycle to data until it will arrive
			read_new_line = 1'b1;
			@(posedge clk);
			read_new_line = 1'b0;
	   end

end
endtask


*/

endmodule