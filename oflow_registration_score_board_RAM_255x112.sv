/*------------------------------------------------------------------------------
 * File          : oflow_registration_score_board_RAM_255x112.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	this ram need EN only for writing, for reading we dont need EN
 *------------------------------------------------------------------------------*/


module  oflow_registration_score_board_RAM_255x112( 
			input logic clk,
			input logic reset_N	,
			input logic [111:0] data_in,
			input logic wr,
			input logic [7:0] addr,
			input logic  EN,// 
			
			
			output logic [111:0] data_out
			);
			
	
reg [111:0] ram [7:0];
//----------------write/read----------------

always_ff @(posedge clk, posedge reset_N) 
begin
	if (reset_N) ram [addr] <=#1 0;
	else if(EN&& wr )ram [addr]  <=#1 data_in;
		 else if(EN & !wr) data_out <=#1 ram[addr];
end


endmodule