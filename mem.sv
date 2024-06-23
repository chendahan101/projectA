/*------------------------------------------------------------------------------
 * File          : mem.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 23, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

//===========================================
 // Function : Synchronous read write RAM
 // Coder    : Deepak Kumar Tala
 // Date     : 1-Nov-2005
 //===========================================
 module mem #(parameter DATA_WIDTH = 290,
				   parameter ADDR_WIDTH = 8,
				   parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
 input  logic                  clk       , // Clock Input
 input logic 					reset_N,
 input  logic [ADDR_WIDTH-1:0] address_0 , // address_0 Input
 input  logic [DATA_WIDTH-1:0] data_in_0    , // data_in_0 
 input  logic                  cs_0      , // Chip Select
 input  logic                  we_0      , // Write Enable/Read Enable
 input  logic                  oe_0      , // Output Enable
 input  logic [ADDR_WIDTH-1:0] address_1 , // address_1 Input
 input  logic [DATA_WIDTH-1:0] data_in_1    , // data_in_1 
 input  logic                  cs_1      , // Chip Select
 input  logic                  we_1      , // Write Enable/Read Enable
 input  logic                  oe_1     ,   // Output Enable
 
 output  logic [DATA_WIDTH-1:0] data_out_0    , // data_out_0 
 output  logic [DATA_WIDTH-1:0] data_out_1    // data_out_1
 ); 
 //--------------Internal variables---------------- 
 reg [DATA_WIDTH-1:0] data_0_out ; 
 reg [DATA_WIDTH-1:0] data_1_out ;
 reg [DATA_WIDTH-1:0] mem [RAM_DEPTH:0];

 //--------------Code Starts Here------------------ 
 // Memory Write Block 
 // Write Operation : When we_0 = 1, cs_0 = 1
 always_ff @ (posedge clk or negedge reset_N)
 begin : MEM_WRITE
	 if(!reset_N) begin
		 mem[address_0] = 0; 
		 mem[address_1] = 0; 
	 end else if ( cs_0 && we_0 ) begin
			mem[address_0] = data_in_0;
	 end if (cs_1 && we_1) begin 
		 mem[address_1] = data_in_1;
   end
 end
 
 // Tri-State Buffer control 
 // output : When we_0 = 0, oe_0 = 1, cs_0 = 1
 assign data_out_0 = (cs_0 && oe_0 &&  ! we_0) ? data_0_out : 8'bz; 
 
 // Memory Read Block 
 // Read Operation : When we_0 = 0, oe_0 = 1, cs_0 = 1
 always_ff @ (posedge clk or negedge reset_N)
 begin : MEM_READ_0
	 if(!reset_N)
		 data_0_out = 0; 
	else if (cs_0 &&  ! we_0 && oe_0) begin
	 data_0_out = mem[address_0]; 
   end else begin
	 data_0_out = 0; 
   end  
end 
 
 //Second Port of RAM
 // Tri-State Buffer control 
// output : When we_0 = 0, oe_0 = 1, cs_0 = 1
 assign data_out_1 = (cs_1 && oe_1 &&  ! we_1) ? data_1_out : 8'bz; 
 // Memory Read Block 1 
 // Read Operation : When we_1 = 0, oe_1 = 1, cs_1 = 1
 always_ff @ (posedge clk or negedge reset_N)
 begin : MEM_READ_1
	if(!reset_N)
		 data_1_out = 0; 
	 else if (cs_1 &&  ! we_1 && oe_1) begin
		 data_1_out = mem[address_1]; 
   end else begin
		data_1_out = 0;
	end
  end
 
endmodule