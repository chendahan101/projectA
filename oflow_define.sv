/*------------------------------------------------------------------------------
 * File          : oflow_define.txt
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *------------------------------------------------------------------------------*/



`define W_Iou   12'h001

`define TH_conflict_counter 12'h018
`define NUM_of_history_frame 12'h01C
`define DONE_for_dma 12'h020

// Transport Clock Generator
`define TSCLK_PERIOD  12'd40


// TSO Packet Size.
`define PACKET_SIZE 8'd187

// TSO Buffer FIFO ram
`define TSO_RAM_SIZE 6'd48


// tso Synchronizing Byte.
// `define SYNC_BYTE   8'h47         //  moved to i88_define
