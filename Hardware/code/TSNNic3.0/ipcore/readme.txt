因针对不同的平台或者不同的FPGA器件，所使用的IP核生成存在差异，所以IP核文件需要用户自行依据提供的IP核配置参数去生成IP核.
TSN网卡硬件核心代码中总共使用到12个IP核文件，IP核详细配置参数如下：
（1）IP核:2-port RAM
    ipcore_name:asdprf16x8_rq
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（2）IP核:2-port RAM
    ipcore_name:asdprf16x9_rq
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（3）IP核: FIFO
    ipcore_name:DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（4）IP核: FIFO
    ipcore_name:dcm_fifo9x256
    Fifo_width:9
    Fifo_depth:256
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（5）IP核:FIFO
    ipcore_name:fifo_35x4
    Fifo_width:35
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Reset:Asynchronous clear
    Others:default

（6）IP核:2-port RAM
    ipcore_name:ram_32_131
    Operation Mode:With two read/write ports
    Ram_width:131
    Ram_depth:32
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（7）IP核:2-port RAM
    ipcore_name:ram_62_256
    Operation Mode:With two read/write ports
    Ram_width:62
    Ram_depth:256
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（8）IP核:2-port RAM
    ipcore_name:sdprf16x23_s
    Operation Mode:With one read port and one write port
    Ram_width:23
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（9）IP核:2-port RAM
    ipcore_name:sdprf16x57_s
    Operation Mode:With one read port and one write port
    Ram_width:57
    Ram_depth:16
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（10）IP核:2-port RAM
    ipcore_name:sdprf512x9_s
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（11）IP核:2-port RAM
    ipcore_name:suhddpsram65536x134_s
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:65536
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（12）IP核:2-port RAM
    ipcore_name:suhddpsram512x4_rq
    Operation Mode:With two read/write ports
    Ram_width:4
    Ram_depth:512
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default



