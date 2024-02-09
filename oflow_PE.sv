/*------------------------------------------------------------------------------
 * File          : oflow_PE.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

module  oflow_PE( 
			input logic clk,
			input logic reset_N	,
			input logic [111:0] data_in
			input logic wr,
			input logic [7:0] addr,
			input logic  EN,
			
			
			output logic [111:0] data_out
			);
			
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	//next 


// -----------------------------------------------------------       
//				Instanciation
// -----------------------------------------------------------  
oflow_registration( 
			.clk(clk),
			.reset_N(reset_N)	,
			.data_in(data_in)
			.wr(wr),
			.addr(addr),
			.EN(EN),// 
			
			
			.data_out(data_out)
					);

/* oflow_feature_extraction();    */

endmodule