# THIS FILE IS AUTOMATICALLY GENERATED
# Project: C:\Users\trehans\Documents\SignAway\Source\PSoC\SignatureVerifier\SignatureVerifier.cydsn\SignatureVerifier.cyprj
# Date: Thu, 05 May 2016 04:17:56 GMT
#set_units -time ns
create_clock -name {CyHFCLK} -period 41.666666666666664 -waveform {0 20.8333333333333} [list [get_pins {ClockBlock/hfclk}]]
create_generated_clock -name {SPI_Clock} -source [get_pins {ClockBlock/hfclk}] -edges {1 3 5} [list [get_pins {ClockBlock/udb_div_0}]]
create_clock -name {CyIMO} -period 41.666666666666664 -waveform {0 20.8333333333333} [list [get_pins {ClockBlock/imo}]]
create_clock -name {CySYSCLK} -period 41.666666666666664 -waveform {0 20.8333333333333} [list [get_pins {ClockBlock/sysclk}]]
create_clock -name {CyILO} -period 31250 -waveform {0 15625} [list [get_pins {ClockBlock/ilo}]]
create_clock -name {CyLFCLK} -period 31250 -waveform {0 15625} [list [get_pins {ClockBlock/lfclk}]]


# Component constraints for C:\Users\trehans\Documents\SignAway\Source\PSoC\SignatureVerifier\SignatureVerifier.cydsn\TopDesign\TopDesign.cysch
# Project: C:\Users\trehans\Documents\SignAway\Source\PSoC\SignatureVerifier\SignatureVerifier.cydsn\SignatureVerifier.cyprj
# Date: Thu, 05 May 2016 04:17:53 GMT