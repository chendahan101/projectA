/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_core_tb #() ();


 	 logic clk;
	 logic reset_N;
	

	// globals inputs and outputs (DMA)
	 logic [`BBOX_VECTOR_SIZE-1:0] set_of_bboxes_from_dma [`PE_NUM];
	 logic new_set_from_dma; // dma ready with new feature extraction set
	 logic ready_new_set; // fsm_core_top ready for new_set from DMA
	 logic ready_new_frame; // fsm_core_top ready for new_frame from DMA
	 logic conflict_counter_th; // fsm_core_top ready for new_frame from DMA
	
	// reg_file
	 logic [`WEIGHT_LEN-1:0] iou_weight;
	 logic [`WEIGHT_LEN-1:0] w_weight;
	 logic [`WEIGHT_LEN-1:0] h_weight;
	 logic [`WEIGHT_LEN-1:0] color1_weight;
	 logic [`WEIGHT_LEN-1:0] color2_weight;
	 logic [`WEIGHT_LEN-1:0] dhistory_weight;
	
	 logic start; // from top
	 logic new_frame;
	
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255
	 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
	 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	 
	 //input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_array_per_frame [`MAX_BBOXES_PER_FRAME-1:0],			//size 
	 
	 
	 
	 
	 //input logic [31:0] apb_prdata,
	 
	 // outputs	
	 
	
	 
	
	  logic valid_id;
	  logic done_frame;
	  logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME]; 


// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

		 oflow_core oflow_core(.*);



// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
	// initiate	
	initiate_all ();   // Initiates all input signals to '0' and open necessary files
	#50

	insert_weight(10'b1000000000,10'b0010000000,10'b0010000000,10'b0001010101,10'b0001010101,10'b0001010101);
	two_frames();

	
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
	 
	  clk = 0;
	  reset_N = 0;
	 

	 // globals inputs and outputs (DMA)
	  set_of_bboxes_from_dma = '{default: 0};
	  new_set_from_dma =0; // dma ready with new feature extraction set
	  ready_new_set =0; // fsm_core_top ready for new_set from DMA
	  ready_new_frame =0; // fsm_core_top ready for new_frame from DMA
	  conflict_counter_th=0; // fsm_core_top ready for new_frame from DMA
	 
	 // reg_file
	  iou_weight=0;
	  w_weight=0;
	  h_weight=0;
	  color1_weight=0;
	  color2_weight=0;
	  dhistory_weight=0;
	 
	  start=0; // from top
	  new_frame=0;
	 
	 //input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255
	  num_of_history_frames=0; // fallback number
	  num_of_bbox_in_frame=0; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
	  #10
	  reset_N = 1'b1;
   
  end  
endtask


task two_frames ();
begin
	
	@(posedge clk);
	// first frame : frame_num = 0
	start = 1'b1;
	
	num_of_history_frames = 3;
	num_of_bbox_in_frame = 50;
	while(!ready_new_frame) begin
		
	end
	set_of_bboxes(5);
	new_frame = 1'b1;
	@(posedge clk);
	new_frame = 1'b0;
	start = 1'b0;

	
	//repeat (3) @(posedge clk);
	while(!ready_new_set) begin
		
	end
	
	new_set_from_dma = 1'b1;
	@(posedge clk);
	new_set_from_dma = 1'b0;
	//repeat (3) @(posedge clk);
	while(!ready_new_set) begin
		
	end
	set_of_bboxes(6);
	new_set_from_dma = 1'b1;
	@(posedge clk);
	new_set_from_dma = 1'b0;
	//repeat (3) @(posedge clk);
	while(!ready_new_set) begin
		
	end
	set_of_bboxes(7);
	new_set_from_dma = 1'b1;
	@(posedge clk);
	new_set_from_dma = 1'b0;
	//repeat (3) @(posedge clk);
	
	
	
	
	// second_frame: frame_num = 1
	num_of_bbox_in_frame = 50;
	while(!ready_new_frame) begin
		
	end
	set_of_bboxes(8);
	new_frame = 1'b1;
	@(posedge clk);
	new_frame = 1'b0;
	//repeat (3) @(posedge clk);
	while(!ready_new_set) begin
		
	end
	
	new_set_from_dma = 1'b1;
	@(posedge clk);
	new_set_from_dma = 1'b0;
   
		
end  
endtask



task insert_weight ( input logic [`WEIGHT_LEN-1:0] a, input logic [`WEIGHT_LEN-1:0] b,input logic [`WEIGHT_LEN-1:0] c,
					input logic [`WEIGHT_LEN-1:0] d,input logic [`WEIGHT_LEN-1:0] e, input logic [`WEIGHT_LEN-1:0] f);
	begin
		iou_weight = a;
		w_weight = b;
		h_weight = c;
		color1_weight = d; 
		color2_weight =e;
		dhistory_weight =f;
	end

endtask



function logic[85:0] bbox (input logic [`CM_CONCATE_LEN/2-1:0 ] x,input logic  [`CM_CONCATE_LEN/2-1:0 ] y,input logic [`WIDTH_LEN-1:0] width,input logic [`HEIGHT_LEN-1:0] height,
				input logic [`COLOR_LEN-1:0] color1,input logic [`COLOR_LEN-1:0] color2);
	begin
	  
		bbox = {x,y,width,height,color1,color2};
		
	end
endfunction	


task set_of_bboxes (input logic [`CM_CONCATE_LEN/2-1:0 ] x);
begin

		set_of_bboxes_from_dma[0] = bbox(1,2,10,20,130,200);
		set_of_bboxes_from_dma[1] = bbox(6,400,10,20,130,200);
		set_of_bboxes_from_dma[2] = bbox(50,60,10,20,130,200);
		set_of_bboxes_from_dma[3] = bbox(50,61,10,20,130,200);
		set_of_bboxes_from_dma[4] = bbox(50,62,10,20,130,200);
		set_of_bboxes_from_dma[5] = bbox(50,63,10,20,130,200);
		set_of_bboxes_from_dma[6] = bbox(50,64,10,20,130,200);
		set_of_bboxes_from_dma[7] = bbox(50,65,10,20,130,200);
		set_of_bboxes_from_dma[8] = bbox(50,66,10,20,130,200);
		set_of_bboxes_from_dma[9] = bbox(50,67,10,20,130,200);
		set_of_bboxes_from_dma[10] = bbox(50,68,10,20,130,200);
		set_of_bboxes_from_dma[11] = bbox(50,69,10,20,130,200);
		set_of_bboxes_from_dma[12] = bbox(50,70,10,20,130,200);
		set_of_bboxes_from_dma[13] = bbox(50,71,10,20,130,200);
		set_of_bboxes_from_dma[14] = bbox(50,72,10,20,130,200);
		set_of_bboxes_from_dma[15] = bbox(50,73,10,20,130,200);
		set_of_bboxes_from_dma[16] = bbox(50,74,10,20,130,200);
		set_of_bboxes_from_dma[17] = bbox(50,75,10,20,130,200);
		set_of_bboxes_from_dma[18] = bbox(50,76,10,20,130,200);
		set_of_bboxes_from_dma[19] = bbox(50,77,10,20,130,200);
		set_of_bboxes_from_dma[20] = bbox(50,78,10,20,130,200);
		set_of_bboxes_from_dma[21] = bbox(50,79,10,20,130,200);
		set_of_bboxes_from_dma[22] = bbox(50,80,10,20,130,200);
		set_of_bboxes_from_dma[23] = bbox(x,81,10,20,130,200);
	
end
endtask	

endmodule

/*
   
// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

	
	logic clk;
	logic reset_N;
	logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_in;
	logic [`BIT_NUMBER_OF_PE-1:0] wr;
	logic [`BIT_NUMBER_OF_PE-1:0][7:0] addr;
	logic  EN;
	logic [`BIT_NUMBER_OF_PE-1:0] pe;
	logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_out;

			
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------



oflow_core oflow_core( .clk(clk),
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
   @(posedge clk); 
   //						data_2_write, addr_2_write,pe_2_write
	write_2_score_board_in_pe(112'd3, 8'hff, 22'd3);
	#100 $finish;  
	read_2_score_board_in_pe(8'hff, 22'd3);
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
	clk = 0;
	reset_N = 1;

	data_in = 0;//[5-1:0]->22 PEs
	wr[3] = 0;
	addr = 0;
	EN = 0;
	#2 reset_N = 1'b0;     // Disable Reset signal.	 
	end
 endtask



 task write_2_score_board_in_pe(input logic [111:0] data_2_write, input logic [7:0] addr_2_write,input logic [4:0] pe_2_write);
	begin
		addr[pe_2_write][addr_2_write] = addr_2_write;
		data_in [pe_2_write] = data_2_write;
		wr[3] = 1'b1;
		EN = 1'b1;
		@(posedge clk); 
		wr = 1'b0;
		EN = 1'b0;
	end   
 endtask	
 
 
 task read_2_score_board_in_pe(input logic [7:0] addr_2_read,input logic [4:0] pe_2_read);
	begin
		addr[pe_2_read][addr_2_read] = addr_2_read;
		//data_in [pe_2_read] = data_2_read;
		wr[3] = 1'b0;
		EN = 1'b1;
		@(posedge clk); 
		wr = 1'b0;
		EN = 1'b0;
	end   
 endtask
 
endmodule  

*/

