/*******************************************************************************
* File Name: Pin_MOSI.h  
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

#if !defined(CY_PINS_Pin_MOSI_H) /* Pins Pin_MOSI_H */
#define CY_PINS_Pin_MOSI_H

#include "cytypes.h"
#include "cyfitter.h"
#include "Pin_MOSI_aliases.h"


/***************************************
*        Function Prototypes             
***************************************/    

void    Pin_MOSI_Write(uint8 value) ;
void    Pin_MOSI_SetDriveMode(uint8 mode) ;
uint8   Pin_MOSI_ReadDataReg(void) ;
uint8   Pin_MOSI_Read(void) ;
uint8   Pin_MOSI_ClearInterrupt(void) ;


/***************************************
*           API Constants        
***************************************/

/* Drive Modes */
#define Pin_MOSI_DRIVE_MODE_BITS        (3)
#define Pin_MOSI_DRIVE_MODE_IND_MASK    (0xFFFFFFFFu >> (32 - Pin_MOSI_DRIVE_MODE_BITS))
#define Pin_MOSI_DRIVE_MODE_SHIFT       (0x00u)
#define Pin_MOSI_DRIVE_MODE_MASK        (0x07u << Pin_MOSI_DRIVE_MODE_SHIFT)

#define Pin_MOSI_DM_ALG_HIZ         (0x00u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_DIG_HIZ         (0x01u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_RES_UP          (0x02u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_RES_DWN         (0x03u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_OD_LO           (0x04u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_OD_HI           (0x05u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_STRONG          (0x06u << Pin_MOSI_DRIVE_MODE_SHIFT)
#define Pin_MOSI_DM_RES_UPDWN       (0x07u << Pin_MOSI_DRIVE_MODE_SHIFT)

/* Digital Port Constants */
#define Pin_MOSI_MASK               Pin_MOSI__MASK
#define Pin_MOSI_SHIFT              Pin_MOSI__SHIFT
#define Pin_MOSI_WIDTH              1u


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define Pin_MOSI_PS                     (* (reg32 *) Pin_MOSI__PS)
/* Port Configuration */
#define Pin_MOSI_PC                     (* (reg32 *) Pin_MOSI__PC)
/* Data Register */
#define Pin_MOSI_DR                     (* (reg32 *) Pin_MOSI__DR)
/* Input Buffer Disable Override */
#define Pin_MOSI_INP_DIS                (* (reg32 *) Pin_MOSI__PC2)


#if defined(Pin_MOSI__INTSTAT)  /* Interrupt Registers */

    #define Pin_MOSI_INTSTAT                (* (reg32 *) Pin_MOSI__INTSTAT)

#endif /* Interrupt Registers */

#endif /* End Pins Pin_MOSI_H */


/* [] END OF FILE */
