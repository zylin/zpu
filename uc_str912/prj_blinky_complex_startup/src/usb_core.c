/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : usb_core.c
* Author             : MCD Application Team
* Date First Issued  : 05/18/2006 : Version 1.0
* Description        : USB protocol state machine functions
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

#define ValBit(VAR,Place)    (VAR & (1<<Place))
#define SetBit(VAR,Place)    ( VAR |= (1<<Place) )
#define ClrBit(VAR,Place)    ( VAR &= ((1<<Place)^255) )

WORD_BYTE StatusInfo;
#define StatusInfo0 StatusInfo.bw.bb1 /* Reverse bb0 & bb1 */
#define StatusInfo1 StatusInfo.bw.bb0
BYTE *Standard_GetStatus(WORD Length);
RESULT Standard_ClearFeature(void);

#define Send0LengthData() { \
  SetEPTxCount(ENDP0, 0); \
  vSetEPTxStatus(EP_TX_VALID);  \
  }

/* cells saving status during interrupt servicing */
WORD SaveRState;
WORD SaveTState;
#define vSetEPRxStatus(st)  (SaveRState = st)
#define vSetEPTxStatus(st)  (SaveTState = st)
#define USB_StatusIn()  Send0LengthData()
#define USB_StatusOut() vSetEPRxStatus(EP_RX_VALID)

/*******************************************************************************
* Function Name  : Standard_GetConfiguration
* Description    : This routine is called to Get the configuration value
* Input          : Length
* Output         : None
* Return         : -Return a pointer on Current_Configuration value if
*                  the "Length" is not 0.
*******************************************************************************/
BYTE *Standard_GetConfiguration(WORD Length)
{
  if (Length == 0)
  return (BYTE *)sizeof(pInformation->Current_Configuration);
  return (BYTE *)&pInformation->Current_Configuration;
} /* Standard_GetConfiguration */

/*******************************************************************************
* Function Name  : Standard_SetConfiguration
* Description    : This routine is called to set the configuration value
* Input          : None
* Output         : None
* Return         : Return USB_SUCCESS, if the request is performed
*                  Return UNSUPPORT, if the request is invalid
*******************************************************************************/
RESULT Standard_SetConfiguration(void)
{
  if (pInformation->USBwValue0 <= Device_Table.Total_Configuration
  && pInformation->USBwValue1==0 && pInformation->USBwIndex==0)
  {
    pInformation->Current_Configuration = pInformation->USBwValue0;
    return USB_SUCCESS;
  }
  else
  return UNSUPPORT;
} /* Standard_SetConfiguration */

/*******************************************************************************
* Function Name  : Standard_GetInterface
* Description    : Return the Alternate Setting of the current interface
* Input          : Length
* Output         : None
* Return         : Return a pointer on Current_AlternateSetting value
*                  if length is not 0
*******************************************************************************/
BYTE *Standard_GetInterface(WORD Length)
{
  if (Length == 0)
  return (BYTE *)sizeof(pInformation->Current_AlternateSetting);
  return (BYTE *)&pInformation->Current_AlternateSetting;
} /* Standard_GetInterface */

/*******************************************************************************
* Function Name  : Standard_SetInterface
* Description    : This routine is called to set the interface alternate settings
* Input          : None
* Output         : None
* Return         : USB_SCCESS or UNSUPPORT
*******************************************************************************/
RESULT Standard_SetInterface(void)
{
  DEVICE_INFO   *pInfo = pInformation;
  DEVICE_PROP   *pProp = pProperty;
  RESULT                  Re;

  /*test if the specified Interface and Alternate Setting
  are supported by the application Firmware*/
  Re = (*pProp->Class_Get_Interface_Setting)(pInfo->USBwIndex0,pInfo->USBwValue0);
  if(pInfo->Current_Configuration==0 )
  return UNSUPPORT;
  else
  {
    if (Re!= USB_SUCCESS || pInfo->USBwIndex1!=0 || pInfo->USBwValue1!=0)
    return  UNSUPPORT;
    else if ( Re == USB_SUCCESS)
    {
      pInfo->Current_Interface = pInfo->USBwIndex0;
      pInfo->Current_AlternateSetting = pInfo->USBwValue0;
      return USB_SUCCESS;
    }
    else return  UNSUPPORT;
  }
} /* Standard_SetInterface */


/*******************************************************************************
* Function Name  : Standard_GetStatus
* Description    : GetStatus request processing (device, interface or endpoint)
* Input          : None
* Output         : None
* Return         : pointer on StatusInfo
*******************************************************************************/

BYTE *Standard_GetStatus(WORD Length)
{
  DEVICE_INFO *pInfo = pInformation;
  if (Length == 0)
  return (BYTE *)2;
  StatusInfo.w = 0;
  /* Reset Status Information */
  if (Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT))
  {
    /*Get Device Status */
    BYTE  Feature = pInfo->Current_Feature;
    if (ValBit(Feature, 5))
    SetBit(StatusInfo0, 1); /* Remote Wakeup enabled */
    if (ValBit(Feature, 7))
    ClrBit(StatusInfo0, 0);  /* Bus-powered */
    else if (ValBit(Feature, 6))
    SetBit(StatusInfo0, 0);  /* Self-powered */
  }
  else if (Type_Recipient == (STANDARD_REQUEST | INTERFACE_RECIPIENT))/*Interface Status*/
  return (BYTE *)&StatusInfo;
  else if (Type_Recipient == (STANDARD_REQUEST | ENDPOINT_RECIPIENT))
  {
    /*Get EndPoint Status*/
    BYTE  Related_Endpoint;
    BYTE  wIndex0 = pInfo->USBwIndex0;
    Related_Endpoint = (wIndex0 & 0x0f);
    if (ValBit(wIndex0, 7))
    {
      /* IN endpoint */
      if (_GetTxStallStatus( Related_Endpoint ))
      SetBit(StatusInfo0, 0); /* IN Endpoint stalled */
    }
    else
    {
      /* OUT endpoint */
      if (_GetRxStallStatus( Related_Endpoint ))
      SetBit(StatusInfo0, 0); /* OUT Endpoint stalled */
    }
  }
  else
  return NULL;
  return (BYTE *)&StatusInfo;
} /* Standard_GetStatus */


/*******************************************************************************
* Function Name  : Standard_ClearFeature
* Description    : Clear (or disable) a specific feature (device or endpoint)
* Input          : None
* Output         : None
* Return         : USB_SUCCESS or UNSUPPORT
*******************************************************************************/
RESULT Standard_ClearFeature(void)
{
  DEVICE_INFO *pInfo = pInformation;
  BYTE  Type_Rec = Type_Recipient;
  WORD    Status;
  if ( Type_Rec == (STANDARD_REQUEST | DEVICE_RECIPIENT) )
  {
     if (pInfo->USBwValue !=  DEVICE_REMOTE_WAKEUP)
     return UNSUPPORT;
    /*Device Clear Feature*/
    ClrBit(pInfo->Current_Feature, 5);
    return USB_SUCCESS;
  }
  else if ( Type_Rec == (STANDARD_REQUEST | ENDPOINT_RECIPIENT) )
  {
    /*EndPoint Clear Feature*/
    DEVICE* pDev;
    BYTE  Related_Endpoint;
    BYTE  wIndex0;
    BYTE  rEP;
    if (pInfo->USBwValue != ENDPOINT_STALL || pInfo->USBwIndex1!=0)
    return UNSUPPORT;
    pDev = &Device_Table;
    wIndex0 = pInfo->USBwIndex0;
    rEP = wIndex0 & ~0x80;
    Related_Endpoint = ENDP0 + rEP;
    if (ValBit(pInfo->USBwIndex0, 7))
    Status =_GetEPTxStatus(Related_Endpoint);
    /*get Status of endpoint & stall the request if the related_ENdpoint is Disabled*/
    else Status =_GetEPRxStatus(Related_Endpoint);
    if (rEP >= pDev->Total_Endpoint || Status==0 || pInfo->Current_Configuration==0)
    return UNSUPPORT;
    if (wIndex0 & 0x80)
    {
      /* IN endpoint */
      if (_GetTxStallStatus(Related_Endpoint ))
      _SetEPTxStatus(Related_Endpoint, EP_TX_NAK);
    }
    else
    {
      /* OUT endpoint */
      if (_GetRxStallStatus(Related_Endpoint))
      {
        if (Related_Endpoint == ENDP0)
        {
          /* After clear the STALL, enable the default endpoint receiver */
          _SetEPRxStatus(Related_Endpoint, EP_RX_VALID);
        }
        else
        _SetEPRxStatus(Related_Endpoint, EP_RX_NAK);
      }
    }
    return USB_SUCCESS;
  }
  return UNSUPPORT;
} /* Standard_ClearFeature */


/*******************************************************************************
* Function Name  : Standard_SetEndPointFeature
* Description    : Sets endpoint feature
* Input          : None
* Output         : None
* Return         : USB_SUCCESS or UNSUPPORT
*******************************************************************************/
RESULT Standard_SetEndPointFeature(void)
{
  DEVICE_INFO *pInfo = pInformation;
  BYTE  wIndex0;
  BYTE    Related_Endpoint;
  BYTE  rEP;
  WORD    Status;
  wIndex0 = pInfo->USBwIndex0;
  rEP = wIndex0 & ~0x80;
  Related_Endpoint = ENDP0 + rEP;
  if (ValBit(pInfo->USBwIndex0, 7))
  Status =_GetEPTxStatus(Related_Endpoint);// get Status of endpoint & stall the request if
  //the related_ENdpoint is Disable
  else Status =_GetEPRxStatus(Related_Endpoint);
  if (Related_Endpoint >= Device_Table.Total_Endpoint || pInfo->USBwValue !=0 || Status==0 ||
  pInfo->Current_Configuration==0 /*&& Related_Endpoint!=ENDP0)*/)
  return UNSUPPORT;
  else
  {
    if (wIndex0 & 0x80)
    {
      /* IN endpoint */
      _SetEPTxStatus(Related_Endpoint, EP_TX_STALL);
    }
    else
    {
      /* OUT endpoint */
      _SetEPRxStatus(Related_Endpoint, EP_RX_STALL);
    }
  }
  return USB_SUCCESS;
} /*Standard_SetEndPointFeature */


/*******************************************************************************
* Function Name  : Standard_SetDeviceFeature
* Description    : Set or enable a specific feature of Device
* Input          : None
* Output         : None
* Return         : USB_SUCCESS
*******************************************************************************/
RESULT Standard_SetDeviceFeature(void)
{
      SetBit(pInformation->Current_Feature, 5);
      return USB_SUCCESS;

} /*Standard_SetDeviceFeature */

/*******************************************************************************
* Function Name  : Standard_GetStringDescriptor
* Description    : GetStringDescriptor
* Input          :
* Output         : None
* Return         : Pointer
*******************************************************************************/

BYTE *Standard_GetStringDescriptor(WORD Length, ONE_DESCRIPTOR *pDesc)
{
  int   len, offset, wOffset;
  wOffset = pInformation->Ctrl_Info.Usb_wOffset;
  if (Length == 0)
  {
    offset = 0;
    do
    {
      len = (int)*(pDesc->Descriptor + offset);
      if (wOffset >= 0 && wOffset < len)
      {
        len -= wOffset;
        if (len > 0)
        return (BYTE*)len;
        break;
      }
      wOffset -= len;
      offset += len;
    }
    while (offset < pDesc->Descriptor_Size);
    return 0;
  }
  return pDesc->Descriptor + wOffset;
}/* Standard_GetStringDescriptor */

/*******************************************************************************
* Function Name  : Standard_GetDescriptorData
* Description    : GetDescriptorData
* Input          :
* Output         : None
* Return         : Return pointer on string descriptor if length is not 0
*                  Return string descriptor length if length is 0
*******************************************************************************/

BYTE *Standard_GetDescriptorData(WORD Length, ONE_DESCRIPTOR *pDesc)
{
  int   len, wOffset;
  wOffset = pInformation->Ctrl_Info.Usb_wOffset;
  if (Length == 0)
  {
    len = pDesc->Descriptor_Size - wOffset;
    if (len <= 0)
    return 0;
    return (BYTE *)len;
  }
  return pDesc->Descriptor + wOffset;
} /* Standard_GetDescriptorData */

/*******************************************************************************
* Function Name  : DataStageOut
* Description    : Data OUT stage of a control transfer
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DataStageOut()
{
  ENDPOINT_INFO *pEPinfo = &pInformation->Ctrl_Info;
  WORD  save_rLength;
  save_rLength = pEPinfo->Usb_rLength;
  if (pEPinfo->CopyData && save_rLength)
  {
    BYTE *Buffer;
    WORD Length;
    WORD wBuffer;
    WORD *Source;
    Length = pEPinfo->PacketSize;
    if (Length > save_rLength)
    Length = save_rLength;
    Buffer = (*pEPinfo->CopyData)(Length);
    pEPinfo->Usb_rLength -= Length;
    pEPinfo->Usb_rOffset += Length;
    Source = (WORD*)(PMAAddr + GetEPRxAddr(ENDP0));
    while (Length)
    {
      wBuffer = *Source;
      Source++;
      *Buffer = wBuffer&0x00FF;
      *(Buffer+1) = ((wBuffer&0xFF00)>>8);
      Buffer++;
      Buffer++;
      Length--;
      if(Length == 0) break; /* odd counter */
      Length--;
    }
  }
  if(pEPinfo->Usb_rLength !=0)
  {
    vSetEPRxStatus(EP_RX_VALID);/* reenable for next data reception */
    SetEPTxCount(ENDP0, 0);
    vSetEPTxStatus(EP_TX_VALID);/* Expect the host to abort the data OUT stage */
  }
  /* Set the next State*/
  if (pEPinfo->Usb_rLength >= pEPinfo->PacketSize)
  pInformation->ControlState = OUT_DATA;
  else
  {
    if (pEPinfo->Usb_rLength >0)
    pInformation->ControlState = LAST_OUT_DATA;
    else if (pEPinfo->Usb_rLength == 0)
    {
      pInformation->ControlState = WAIT_STATUS_IN;
      USB_StatusIn();
    }
  }
} /* DataStageOut */

/*******************************************************************************
* Function Name  : DataStageIn
* Description    : Data IN stage of a Control Transfer
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DataStageIn(void)
{
  ENDPOINT_INFO *pEPinfo = &pInformation->Ctrl_Info;
  WORD  save_wLength = pEPinfo->Usb_wLength;
  BYTE  ControlState;
  BYTE  *DataBuffer;
  WORD  Length;
  DWORD    tmp;
  int i;
  DWORD *pTxBuff;



  if (save_wLength == 0)
  {
    /* no more data to send so STALL the TX Status*/
    ControlState = WAIT_STATUS_OUT;
    vSetEPTxStatus(EP_TX_STALL);
    goto Expect_Status_Out;
  }
  Length = pEPinfo->PacketSize;
  ControlState = (save_wLength < Length) ? LAST_IN_DATA : IN_DATA;

  /* Same as UsbWrite */
  if (Length > save_wLength)
  Length = save_wLength;
  DataBuffer = (*pEPinfo->CopyData)(Length);
  /* transfer data from buffer to PMA */
  pTxBuff = (DWORD *)(PMAAddr + GetEPTxAddr(ENDP0));
  for(i=0;i < Length;)
  {
    tmp = *DataBuffer;
    tmp|=*(DataBuffer+1)<<8;
    tmp|=*(DataBuffer+2)<<16;
    tmp|=*(DataBuffer+3)<<24;
    DataBuffer = DataBuffer+4;
    i=i+4;
    *pTxBuff=tmp;
    pTxBuff++;
  }
  SetEPTxCount(ENDP0, Length);
  pEPinfo->Usb_wLength -= Length;
  pEPinfo->Usb_wOffset += Length;
  vSetEPTxStatus(EP_TX_VALID);
  USB_StatusOut();/* Expect the host to abort the data IN stage */

Expect_Status_Out:  pInformation->ControlState = ControlState;

}/* DataStageIn */

/*******************************************************************************
* Function Name  : NoData_Setup0
* Description    : Proceed the processing of setup request without data stage
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void NoData_Setup0()
{
  DEVICE_INFO *pInfo = pInformation;
  RESULT  Result;
  BYTE  RequestNo = pInformation->USBbRequest;
  BYTE  ControlState;

  /*Standard Device Requests*/
  if (Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT))
  {
    /*SET_CONFIGURATION*/
    if (RequestNo == SET_CONFIGURATION)
    Result = Standard_SetConfiguration();

    /*SET ADDRESS*/
    else if (RequestNo == SET_ADDRESS)
    {
      if(pInfo->USBwValue0 > 127 || pInfo->USBwValue1!=0
      ||pInfo->USBwIndex!=0 || pInfo->Current_Configuration!=0)
      {
        ControlState = STALLED;
        goto exit_NoData_Setup0;
      }
      else Result = USB_SUCCESS;
    }

    /*SET FEATURE*/
    else if (RequestNo == SET_FEATURE)
    {
      if (pInfo->USBwValue0==DEVICE_REMOTE_WAKEUP && pInfo->USBwIndex==0
      && ValBit(pInfo->Current_Feature,5))
      Result = Standard_SetDeviceFeature();
      else
      Result = UNSUPPORT;
    }

    /*Clear FEATURE */
    else if (RequestNo == CLEAR_FEATURE)
    {
      if (pInfo->USBwValue0==DEVICE_REMOTE_WAKEUP && pInfo->USBwIndex==0
      &&ValBit(pInfo->Current_Feature,5))
      Result = Standard_ClearFeature();
      else
      Result = UNSUPPORT;
    }
  }

  /*Standard Interface Requests*/
  else if (Type_Recipient == (STANDARD_REQUEST | INTERFACE_RECIPIENT))
  {
    /*SET INTERFACE*/
    if (RequestNo == SET_INTERFACE)
    Result = Standard_SetInterface();
  }

  /*Standard EndPoint Requests*/
  else if (Type_Recipient == (STANDARD_REQUEST | ENDPOINT_RECIPIENT))
  {
    /*CLEAR FEATURE for EndPoint*/
    if (RequestNo == CLEAR_FEATURE)
    Result = Standard_ClearFeature();

    /*SET FEATURE for EndPoint*/
    else if (RequestNo == SET_FEATURE)
    {
      Result = Standard_SetEndPointFeature();
    }
  }

  else Result = UNSUPPORT;
  if (Result != USB_SUCCESS)
  {
    /*Check and Process possible Class_NoData_Setup Requests*/
    Result = (*pProperty->Class_NoData_Setup)(RequestNo);
    if (Result == NOT_READY)
    {
      ControlState = PAUSE;
      goto exit_NoData_Setup0;
    }
  }
  if (Result != USB_SUCCESS)
  {
    ControlState = STALLED;
    goto exit_NoData_Setup0;
  }
  ControlState = WAIT_STATUS_IN; /* After no data stage SETUP */
  USB_StatusIn();

exit_NoData_Setup0:
  pInfo->ControlState = ControlState;
  return;
} /* NoData_Setup0 */

/*******************************************************************************
* Function Name  : Data_Setup0
* Description    : Processing Setup Requests with data stage
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void Data_Setup0()
{
  DEVICE_INFO   *pInfo = pInformation;
  DEVICE_PROP   *pProp = pProperty;
  BYTE  *(*CopyRoutine)(WORD);
  RESULT  Result;
  BYTE Request_No = pInfo->USBbRequest;
  BYTE *pbLen;
  BYTE Related_Endpoint,Reserved;
  WORD  wOffset,wLen,Status;

  CopyRoutine = NULL;
  wOffset = 0;

  /*GET_DESCRIPTOR*/
  if (Request_No == GET_DESCRIPTOR)
  {
    if (Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT))
    {
      BYTE wValue1 = pInfo->USBwValue1;
      if (wValue1 == DEVICE_DESCRIPTOR)
      CopyRoutine = pProp->GetDeviceDescriptor;
      else if (wValue1 == CONFIG_DESCRIPTOR)
      CopyRoutine = pProp->GetConfigDescriptor;
      else if (wValue1 == STRING_DESCRIPTOR)
      {
        wOffset = pInfo->USBwValue0;
        CopyRoutine = pProp->GetStringDescriptor;
      }
    }
  }

  /*GET STATUS*/
  else if (Request_No == GET_STATUS && pInfo->USBwValue==0
  && pInfo->USBwLength == 0x0002 && pInfo->USBwIndex1==0)
  {
    /* GET STATUS for Device*/
    if (Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT) && pInfo->USBwIndex==0)
    {
      CopyRoutine = Standard_GetStatus;
    }

    /* GET STATUS for Interface*/
    else if (Type_Recipient == (STANDARD_REQUEST | INTERFACE_RECIPIENT))
    {
      if ((*pProp->Class_Get_Interface_Setting)(pInfo->USBwIndex0,0)==USB_SUCCESS
      && pInfo->Current_Configuration!=0)
      CopyRoutine = Standard_GetStatus;
    }

    /* GET STATUS for EndPoint*/
    else if (Type_Recipient == (STANDARD_REQUEST | ENDPOINT_RECIPIENT))
    {
      Related_Endpoint = (pInfo->USBwIndex0 & 0x0f);
      Reserved= pInfo->USBwIndex0 & 0x70;
      if (ValBit(pInfo->USBwIndex0, 7))
      Status =_GetEPTxStatus(Related_Endpoint);
      else Status =_GetEPRxStatus(Related_Endpoint);
      if(Related_Endpoint < Device_Table.Total_Endpoint && Reserved==0 && Status != 0)
      CopyRoutine = Standard_GetStatus;
    }
  }

  /*GET CONFIGURATION*/
  else if (Request_No == GET_CONFIGURATION)
  {
    if ( Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT) )
    CopyRoutine = Standard_GetConfiguration;
  }

  /*GET INTERFACE*/
  else if (Request_No == GET_INTERFACE)
  {
    if (Type_Recipient == (STANDARD_REQUEST | INTERFACE_RECIPIENT)
    && pInfo->Current_Configuration!=0 && pInfo->USBwValue==0
    && pInfo->USBwIndex1==0 && pInfo->USBwLength == 0x0001
    && (*pProperty->Class_Get_Interface_Setting)(pInfo->USBwIndex0,0)==USB_SUCCESS)
    CopyRoutine = Standard_GetInterface;
  }

  if (CopyRoutine)
  {
    pInfo->Ctrl_Info.Usb_wOffset = wOffset;
    pInfo->Ctrl_Info.CopyData = CopyRoutine;
    pbLen = (*CopyRoutine)(0);
    wLen = (WORD)((DWORD)pbLen);
    pInfo->Ctrl_Info.Usb_wLength = wLen;
    Result = USB_SUCCESS;
  }
  else
  {
    /*check and process possible Class_Data_Setup request*/
    Result = (*pProp->Class_Data_Setup)(pInfo->USBbRequest);
    if(Result == NOT_READY)
    {
      pInfo->ControlState = PAUSE;
      return;
    }
  }
  if (pInfo->Ctrl_Info.Usb_wLength == 255)
  {
    /* Data is not ready, wait it */
    pInfo->ControlState = PAUSE;
    return;
  }
  if (Result == UNSUPPORT || pInfo->Ctrl_Info.Usb_wLength == 0)
  {
    /* Unsupported request */
    pInfo->ControlState = STALLED;
    return;
  }
  if (ValBit(pInfo->USBbmRequestType, 7))
  {
    /* Device ==> Host */
    WORD  wLength = pInfo->USBwLength;
    /* Restrict the data length to be the one host asks */
    if (pInfo->Ctrl_Info.Usb_wLength > wLength)
    pInfo->Ctrl_Info.Usb_wLength = wLength;
    pInfo->Ctrl_Info.PacketSize = pProp->MaxPacketSize;
    DataStageIn();
  }
  else
  {
    pInfo->ControlState = OUT_DATA;
    vSetEPRxStatus(EP_RX_VALID);/* enable for next data reception */
  }
  return;
} /* Data_Setup0 */

/*******************************************************************************
* Function Name  : Setup0_Process
* Description    : Setup Token processing (entry point)
* Input          : None
* Output         : None
* Return         : (see Post0_Process)
*******************************************************************************/
BYTE Setup0_Process()
{
  DEVICE_INFO *pInfo = pInformation;
  WORD*    pBuf;

  pBuf= (WORD *)(GetEPRxAddr(ENDP0)+PMAAddr);
  if (pInfo->ControlState != PAUSE)
  {
    pInfo->USBbmRequestType = (*pBuf)&0xFF; /* bmRequestType */
    pInfo->USBbRequest = ((*pBuf)&0xFF00)>>8; /* bRequest */
    pInfo->USBwValue = ByteSwap(*(pBuf+1)); /* wValue */
    pInfo->USBwIndex = ByteSwap(*(pBuf+2)); /* wIndex */
    pInfo->USBwLength = *(pBuf+3);  /* wLength */
  }
  pInfo->ControlState = SETTING_UP;
  if (pInfo->USBwLength == 0)
  {
    /* Setup with no data stage */
    NoData_Setup0();
  }
  else
  {
    /* Setup with data stage */
    Data_Setup0();
  }
  return Post0_Process();
} /* Setup0_Process */

/*******************************************************************************
* Function Name  : In0_Process
* Description    : Process the IN tocken on control endpoint
* Input          : None
* Output         : None
* Return         : (see Post0_Process)
*******************************************************************************/
BYTE In0_Process()
{
  DEVICE_INFO *pInfo = pInformation;
  BYTE  ControlState = pInfo->ControlState;
  if (ControlState == IN_DATA || ControlState == LAST_IN_DATA)
  {
    DataStageIn();
    ControlState = pInfo->ControlState;
  }
  else if (ControlState == WAIT_STATUS_IN)
  {
    if (pInfo->USBbRequest == SET_ADDRESS &&
    Type_Recipient == (STANDARD_REQUEST | DEVICE_RECIPIENT) )
    {
      SetDeviceAddress(pInfo->USBwValue0);
    }
    (*pProperty->Process_Status_IN)();
    ControlState = STALLED;
  }
  else
  ControlState = STALLED;
  pInfo->ControlState = ControlState;
  return Post0_Process();
} /* In0_Process */

/*******************************************************************************
* Function Name  : Out0_Process
* Description    : Process the OUT token on control endpoint
* Input          : None
* Output         : None
* Return         : (see Post0_Process)
*******************************************************************************/
BYTE Out0_Process()
{
  DEVICE_INFO *pInfo = pInformation;
  BYTE  ControlState = pInfo->ControlState;
  if(ControlState == OUT_DATA || ControlState == LAST_OUT_DATA)
  DataStageOut();
  else if (ControlState == WAIT_STATUS_OUT)
  {
    (*pProperty->Process_Status_OUT)();
    ControlState = STALLED;
  }
  else if (ControlState == IN_DATA || ControlState == LAST_IN_DATA)
  {
    /* host aborts the transfer before finish */
    ControlState = STALLED;
  }
  /* Unexpect state, STALL the endpoint */
  else
  {
    ControlState = STALLED;
  }
  pInfo->ControlState = ControlState;
  return Post0_Process();
} /* Out0_Process */

/*******************************************************************************
* Function Name  : Post0_Process
* Description    : Stalls ENDPOINT0 if ControlState = STALLED
* Input          : None
* Output         : None
* Return         : 0: if ControlState is not " PAUSE "
*                  1: if ControlState is "PAUSE"
*******************************************************************************/
BYTE Post0_Process()
{
  _SetEPRxCount(ENDP0, STD_MAXPACKETSIZE);
  if (pInformation->ControlState == STALLED)
  {
    vSetEPRxStatus(EP_RX_STALL);
    vSetEPTxStatus(EP_TX_STALL);
  }
  return (pInformation->ControlState == PAUSE);
} /* Post0_Process */


/*******************************************************************************
* Function Name  : SetDeviceAddress
* Description    : Set Device Address
* Input          : Val: Device Address
* Output         : None
* Return         : None
*******************************************************************************/
void SetDeviceAddress(BYTE Val)
{
	int i;
  DEVICE *pDevice = &Device_Table;
  /*  BYTE	EP0 = pDevice->EP0;	*/
  int	nEP = pDevice->Total_Endpoint;
  /* set address in every used endpoint */
	for(i=0;i<nEP;i++)
	{
		_SetEPAddress((BYTE)i, (BYTE)i);
	} /* for */
	_SetDADDR(Val|DADDR_EF); /* set device address and enable function */
} /* SetDeviceAddress */


/*******************************************************************************
* Function Name  : NOP_Process
* Description    : Do Nothing
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void NOP_Process(void)
{
}

