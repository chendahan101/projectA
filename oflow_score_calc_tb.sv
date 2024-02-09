/*------------------------------------------------------------------------------
 * File          : oflow_score_calc_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_score_calc_tb ();

// -----------------------------------------------------------       
//                  logicisters & logics
// -----------------------------------------------------------  
	
	logic    [255:0][21:0]	bbox_xy;
	logic	[255:0][21:0]	bbox_wh;
	logic 	[255:0][23:0]	bbox_color1;
	logic	[255:0][23:0]	bbox_color2;
	logic 	[255:0][7:0]	bbox_dhistory;
		   
	logic	[255:0][20:0]	ids;

		   
	logic [31:0] apb_oflow_prdata;
	logic oflow_rst_N;
	logic oflow_clk;
	logic apb_oflow_pclk;
	logic apb_oflow_pread;
	logic apb_oflow_pwrite;
	logic apb_oflow_psel ;
	logic apb_oflow_penable;
	logic [11:0] apb_oflow_address;
	logic [31:0] apb_oflow_pwdata;
	logic apb_oflow_pready;

   
  
   

// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------

oflow_score_calc oflow_score_calc1(   .clk			(oflow_clk),
		   .reset_N		(oflow_rst_N),
		   
		   .bbox_xy		(bbox_xy ),
		   .bbox_wh		(bbox_wh),
		   .bbox_color1		(bbox_color1),
		   .bbox_color2		(bbox_color2),
		   .bbox_dhistory	(bbox_dhistory),
		   
		 

		   
		   .apb_pclk		(oflow_clk), 
		   .apb_pwrite		(apb_oflow_pwrite),
		   .apb_psel 	    (apb_oflow_psel), 
		   .apb_penable 	(apb_oflow_penable),
		   .apb_addr		(apb_oflow_address),
		   .apb_pwdata		(apb_oflow_pwdata),
		   .apb_pready      (apb_oflow_pready),  
		   .apb_prdata		(apb_oflow_prdata),
		   
		   .ids            (ids)
		   
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
  
   apb_write(`TH_conflict_counter, 32'h00000006); 
   apb_write(`NUM_of_history_frame, 32'h00000005); 
   apb_write(`W_Iou, 32'h421E4000);              // CPU WRITE configurations (TSI master) 
   #10
   apb_read(`W_Iou);
   apb_write(`W_Iou, 32'h423E4000);
   apb_read(`NUM_of_history_frame);
   apb_read(`W_Iou);
   #100 $finish; 
//   #100000  $finish;
   
end
   



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 5ns)
// ----------------------------------------------------------------------

   
 always begin
	#2.5 oflow_clk = ~oflow_clk;
	
  end
 /*always begin
	 #2.5 apb_oflow_pclk =~ apb_oflow_pclk;
 end */
// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------

 
 task initiate_all;        // sets all oflow inputs to '0'.
	  begin
		oflow_clk = 1'b0;  
		oflow_rst_N = 1'b0;
		//apb_oflow_pclk = 0;			
		apb_oflow_pwrite = 1'b0;		
		apb_oflow_psel = 1'b0;	    
		apb_oflow_penable = 1'b0;	
		apb_oflow_address = 12'h000;		
		apb_oflow_pwdata = 0;		
		//apb_oflow_prdata = 0;			
	  
		 #10 oflow_rst_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask




 task apb_write(input logic [11:0]  addr,input logic [31:0] data);
	begin
		
		// ---------------T1------------
		@(posedge oflow_clk); 
		#1
		apb_oflow_penable = 1'b0;	
		apb_oflow_pwrite = 1'b1;
		apb_oflow_psel = 1'b1;	
		apb_oflow_address = addr;		
		apb_oflow_pwdata = data;
		// ---------------T2------------
		@(posedge oflow_clk);  
		#1
		apb_oflow_penable = 1'b1;	
		// ---------------T3------------
		 @(posedge oflow_clk);
		 #1
		  //apb_oflow_pwrite    = 1'b0;
		 apb_oflow_psel 		  = 1'b1;
		 //apb_oflow_address  = 13'h0;
		// apb_oflow_pwdata  = 31'h0;
		 apb_oflow_penable = 1'b0;	
		 $display("Writing Data \n");
	end
 endtask	
 
 task apb_read(input logic [11:0]  addr);
	 begin
		 
		 // ---------------T1------------
		 @(posedge oflow_clk); 
		 #1
		 apb_oflow_penable = 1'b0;			 
		 apb_oflow_pwrite = 1'b0;			
		 apb_oflow_psel = 1'b1;
		 apb_oflow_address = addr;	
		 // ---------------T2------------
		 @(posedge oflow_clk);
		 #1
		 apb_oflow_penable = 1'b1;		 
		 // ---------------T3------------
		 @(posedge oflow_clk);
		 #1 
		 //apb_oflow_pwrite    = 1'b0;
		 apb_oflow_psel 		  = 1'b0;
		 //apb_oflow_address  = 13'h0;
		 apb_oflow_penable = 1'b0;	
		$display("Reading Data \n");
	 end
  endtask	
 
 
endmodule

