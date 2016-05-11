#include <project.h>
#include <header.h>
#include <stdio.h>

int16 x_position = 0;
int16 y_position = 0;

int16 x_positions[512];
int16 y_positions[512];
uint16 pos_index = 0;

uint8 action_state = RECORDING;
bool positions_full = false;
bool reading = false;

uint8 debug_state = LOW;

CY_ISR_PROTO(isr_spi_handler);
CY_ISR_PROTO(isr_reset_handler);
CY_ISR_PROTO(isr_button_handler);

CY_ISR(isr_spi_handler) {
    // Get the data that arrives over SPI
    uint16 rxData = SPI_ReadRxData();
    int8 delta_x = (0xf0 | rxData) >> 8;
    int8 delta_y = 0x0f | rxData;
    
    if (action_state == RECORDING && positions_full == false && reading == true) {
        // Update x and y positions
        x_position += delta_x;
        y_position += delta_y;
        x_positions[pos_index] = x_position;
        y_positions[pos_index] = y_position;
        
        // Send it to the desktop
        char outputString[12];
        snprintf(outputString, 12, "%i %i", x_position, y_position);
        UART_UartPutString(outputString);
        UART_UartPutString("\r\n");
        
        // Update pos_index
        pos_index++;
        if (pos_index > 511) {
            positions_full = true;
        }
    }
}

CY_ISR(isr_reset_handler) {
    // Reset everything back to initial values
    x_position = 0;
    y_position = 0;
    pos_index = 0;
    positions_full = false;
    
    isr_reset_ClearPending();
}

CY_ISR(isr_button_handler) {
    CyDelay(1);
    // Change the action_state to reflect which way the switch is set
    uint8 btn = Pin_Button_Read();
    if ((0x2 & btn) == 0) {
        action_state = RECORDING;
    } else if ((0x4 & btn) == 0) {
        action_state = VERIFYING;
    } else {
        action_state = FORGING;
    }
    
    // Change the reading variable to reflect whether the red button is held down or not
    if ((0x1 & btn) == 0) {
        reading = true;
    } else {
        reading = false;
    }
    
    // Debugging!
    Pin_LED_Debug_Write(action_state == RECORDING);
    debug_state = HIGH - debug_state;
    
    isr_button_ClearPending();
    Pin_Button_ClearInterrupt();
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
    
    // Enable the isrs
    isr_spi_StartEx(isr_spi_handler);
    isr_reset_StartEx(isr_reset_handler);
    isr_button_StartEx(isr_button_handler);
    
    // Enable global interrupts
    CyGlobalIntEnable;
    
    // Debugging!
    Pin_LED_Debug_Write(debug_state);
    debug_state = HIGH - debug_state;
    
    // Chill out
    for(;;) { }
}