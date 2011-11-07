/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : usb_regs.c
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
#include "USB_lib.h"

/*******************************************************************************
* Function Name  : SetCNTR
* Description    : Sets the CNTR (Control Register)
* Input          : wRegValue = register value
* Output         : None
* Return         : None
*******************************************************************************/
void SetCNTR(WORD wRegValue)
{
  _SetCNTR(wRegValue);
}

/*******************************************************************************
* Function Name  : GetCNTR
* Description    : Gets the CNTR
* Input          : None
* Output         : None
* Return         : CNTR value
*******************************************************************************/
WORD GetCNTR(void)
{
  return(_GetCNTR());
}

/*******************************************************************************
* Function Name  : SetISTR
* Description    : Sets the ISTR
* Input          : wRegValue = register value
* Output         : None
* Return         : None
*******************************************************************************/
void SetISTR(WORD wRegValue)
{
  _SetISTR(wRegValue);
}

/*******************************************************************************
* Function Name  : GetISTR
* Description    : Gets the ISTR (Interrupt Status Register)
* Input          : None
* Output         : None
* Return         : ISTR register value
*******************************************************************************/
WORD GetISTR(void)
{
  return(_GetISTR());
}

/*******************************************************************************
* Function Name  : GetFNR
* Description    : Gets the FNR (Frame Number Register)
* Input          : None
* Output         : None
* Return         : FNR regiter value
*******************************************************************************/
WORD GetFNR(void)
{
  return(_GetFNR());
}

/*******************************************************************************
* Function Name  : SetDADDR
* Description    : Sets the DADDR (Device Address Register)
* Input          : wRegValue = register value
* Output         : None
* Return         : None
*******************************************************************************/
void SetDADDR(WORD wRegValue)
{
  _SetDADDR(wRegValue);
}

/*******************************************************************************
* Function Name  : GetDADDR
* Description    : Gets the DADDR (Device Address Register)
* Input          : None
* Output         : None
* Return         : DADDR register value
*******************************************************************************/
WORD GetDADDR(void)
{
  return(_GetDADDR());
}

/*******************************************************************************
* Function Name  : SetBTABLE
* Description    : Sets the BTABLE (Buffer Table Register)
* Input          : BTABLE value
* Output         : None
* Return         : None
*******************************************************************************/
void SetBTABLE(WORD wRegValue)
{
  _SetBTABLE(wRegValue);
}

/*******************************************************************************
* Function Name  : GetBTABLE
* Description    : Gets the BTABLE (Buffer Table Register)
* Input          : None
* Output         : None
* Return         : BTABLE value
*******************************************************************************/
WORD GetBTABLE(void)
{
  return(_GetBTABLE());
}

/*******************************************************************************
* Function Name  : SetENDPOINT
* Description    : Sets the Endpoint Register
* Input          : bEpNum = endpoint Number[0:9], wRegValue= register value
* Output         : None
* Return         : None
*******************************************************************************/
void SetENDPOINT(BYTE bEpNum, WORD wRegValue)
{
  _SetENDPOINT(bEpNum,wRegValue);
}

/*******************************************************************************
* Function Name  : GetENDPOINT
* Description    : Gets the Endpoint Register value
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : Endpoint register value
*******************************************************************************/
WORD GetENDPOINT(BYTE bEpNum)
{
  return(_GetENDPOINT(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPtype
* Description    : Sets the Endpoint Type
* Input          : - bEpNum = endpoint number[0:9]
*                  - wType  = endpint type:  EP_BULK,EP_CONTROL,EP_ISOCHRONOUS
*                  EP_INTERRUPT
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPType(BYTE bEpNum, WORD wType)
{
  _SetEPType(bEpNum, wType);
}

/*******************************************************************************
* Function Name  : GetEPtype
* Description    : Gets the Endpoint type
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : Endpoint type: EP_BULK,EP_CONTROL,EP_ISOCHRONOUS
*                  EP_INTERRUPT
*******************************************************************************/
WORD GetEPType(BYTE bEpNum)
{
  return(_GetEPType(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPTxStatus
* Description    : Sets the endpoint Tx status
* Input          : - bEpNum = endpoint number[0:9]
*                  - wState = Tx status: EP_TX_DIS,EP_TX_STALL,EP_TX_NAK,EP_TX_VALID
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPTxStatus(BYTE bEpNum, WORD wState)
{
  _SetEPTxStatus(bEpNum,wState);
}

/*******************************************************************************
* Function Name  : SetEPRxStatus
* Description    : Sets the endpoint Rx status
* Input          : - bEpNum = endpoint number[0:9]
*                  - wState = Rx status: EP_RX_DIS,EP_RX_STALL,EP_RX_NAK,EP_RX_VALID
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPRxStatus(BYTE bEpNum, WORD wState)
{
  _SetEPRxStatus(bEpNum,wState);
}

/*******************************************************************************
* Function Name  : GetEPTxStatus
* Description    : Gets the endpoint Tx Status
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : Enpointx Tx Status: EP_TX_DIS,EP_TX_STALL,EP_TX_NAK,EP_TX_VALID
*******************************************************************************/
WORD GetEPTxStatus(BYTE bEpNum)
{
  return(_GetEPTxStatus(bEpNum));
}

/*******************************************************************************
* Function Name  : GetEPRxStatus
* Description    : Gets the endpoint Rx Status
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : Enpointx Rx Status: EP_RX_DIS,EP_RX_STALL,EP_RX_NAK,EP_RX_VALID
*******************************************************************************/
WORD GetEPRxStatus(BYTE bEpNum)
{
  return(_GetEPRxStatus(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPTxValid
* Description    : Sets the Endpoint Tx Status as valid
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPTxValid(BYTE bEpNum)
{
  _SetEPTxStatus(bEpNum, EP_TX_VALID);
}

/*******************************************************************************
* Function Name  : SetEPRxStatus
* Description    : Sets the Endpoint Rx Status as valid
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPRxValid(BYTE bEpNum)
{
  _SetEPRxStatus(bEpNum, EP_RX_VALID);
}

/*******************************************************************************
* Function Name  : SetEP_KIND
* Description    : Sets the Endpoint EP_KIND bit
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void SetEP_KIND(BYTE bEpNum)
{
  _SetEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : ClearEP_KIND
* Description    : Clears the Endpoint EP_KIND bit
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearEP_KIND(BYTE bEpNum)
{
  _ClearEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : Clear_Status_Out
* Description    : Clears the Status_Out bit (= EP_KIND bit)
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void Clear_Status_Out(BYTE bEpNum)
{
   _ClearEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : Set_Status_Out
* Description    : Sets the Status_Out bit (=EP_KIND bit)
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void Set_Status_Out(BYTE bEpNum)
{
  _SetEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : SetEPDoubleBuff
* Description    : Sets the DBL_BUF bit (=EP_KIND bit)
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDoubleBuff(BYTE bEpNum)
{
   _SetEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : ClearEPDoubleBuff
* Description    : Clears the DBL_BUF bit (=EP_KIND bit)
* Input          : bEpNum = endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearEPDoubleBuff(BYTE bEpNum)
{
   _ClearEP_KIND(bEpNum);
}

/*******************************************************************************
* Function Name  : GetTxStallStatus
* Description    : checks if endpoint Tx status== STALL
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : TRUE or FALSE
*******************************************************************************/
BOOL GetTxStallStatus(BYTE bEpNum)
{
  return(_GetTxStallStatus(bEpNum));
}

/*******************************************************************************
* Function Name  : GetRxStallStatus
* Description    : checks if endpoint Rx status ==STALL
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : TRUE or FALSE
*******************************************************************************/
BOOL GetRxStallStatus(BYTE bEpNum)
{
  return(_GetRxStallStatus(bEpNum));
}

/*******************************************************************************
* Function Name  : ClearEP_CTR_RX
* Description    : Clears the CTR_RX flag in endpoint
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearEP_CTR_RX(BYTE bEpNum)
{
  _ClearEP_CTR_RX(bEpNum);
}

/*******************************************************************************
* Function Name  : ClearEP_CTR_Tx
* Description    : Clears the CTR_Tx flag
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearEP_CTR_TX(BYTE bEpNum)
{
  _ClearEP_CTR_TX(bEpNum);
}

/*******************************************************************************
* Function Name  : ToggleDTOG_RX
* Description    : Toggles the DTOG_RX bit
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ToggleDTOG_RX(BYTE bEpNum)
{
 _ToggleDTOG_RX(bEpNum);
}

/*******************************************************************************
* Function Name  : ToggleDTOG_TX
* Description    : Toggles the DTOG_Tx bit
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ToggleDTOG_TX(BYTE bEpNum)
{
  _ToggleDTOG_TX(bEpNum);
}

/*******************************************************************************
* Function Name  : ClearDTOG_RX
* Description    : Clears the DTOG_RX bit
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearDTOG_RX(BYTE bEpNum)
{
  _ClearDTOG_RX(bEpNum);
}

/*******************************************************************************
* Function Name  : ClearDTOG_TX
* Description    : Clears the DTOG_TX bit
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void ClearDTOG_TX(BYTE bEpNum)
{
  _ClearDTOG_TX(bEpNum);
}

/*******************************************************************************
* Function Name  : SetEPAddress
* Description    : Sets the Endpoint Address
* Input          : -bEpNum: endpoint number[0:9]
*                  -bAddr : Address value
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPAddress(BYTE bEpNum,BYTE bAddr)
{
  _SetEPAddress(bEpNum,bAddr);
}

/*******************************************************************************
* Function Name  : GetEPAddress
* Description    : Gets the Endpoint Address
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Endpoint address value
*******************************************************************************/
BYTE GetEPAddress(BYTE bEpNum)
{
  return(_GetEPAddress(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPTxAddr
* Description    : Sets the Endpoint Tx buffer Addr offset in the PMA
* Input          : - bEpNum: endpoint number[0:9]
*                  - wAddr : Tx buffer address offset value in the PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPTxAddr(BYTE bEpNum, WORD wAddr)
{
	_SetEPTxAddr(bEpNum,wAddr);
}

/*******************************************************************************
* Function Name  : SetEPRxAddr
* Description    : Sets the Endpoint Rx buffer Addr in the Packet Memory Area PMA
* Input          : - bEpNum: endpoint number[0:9]
*                  - wAddr : Rx buffer address offset value in the PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPRxAddr(BYTE bEpNum, WORD wAddr)
{
   _SetEPRxAddr(bEpNum,wAddr);
}

/*******************************************************************************
* Function Name  : GetEPTxAddr
* Description    : Gets the Endpoint Tx buffer address offset in PMA
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Endpoint Tx buffer Address offset in PMA
*******************************************************************************/
WORD GetEPTxAddr(BYTE bEpNum)
{
  return (_GetEPTxAddr(bEpNum));
}

/*******************************************************************************
* Function Name  : GetEPRxAddr
* Description    : Gets the Endpoint Rx buffer address offset in the PMA
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Endpoint Rx buffer Address offset in PMA
*******************************************************************************/
WORD GetEPRxAddr(BYTE bEpNum)
{
 return(_GetEPRxAddr(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPTxCount
* Description    : Sets the Endpoint Tx buffer size
* Input          : - bEpNum: endpoint number[0:9]
*                  - wCount: size (in bytes) of the Tx buffer in the PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPTxCount(BYTE bEpNum, WORD wCount)
{
  _SetEPTxCount(bEpNum,wCount);
}

/*******************************************************************************
* Function Name  : SetEPRxCount
* Description    : Sets the Endpoint Rx buffer size
* Input          : - bEpNum: endpoint number[0:9]
*                  - wCount : size (in bytes) of the Rx buffer in the PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPRxCount(BYTE bEpNum, WORD wCount)
{
   _SetEPRxCount(bEpNum,wCount);
}
/*******************************************************************************
* Function Name  : GetEPTxCount
* Description    : Gets the Endpoint count value
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Endpoint TxCount value
*******************************************************************************/

WORD GetEPTxCount(BYTE bEpNum)
{
	  return(_GetEPTxCount(bEpNum));
}

/*******************************************************************************
* Function Name  : GetEPRxCount
* Description    : Gets the Endpoint Count register value
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Endpoint Rx Count value
*******************************************************************************/
WORD GetEPRxCount(BYTE bEpNum)
{
   return(_GetEPRxCount(bEpNum));
}

/*******************************************************************************
* Function Name  : SetEPDblBuffAddr
* Description    : Set double buffer buffer0, buffer1 addresses in the PMA
* Input          : - bEpNum: endpoint number[0:9]
*                  - wBuf0Addr : buffer0 Address offset in PMA
*                  - wBuf1Addr : buffer1 Address offset in PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuffAddr(BYTE bEpNum, WORD wBuf0Addr, WORD wBuf1Addr)
{
  _SetEPDblBuffAddr(bEpNum, wBuf0Addr, wBuf1Addr);
}

/*******************************************************************************
* Function Name  : SetEPDBlBuf0Addr
* Description    : Set buffer0 address in PMA
* Input          : -bEpNum: endpoint number[0:9]
*                  -wBuf0Addr: buffer0 Address offset in PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuf0Addr(BYTE bEpNum,WORD wBuf0Addr)
{
  _SetEPDblBuf0Addr(bEpNum, wBuf0Addr);
}
/*******************************************************************************
* Function Name  : SetEPDBlBuf1Addr
* Description    : Set buffer1 address in PMA
* Input          : -bEpNum: endpoint number[0:9]
*                  -wBuf1Addr: buffer1 Address offset in PMA
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuf1Addr(BYTE bEpNum,WORD wBuf1Addr)
{
  _SetEPDblBuf1Addr(bEpNum, wBuf1Addr);
}

/*******************************************************************************
* Function Name  : GetEPDblBuf0Addr
* Description    : Gets buffer0 address
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Buffer 0 Address offset in PMA
*******************************************************************************/
WORD GetEPDblBuf0Addr(BYTE bEpNum)
{
  return(_GetEPDblBuf0Addr(bEpNum));
}

/*******************************************************************************
* Function Name  : GetEPDblbuf1Addr
* Description    : Gets buffer1 address
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : Buffer 1 Address offset in PMA
*******************************************************************************/
WORD GetEPDblBuf1Addr(BYTE bEpNum)
{
  return(_GetEPDblBuf1Addr(bEpNum));
}
/*******************************************************************************
* Function Name  : SetEPDblBuf1Count
* Description    : Set buffer1 size
* Input          : - bEpNum: endpoint number[0:9]
*                  - bDir: buffer direction :  EP_DBUF_OUT or EP_DBUF_IN
*                  - wCount: bytes count value
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuf1Count(BYTE bEpNum, BYTE bDir,WORD wCount)
{
 if(bDir == EP_DBUF_IN)					
 /* IN double buffered endpoint */						
 {
   *_pEPBufCount(bEpNum)&= 0x000FFFF;
   *_pEPBufCount(bEpNum)|=(wCount<<16);
 }
 else if(bDir == EP_DBUF_OUT)				
 /* OUT double buffered endpoint */						
  _SetEPRxCount(bEpNum, wCount);
}


/*******************************************************************************
* Function Name  : SetEPDblBuf0Count
* Description    : Set buffer0 size
* Input          : - bEpNum: endpoint number[0:9]
*                  - bDir: buffer direction :  EP_DBUF_OUT or EP_DBUF_IN
*                  - wCount: bytes count value
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuf0Count(BYTE bEpNum, BYTE bDir,WORD wCount)
{
DWORD BLsize=0;
DWORD Blocks;
if(bDir == EP_DBUF_IN)   					
/* IN double bufferd endpoint */						
SetEPTxCount(bEpNum,wCount);
else if(bDir == EP_DBUF_OUT) {				
/* OUT double bufferd endpoint */			

   if (wCount < 64) Blocks = wCount>>1;
   else
   {
   BLsize = 0x8000;
   Blocks = wCount>>6;
   }
	 *_pEPBufCount(bEpNum) &=~0x8000;
	 *_pEPBufCount(bEpNum) |=BLsize;
	 *_pEPBufCount(bEpNum)  &=~0x7C00;
	 *_pEPBufCount(bEpNum) |=Blocks<<10;
	 *_pEPBufCount(bEpNum) &=0xFFFFFC00;
 }
}

/*******************************************************************************
* Function Name  : SetEPDblBuffCount
* Description    : Set buffer0 or 1 size
* Input          : - bEpNum: endpoint number[0:9]
                   - bDir: buffer direction :  EP_DBUF_OUT, EP_DBUF_IN
                   - wCount: bytes count value
* Output         : None
* Return         : None
*******************************************************************************/
void SetEPDblBuffCount(BYTE bEpNum, BYTE bDir, WORD wCount)
{
	SetEPDblBuf0Count(bEpNum, bDir,wCount);
	SetEPDblBuf1Count(bEpNum, bDir,wCount);
}

/*******************************************************************************
* Function Name  : GetEPDblBuf0Count
* Description    : Get buffer0 bytes count
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : buffer0 bytes count
*******************************************************************************/
WORD GetEPDblBuf0Count(BYTE bEpNum)
{
	return(_GetEPDblBuf0Count(bEpNum));
}

/*******************************************************************************
* Function Name  : GetEPDBuf1Count
* Description    : Get buffer1 bytes count
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : buffer1 bytes count
*******************************************************************************/
WORD GetEPDblBuf1Count(BYTE bEpNum)
{
	return(_GetEPDblBuf1Count(bEpNum));
}

/*******************************************************************************
* Function Name  : Free User buffer
* Description    : Toggles the SW_Buf bit
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void FreeUserBuffer(BYTE bEpNum, BYTE bDir)
{
   if(bDir== EP_DBUF_OUT)
   { /* OUT double buffered endpoint */
    _ToggleDTOG_TX(bEpNum);
   }
   else if(bDir == EP_DBUF_IN)
   { /* IN double buffered endpoint */
    _ToggleDTOG_RX(bEpNum);
   }
}

/*******************************************************************************
* Function Name  : ToWord
* Description    : Puts 2 bytes into a single word
* Input          : -bh : MSB byte
                   -bl : LSB byte
* Output         : None
* Return         : Word
*******************************************************************************/
WORD ToWord(BYTE bh, BYTE bl)
{
	WORD wRet;
	wRet = (WORD)bl | ((WORD)bh << 8);
	return(wRet);
}

/*******************************************************************************
* Function Name  : ByteSwap
* Description    : Swaps two bytes in a word
* Input          : wSwW: word
* Output         : None
* Return         : Word swapped
*******************************************************************************/
WORD ByteSwap(WORD wSwW)
{
	BYTE bTemp;
	WORD wRet;
	bTemp = (BYTE)(wSwW & 0xff);
	wRet =  (wSwW >> 8) | ((WORD)bTemp << 8);
	return(wRet);
}


/* DMA Functions */

/*******************************************************************************
* Function Name  : SetDMAburstTxSize
* Description    : Configure the Burst Size for a Tx Endpoint
* Input          : DestBsize: Destination Burst Size
* Output         : None
* Return         : None
*******************************************************************************/
void SetDMABurstTxSize(BYTE DestBsize)
{
  *DMABSIZE &=~0xEF;
  *DMABSIZE = (DestBsize<<4);
}

/*******************************************************************************
* Function Name  : SetDMABurstRxSize
* Description    : Configure the Burst Size for a Rx Endpoint
* Input          : SrcBsize: Source Burst
* Output         : None
* Return         : None
*******************************************************************************/
void SetDMABurstRxSize(BYTE SrcBsize)
{
	*DMABSIZE &=~0x7;
	*DMABSIZE = SrcBsize;
}

/*******************************************************************************
* Function Name  : DMAUnlinkedModeTxConfig
* Description    : Configure a Tx Endpoint to trigger TX Unlinked DMA request
* Note           : Up to three endpoints could be configured to trigger DMA
                   request, an index[0:2] must be associated to an endpoint
* Input          : -bEpNum: endpoint number[0:9]
*                  -index: 0,1 or 2
* Output         : None
* Return         : None
*******************************************************************************/
void DMAUnlinkedModeTxConfig(BYTE bEpNum ,BYTE index)
{
  *DMACR2 &=~(0x0F<<(4*index));
  *DMACR2 |=bEpNum<<(4*index);
}

/*******************************************************************************
* Function Name  : DMAUnlinkedModeTxEnable
* Description    : Enable a Tx endpoint to trigger Tx DMA request
* Input          : -index :0,1 or 2 = index associated to endpoint in function
*                   "DMAUnlinkedModeTxConfig"
* Output         : None
* Return         : None
*******************************************************************************/
void DMAUnlinkedModeTxEnable(BYTE index)
{
	*DMACR3 &=~0x01;  /*DMA Tx linked mode disabled*/
	*DMACR2 &=~0x3000;
	*DMACR2 |=(index+1)<<12;
}
	
/*******************************************************************************
* Function Name  : DMAUnlinkedModeTxDisable
* Description    : Enable a Tx endpoint to trigger Tx DMA request
* Input          : index :0,1 or 2 = index associated to endpoint in function
*                   "DMAUnlinkedModeTxConfig"
* Output         : None
* Return         : None
*******************************************************************************/	
void DMAUnlinkedModeTxDisable(BYTE index)
{
	*DMACR2 &=~0x3000;
}

/*******************************************************************************
* Function Name  : DMAUnlinkedModeRxEnable
* Description    : Enable a Rx Endpoint to trigger Rx DMA
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void DMAUnlinkedModeRxEnable(BYTE bEpNum)
{
	*DMACR3 &=~0x80;   /*DMA Rx linked mode disabled*/
	*DMACR1 |=(0x1<<bEpNum);
}

/*******************************************************************************
* Function Name  : DMAUnlinkedModeRxDisable
* Description    : Disable a Rx Endpoint to trigger Rx DMA
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void DMAUnlinkedModeRxDisable(BYTE bEpNum)
{
	*DMACR1 &=~(0x1<<bEpNum);
}

/*******************************************************************************
* Function Name  : DMALinkedModeRxConfig
* Description    : Configure a Rx endpoint to trigger DMA linked request
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeRxConfig(BYTE bEpNum)
{
	*DMACR3 &=~0x1E00;
	*DMACR3 |=bEpNum<<9;
}

/*******************************************************************************
* Function Name  : DMALinkedModeTxConfig
* Description    : Configure a Tx endpoint to trigger DMA linked request
* Input          : bEpNum: endpoint number[0:9]
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeTxConfig(BYTE bEpNum)
{
	*DMACR3 &=~0x1E;
	*DMACR3 |=bEpNum<<1;
}

/*******************************************************************************
* Function Name  : DMALinkedModeRxEnable
* Description    : Enable the DMA Linked Rx mode
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeRxEnable(void)
{
	*DMACR3 |=0x100;
	*DMACR3 |=0x2000;
}

/*******************************************************************************
* Function Name  : DMALinkedModeTxEnable
* Description    : Enable the DMA Linked Tx mode
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeTxEnable(void)
{
	*DMACR3 |=0x1;
	*DMACR3 |=0x20;
}
/*******************************************************************************
* Function Name  : DMALinkedModeRxDisable
* Description    : Disable the DMA Linked Rx mode
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeRxDisable(void)
{
	*DMACR3 &=~0x100;
	*DMACR3 &=~0x2000;
}

/*******************************************************************************
* Function Name  : DMALinkedModeTxDisable
* Description    : Disable the DMA Linked Tx mode
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMALinkedModeTxDisable(void)
{
	*DMACR3 &=~0x1;
	*DMACR3 &=~0x20;
}
/*******************************************************************************
* Function Name  : USB_DMASynchEnable
* Description    : Enable the Synchronization Logic
* Input          : TRUE or FALSE
* Output         : None
* Return         : None
*******************************************************************************/
void DMASynchEnable(void)
{
	*DMACR3 |=0x40;
}

/*******************************************************************************
* Function Name  : USB_DMASynchDisable
* Description    : Disable the Synchronization Logic
* Input          : TRUE or FALSE
* Output         : None
* Return         : None
*******************************************************************************/
void DMASynchDisable(void)
{
	*DMACR3 &=~0x40;
}

/*******************************************************************************
* Function Name  : SetDMALLITxLength
* Description    : Set the DMA LLI Tx length
* Input          : length
* Output         : None
* Return         : None
*******************************************************************************/
void SetDMALLITxLength(BYTE length)
{
	*DMALLI &=~0xFF;
	*DMALLI |= length;
}

/*******************************************************************************
* Function Name  : SetDMALLIRxLength
* Description    : Set the DMA LLI Rx length
* Input          : length
* Output         : None
* Return         : None
*******************************************************************************/
void SetDMALLIRxLength(BYTE length )
{
		*DMALLI &=~0xFF00;
	  *DMALLI |= length<<8;
}

/*******************************************************************************
* Function Name  : SetDMALLIRxPacketNum
* Description    : Set the LLI_RX_NPACKETS field in register USB_DMABSIZE register
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void SetDMALLIRxPacketNum(BYTE PacketNum)
{
	*DMABSIZE &=0xFF;
	*DMABSIZE |=(PacketNum<<8);
}

/*******************************************************************************
* Function Name  : GetDMALLIPacketNum
* Description    : gets the LLI_RX_NPACKETS field value
* Input          : None
* Output         : None
* Return         : LLI_RX_NPACKETS field value
*******************************************************************************/
BYTE GetDMALLIRxPacketNum(void)
{
	return((BYTE)(*DMABSIZE & 0xFF00)>>8);
}
