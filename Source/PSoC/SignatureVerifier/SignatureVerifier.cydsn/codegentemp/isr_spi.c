/*******************************************************************************
* File Name: isr_spi.c  
* Version 1.70
*
*  Description:
*   API for controlling the state of an interrupt.
*
*
*  Note:
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/


#include <cydevice_trm.h>
#include <CyLib.h>
#include <isr_spi.h>

#if !defined(isr_spi__REMOVED) /* Check for removal by optimization */

/*******************************************************************************
*  Place your includes, defines and code here 
********************************************************************************/
/* `#START isr_spi_intc` */

/* `#END` */

extern cyisraddress CyRamVectors[CYINT_IRQ_BASE + CY_NUM_INTERRUPTS];

/* Declared in startup, used to set unused interrupts to. */
CY_ISR_PROTO(IntDefaultHandler);


/*******************************************************************************
* Function Name: isr_spi_Start
********************************************************************************
*
* Summary:
*  Set up the interrupt and enable it.
*
* Parameters:  
*   None
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_Start(void)
{
    /* For all we know the interrupt is active. */
    isr_spi_Disable();

    /* Set the ISR to point to the isr_spi Interrupt. */
    isr_spi_SetVector(&isr_spi_Interrupt);

    /* Set the priority. */
    isr_spi_SetPriority((uint8)isr_spi_INTC_PRIOR_NUMBER);

    /* Enable it. */
    isr_spi_Enable();
}


/*******************************************************************************
* Function Name: isr_spi_StartEx
********************************************************************************
*
* Summary:
*  Set up the interrupt and enable it.
*
* Parameters:  
*   address: Address of the ISR to set in the interrupt vector table.
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_StartEx(cyisraddress address)
{
    /* For all we know the interrupt is active. */
    isr_spi_Disable();

    /* Set the ISR to point to the isr_spi Interrupt. */
    isr_spi_SetVector(address);

    /* Set the priority. */
    isr_spi_SetPriority((uint8)isr_spi_INTC_PRIOR_NUMBER);

    /* Enable it. */
    isr_spi_Enable();
}


/*******************************************************************************
* Function Name: isr_spi_Stop
********************************************************************************
*
* Summary:
*   Disables and removes the interrupt.
*
* Parameters:  
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_Stop(void)
{
    /* Disable this interrupt. */
    isr_spi_Disable();

    /* Set the ISR to point to the passive one. */
    isr_spi_SetVector(&IntDefaultHandler);
}


/*******************************************************************************
* Function Name: isr_spi_Interrupt
********************************************************************************
*
* Summary:
*   The default Interrupt Service Routine for isr_spi.
*
*   Add custom code between the coments to keep the next version of this file
*   from over writting your code.
*
* Parameters:  
*   None
*
* Return:
*   None
*
*******************************************************************************/
CY_ISR(isr_spi_Interrupt)
{
    /*  Place your Interrupt code here. */
    /* `#START isr_spi_Interrupt` */
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
    /* `#END` */
}


/*******************************************************************************
* Function Name: isr_spi_SetVector
********************************************************************************
*
* Summary:
*   Change the ISR vector for the Interrupt. Note calling isr_spi_Start
*   will override any effect this method would have had. To set the vector 
*   before the component has been started use isr_spi_StartEx instead.
*
* Parameters:
*   address: Address of the ISR to set in the interrupt vector table.
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_SetVector(cyisraddress address)
{
    CyRamVectors[CYINT_IRQ_BASE + isr_spi__INTC_NUMBER] = address;
}


/*******************************************************************************
* Function Name: isr_spi_GetVector
********************************************************************************
*
* Summary:
*   Gets the "address" of the current ISR vector for the Interrupt.
*
* Parameters:
*   None
*
* Return:
*   Address of the ISR in the interrupt vector table.
*
*******************************************************************************/
cyisraddress isr_spi_GetVector(void)
{
    return CyRamVectors[CYINT_IRQ_BASE + isr_spi__INTC_NUMBER];
}


/*******************************************************************************
* Function Name: isr_spi_SetPriority
********************************************************************************
*
* Summary:
*   Sets the Priority of the Interrupt. Note calling isr_spi_Start
*   or isr_spi_StartEx will override any effect this method would 
*   have had. This method should only be called after isr_spi_Start or 
*   isr_spi_StartEx has been called. To set the initial
*   priority for the component use the cydwr file in the tool.
*
* Parameters:
*   priority: Priority of the interrupt. 0 - 3, 0 being the highest.
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_SetPriority(uint8 priority)
{
	uint8 interruptState;
    uint32 priorityOffset = ((isr_spi__INTC_NUMBER % 4u) * 8u) + 6u;
    
	interruptState = CyEnterCriticalSection();
    *isr_spi_INTC_PRIOR = (*isr_spi_INTC_PRIOR & (uint32)(~isr_spi__INTC_PRIOR_MASK)) |
                                    ((uint32)priority << priorityOffset);
	CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: isr_spi_GetPriority
********************************************************************************
*
* Summary:
*   Gets the Priority of the Interrupt.
*
* Parameters:
*   None
*
* Return:
*   Priority of the interrupt. 0 - 3, 0 being the highest.
*
*******************************************************************************/
uint8 isr_spi_GetPriority(void)
{
    uint32 priority;
	uint32 priorityOffset = ((isr_spi__INTC_NUMBER % 4u) * 8u) + 6u;

    priority = (*isr_spi_INTC_PRIOR & isr_spi__INTC_PRIOR_MASK) >> priorityOffset;

    return (uint8)priority;
}


/*******************************************************************************
* Function Name: isr_spi_Enable
********************************************************************************
*
* Summary:
*   Enables the interrupt.
*
* Parameters:
*   None
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_Enable(void)
{
    /* Enable the general interrupt. */
    *isr_spi_INTC_SET_EN = isr_spi__INTC_MASK;
}


/*******************************************************************************
* Function Name: isr_spi_GetState
********************************************************************************
*
* Summary:
*   Gets the state (enabled, disabled) of the Interrupt.
*
* Parameters:
*   None
*
* Return:
*   1 if enabled, 0 if disabled.
*
*******************************************************************************/
uint8 isr_spi_GetState(void)
{
    /* Get the state of the general interrupt. */
    return ((*isr_spi_INTC_SET_EN & (uint32)isr_spi__INTC_MASK) != 0u) ? 1u:0u;
}


/*******************************************************************************
* Function Name: isr_spi_Disable
********************************************************************************
*
* Summary:
*   Disables the Interrupt.
*
* Parameters:
*   None
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_Disable(void)
{
    /* Disable the general interrupt. */
    *isr_spi_INTC_CLR_EN = isr_spi__INTC_MASK;
}


/*******************************************************************************
* Function Name: isr_spi_SetPending
********************************************************************************
*
* Summary:
*   Causes the Interrupt to enter the pending state, a software method of
*   generating the interrupt.
*
* Parameters:
*   None
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_SetPending(void)
{
    *isr_spi_INTC_SET_PD = isr_spi__INTC_MASK;
}


/*******************************************************************************
* Function Name: isr_spi_ClearPending
********************************************************************************
*
* Summary:
*   Clears a pending interrupt.
*
* Parameters:
*   None
*
* Return:
*   None
*
*******************************************************************************/
void isr_spi_ClearPending(void)
{
    *isr_spi_INTC_CLR_PD = isr_spi__INTC_MASK;
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
