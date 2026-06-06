module spi(sclk, sdio, sen,reset);

input sclk; 
inout sdio;
input sen;
input reset;
reg sdio_reg_s=1'b0; //refers sdio register of slave which is used while transfering data from slave to master
reg [2:0]data_count_r=3'b000; // for counting reading data
reg [7:0] memory[4095:0]; //memory array declaration
reg [7:0] data=8'b0;       //register to store 8 bit data
reg [11:0] address=12'b0;  //register to store 12 bit address
reg [23:0] bit_24_reg =24'b0; //regiter to store whole transaction
reg [4:0] bit_counter =5'b0; //counter for counting bits
reg [2:0] data_count_w=3'b0; //for counting no. of bits of writing data
reg [3:0] address_count=4'b0; // for counting no. of bits of address
reg read_write_bit=1'b0;

parameter NO=2'b00, READ=2'b01, WRITE=2'b10;
reg [1:0] state=NO;

assign sdio = (read_write_bit) ? sdio_reg_s : 1'hz;

always@(posedge sclk or posedge reset or posedge sen) begin

 // reset block for reseting signals when reset is high
 if(reset)begin
 data<=8'b0;
 address<=12'b0;
 bit_24_reg<=24'b0;
 bit_counter<=5'b0;
 data_count_w<=3'b0;
 address_count<=4'b0;
 read_write_bit<=1'b0;
 state<=2'b00;
 end
 
 
 
 // block what to do when sen is 0
 if(!sen) begin
  bit_counter <= bit_counter + 5'b00001;
  bit_24_reg[23-bit_counter] <= sdio;
 
 
 //if block for storing address
  if((bit_counter>5'b00011) && (bit_counter<5'b10000)) begin
  address_count <= address_count + 4'b0001;
  address[11-address_count] <= sdio;
  end
  
  
 //if block to judge whether to read or write
  if (bit_counter == 5'b01111) begin
    if (bit_24_reg[23]) begin //if bit is high then read else write
        state <= READ;
        read_write_bit <= 1'b1;
    end
    else begin
        state <= WRITE;
        read_write_bit <= 1'b0;
    end
  end
  
  
 //if block to write data when masters writes
  if((bit_counter>5'b01111) && (bit_counter<5'b11000)) begin
  case(state) 
  
  WRITE : begin
  
  data_count_w <= data_count_w + 3'b001;
  memory[address][7-data_count_w] <= sdio;
  end
  
  endcase
  end
  
  
 end
 // block when what to do sen is 0 and reset is 0
 else begin 
 data<=8'b0;
 address<=12'b0;
 bit_24_reg<=24'b0;
 bit_counter<=5'b0;
 data_count_w<=3'b0;
 address_count<=4'b0;
 read_write_bit<=1'b0;
 state<=2'b00;
 data_count_w<=3'b0;
 end 
end

always@(negedge sclk or posedge reset or posedge sen) begin

// reset block for reseting signals when reset is high
if(reset)begin
data_count_r<=3'b0;
end

        // block what to do when sen is 0
	if(!sen) begin
	
	//if block to transfer data when master reads
	if((bit_counter>5'b01111) && (bit_counter<5'b11000)) begin
	
	case (state)
	
		READ : begin
  
		data_count_r <= data_count_r + 3'b001;
		sdio_reg_s <= memory[address][7-data_count_r] ;
  
		end
	endcase
	
	end
	end
	// block when what to do sen is 0 and reset is 0
	else begin
	data_count_r<=3'b0;
	end
	
end
endmodule
