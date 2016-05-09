#include <project.h>
#include <header.h>
#include <stdio.h>

uint16 x_position = 0x00;
uint16 y_position = 0x00;

uint16 x_positions[256];
uint16 y_positions[256];
uint8 pos_index = 0;

CY_ISR_PROTO(isr_spi_handler);

CY_ISR(isr_spi_handler) {
    // Get the data that arrives over SPI
    uint16 rxData = SPI_ReadRxData();
    uint8 delta_x = (0xf0 | rxData) >> 8;
    uint8 delta_y = 0x0f | rxData;
    
    // Update x and y positions
    x_position += delta_x;
    y_position += delta_y;
    x_positions[pos_index] = x_position;
    y_positions[pos_index] = y_position;
    
    // Send it to the desktop
    char outputString[13];
    snprintf(outputString, 13, "(%04X, %04X)", x_position, y_position);
    UART_UartPutString(outputString);
    UART_UartPutString("\r\n");
}

int main()
{
    // Initialize positions    
    x_positions[pos_index] = x_position;
    y_positions[pos_index] = y_position;
    
    // Start the serial communication systems
    SPI_Start();
    UART_Start();
    
    // Enable interrupts for the SPI system
    SPI_EnableRxInt();
    
    // Enable isr_spi
    isr_spi_StartEx(isr_spi_handler);
    
    // Enable global interrupts
    CyGlobalIntEnable;
    
    // Chill out
    for(;;) { }
}