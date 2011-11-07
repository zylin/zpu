/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : usb_mem.c
* Author             : MCD Application Team
* Date First Issued  : 05/18/2006 : Version 1.0
* Description        : utility functions for memory transfers
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

#include "usb_lib.h"
#include "usb_mem.h"

/*******************************************************************************
* Function Name : UserToPMABufferCopy
* Description   : Copy a buffer from user memory to packet memory area
* Input         : - pbUsrBuf = pointer to user memory area
*                 - wPMABufAddr = address into PMA
*                 - wNBytes = number of bytes to be copied
* Output        : None
* Return value  : None
*******************************************************************************/
void UserToPMABufferCopy(BYTE *pbUsrBuf,WORD wPMABufAddr, WORD wNBytes)
{
	DWORD *pdwVal;
	
	DWORD wTra, i;
 	union
 	{
 		BYTE *bTra;
 		DWORD *wTra;
	}pBuf;
	int wNTrasf=wNBytes;
	
	pdwVal= (DWORD *)(PMAAddr+(DWORD)((wPMABufAddr)));
	pBuf.wTra = &wTra;
	for(i=0;i < wNTrasf;)
	{
		*(pBuf.bTra  ) = *pbUsrBuf++;
		i++;
    *(pBuf.bTra+1) = *pbUsrBuf++;
    i++;
		*(pBuf.bTra+2) = *pbUsrBuf++;
    i++;
	  *(pBuf.bTra+3) = *pbUsrBuf++;
    i++;
    *pdwVal = wTra;
    pdwVal++;
  }
} /* UserToPMABufferCopy */

/*******************************************************************************
* Function Name : PMAToUserBufferCopy
* Description   : Copy a buffer from packet memory area to user memory
* Input         : - pbUsrBuf = pointer to user memory area
*                 - wPMABufAddr = address into PMA
*                 - wNBytes = number of bytes to be copied
* Output        : None
* Return value  : None
*******************************************************************************/
void PMAToUserBufferCopy(BYTE *pbUsrBuf,WORD wPMABufAddr, WORD wNBytes)
{
	BYTE *pbVal;
	WORD wNTrasf=wNBytes;
	if((wNBytes) == 0) return;
	pbVal = (BYTE *)(PMAAddr + wPMABufAddr);
	while(1)
	{
		*pbUsrBuf++ = *pbVal++;
		if((--wNTrasf) == 0) return;
		*pbUsrBuf++ = *pbVal++;
		if((--wNTrasf) == 0) return;
	}/* while */
} /* PMAToUserBufferCopy */



