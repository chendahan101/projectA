/*------------------------------------------------------------------------------
 * File          : oflow_core_fsm.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 27, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_core_fsm #() (

input logic clk,
input logic reset_N,
input logic start,// start =1 evaery time we get new frame


output logic 

);




// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  
//mem logic

	 logic start_read_mem;
	 logic start_write_mem;
	 logic done_read_mem;
	 logic done_write_mem;
	 

 //pe_conflict logic
	 logic start_new_frame;
	
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

//mem instantiation
oflow_MEM_buffer_fsm oflow_MEM_buffer_fsm (
	.clk (clk),
	.reset_N (reset_N),
	.start_read (start_read_mem),
	.start_write (start_write_mem),
	.done_read (done_read_mem),
	.done_write (done_write_mem)
	);
//pe_conflict instantiation
oflow_pe_conflict_fsm oflow_pe_conflict_fsm (
	.clk(clk),
	.reset_N (reset_N),
	.start (start),
	.start_read(start_read_mem),
	.start_write(start_write_mem),
	.done_read(done_read_mem),
	.done_write(done_write_mem)

);





endmodule