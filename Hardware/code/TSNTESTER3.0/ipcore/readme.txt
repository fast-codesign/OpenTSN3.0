因针对不同的平台或者不同的FPGA器件，所使用的IP核生成存在差异，所以ip核文件需要自行依据提供的IP核配置参数去生成ip核。
TSN交换机硬件逻辑源码中总共使用到8个ip核文件，IP核详细配置参数如下：
（1）IP核:2-port RAM
    ipcore_name: ram_sdport_w128d32
    Operation Mode:With one read port and one write port
    Ram_width:128
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（2）IP核:2-port RAM
    ipcore_name: ram_sdport_w128d64
    Operation Mode:With one read port and one write port
    Ram_width:128
    Ram_depth:64
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（3）IP核:2-port RAM
    ipcore_name: ram_sdport_separaterwclock_rdaclr_w8d16
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method : Single
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（4）IP核: FIFO
    ipcore_name: fifo_w134d128_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:128
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default


（5）IP核: FIFO
    ipcore_name: fifo_w31d4_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:31
    Ram_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default

（6）IP核: FIFO
    ipcore_name: fifo_w12d4_commonclock_sclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:12
    Ram_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
     Read access:show_ahead synchronous FIFO mode
    Reset:Synchronous clear
    Others:default

（7）IP核: FIFO
    ipcore_name: fifo_w9d16_respectclock_aclr_showahead
    Operation Mode:With two read/write ports
    Ram_width:9
    Ram_depth:16
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（8）IP核: FIFO
    ipcore_name: DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default
