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

int main()
{
    SPI_Start();
    UART_Start();

    /* CyGlobalIntEnable; */ /* Uncomment this line to enable global interrupts. */
    for(;;)
    {
        uint8 rxBufferSize = SPI_GetRxBufferSize();
        if (rxBufferSize > 0) {
            uint16 rxData = SPI_ReadRxData();
            const char8 dataReceivedString[] = "Data Received\0";
            UART_UartPutString(dataReceivedString);
        }
    }
}

/* [] END OF FILE */
