module fifo(data_in,rst,clk,rd,wr,full,empty,data_out);
  input [7:0] data_in;
  input rst,clk,rd,wr;
  output full,empty;
  output reg [7:0] data_out;
  
  reg [7:0] mem [31:0];
  reg [4:0] rd_ptr,wr_ptr;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst) 
        begin
        data_out <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
        end
      else
        begin
          if(wr && !full)
            begin
              mem[wr_ptr] <= data_in;
              wr_ptr <= (wr_ptr == 31) ? 0 : wr_ptr + 1;
            end
          if(rd && !empty)
            begin
              data_out <= mem[rd_ptr];
              rd_ptr <= (rd_ptr == 31) ? 0 : rd_ptr + 1;
            end
        end
    end
  assign full = (wr_ptr == rd_ptr - 1) || (rd_ptr == 0 && wr_ptr == 31);
  assign empty = (wr_ptr == rd_ptr);
endmodule



module tb;
  reg [7:0] data_in;
  reg rst,clk,rd,wr;
  wire full,empty;
  wire [7:0] data_out;
  
  integer i;
  fifo f1(data_in,rst,clk,rd,wr,full,empty,data_out);

  initial clk=1'b0;
  always #5 clk=~clk;
    
  initial begin
    // Reset pulse
    rst = 1; rd = 0; wr = 0;
    #10 rst = 0;

    // Simple test sequence
    for (i = 0; i < 10; i = i + 1) begin
      data_in = $random;
      wr = $random % 2;
      rd = ~wr;  // Avoid simultaneous read and write
      #10;
      $display("data_in=%0d ,wr=%0d ,rd=%0d, data_out=%0d, full=%0d, empty=%0d", data_in,wr,rd,data_out,full,empty);
    end

    #200 $stop;
  end

endmodule
