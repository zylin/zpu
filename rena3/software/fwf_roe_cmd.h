#ifndef FWF_ROE_CMD_H
#define FWF_ROE_CMD_H
//==================================================================================
// P.Kaever B.Lange
// Kommandos des Kommandointerpreters in der Read Out Elektronik ROE
//  1.0    	12-2011  Basisimplementierung erste Schnittstelle
//
// ToDo
//==================================================================================

//==================================================================================
#define FWF_ROE_CMD_TEST_COM    0				// Testkommando zur Prüfung der Kommunikation

#define FWF_ROE_CMD_HELP		"h"				// Anzeige der Hilfe
#define FWF_ROE_CMD_GET_ID      "GET_ID"  		// Abfrage der ID der ROE

#define FWF_ROE_CMD_GET_PORT    "GET_PORT"     	// Abfrage der TCP/UDP Kommunikations-Port#
#define FWF_ROE_PORT			2036

#define FWF_ROE_CMD_SET_PORT 	"SET PORT"	 	// Setzen der TCP/UDP Kommunikations-Port#

#define FWF_ROE_ZPU_SW_VERSION "V1.0-12.2011_ROE_ZPU"
#define FWF_ROE_CMD_VERSION     "version"	    // Abfrage Versionsinformation

#define FWF_ROE_CMD_CONTROL     "control"
/*
description:    rena controller status
parameter:      none
result:         string (idle, configure, detect, aquire, analyze, desire, readout, UNKNOWN)
*/

#define FWF_ROE_CMD_STATUS     "status"
/*
description:    rena status
parameter:      none
result:
<pre>
fast trigger : 0
slow trigger : 0
overflow     : 0
</pre>
*/

#define FWF_ROE_CMD_CONFIG       "config"
/*
description:    channel configuration
parameter:      <channel> <high_config> <low_config>
                channel     --> channel number
                high_config --> config bits 34..32
                low_config  --> config bits 31..0
result:         none
*/


#define FWF_ROE_CMD_DEMO        "demo"
/*
description:    do complete demo config for RENA
parameter:      none
result:         none
*/

#define FWF_ROE_CMD_ACQUIRE       "acquire"
/*
description:    activate RENA
parameter:      time (optional) additional acquire time after first trigger in 10 ns steps
result:         none
*/

#define FWF_ROE_CMD_STOP      "stop"
/*
description:    set RENA controller to IDLE
parameter:      none
result:         none
*/

#define FWF_ROE_CMD_CHAINS        "chains"
/*
description:    print trigger chains
parameter:      none
result:
<pre>
fast trigger chain: 0x0000000000000000
slow trigger chain: 0x0000000000000000
</pre>
*/

#define FWF_ROE_CMD_TOKEN        "token"
/*
description:    print sampled RENA tokens
parameter:      none
result:
<pre>
tokens: 0
</pre>
*/

#define FWF_ROE_CMD_DDSINIT        "ddsinit"
/*
description:    initalize DDS chip
parameter:      frequency tuning word (optional)
result:         none
*/

#endif

