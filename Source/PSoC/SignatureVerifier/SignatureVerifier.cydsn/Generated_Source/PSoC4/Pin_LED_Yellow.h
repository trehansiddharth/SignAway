/*******************************************************************************
* File Name: Pin_LED_Yellow.h  
* Version 2.5
*
* Description:
*  This file containts Control Register function prototypes and register defines
*
* Note:
*
********************************************************************************
* Copyright 2008-2014, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_PINS_Pin_LED_Yellow_H) /* Pins Pin_LED_Yellow_H */
#define CY_PINS_Pin_LED_Yellow_H

#include "cytypes.h"
#include "cyfitter.h"
#include "Pin_LED_Yellow_aliases.h"


/***************************************
*        Function Prototypes             
***************************************/    

void    Pin_LED_Yellow_Write(uint8 value) ;
void    Pin_LED_Yellow_SetDriveMode(uint8 mode) ;
uint8   Pin_LED_Yellow_ReadDataReg(void) ;
uint8   Pin_LED_Yellow_Read(void) ;
uint8   Pin_LED_Yellow_ClearInterrupt(void) ;


/***************************************
*           API Constants        
***************************************/

/* Drive Modes */
#define Pin_LED_Yellow_DRIVE_MODE_BITS        (3)
#define Pin_LED_Yellow_DRIVE_MODE_IND_MASK    (0xFFFFFFFFu >> (32 - Pin_LED_Yellow_DRIVE_MODE_BITS))
#define Pin_LED_Yellow_DRIVE_MODE_SHIFT       (0x00u)
#define Pin_LED_Yellow_DRIVE_MODE_MASK        (0x07u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)

#define Pin_LED_Yellow_DM_ALG_HIZ         (0x00u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_DIG_HIZ         (0x01u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_RES_UP          (0x02u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_RES_DWN         (0x03u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_OD_LO           (0x04u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_OD_HI           (0x05u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_STRONG          (0x06u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)
#define Pin_LED_Yellow_DM_RES_UPDWN       (0x07u << Pin_LED_Yellow_DRIVE_MODE_SHIFT)

/* Digital Port Constants */
#define Pin_LED_Yellow_MASK               Pin_LED_Yellow__MASK
#define Pin_LED_Yellow_SHIFT              Pin_LED_Yellow__SHIFT
#define Pin_LED_Yellow_WIDTH              1u


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define Pin_LED_Yellow_PS                     (* (reg32 *) Pin_LED_Yellow__PS)
/* Port Configuration */
#define Pin_LED_Yellow_PC                     (* (reg32 *) Pin_LED_Yellow__PC)
/* Data Register */
#define Pin_LED_Yellow_DR                     (* (reg32 *) Pin_LED_Yellow__DR)
/* Input Buffer Disable Override */
#define Pin_LED_Yellow_INP_DIS                (* (reg32 *) Pin_LED_Yellow__PC2)


#if defined(Pin_LED_Yellow__INTSTAT)  /* Interrupt Registers */

    #define Pin_LED_Yellow_INTSTAT                (* (reg32 *) Pin_LED_Yellow__INTSTAT)

#endif /* Interrupt Registers */

#endif /* End Pins Pin_LED_Yellow_H */


/* [] END OF FILE */
