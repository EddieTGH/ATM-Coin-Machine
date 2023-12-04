module priorityEncoder164(i,out);
  input [11:0] i;
  output reg [3:0] out;

  always @(i) begin
        if(|i[11:0]) begin
            // priority encoder
            // if condition to choose 
            // output based on priority. 
            if(i[11]==1) out = 4'b1011;
            else if(i[10]==1) out = 4'b1010;
            else if(i[9]==1) out = 4'b1001;
            else if(i[8]==1) out = 4'b1000;
            else if(i[7]==1) out = 4'b0111;
            else if(i[6]==1) out = 4'b0110;
            else if(i[5]==1) out = 4'b0101;
            else if(i[4]==1) out = 4'b0100;
            else if(i[3]==1) out = 4'b0011;
            else if(i[2]==1) out = 4'b0010;
            else if(i[1]==1) out = 4'b0001;
            else
            out = 4'b0000;
        end else begin
            out = 4'bzzzz;
        end
  end
endmodule