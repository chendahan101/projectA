/*------------------------------------------------------------------------------
 * File          : oflow_score_calc.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	
 *------------------------------------------------------------------------------*/

module  oflow_score_calc( 
			input logic clk,
			input logic reset_N	,
			input logic [111:0] data_in,
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
oflow_similarity_metric oflow_similarity_metric_1( 
			.clk(clk),
			.reset_N(reset_N)	,
			.data_in(data_in),
			.wr(wr),
			.addr(addr),
			.EN(EN), 
			
			.data_out(data_out) );
			
oflow_similarity_metric oflow_similarity_metric_2( 
			.clk(clk),
			.reset_N(reset_N)	,
			.data_in(data_in),
			.wr(wr),
			.addr(addr),
			.EN(EN), 
			
			.data_out(data_out) );

endmodule