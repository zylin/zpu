/***********************************************************************************
*	Copyright 2005 Anglia Design
*	This demo code and associated components are provided as is and has no warranty,
*	implied or otherwise.  You are free to use/modify any of the provided
*	code at your own risk in your applications with the expressed limitation
*	of liability (see below)
* 
*	LIMITATION OF LIABILITY:   ANGLIA OR ANGLIA DESIGNS SHALL NOT BE LIABLE FOR ANY
*	LOSS OF PROFITS, LOSS OF USE, LOSS OF DATA, INTERRUPTION OF BUSINESS, NOR FOR
*	INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND WHETHER UNDER
*	THIS AGREEMENT OR OTHERWISE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*
*	Author			: Spencer Oliver
*	Web     		: www.anglia-designs.com
*
***********************************************************************************/

#ifndef _VECTOR_H
#define _VECTOR_H

#ifdef __cplusplus
extern "C" {
#endif

void Undefined_Handler(void);
void FIQ_Handler(void);
void SWI_Handler(void);
void Prefetch_Handler(void);
void Abort_Handler(void);
void WDG_IRQHandler(void);
void SW_IRQHandler(void);
void ARMRX_IRQHandler(void);
void ARMTX_IRQHandler(void);
void TIM0_IRQHandler(void);
void TIM1_IRQHandler(void);
void TIM2_IRQHandler(void);
void TIM3_IRQHandler(void);
void USBHP_IRQHandler(void);
void USBLP_IRQHandler(void);
void SCU_IRQHandler(void);
void ENET_IRQHandler(void);
void DMA_IRQHandler(void);
void CAN_IRQHandler(void);
void MC_IRQHandler(void);
void ADC_IRQHandler(void);
void UART0_IRQHandler(void);
void UART1_IRQHandler(void);
void UART2_IRQHandler(void);
void I2C0_IRQHandler(void);
void I2C1_IRQHandler(void);
void SSP0_IRQHandler(void);
void SSP1_IRQHandler(void);
void LVD_IRQHandler(void);
void RTC_IRQHandler(void);
void WIU_IRQHandler(void);
void EXTIT0_IRQHandler(void);
void EXTIT1_IRQHandler(void);
void EXTIT2_IRQHandler(void);
void EXTIT3_IRQHandler(void);
void USBWU_IRQHandler(void);
void PFQBC_IRQHandler(void);

#ifdef __cplusplus
}
#endif

#endif	//_VECTOR_H
