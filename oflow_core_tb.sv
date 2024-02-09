/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
'define BIT_NUMBER_OF_PE 5

module oflow_tb_conflict_resolve_histogram_ram #() ();


   
// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

	
	logic clk;
	logic reset_N;
	logic [BIT_NUMBER_OF_PE-1:0][111:0] data_in;
	logic [BIT_NUMBER_OF_PE-1:0] wr;
	logic [BIT_NUMBER_OF_PE-1:0][7:0] addr;
	logic  EN;
	logic [BIT_NUMBER_OF_PE-1:0] pe;
	logic [BIT_NUMBER_OF_PE-1:0][111:0] data_out;

			
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------



oflow_core( .clk(clk),
			.reset_N(reset_N)	,
			.data_in(data_in),
			.wr(wr),
			.addr(addr),
			.EN(EN),
			
			.data_out(data_out)
			);
	
	 
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #100 
   @(posedge oflow_clk); 
   //						data_2_write, addr_2_write,pe_2_write
	write_2_score_board_in_pe(112'd3, 8'hff,5'd3)   #100 $finish;  
   
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

 
 task initiate_all;        // sets all tso inputs to '0'.
    begin
	clk = 0,
	reset_N = 1	,

	data_in=0;//[5-1:0]->22 PEs
	wr=0;
	EN=0;
    #2 reset_N = 1'b0;     // Disable Reset signal.	 
    end
 endtask



 task write_2_score_board_in_pe(data_2_write, addr_2_write,pe_2_write)
	begin
		add[pe_2_write][addr_2_write] = data_2_write;
		data_in [pe_2_write] = data_2_write;
		wr = 1'b1;
		EN = 1'b1;
		@(posedge oflow_clk); 
		wr = 1'b0;
		EN = 1'b0;
	   
 endtask	
 
 
 
endmodule  


