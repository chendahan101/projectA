/*------------------------------------------------------------------------------
 * File          : oflow_mem_buffer_wrapper.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"

module oflow_mem_buffer_wrapper #() (

input logic clk,
input logic reset_N,
// control signal from core fsm
input logic read_new_line, //only after the similarity metric finish to process one line 	
input logic start_read,
input logic start_write,
// data in from pe
input logic [`DATA_WIDTH-1:0] data_in_0,
input logic [`DATA_WIDTH-1:0] data_in_1,
//global variable
input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//control signal for core fsm
input logic rnw_st,
input logic ready_from_core,	
output logic done_read,
output logic done_write,
//data out for pe
output logic [`DATA_WIDTH-1:0] data_out_0,
output logic [`DATA_WIDTH-1:0] data_out_1 ,

//data out for interface
output logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface


);


// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  
//mem logic
	logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num_to_mem_buffer;
	 
	logic [`OFFSET_WIDTH-1:0] offset_0;
	 logic [`OFFSET_WIDTH-1:0] offset_1;
	 logic we;
	 logic done_read_mem;
	 logic done_write_mem;
	 // logic valid_read_data;
	//logic [`DATA_WIDTH-1:0] data_out_0_reg;
	//logic [`DATA_WIDTH-1:0] data_out_1_reg;
	logic csb_0;
	logic csb_1;
	logic oeb;

	logic read_new_line_reg;
 // fsm mem logic
	logic start_new_frame;
	logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_to_read;
	logic [`OFFSET_WIDTH-1:0] offset_0_read;
	logic [`OFFSET_WIDTH-1:0] offset_1_read;
	logic [`OFFSET_WIDTH-1:0] offset_0_write;
	logic [`OFFSET_WIDTH-1:0] offset_1_write;
	
	
	
// -----------------------------------------------------------       
//               synchronous procedural block.	
// -----------------------------------------------------------
/*always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) data_out_0 <= #1 0;
		else if(valid_read_data) data_out_0 <= #1 data_out_0_reg;
end
// -----------------------------------------------------------       
//                synchronous procedural block.	
// -----------------------------------------------------------
always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) data_out_1 <= #1 0;
		else if(valid_read_data) data_out_1 <= #1 data_out_1_reg;
end
*/

// -----------------------------------------------------------       
//               synchronous procedural block.	
// -----------------------------------------------------------
/*always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) csb_0 <= #1 0;
		else csb_0 <= #1 (!rnw_st) ? !(ready_from_core) : !(read_new_line || start_read);// we add not cause csb is active low
end
// -----------------------------------------------------------       
//                synchronous procedural block.	
// -----------------------------------------------------------
always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) csb_1 <= #1 0;
		else csb_1 <= #1 (!rnw_st) ? !(ready_from_core) : 1'b1;
end
*/	

	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) read_new_line_reg <= #1 0;
		else read_new_line_reg <= #1 (read_new_line);
	end
	






// -----------------------------------------------------------       
//              Assign
// -----------------------------------------------------------  

	assign frame_num_to_mem_buffer = (~rnw_st) ? frame_num : frame_to_read ;
	assign offset_0 = (~rnw_st) ? offset_0_write : offset_0_read ;
	assign offset_1 = (~rnw_st) ? offset_1_write : offset_1_read ;

	assign we = ((~rnw_st)& ready_from_core); //rnw=1-read.
	// assign valid_read_data = (!clk )& (!we);
	
	
	//assign csb_0 = (~rnw_st) ? ~(ready_from_core) : ~(read_new_line | start_read);// we add not cause csb is active low
	//assign csb_1 = (~rnw_st) ? ~(ready_from_core) : 1'b1;
	assign csb_0 = (~rnw_st) ? ~(ready_from_core) : ~(read_new_line_reg | start_read);// we add not cause csb is active low
	assign csb_1 = (~rnw_st) ? ~(ready_from_core) : 1'b1;



/*	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) csb_0 <= #1 0;
		else if(~rnw_st)	csb_0 <= #1 ~(ready_from_core);
		else   csb_0 <= #1  ~(read_new_line | start_read); 
	 end
	
	always_ff @(posedge clk or negedge reset_N) begin
		if (!reset_N) csb_1 <= #1 0;
		else if(~rnw_st)	csb_1 <= #1 ~(ready_from_core);
		else   csb_1 <= #1   1'b1; 
	 end
	*/
	
	
	
	assign oeb = ~rnw_st;
// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

//mem instantiation
	 oflow_MEM_buffer oflow_MEM_buffer (
	.clk (clk),
	.reset_N (reset_N),

	.frame_num(frame_num_to_mem_buffer),
	.num_of_history_frames(num_of_history_frames), 
	
	.data_in_0(data_in_0),
	.data_in_1(data_in_1),
	
	.offset_0(offset_0),
	.offset_1(offset_1),
	.csb_0(csb_0),
	.csb_1(csb_1),
	.we(we),
	.oeb(oeb),
	
	.data_out_0(data_out_0),
	.data_out_1(data_out_1) 
	);
	 
	 
//fsm of mem  in wrapper instantiation
	 oflow_fsm_mem_buffer_in_mem_wrapper oflow_fsm_mem_buffer_in_mem_wrapper (
	.clk(clk),
	.reset_N (reset_N),
	.frame_num(frame_num),
	.num_of_history_frames(num_of_history_frames),
	.num_of_bbox_in_frame(num_of_bbox_in_frame),
	.similarity_metric_flag_ready_to_read_new_line (read_new_line),
	.start_read(start_read),
	.start_write(start_write),
	.ready_from_core(ready_from_core),	 
	.done_read(done_read),
	.done_write(done_write),
	 .frame_to_read(frame_to_read),
	 .offset_0_read(offset_0_read),
	 .offset_1_read(offset_1_read),
	 .offset_0_write(offset_0_write),
	 .offset_1_write(offset_1_write),
	.counter_of_history_frame_to_interface(counter_of_history_frame_to_interface)
);




endmodule