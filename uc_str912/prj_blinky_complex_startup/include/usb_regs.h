/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : usb_regs.h
* Author             : MCD Application Team
* Date First Issued  : 05/18/2006 : Version 1.0
* Description        : Interface functions to USB cell registers
********************************************************************************
* History:
* 05/24/2006 : Version 1.1
* 05/18/2006 : Version 1.0
********************************************************************************
* THE PRESENT SOFTWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS WITH
* CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME. AS
* A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY DIRECT, INDIRECT
* OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE CONTENT
* OF SUCH SOFTWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING INFORMATION
* CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

#define RegBase  (0x70000800L)  /* USB_IP Peripheral Registers base address */
#define PMAAddr  (0x70000000L)  /* USB_IP Packet Memory Area base address */

/* General registers */
#define CNTR    ((volatile unsigned *)(RegBase + 0x40))	/* Control register */
#define ISTR    ((volatile unsigned *)(RegBase + 0x44))	/* Interrupt status register */
#define FNR     ((volatile unsigned *)(RegBase + 0x48)) /* Frame number register */
#define DADDR   ((volatile unsigned *)(RegBase + 0x4C))	/* Device address register */
#define BTABLE  ((volatile unsigned *)(RegBase + 0x50))	/* Buffer Table address register */
#define DMACR1  ((volatile unsigned *)(RegBase + 0x54)) /* DMA control register 1 */
#define DMACR2  ((volatile unsigned *)(RegBase + 0x58)) /* DMA control register 2 */
#define DMACR3  ((volatile unsigned *)(RegBase + 0x5C)) /* DMA control register 3 */
#define DMABSIZE ((volatile unsigned *)(RegBase + 0x60))/* DMA burst size register */
#define DMALLI  ((volatile unsigned *)(RegBase + 0x64)) /* DMA LLI register */


/* Endpoint registers */
#define EP0REG  ((volatile unsigned *)(RegBase)) /* endpoint 0 register address */
/* endpoints enumeration */
#define ENDP0	 ((BYTE)0)
#define ENDP1	 ((BYTE)1)
#define ENDP2	 ((BYTE)2)
#define ENDP3	 ((BYTE)3)
#define ENDP4	 ((BYTE)4)
#define ENDP5	 ((BYTE)5)
#define ENDP6	 ((BYTE)6)
#define ENDP7	 ((BYTE)7)
#define ENDP8	 ((BYTE)8)
#define ENDP9	 ((BYTE)9)

/******************************************************************************/
/* 							ISTR interrupt events  							                          */
/******************************************************************************/
#define ISTR_CTR   	(0x8000)	/* Correct TRansfer	 (clear-only bit) */
#define ISTR_DOVR  	(0x4000)	/* DMA OVeR/underrun (clear-only bit) */
#define ISTR_ERR   	(0x2000)	/* ERRor					   (clear-only bit) */
#define ISTR_WKUP  	(0x1000)	/* WaKe UP					 (clear-only bit) */
#define ISTR_SUSP  	(0x0800)	/* SUSPend				   (clear-only bit) */
#define ISTR_RESET 	(0x0400)	/* RESET					   (clear-only bit) */
#define ISTR_SOF   	(0x0200)	/* Start Of Frame		 (clear-only bit) */
#define ISTR_ESOF  	(0x0100)	/* Expected Start Of Frame	(clear-only bit) */
#define ISTR_SZDPR  (0x0080)  /* Short or Zero-Length Received Data Packet */
#define ISTR_DIR   	(0x0010)	/* DIRection of transaction	(read-only bit)  */
#define ISTR_EP_ID 	(0x000F)	/* EndPoint IDentifier		  (read-only bit)  */

#define CLR_CTR   	(~ISTR_CTR)	 /* clear Correct TRansfer bit */
#define CLR_DOVR  	(~ISTR_DOVR) /* clear DMA OVeR/underrun	bit*/
#define CLR_ERR   	(~ISTR_ERR)	 /* clear ERRor	bit */
#define CLR_WKUP  	(~ISTR_WKUP) /* clear WaKe UP bit */
#define CLR_SUSP  	(~ISTR_SUSP) /* clear SUSPend bit */
#define CLR_RESET 	(~ISTR_RESET)/* clear RESET	bit */
#define CLR_SOF   	(~ISTR_SOF)	 /* clear Start Of Frame bit */
#define CLR_ESOF  	(~ISTR_ESOF) /* clear Expected Start Of Frame bit */
#define CLR_SZDPR   (~ISTR_SZDPR)/* clear SZDPR bit */

/******************************************************************************/
/*				 CNTR control register bits definitions						                  */
/******************************************************************************/
#define CNTR_CTRM   (0x8000)	/* Correct TRansfer Mask */
#define CNTR_DOVRM  (0x4000)	/* DMA OVeR/underrun Mask */
#define CNTR_ERRM   (0x2000)	/* ERRor Mask */
#define CNTR_WKUPM  (0x1000)	/* WaKe UP Mask */
#define CNTR_SUSPM  (0x0800)	/* SUSPend Mask	*/
#define CNTR_RESETM (0x0400)	/* RESET Mask   */
#define CNTR_SOFM   (0x0200)	/* Start Of Frame Mask */
#define CNTR_ESOFM  (0x0100)	/* Expected Start Of Frame Mask */
#define CNTR_SZDPRM (0x0080)  /* Short or Zero-Length Received Data Packet Mask*/
#define CNTR_RESUME (0x0010)	/* RESUME request */
#define CNTR_FSUSP  (0x0008)	/* Force SUSPend */
#define CNTR_LPMODE (0x0004)	/* Low-power MODE	*/
#define CNTR_PDWN   (0x0002)	/* Power DoWN */
#define CNTR_FRES   (0x0001)	/* Force USB RESet */

/******************************************************************************/
/* 					FNR Frame Number Register bit definitions				                  */
/******************************************************************************/
#define FNR_RXDP	(0x8000)	/* status of D+ data line */
#define FNR_RXDM	(0x4000)	/* status of D- data line */
#define FNR_LCK		(0x2000)	/* LoCKed */
#define FNR_LSOF	(0x1800)	/* Lost SOF */
#define FNR_FN		(0x07FF)	/* Frame Number */
/******************************************************************************/
/*					DADDR Device ADDRess bit definitions					                    */
/******************************************************************************/
#define DADDR_EF	(0x80)
#define DADDR_ADD	(0x7F)

/******************************************************************************/
/*          Endpoint register                                                 */
/******************************************************************************/
/* bit positions */
#define EP_CTR_RX      (0x8000) /* EndPoint Correct TRansfer RX 	*/
#define EP_DTOG_RX     (0x4000) /* EndPoint Data TOGGLE RX */
#define EPRX_STAT      (0x3000)	/* EndPoint RX STATus bit field */
#define EP_SETUP       (0x0800)	/* EndPoint SETUP */
#define EP_T_FIELD     (0x0600) /* EndPoint TYPE */
#define EP_KIND        (0x0100) /* EndPoint KIND */
#define EP_CTR_TX      (0x0080) /* EndPoint Correct TRansfer TX */
#define EP_DTOG_TX     (0x0040) /* EndPoint Data TOGGLE TX */
#define EPTX_STAT      (0x0030)	/* EndPoint TX STATus bit field */
#define EPADDR_FIELD   (0x000F) /* EndPoint ADDRess FIELD */

/* EndPoint REGister MASK (no toggle fields) */
#define EPREG_MASK     (EP_CTR_RX|EP_SETUP|EP_T_FIELD|EP_KIND|EP_CTR_TX|EPADDR_FIELD)

/* EP_TYPE[1:0] EndPoint TYPE */
#define EP_BULK        (0x0000)	/* EndPoint BULK */
#define EP_CONTROL     (0x0200) /* EndPoint CONTROL */
#define EP_ISOCHRONOUS (0x0400) /* EndPoint ISOCHRONOUS */
#define EP_INTERRUPT   (0x0600) /* EndPoint INTERRUPT */
#define EP_T_MASK      (~EP_T_FIELD & EPREG_MASK)


/* EP_KIND EndPoint KIND */
#define EPKIND_MASK    (~EP_KIND & EPREG_MASK)

/* STAT_TX[1:0] STATus for TX transfer */
#define EP_TX_DIS      (0x0000)	/* EndPoint TX DISabled */
#define EP_TX_STALL    (0x0010)	/* EndPoint TX STALLed */
#define EP_TX_NAK      (0x0020) /* EndPoint TX NAKed */
#define EP_TX_VALID    (0x0030)	/* EndPoint TX VALID */
#define EPTX_DTOG1     (0x0010)	/* EndPoint TX Data TOGgle bit1 */
#define EPTX_DTOG2     (0x0020)	/* EndPoint TX Data TOGgle bit2 */
#define EPTX_DTOGMASK  (EPTX_STAT|EPREG_MASK)

/* STAT_RX[1:0] STATus for RX transfer */
#define EP_RX_DIS      (0x0000)	/* EndPoint RX DISabled */
#define EP_RX_STALL    (0x1000)	/* EndPoint RX STALLed */
#define EP_RX_NAK      (0x2000)	/* EndPoint RX NAKed */
#define EP_RX_VALID    (0x3000)	/* EndPoint RX VALID */
#define EPRX_DTOG1     (0x1000)	/* EndPoint RX Data TOGgle bit1 */
#define EPRX_DTOG2     (0x2000)	/* EndPoint RX Data TOGgle bit1 */
#define EPRX_DTOGMASK  (EPRX_STAT|EPREG_MASK)


typedef enum _EP_DBUF_DIR{		/* double buffered endpoint direction */
 EP_DBUF_ERR,
 EP_DBUF_OUT,
 EP_DBUF_IN
}EP_DBUF_DIR;

enum EP_BUF_NUM{	/* endpoint buffer number */
 EP_NOBUF,
 EP_BUF0 ,
 EP_BUF1
};


extern volatile WORD wIstr;  /* ISTR register last read value */

/******************************************************************************/
/*				             FUNCTION PROTOTYPES							                      */
/*							                &									                            */
/*						              M A C R O s 							                        */
/******************************************************************************/

/* SetCNTR */
void SetCNTR(WORD /*wRegValue*/);
#define _SetCNTR(wRegValue)	 (*CNTR   = (WORD)wRegValue)
/*----------------------------------------------------------------------------*/
/* SetISTR */
void SetISTR(WORD /*wRegValue*/);
#define _SetISTR(wRegValue)	 (*ISTR   = (WORD)wRegValue)
/*----------------------------------------------------------------------------*/
/* SetDADDR */
void SetDADDR(WORD /*wRegValue*/);
#define _SetDADDR(wRegValue) (*DADDR  = (WORD)wRegValue)
/*----------------------------------------------------------------------------*/
/* SetBTABLE */
void SetBTABLE(WORD /*wRegValue*/);
#define _SetBTABLE(wRegValue)(*BTABLE = (WORD)(wRegValue & 0xFFF8))
/*----------------------------------------------------------------------------*/
/* GetCNTR */
WORD GetCNTR(void);
#define _GetCNTR()   ((WORD) *CNTR)
/*----------------------------------------------------------------------------*/
/* GetISTR */
WORD GetISTR(void);
#define _GetISTR()   ((WORD) *ISTR)
/*----------------------------------------------------------------------------*/
/* GetFNR */
WORD GetFNR(void);
#define _GetFNR()    ((WORD) *FNR)
/*----------------------------------------------------------------------------*/
/* GetDADDR */
WORD GetDADDR(void);
#define	_GetDADDR()  ((WORD) *DADDR)
/*----------------------------------------------------------------------------*/
/* GetBTABLE */
WORD GetBTABLE(void);
#define _GetBTABLE() ((WORD) *BTABLE)
/*----------------------------------------------------------------------------*/
/* Pointers on endpoint(bEpNum) Count & Addr registers on PMA */
#define _pEPBufCount(bEpNum)	((DWORD *)(_GetBTABLE()+bEpNum*8 + 4   + PMAAddr))
#define _pEPBufAddr(bEpNum)	((DWORD *)(_GetBTABLE()+bEpNum*8         + PMAAddr))
/*----------------------------------------------------------------------------*/
/* SetENDPOINT */
void SetENDPOINT(BYTE /*bEpNum*/,WORD /*wRegValue*/);
#define _SetENDPOINT(bEpNum,wRegValue)  (*(EP0REG + bEpNum)= \
/*----------------------------------------------------------------------------*/												 (WORD)wRegValue)
/* GetENDPOINT */
WORD GetENDPOINT(BYTE /*bEpNum*/);
#define _GetENDPOINT(bEpNum)  		    ((WORD)(*(EP0REG + bEpNum)))
/*----------------------------------------------------------------------------*/
/* SetEPType */
void SetEPType(BYTE /*bEpNum*/,WORD /*wType*/);
#define _SetEPType(bEpNum,wType)	(_SetENDPOINT(bEpNum,\
						((_GetENDPOINT(bEpNum) & EP_T_MASK) | wType)))
/*----------------------------------------------------------------------------*/
/* GetEPType */
WORD GetEPType(BYTE /*bEpNum*/);
#define _GetEPType(bEpNum) (_GetENDPOINT(bEpNum) & EP_T_FIELD)
/*----------------------------------------------------------------------------*/
/* SetEPTxStatus */
void SetEPTxStatus(BYTE /*bEpNum*/,WORD /*wState*/);
#define _SetEPTxStatus(bEpNum,wState) {\
 register WORD _wRegVal; \
 _wRegVal = _GetENDPOINT(bEpNum) & EPTX_DTOGMASK; \
 /* toggle first bit ? */		   \
 if((EPTX_DTOG1 & wState)!= 0) \
 _wRegVal ^= EPTX_DTOG1;    	 \
 /* toggle second bit ?  */ 	 \
 if((EPTX_DTOG2 & wState)!= 0) \
 _wRegVal ^= EPTX_DTOG2; \
 _SetENDPOINT(bEpNum, _wRegVal); \
} /* _SetEPTxStatus */
/*----------------------------------------------------------------------------*/
/* SetEPRxStatus */
void SetEPRxStatus(BYTE /*bEpNum*/,WORD /*wState*/);
#define _SetEPRxStatus(bEpNum,wState) {\
 register WORD _wRegVal;			\
 _wRegVal = _GetENDPOINT(bEpNum) & EPRX_DTOGMASK;\
 /* toggle first bit ?	*/		\
 if((EPRX_DTOG1 & wState)!= 0)	\
 _wRegVal ^= EPRX_DTOG1;		\
 /* toggle second bit ?	*/		\
 if((EPRX_DTOG2 & wState)!= 0)	\
 _wRegVal ^= EPRX_DTOG2;		\
 _SetENDPOINT(bEpNum, _wRegVal);	\
} /* _SetEPRxStatus */
/*----------------------------------------------------------------------------*/
/* GetEPTxStatus / GetEPRxStatus */
WORD GetEPTxStatus(BYTE /*bEpNum*/);
WORD GetEPRxStatus(BYTE /*bEpNum*/);
#define _GetEPTxStatus(bEpNum) ((WORD)_GetENDPOINT(bEpNum) & EPTX_STAT)
#define _GetEPRxStatus(bEpNum) ((WORD)_GetENDPOINT(bEpNum) & EPRX_STAT)
/*----------------------------------------------------------------------------*/
/* SetEPTxValid / SetEPRxValid */
void SetEPTxValid(BYTE /*bEpNum*/);
void SetEPRxValid(BYTE /*bEpNum*/);
#define _SetEPTxValid(bEpNum)     (_SetEPTxStatus(bEpNum, EP_TX_VALID))
#define _SetEPRxValid(bEpNum)     (_SetEPRxStatus(bEpNum, EP_RX_VALID))
/*----------------------------------------------------------------------------*/
/* GetTxStallStatus / GetRxStallStatus */
BOOL GetTxStallStatus(BYTE /*bEpNum*/);
BOOL GetRxStallStatus(BYTE /*bEpNum*/);
#define _GetTxStallStatus(bEpNum) (_GetEPTxStatus(bEpNum) \
													 == EP_TX_STALL)
#define _GetRxStallStatus(bEpNum) (_GetEPRxStatus(bEpNum) \
													 == EP_RX_STALL)
/*----------------------------------------------------------------------------*/
/* SetEP_KIND / ClearEP_KIND */
void SetEP_KIND(BYTE /*bEpNum*/);
void ClearEP_KIND(BYTE /*bEpNum*/);
#define _SetEP_KIND(bEpNum)	   (_SetENDPOINT(bEpNum, \
					    (_GetENDPOINT(bEpNum) | EP_KIND) & EPREG_MASK))
#define _ClearEP_KIND(bEpNum)  (_SetENDPOINT(bEpNum, \
						         (_GetENDPOINT(bEpNum) & EPKIND_MASK)))
/*----------------------------------------------------------------------------*/
/* Set_Status_Out / Clear_Status_Out */
void Set_Status_Out(BYTE /*bEpNum*/);
void Clear_Status_Out(BYTE /*bEpNum*/);
#define _Set_Status_Out(bEpNum)	   _SetEP_KIND(bEpNum)
#define _Clear_Status_Out(bEpNum)  _ClearEP_KIND(bEpNum)
/*----------------------------------------------------------------------------*/
/* SetEPDoubleBuff / ClearEPDoubleBuff */
void SetEPDoubleBuff(BYTE /*bEpNum*/);
void ClearEPDoubleBuff(BYTE /*bEpNum*/);
#define _SetEPDoubleBuff(bEpNum)   _SetEP_KIND(bEpNum)
#define _ClearEPDoubleBuff(bEpNum) _ClearEP_KIND(bEpNum)
/*----------------------------------------------------------------------------*/
/* ClearEP_CTR_RX / ClearEP_CTR_TX */
void ClearEP_CTR_RX(BYTE /*bEpNum*/);
void ClearEP_CTR_TX(BYTE /*bEpNum*/);
#define _ClearEP_CTR_RX(bEpNum)   (_SetENDPOINT(bEpNum,\
						   _GetENDPOINT(bEpNum) & 0x7FFF & EPREG_MASK))
#define _ClearEP_CTR_TX(bEpNum)   (_SetENDPOINT(bEpNum,\
						   _GetENDPOINT(bEpNum) & 0xFF7F & EPREG_MASK))
/*----------------------------------------------------------------------------*/
/* ToggleDTOG_RX / ToggleDTOG_TX */
void ToggleDTOG_RX(BYTE /*bEpNum*/);
void ToggleDTOG_TX(BYTE /*bEpNum*/);
#define _ToggleDTOG_RX(bEpNum)    (_SetENDPOINT(bEpNum, \
					   ((EP_DTOG_RX | _GetENDPOINT(bEpNum)) & EPREG_MASK)))
#define _ToggleDTOG_TX(bEpNum)    (_SetENDPOINT(bEpNum, \
					   ((EP_DTOG_TX | _GetENDPOINT(bEpNum)) & EPREG_MASK)))
/*----------------------------------------------------------------------------*/
/* ClearDTOG_RX / ClearDTOG_TX */
void ClearDTOG_RX(BYTE /*bEpNum*/);
void ClearDTOG_TX(BYTE /*bEpNum*/);
#define _ClearDTOG_RX(bEpNum)  if((_GetENDPOINT(bEpNum) & EP_DTOG_RX) != 0)\
			 							_ToggleDTOG_RX(bEpNum)
#define _ClearDTOG_TX(bEpNum)  if((_GetENDPOINT(bEpNum) & EP_DTOG_TX) != 0)\
			 							_ToggleDTOG_TX(bEpNum)
/*----------------------------------------------------------------------------*/
/* SetEPAddress */
void SetEPAddress(BYTE /*bEpNum*/,BYTE /*bAddr*/);
#define _SetEPAddress(bEpNum,bAddr) _SetENDPOINT(bEpNum,\
						(_GetENDPOINT(bEpNum) & (EPREG_MASK | bAddr)))
/*----------------------------------------------------------------------------*/
/* GetEPAddress */
BYTE GetEPAddress(BYTE /*bEpNum*/);
#define _GetEPAddress(bEpNum) ((BYTE)(_GetENDPOINT(bEpNum) & EPADDR_FIELD))
/*----------------------------------------------------------------------------*/
/* SetEPTxAddr / SetEPRxAddr*/
void SetEPTxAddr(BYTE /*bEpNum*/,WORD /*wAddr*/);
#define _SetEPTxAddr(bEpNum , wAddr) {\
 *_pEPBufAddr(bEpNum) &=0xFFFF0000; \
 *_pEPBufAddr(bEpNum) |=((wAddr)&0x0FFFC);\
 }
void SetEPRxAddr(BYTE /*bEpNum*/,WORD /*wAddr*/);
#define _SetEPRxAddr(bEpNum, wAddr) {\
 *_pEPBufAddr(bEpNum) &=0x0000FFFF;\
 *_pEPBufAddr(bEpNum) |=((wAddr<<16)&0xFFFC0000);\
}
/*----------------------------------------------------------------------------*/
/* GetEPTxAddr / GetEPRxAddr */
WORD GetEPTxAddr(BYTE /*bEpNum*/);
#define _GetEPTxAddr(bEpNum) ((WORD)(*_pEPBufAddr(bEpNum) &0x0000FFFF))
WORD GetEPRxAddr(BYTE /*bEpNum*/);
#define _GetEPRxAddr(bEpNum) ((WORD)((*_pEPBufAddr(bEpNum)&0xFFFF0000)>>16))
/*----------------------------------------------------------------------------*/
/* SetEPTxCount / SetEPRxCount */
void SetEPTxCount(BYTE /*bEpNum*/,WORD /*wCount*/);
#define _SetEPTxCount(bEpNum,wCount) {\
 *_pEPBufCount(bEpNum) &=0xFFFFFC00;\
 *_pEPBufCount(bEpNum) |=wCount;\
}
/*----------------------------------------------------------------------------*/
void SetEPRxCount(BYTE /*bEpNum*/,WORD /*wCount*/);
#define _SetEPRxCount(bEpNum,wCount) {\
DWORD BLsize=0;\
DWORD Blocks;\
if (wCount < 64) Blocks = wCount>>1;\
else\
{\
  BLsize = 0x80000000;\
  Blocks = wCount>>6;\
}\
*_pEPBufCount(bEpNum) &=~0x80000000;\
*_pEPBufCount(bEpNum) |=BLsize;\
*_pEPBufCount(bEpNum)  &=0x83FFFFFF;\
*_pEPBufCount(bEpNum) |=Blocks<<26;\
*_pEPBufCount(bEpNum) &=0xFC00FFFF;\
}

/*----------------------------------------------------------------------------*/
/* GetEPTxCount / GetEPRxCount */
WORD GetEPTxCount(BYTE /*bEpNum*/);
#define _GetEPTxCount(bEpNum) (WORD)(*_pEPBufCount(bEpNum)&0x3FF)
WORD GetEPRxCount(BYTE /*bEpNum*/);
#define _GetEPRxCount(bEpNum) (WORD)((*_pEPBufCount(bEpNum)&0x3FF0000)>>16)
/*----------------------------------------------------------------------------*/
/* SetEPDblBuf0Addr / SetEPDblBuf1Addr */
void SetEPDblBuf0Addr(BYTE /*bEpNum*/,WORD /*wBuf0Addr*/);
void SetEPDblBuf1Addr(BYTE /*bEpNum*/,WORD /*wBuf1Addr*/);
#define _SetEPDblBuf0Addr(bEpNum,wBuf0Addr) {_SetEPTxAddr(bEpNum, wBuf0Addr);}
#define _SetEPDblBuf1Addr(bEpNum,wBuf1Addr) {_SetEPRxAddr(bEpNum, wBuf1Addr);}
/*----------------------------------------------------------------------------*/
/* SetEPDblBuffAddr */
void SetEPDblBuffAddr(BYTE /*bEpNum*/,WORD /*wBuf0Addr*/,WORD /*wBuf1Addr*/);
#define _SetEPDblBuffAddr(bEpNum,wBuf0Addr,wBuf1Addr) { 		\
					_SetEPDblBuf0Addr(bEpNum, wBuf0Addr);	\
					_SetEPDblBuf1Addr(bEpNum, wBuf1Addr);	\
} /* _SetEPDblBuffAddr */
/*----------------------------------------------------------------------------*/
/* GetEPDblBuf0Addr / GetEPDblBuf1Addr */
WORD GetEPDblBuf0Addr(BYTE /*bEpNum*/);
WORD GetEPDblBuf1Addr(BYTE /*bEpNum*/);
#define _GetEPDblBuf0Addr(bEpNum) (_GetEPTxAddr(bEpNum))
#define _GetEPDblBuf1Addr(bEpNum) (_GetEPRxAddr(bEpNum))
/*----------------------------------------------------------------------------*/
/* SetEPDblBuffCount / SetEPDblBuf0Count / SetEPDblBuf1Count */
void SetEPDblBuffCount(BYTE /*bEpNum*/, BYTE /*bDir*/, WORD /*wCount*/);
void SetEPDblBuf0Count(BYTE /*bEpNum*/, BYTE /*bDir*/, WORD /*wCount*/);
void SetEPDblBuf1Count(BYTE /*bEpNum*/, BYTE /*bDir*/, WORD /*wCount*/);

/*----------------------------------------------------------------------------*/
/* GetEPDblBuf0Count / GetEPDblBuf1Count */
WORD GetEPDblBuf0Count(BYTE /*bEpNum*/);
WORD GetEPDblBuf1Count(BYTE /*bEpNum*/);
#define _GetEPDblBuf0Count(bEpNum) (GetEPTxCount(bEpNum))
#define _GetEPDblBuf1Count(bEpNum) (GetEPRxCount(bEpNum))
/*----------------------------------------------------------------------------*/
/* FreeUserBuffer */
void FreeUserBuffer(BYTE /*bEpNum*/,BYTE Dir);
/*----------------------------------------------------------------------------*/
/* ToWord */
WORD ToWord(BYTE,BYTE);
/*----------------------------------------------------------------------------*/
/* ByteSwap */
WORD ByteSwap(WORD);
/*----------------------------------------------------------------------------*/

/* DMA Functions */
void SetDMABurstTxSize(BYTE /*DestBsize*/);
void SetDMABurstRxSize(BYTE /*SrcBsize*/);
void DMAUnlinkedModeTxConfig(BYTE /*bEpNum*/ ,BYTE /*index*/);
void DMAUnlinkedModeTxEnable(BYTE /*index*/);
void DMAUnlinkedModeTxDisable(BYTE /*index*/);
void DMAUnlinkedModeRxEnable(BYTE /*bEpNum*/);
void DMAUnlinkedModeRxDisable(BYTE /*bEpNum*/);
void DMALinkedModeRxConfig(BYTE /*bEpNum*/);
void DMALinkedModeTxConfig(BYTE /*bEpNum*/);
void DMALinkedModeRxEnable(void);
void DMALinkedModeTxEnable(void);
void DMALinkedModeRxDisable(void);
void DMALinkedModeTxDisable(void);
void DMASynchEnable(void);
void DMASynchDisable(void);
void SetDMALLITxLength(BYTE /*length*/);
void SetDMALLIRxLength(BYTE /*length*/ );
void SetDMALLIRxPacketNum(BYTE /*PacketNum*/);
BYTE GetDMALLIRxPacketNum(void);
