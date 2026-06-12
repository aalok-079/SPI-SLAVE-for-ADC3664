module spi_tb();
reg sclk;  // clock line given by master
wire sdio; // bidirectional transaction line
reg sdio_reg_m; // register used to transfer data from MASTER to SLAVE
reg sen; // transaction enable line
reg reset; // reset pin
reg decide=1'b0; // this variable is used to decide whether sdio will work as input or output line
reg [7:0]data_store=8'b0; // this register stores data coming from SLAVE in MASTER
integer i=0; // variable for running loop
reg [23:0] in = 24'b000010100000110110001100; //input register which contains all the bits that are to be sent
spi S1(.sclk(sclk),.sdio(sdio),.sen(sen),.reset(reset)); // declaration of spi module 

assign sdio = (!decide)? sdio_reg_m : 1'hz; //line to control whether the sdio will act as input or output

initial begin
 sen=1'b1;
 sclk=1'b1;
 
 forever #50 sclk = ~sclk; //clock period of 100 time units
 end
 
initial begin
reset=1'b0;
#50
reset=1'b1;
#40
reset=1'b0;
#110
sen=1'b0; // lowering the sen line to enable the transaction


for(i=0;i<24;i=i+1) begin // for loop to send 24 bits sequentially
 sdio_reg_m=in[23-i]; //23-i for sending MSB first
 #100;
 end
 
 sen=1'b1; // making sen high to disable transaction after successful transfer
 #100
 $finish;
 
end

// printing signals for monitoring
initial begin
   $monitor("Time=%0t | sclk=%b sdio=%b sen=%b  reset=%b data=%b address=%b bit_counter=%b bits=%b data_b=%b mem = %b",
              $time, sclk, sdio, sen, reset, S1.data, S1.address, S1.bit_counter,S1.bit_24_reg,S1.data_count_w, S1.memory[2573]);
end

// dumping of data in file
initial begin
 $dumpfile("write.vcd"); // specifies the VCD file
 $dumpvars(0, spi_tb); //dump all the variables
end

endmodule

