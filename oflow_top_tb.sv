/*------------------------------------------------------------------------------
 * File          : oflow_top_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_reg_file_define.sv"


//`timescale 1ns/100ps
module oflow_top_tb ();


// -----------------------------------------------------------       
//                  logicisters & logics
// -----------------------------------------------------------  
		
// inputs
 logic clk;
 logic reset_N;

// globals inputs and outputs (DMA)
 logic [`BBOX_VECTOR_SIZE-1:0] set_of_bboxes_from_dma [`PE_NUM];
 logic start; // from top
 logic new_set_from_dma; // dma ready with new feature extraction set
 logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
 logic new_frame;
 logic ready_new_set; // fsm_core_top ready for new_set from DMA
 logic ready_new_frame; // fsm_core_top ready for new_frame from DMA
 logic conflict_counter_th; // fsm_core_top ready for new_frame from DMA

 
// APB Interface	

// inputs
 logic [31:0] apb_pwdata;		
 logic apb_pwrite;
 logic apb_psel; 
 logic apb_penable;
 logic[`ADDR_LEN-1:0] apb_addr;
// outputs
 logic apb_pready;      
 logic[31:0] apb_prdata;
 
 
 logic valid_id;
 logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME];
		 
  
   
   
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

oflow_top  oflow_top( .* );
	
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #20
  write_to_reg_file();
   
  #20
	//frames_test_1();
	frames_test_2();
  
   #100 $finish; 
//   #100000  $finish;
   
end
   



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 5ns)
// ----------------------------------------------------------------------

   
 always begin
	#2.5 clk = ~clk;
	
  end
 /*always begin
	 #2.5 apb_oflow_pclk =~ apb_oflow_pclk;
 end */
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
	  
	 
	 // reg_file
	  apb_pwrite = 1'b0;		
	  apb_psel = 1'b0;	    
	  apb_penable = 1'b0;	
	  apb_addr = 3'b000;		
	  apb_pwdata = 32'd0;	
	  
	  /*
	  iou_weight=0;
	  w_weight=0;
	  h_weight=0;
	  color1_weight=0;
	  color2_weight=0;
	  dhistory_weight=0;
	  score_th_for_new_bbox = 32'h1_2a00;
	  */
	  
	  start=0; // from top
	  new_frame=0;
	  num_of_bbox_in_frame=0; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
	//check
	  //signal = 0;
	  #10
	  reset_N = 1'b1;
		//signal = ready_new_set;
  end  
endtask


task write_to_reg_file();
	begin
		
		
		apb_write(`W_IOU_ADDR, 10'b1000000000);              // CPU WRITE configurations (TSI master) 
		apb_write(`W_WIDTH_ADDR, 10'b0010000000); 
		apb_write(`W_HEIGHT_ADDR, 10'b0010000000); 
		apb_write(`W_COLOR1_ADDR, 10'b0001010101);               
		apb_write(`W_COLOR2_ADDR, 10'b0001010101); 
		apb_write(`W_HISTORY_ADDR, 10'b0001010101); 
		apb_write(`SCORE_TH_FOR_NEW_BBOX_ADDR, 32'h1_2a00);   
		apb_write(`NUM_OF_HISTORY_FRAMES_ADDR, 32'h00000003); 
		apb_write(`MAX_THRESHOLD_FOR_CONFLICTS_ADDR, 4'd10); 
		
		
	end
endtask



 task apb_write(input logic [`ADDR_LEN-1:0]  addr,input logic [31:0] data);
	 begin
		 
		 // ---------------T1------------
		 @(posedge clk); 
		 #1
		 apb_penable = 1'b0;	
		 apb_pwrite = 1'b1;
		 apb_psel = 1'b1;	
		 apb_addr = addr;		
		 apb_pwdata = data;
		 // ---------------T2------------
		 @(posedge clk);  
		 #1
				 apb_penable = 1'b1;	
		 // ---------------T3------------
		  @(posedge clk);
		  #1
		   //apb_oflow_pwrite    = 1'b0;
				  apb_psel 		  = 1'b0;
		  //apb_oflow_address  = 13'h0;
		 // apb_oflow_pwdata  = 31'h0;
		  apb_penable = 1'b0;
		  #5
		  apb_pwrite = 1'b0;
		  $display("Writing Data \n");
	 end
  endtask	
  
  task apb_read(input logic [`ADDR_LEN-1:0]  addr);
	  begin
		  
		  // ---------------T1------------
		  @(posedge clk); 
		  #1
				  apb_penable = 1'b0;			 
		  apb_pwrite = 1'b0;			
		  apb_psel = 1'b1;
		  apb_addr = addr;	
		  // ---------------T2------------
		  @(posedge clk);
		  #1
				  apb_penable = 1'b1;		 
		  // ---------------T3------------
		  @(posedge clk);
		  #1 
		  //apb_oflow_pwrite    = 1'b0;
				  apb_psel 		  = 1'b0;
		  //apb_oflow_address  = 13'h0;
		  apb_penable = 1'b0;	
		 $display("Reading Data \n");
	  end
   endtask	
 
   task frames_test_1 ();
	   begin
		   
		   //==================== START================
		   @(posedge clk);
		   // first frame : frame_num = 0
		   start = 1'b1;
		   @(posedge clk);
		   start = 1'b0;
		   //====================================

		   //==================== START FRAME 0================

		
		   num_of_bbox_in_frame = 72;
		   

		   //====================================

		   //==================== START SET 0================

		   set_of_bboxes(12,200);
		   new_frame = 1'b1;
		   @(posedge clk);
		   new_frame = 1'b0;
		   
		   @(posedge ready_new_set);
		   //====================================

		   //==================== START SET 1================

		   set_of_bboxes(5,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;

		   @(posedge ready_new_set);
		   //====================================

		   //==================== START SET 2================

		   set_of_bboxes(7,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;
		   
		   
		   //====================================


		   

		   //==================== START FRAME 1================

		   @(posedge ready_new_frame);
		 
		   num_of_bbox_in_frame = 70;
		   

		   //====================================

		   //==================== START SET 0================

		   set_of_bboxes(13,200);
		   new_frame = 1'b1;
		   @(posedge clk);
		   new_frame = 1'b0;
		   
		   @(posedge ready_new_set);
		   //====================================
		   
		   //==================== START SET 1================

		   set_of_bboxes(6,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;

		   @(posedge ready_new_set);
		   //====================================

		   //==================== START SET 2================

		   set_of_bboxes(8,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;
		   
		   //====================================
		   
		   
		   
		   
		   
		   //==================== START FRAME 2================

		   @(posedge ready_new_frame);
		  
		   num_of_bbox_in_frame = 70;
		   

		   //====================================

		   //==================== START SET 0================

		   set_of_bboxes_frame_2(10,200);
		   new_frame = 1'b1;
		   @(posedge clk);
		   new_frame = 1'b0;
		   
		   @(posedge ready_new_set);
		   //====================================
		   
		   //==================== START SET 1================

		   set_of_bboxes_frame_2(9,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;

		   @(posedge ready_new_set);
		   //====================================

		   //==================== START SET 2================

		   set_of_bboxes_frame_2(4,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;
		   
		   //====================================
		   
		   
		   
		   
		   
		   //==================== START FRAME 3================

		   @(posedge ready_new_frame);
		   
		   num_of_bbox_in_frame = 24;
		   

		   //====================================

		   //==================== START SET 0================

		   set_of_bboxes(12,200);
		   new_frame = 1'b1;
		   @(posedge clk);
		   new_frame = 1'b0;
		 
		   
		   /*
		   @(posedge ready_new_set);
		   //====================================
		  
		   
		   //==================== START SET 1================

		   set_of_bboxes(6,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;

		   @(posedge ready_new_set);
		   //====================================

		   //==================== START SET 2================

		   set_of_bboxes(7,200);
		   //@(posedge clk);
		   new_set_from_dma = 1'b1;
		   @(posedge clk);
		   new_set_from_dma = 1'b0;
		   
		   //====================================
		   
		   
		   |*/
		   
		   @(posedge ready_new_frame);
		   
	   end  
	   endtask

	   task frames_test_2 ();
		   begin
			   
			   //==================== START================
			   @(posedge clk);
			   // first frame : frame_num = 0
			   start = 1'b1;
			   @(posedge clk);
			   start = 1'b0;
			   //====================================

			   //==================== START FRAME 0================

			
			   num_of_bbox_in_frame = 72;
			   

			   //====================================

			   //==================== START SET 0================

			   set_of_bboxes(15,200);
			   new_frame = 1'b1;
			   @(posedge clk);
			   new_frame = 1'b0;
			   
			   @(posedge ready_new_set);
			   //====================================

			   //==================== START SET 1================

			   set_of_bboxes(5,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;

			   @(posedge ready_new_set);
			   //====================================

			   //==================== START SET 2================

			   set_of_bboxes(7,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;
			   
			   
			   //====================================


			   

			   //==================== START FRAME 1================

			   @(posedge ready_new_frame);
			 
			   num_of_bbox_in_frame = 70;
			   

			   //====================================

			   //==================== START SET 0================

			   set_of_bboxes(13,200);
			   new_frame = 1'b1;
			   @(posedge clk);
			   new_frame = 1'b0;
			   
			   @(posedge ready_new_set);
			   //====================================
			   
			   //==================== START SET 1================

			   set_of_bboxes(4,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;

			   @(posedge ready_new_set);
			   //====================================

			   //==================== START SET 2================

			   set_of_bboxes(10,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;
			   
			   //====================================
			   
			   
			   
			   
			   
			   //==================== START FRAME 2================

			   @(posedge ready_new_frame);
			  
			   num_of_bbox_in_frame = 75;
			   

			   //====================================

			   //==================== START SET 0================

			   set_of_bboxes(14,200);
			   new_frame = 1'b1;
			   @(posedge clk);
			   new_frame = 1'b0;
			   
			   @(posedge ready_new_set);
			   //====================================
			   
			   //==================== START SET 1================

			   set_of_bboxes(3,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;

			   @(posedge ready_new_set);
			   //====================================

			   //==================== START SET 2================

			   set_of_bboxes(8,200);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;
			   
			   @(posedge ready_new_set);
			   //====================================
			   
			   //==================== START SET 3================

			   set_of_bboxes_frame_2_test_2(20,2000);
			   //@(posedge clk);
			   new_set_from_dma = 1'b1;
			   @(posedge clk);
			   new_set_from_dma = 1'b0;
			   
			   //====================================
			   
			   
			  
		
			   
			   @(posedge ready_new_frame);
			   
		   end  
		   endtask




	   function logic[85:0] bbox (input logic [`CM_CONCATE_LEN/2-1:0 ] x,input logic  [`CM_CONCATE_LEN/2-1:0 ] y,input logic [`WIDTH_LEN-1:0] width,input logic [`HEIGHT_LEN-1:0] height,
					   input logic [`COLOR_LEN-1:0] color1,input logic [`COLOR_LEN-1:0] color2);
		   begin
			 
			   bbox = {x,y,width,height,color1,color2};
			   
		   end
	   endfunction	


	   task set_of_bboxes (input logic [`CM_CONCATE_LEN/2-1:0 ] x, input logic [`COLOR_LEN-1:0 ] z);
	   begin

			   set_of_bboxes_from_dma[0] = bbox(1,2,10,20,130,200);
			   set_of_bboxes_from_dma[1] = bbox(6,400,10,20,130,200);
			   set_of_bboxes_from_dma[2] = bbox(x,60,10,20,130,z);
			   set_of_bboxes_from_dma[3] = bbox(x,61,10,20,130,z);
			   set_of_bboxes_from_dma[4] = bbox(x,62,10,20,130,z);
			   set_of_bboxes_from_dma[5] = bbox(x,63,10,20,130,z);
			   set_of_bboxes_from_dma[6] = bbox(x,64,10,20,130,z);
			   set_of_bboxes_from_dma[7] = bbox(x,65,10,20,130,z);
			   set_of_bboxes_from_dma[8] = bbox(x,66,10,20,130,z);
			   set_of_bboxes_from_dma[9] = bbox(x,67,10,20,130,200);
			   set_of_bboxes_from_dma[10] = bbox(x,68,10,20,130,200);
			   set_of_bboxes_from_dma[11] = bbox(x,69,10,20,130,200);
			   set_of_bboxes_from_dma[12] = bbox(x,70,10,20,130,200);
			   set_of_bboxes_from_dma[13] = bbox(x,71,10,20,130,200);
			   set_of_bboxes_from_dma[14] = bbox(x,72,10,20,130,200);
			   set_of_bboxes_from_dma[15] = bbox(x,73,10,20,130,200);
			   set_of_bboxes_from_dma[16] = bbox(x,74,10,20,130,200);
			   set_of_bboxes_from_dma[17] = bbox(x,75,10,20,130,200);
			   set_of_bboxes_from_dma[18] = bbox(x,76,10,20,130,200);
			   set_of_bboxes_from_dma[19] = bbox(x,77,10,20,130,200);
			   set_of_bboxes_from_dma[20] = bbox(x,78,10,20,130,200);
			   set_of_bboxes_from_dma[21] = bbox(x,79,10,20,130,200);
			   set_of_bboxes_from_dma[22] = bbox(x,80,10,20,130,200);
			   set_of_bboxes_from_dma[23] = bbox(x,81,10,20,130,200);
		   
	   end
	   endtask
	   
	   task set_of_bboxes_frame_2 (input logic [`CM_CONCATE_LEN/2-1:0 ] x, input logic [`COLOR_LEN-1:0 ] z);
	   begin

		   set_of_bboxes_from_dma[0] = bbox(1,2,10,20,130,200);
		   set_of_bboxes_from_dma[1] = bbox(6,400,10,20,130,200);
		   set_of_bboxes_from_dma[2] = bbox(x,60,10,20,130,z);
		   set_of_bboxes_from_dma[3] = bbox(x,59,10,20,130,z);
		   set_of_bboxes_from_dma[4] = bbox(x,58,10,20,130,z);
		   set_of_bboxes_from_dma[5] = bbox(x,57,10,20,130,z);
		   set_of_bboxes_from_dma[6] = bbox(x,56,10,20,130,z);
		   set_of_bboxes_from_dma[7] = bbox(x,55,10,20,130,z);
		   set_of_bboxes_from_dma[8] = bbox(x,54,10,20,130,z);
		   set_of_bboxes_from_dma[9] = bbox(x,67,10,20,130,200);
		   set_of_bboxes_from_dma[10] = bbox(x,68,10,20,130,200);
		   set_of_bboxes_from_dma[11] = bbox(x,69,10,20,130,200);
		   set_of_bboxes_from_dma[12] = bbox(x,70,10,20,130,200);
		   set_of_bboxes_from_dma[13] = bbox(x,71,10,20,130,200);
		   set_of_bboxes_from_dma[14] = bbox(x,72,10,20,130,200);
		   set_of_bboxes_from_dma[15] = bbox(x,73,10,20,130,200);
		   set_of_bboxes_from_dma[16] = bbox(x,74,10,20,130,200);
		   set_of_bboxes_from_dma[17] = bbox(x,75,10,20,130,200);
		   set_of_bboxes_from_dma[18] = bbox(x,76,10,20,130,200);
		   set_of_bboxes_from_dma[19] = bbox(x,77,10,20,130,200);
		   set_of_bboxes_from_dma[20] = bbox(x,78,10,20,130,200);
		   set_of_bboxes_from_dma[21] = bbox(x,79,10,20,130,200);
		   set_of_bboxes_from_dma[22] = bbox(x,80,10,20,130,200);
		   set_of_bboxes_from_dma[23] = bbox(x,81,10,20,130,200);
	   
   end
   endtask 
	   
   task set_of_bboxes_frame_2_test_2 (input logic [`CM_CONCATE_LEN/2-1:0 ] x, input logic [`COLOR_LEN-1:0 ] z);
	   begin

		   set_of_bboxes_from_dma[0] = bbox(1,2,10,20,130,z);
		   set_of_bboxes_from_dma[1] = bbox(6,400,10,20,130,z);
		   set_of_bboxes_from_dma[2] = bbox(x,60,10,20,130,z);
		   set_of_bboxes_from_dma[3] = bbox(x,59,10,20,130,z);
		   set_of_bboxes_from_dma[4] = bbox(x,58,10,20,130,z);
		   set_of_bboxes_from_dma[5] = bbox(x,57,10,20,130,z);
		   set_of_bboxes_from_dma[6] = bbox(x,56,10,20,130,z);
		   set_of_bboxes_from_dma[7] = bbox(x,55,10,20,130,z);
		   set_of_bboxes_from_dma[8] = bbox(x,54,10,20,130,z);
		   set_of_bboxes_from_dma[9] = bbox(x,67,10,20,130,200);
		   set_of_bboxes_from_dma[10] = bbox(x,68,10,20,130,200);
		   set_of_bboxes_from_dma[11] = bbox(x,69,10,20,130,200);
		   set_of_bboxes_from_dma[12] = bbox(x,70,10,20,130,200);
		   set_of_bboxes_from_dma[13] = bbox(x,71,10,20,130,200);
		   set_of_bboxes_from_dma[14] = bbox(x,72,10,20,130,200);
		   set_of_bboxes_from_dma[15] = bbox(x,73,10,20,130,200);
		   set_of_bboxes_from_dma[16] = bbox(x,74,10,20,130,200);
		   set_of_bboxes_from_dma[17] = bbox(x,75,10,20,130,200);
		   set_of_bboxes_from_dma[18] = bbox(x,76,10,20,130,200);
		   set_of_bboxes_from_dma[19] = bbox(x,77,10,20,130,200);
		   set_of_bboxes_from_dma[20] = bbox(x,78,10,20,130,200);
		   set_of_bboxes_from_dma[21] = bbox(x,79,10,20,130,200);
		   set_of_bboxes_from_dma[22] = bbox(x,80,10,20,130,200);
		   set_of_bboxes_from_dma[23] = bbox(x,81,10,20,130,200);
	   
   end
   endtask 
	   
endmodule


