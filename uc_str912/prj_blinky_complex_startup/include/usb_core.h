/******************** (C) COPYRIGHT 2006 STMicroelectronics ********************
* File Name          : usb_core.h
* Author             : MCD Application Team
* Date First Issued  : 05/18/2006 : Version 1.0
* Description        : USB state machine structures and functions prototypes
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
#define Type_Recipient	(pInfo->USBbmRequestType & (REQUEST_TYPE | RECIPIENT))

#define STD_MAXPACKETSIZE		 0x40  /* 64 bytes*/
 
typedef enum _CONTROL_STATE {
	WAIT_SETUP,  	
	SETTING_UP,  	
	IN_DATA,	 	
	OUT_DATA,	
	LAST_IN_DATA,	
	LAST_OUT_DATA,	
	WAIT_STATUS_IN,	
	WAIT_STATUS_OUT,
	STALLED,		
	PAUSE		
} CONTROL_STATE;		/* The state machine states of a control pipe */


typedef struct OneDescriptor {
	BYTE *Descriptor;
	WORD Descriptor_Size;
} ONE_DESCRIPTOR, *PONE_DESCRIPTOR;


typedef enum _RESULT {
	USB_SUCCESS = 0,			/* Process sucessfully */
	USB_ERROR,
	UNSUPPORT,
	NOT_READY				      /* The process has not been finished,	*/
							          /* endpoint will be NAK to further rquest	*/
} RESULT;


/*-*-*-*-*-*-*-*-*-*-* Definitions for endpoint level -*-*-*-*-*-*-*-*-*-*-*-*/

typedef struct _ENDPOINT_INFO {
	WORD		Usb_wLength;
	WORD		Usb_wOffset;
	WORD		PacketSize;
	BYTE 		*(*CopyData)(WORD Length);
} ENDPOINT_INFO;

#define Usb_rLength Usb_wLength
#define Usb_rOffset Usb_wOffset


/*-*-*-*-*-*-*-*-*-*-*-* Definitions for device level -*-*-*-*-*-*-*-*-*-*-*-*/

typedef struct _DEVICE {
	BYTE Total_Endpoint;	 /* Number of endpoints that are used */
	BYTE Total_Configuration;/* Number of configuration available */
} DEVICE;

typedef union {
	WORD	w;
	struct BW {
		BYTE	bb1;
		BYTE	bb0;
	} bw;
} WORD_BYTE;

typedef struct _DEVICE_INFO {
	BYTE		USBbmRequestType;		/* bmRequestType */
	BYTE		USBbRequest;			  /* bRequest */
	WORD_BYTE	USBwValues;				/* wValue */
	WORD_BYTE	USBwIndexs;				/* wIndex */
	WORD_BYTE	USBwLengths;			/* wLength */

	BYTE		ControlState;			       /* of type CONTROL_STATE */
	BYTE		Current_Feature;         /*selected features*/

	BYTE		Current_Configuration;   /* Selected configuration */
	BYTE		Current_Interface;       /* Selected interface of current configuration */
	BYTE		Current_AlternateSetting;/* Selected Alternate Setting of current interface*/				
	ENDPOINT_INFO	Ctrl_Info;
} DEVICE_INFO;

typedef struct _DEVICE_PROP {
	void	(*Init)(void);				
	void	(*Reset)(void);				
	void	(*Process_Status_IN)(void);
	void	(*Process_Status_OUT)(void);
	RESULT	(*Class_Data_Setup)(BYTE RequestNo);
	RESULT	(*Class_NoData_Setup)(BYTE RequestNo);
	RESULT  (*Class_Get_Interface_Setting)(BYTE Interface,BYTE AlternateSetting);
	BYTE*	(*GetDeviceDescriptor)(WORD Length);
	BYTE*	(*GetConfigDescriptor)(WORD Length);
	BYTE*	(*GetStringDescriptor)(WORD Length);
	BYTE*	RxEP_buffer;
	WORD	MaxPacketSize;
} DEVICE_PROP;

extern	DEVICE_PROP Device_Property;
extern  DEVICE  Device_Table;
extern	DEVICE_INFO	Device_Info;

/* cells saving status during interrupt servicing */
extern WORD SaveRState;
extern WORD SaveTState;

#define	USBwValue	USBwValues.w
#define	USBwValue0	USBwValues.bw.bb0
#define	USBwValue1	USBwValues.bw.bb1
#define	USBwIndex	USBwIndexs.w
#define	USBwIndex0	USBwIndexs.bw.bb0
#define	USBwIndex1	USBwIndexs.bw.bb1
#define	USBwLength	USBwLengths.w
#define	USBwLength0	USBwLengths.bw.bb0
#define	USBwLength1	USBwLengths.bw.bb1

BYTE Setup0_Process(void);
BYTE Post0_Process(void);
BYTE Out0_Process(void);
BYTE In0_Process(void);

RESULT Standard_SetEndPointFeature(void);
RESULT Standard_SetDeviceFeature(void);

BYTE *Standard_GetConfiguration(WORD Length);
RESULT Standard_SetConfiguration(void);
BYTE *Standard_GetInterface(WORD Length);
RESULT Standard_SetInterface(void);
BYTE *Standard_GetDescriptorData(WORD Length, PONE_DESCRIPTOR pDesc);
BYTE *Standard_GetStringDescriptor(WORD Length, PONE_DESCRIPTOR pDesc);

void SetDeviceAddress(BYTE);
void NOP_Process(void);

