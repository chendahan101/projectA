/*------------------------------------------------------------------------------
 * File          : oflow_reg_file_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *------------------------------------------------------------------------------*/


`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_reg_file_define.sv"

//`timescale 1ns/100ps
module oflow_reg_file_tb #() ();


// -----------------------------------------------------------       
//                   logics
// -----------------------------------------------------------  
	
// inputs
logic clk;  			          
logic reset_N;
logic [31:0] apb_pwdata;

// APB Interface							
 //logic apb_pclk;		
 logic apb_pwrite;
 logic apb_psel; 
 logic apb_penable;
 logic[`ADDR_LEN-1:0] apb_addr;



// outputs
 logic apb_pready;    
 logic[31:0] apb_prdata; 
 logic [`WEIGHT_LEN-1:0] w_iou;
 logic [`WEIGHT_LEN-1:0] w_w;
 logic [`WEIGHT_LEN-1:0] w_h; 
 logic [`WEIGHT_LEN-1:0] w_color1; 
 logic [`WEIGHT_LEN-1:0] w_color2;
 logic [`WEIGHT_LEN-1:0] w_dhistory;
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frame;
 logic [`SCORE_LEN-1:0] score_th_for_new_bbox;	
   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

oflow_reg_file  oflow_reg_file( 
	.clk(clk),
	.reset_N(reset_N),
	.apb_pwdata(apb_pwdata),
	
	
	.apb_pwrite(apb_pwrite),
	.apb_psel(apb_psel),
	.apb_penable(apb_penable),
	.apb_addr(apb_addr),
	
	.apb_pready(apb_pready),
	.apb_prdata(apb_prdata),
	.w_iou(w_iou),
	.w_w(w_w),
	.w_h(w_h),
	.w_color1(w_color1),
	.w_color2(w_color2),
	.w_dhistory(w_dhistory),
	.num_of_history_frame(num_of_history_frame),
	.score_th_for_new_bbox(score_th_for_new_bbox)
			   
);

//apb ממשים או מקבלים
//הבדל בין logic ל-logic

// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #100 
  
   apb_write(`NUM_OF_HISTORY_FRAMES_ADDR, 32'h00000005); 
   apb_write(`W_IOU_ADDR, 10'b0100000000);              // CPU WRITE configurations (TSI master) . q0.10 = 0.25
   #10
   apb_read(`W_IOU_ADDR);
   apb_write(`W_IOU_ADDR, 10'b0110000000);			// CPU WRITE configurations (TSI master) . q0.10 = 0.375
   apb_read(`NUM_OF_HISTORY_FRAMES_ADDR);
   apb_read(`W_IOU_ADDR);
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

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		clk = 1'b0;  
		reset_N = 1'b0;
		//apb_oflow_pclk = 0;			
		apb_pwrite = 1'b0;		
		apb_psel = 1'b0;	    
		apb_penable = 1'b0;	
		apb_addr = 0;		
		apb_pwdata = 0;		
		//apb_oflow_prdata = 0;			
	  
		 #10 reset_N = 1'b1;     // Disable Reset signal.	 
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
 
 
endmodule


