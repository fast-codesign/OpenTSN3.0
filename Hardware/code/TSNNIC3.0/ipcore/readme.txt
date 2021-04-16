因针对不同的平台或者不同的FPGA器件，所使用的IP核生成存在差异，所以ip核文件需要自行依据提供的IP核配置参数去生成ip核.
TSN网卡硬件逻辑源码中总共使用到14个ip核文件，IP核详细配置参数如下：
（1）IP核名称: clk125M_50M125M
     Reference Clock Frequency: 125.0 MHz
     Number Of Clocks : 2
     Clock Name of outclk0 : 50MHz
     Clock Name of outclk1 : 125MHz

（2）IP核名称: sgmii_pcs_share
    Core variation : 10/100/1000Mb Ethernet MAC with 1000BASE-X/sgmii pcs
    Number of ports : 4
    Transceiver type : LVDS I/O
    PHY ID : 0x00000000
    Others:default


（3）IP核名称: asdprf16x8_rq
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（4）IP核名称: asdprf16x9_rq
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（5）IP核名称: DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（6）IP核名称: dcm_fifo9x256
    Fifo_width:9
    Fifo_depth:256
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（7）IP核名称:fifo_35x4
    Fifo_width:35
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（8）IP核名称:ram_32_131
    Operation Mode:With two read/write ports
    Ram_width:131
    Ram_depth:32
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（9）IP核名称:ram_62_256
    Operation Mode:With two read/write ports
    Ram_width:62
    Ram_depth:256
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（10）IP核名称:sdprf16x23_s
    Operation Mode:With one read port and one write port
    Ram_width:23
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（11）IP核名称:sdprf16x57_s
    Operation Mode:With one read port and one write port
    Ram_width:57
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（12）IP核名称:sdprf512x9_s
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（13）IP核名称:suhddpsram65536x134_s
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:65536
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（14）IP核名称:suhddpsram512x4_rq
    Operation Mode:With two read/write ports
    Ram_width:4
    Ram_depth:512
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

