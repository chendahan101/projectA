/*------------------------------------------------------------------------------
 * File          : LUT_MAPPING_ID_HISTOGRAM_CONFLICT_RESOLVE.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :	we will use this table to extract the index that we need to save this id in histogram 
 *for example we get id =300- 1. we will save this instance in the histogram in index i , the in the lut we will save in the cell of 300 =i.
 ----------
 index | the index in the histogram, where we save the instansiation of the id 300
 id=300| i
 *------------------------------------------------------------------------------*/


  1 //===========================================
  2 // Function : Synchronous read write RAM 
  3 // Coder    : Deepak Kumar Tala
  4 // Date     : 1-Nov-2005
  5 //===========================================
  6 module oflow_conflict_resolve_LUT #(parameter DATA_WIDTH = 16,//upper-8bit, lower -8 bit 
  7                   parameter ADDR_WIDTH = 11,// 2048 row -start 0 -end 2047
  8                   parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
  9 input  wire                  clk      , // Clock Input
 10 input  wire [ADDR_WIDTH-1:0] address  , // Address Input
 11 inout  wire [DATA_WIDTH-1:0] data     , // Data bi-directional
 12 input  wire                  cs       , // Chip Select
 13 input  wire                  we       , // Write Enable/Read Enable
 14 input  wire                  oe         // Output Enable
 15 ); 
 
 16 //--------------Internal variables---------------- 
 17 reg [DATA_WIDTH-1:0]   data_out ;
 18 // Use Associative array to save memory footprint
 19 typedef reg [ADDR_WIDTH-1:0] mem_addr;
 20 reg [DATA_WIDTH-1:0] mem [mem_addr];
 21 
 22 //--------------Code Starts Here------------------ 
 23 // Tri-State Buffer control 
 24 // output : When we = 0, oe = 1, cs = 1
 25 assign data = (cs && oe &&  ! we) ? data_out : 8'bz; 
 26 
 27 // Memory Write Block 
 28 // Write Operation : When we = 1, cs = 1
 29 always @ (posedge clk)
 30 begin : MEM_WRITE
 31    if ( cs && we ) begin
 32        mem[address] = data;
 33    end
 34 end
 35 
 36 // Memory Read Block 
 37 // Read Operation : When we = 0, oe = 1, cs = 1
 38 always @ (posedge clk)
 39 begin : MEM_READ
 40     if (cs &&  ! we && oe) begin
 41          data_out = mem[address];
 42     end
 43 end
 44 
 45 endmodule // End of Module ram_sp_sr_sw
