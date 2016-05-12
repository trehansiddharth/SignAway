#include <project.h>
#include <header.h>
#include <stdio.h>

int16 x_position = 0;
int16 y_position = 0;

int16 x_positions_template[256];
int16 y_positions_template[256];
uint16 pos_index_template = 0;

int16 x_positions_test[256];
int16 y_positions_test[256];
uint16 pos_index_test = 0;

uint16 pos_size = 256;

uint8 action_state = RECORDING;
bool reading = false;

uint8 debug_state = LOW;

CY_ISR_PROTO(isr_spi_handler);
CY_ISR_PROTO(isr_button_handler);

void reset_all() {
    // Reset everything back to initial values
    x_position = 0;
    y_position = 0;
    if (action_state == RECORDING) {
        x_positions_template[0] = 0;
        y_positions_template[0] = 0;
        pos_index_template = 1;
    } else {
        x_positions_test[0] = 0;
        y_positions_test[0] = 0;
        pos_index_test = 1;
    }
}

void start_reading() {
    // Tell the desktop we're about to start forging if action_state is FORGING
    if (action_state == FORGING) {
        UART_UartPutString(":F\r\n\0");
    }
}

void stop_reading () {
    char outputString[14];
    int i = 0;
    // Send data to the desktop
    if (action_state == RECORDING) {
        for (i = 0; i < pos_index_template; i++) {
            snprintf(outputString, 14, "%i %i\r\n", x_positions_template[i], y_positions_template[i]);
            UART_UartPutString(outputString);
        }
        UART_UartPutString(":R\r\n\0");
    } else {
        if (action_state == VERIFYING) {
            for (i = 0; i < pos_index_test; i++) {
                snprintf(outputString, 14, "%i %i\r\n", x_positions_test[i], y_positions_test[i]);
                UART_UartPutString(outputString);
            }
            UART_UartPutString(":V\r\n\0");
        }
        UART_UartPutString(":E\r\n\0");
    }
}

CY_ISR(isr_spi_handler) {
    // Get the data that arrives over SPI
    uint16 rxData = SPI_ReadRxData();
    int8 delta_x = (0xf0 | rxData) >> 8;
    int8 delta_y = 0x0f | rxData;
    
    //char outputString[20];
    //snprintf(outputString, 20, ":p_temp %i\r\n", pos_index_template);
    //UART_UartPutString(outputString);
    //snprintf(outputString, 20, ":p_test %i\r\n", pos_index_test);
    //UART_UartPutString(outputString);
    if (reading == true) {
        if ((action_state == RECORDING) && (pos_index_template < pos_size)) {
            // Update x and y positions
            x_position += delta_x;
            y_position += delta_y;
            x_positions_template[pos_index_template] = x_position;
            y_positions_template[pos_index_template] = y_position;
            
            // Update pos_index_template
            pos_index_template++;
        }
        if ((action_state != RECORDING) && (pos_index_test < pos_size)) {
            // Update x and y positions
            x_position += delta_x;
            y_position += delta_y;
            x_positions_test[pos_index_test] = x_position;
            y_positions_test[pos_index_test] = y_position;
            
            // Update pos_index_size
            pos_index_test++;
            
            // Send data to the desktop if action_state is FORGING
            if (action_state == FORGING) {
                char outputString[14];
                snprintf(outputString, 14, "%i %i\r\n", x_position, y_position);
                UART_UartPutString(outputString);
            }
        }
    }
}

CY_ISR(isr_button_handler) {
    // Wait for a bit for the buttons to settle and then read
    CyDelay(1);
    uint8 btn = Pin_Button_Read();
    
    // Change the reading variable to reflect whether the red button is held down or not
    if ((0x1 & btn) == 0 && reading == false) {
        reset_all();
        reading = true;
        start_reading();
    } else if ((0x1 & btn) != 0 && reading == true) {
        reading = false;
        stop_reading();
    }
    
    // Change the action_state to reflect which way the switch is set
    if ((0x2 & btn) == 0) {
        action_state = RECORDING;
    } else if ((0x4 & btn) == 0) {
        action_state = VERIFYING;
    } else {
        action_state = FORGING;
    }
    
    if ((0x8 & btn) == 1) {        
        // Reset everything
        CySoftwareReset();
    }
    
    // Debugging!
    Pin_LED_Debug_Write(debug_state);
    debug_state = HIGH - debug_state;
    
    isr_button_ClearPending();
    Pin_Button_ClearInterrupt();
}

int main()
{
    // Reset everything
    reset_all();
    
    // Start the serial communication systems
    SPI_Start();
    UART_Start();
    
    // Enable interrupts for the SPI system
    SPI_EnableRxInt();
    
    // Enable the isrs
    isr_spi_StartEx(isr_spi_handler);
    isr_button_StartEx(isr_button_handler);
    
    // Enable global interrupts
    CyGlobalIntEnable;
    
    // Debugging!
    Pin_LED_Debug_Write(debug_state);
    debug_state = HIGH - debug_state;
    
    // Chill out
    for(;;) { }
}