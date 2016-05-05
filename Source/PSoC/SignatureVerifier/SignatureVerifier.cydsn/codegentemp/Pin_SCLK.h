/*******************************************************************************
* File Name: Pin_SCLK.h  
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

#if !defined(CY_PINS_Pin_SCLK_H) /* Pins Pin_SCLK_H */
#define CY_PINS_Pin_SCLK_H

#include "cytypes.h"
#include "cyfitter.h"
#include "Pin_SCLK_aliases.h"


/***************************************
*        Function Prototypes             
***************************************/    

void    Pin_SCLK_Write(uint8 value) ;
void    Pin_SCLK_SetDriveMode(uint8 mode) ;
uint8   Pin_SCLK_ReadDataReg(void) ;
uint8   Pin_SCLK_Read(void) ;
uint8   Pin_SCLK_ClearInterrupt(void) ;


/***************************************
*           API Constants        
***************************************/

/* Drive Modes */
#define Pin_SCLK_DRIVE_MODE_BITS        (3)
#define Pin_SCLK_DRIVE_MODE_IND_MASK    (0xFFFFFFFFu >> (32 - Pin_SCLK_DRIVE_MODE_BITS))
#define Pin_SCLK_DRIVE_MODE_SHIFT       (0x00u)
#define Pin_SCLK_DRIVE_MODE_MASK        (0x07u << Pin_SCLK_DRIVE_MODE_SHIFT)

#define Pin_SCLK_DM_ALG_HIZ         (0x00u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_DIG_HIZ         (0x01u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_RES_UP          (0x02u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_RES_DWN         (0x03u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_OD_LO           (0x04u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_OD_HI           (0x05u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_STRONG          (0x06u << Pin_SCLK_DRIVE_MODE_SHIFT)
#define Pin_SCLK_DM_RES_UPDWN       (0x07u << Pin_SCLK_DRIVE_MODE_SHIFT)

/* Digital Port Constants */
#define Pin_SCLK_MASK               Pin_SCLK__MASK
#define Pin_SCLK_SHIFT              Pin_SCLK__SHIFT
#define Pin_SCLK_WIDTH              1u


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define Pin_SCLK_PS                     (* (reg32 *) Pin_SCLK__PS)
/* Port Configuration */
#define Pin_SCLK_PC                     (* (reg32 *) Pin_SCLK__PC)
/* Data Register */
#define Pin_SCLK_DR                     (* (reg32 *) Pin_SCLK__DR)
/* Input Buffer Disable Override */
#define Pin_SCLK_INP_DIS                (* (reg32 *) Pin_SCLK__PC2)


#if defined(Pin_SCLK__INTSTAT)  /* Interrupt Registers */

    #define Pin_SCLK_INTSTAT                (* (reg32 *) Pin_SCLK__INTSTAT)

#endif /* Interrupt Registers */

#endif /* End Pins Pin_SCLK_H */


/* [] END OF FILE */
