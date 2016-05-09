/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include <project.h>
#include <header.h>
#include <stdio.h>

int main()
{
    SPI_Start();
    UART_Start();
    
    uint8 debugState = LOW;
    Pin_LED_Debug_Write(debugState);

    /* CyGlobalIntEnable; */ /* Uncomment this line to enable global interrupts. */
    for(;;)
    {
        uint8 rxBufferSize = SPI_GetRxBufferSize();
        if (rxBufferSize > 0) {
            uint16 rxData = SPI_ReadRxData();
            char outputString[5];
            snprintf(outputString, 5, "%04X", rxData);
            UART_UartPutString(outputString);
            UART_UartPutString("\r\n");
            debugState = HIGH - debugState;
            Pin_LED_Debug_Write(debugState);
        }
    }
}

/* [] END OF FILE */
