# ****************************************************************************
# *** makefile XMC4500 based BMS for B48 Battery
# ****************************************************************************
# *** History ***
#
# Date YYMMDD	Owner		Comment
# ----------------------------------------------------------------------------
# 230422	DM6JM           initial version 
# *** History End ***
# ****************************************************************************

# enable SECONDEXPANSION (is used below in rules)
.SECONDEXPANSION:

# User specific settings
OBJ_DIR = obj
PROD_DIR = exe

LINKER_SCRIPT = xmc4500_flash.ld

GNUWINTOOLS = C:/Tools/GnuWin32/bin
RM          = $(GNUWINTOOLS)/rm.exe
MKDIR       = $(GNUWINTOOLS)/mkdir.exe
TOUCH       = $(GNUWINTOOLS)/touch.exe

GCC_PATH = C:/Tools/gcc-arm-none-eabi-8-2019-q3-update-win32/bin
GCC = $(GCC_PATH)/arm-none-eabi-gcc.exe
#GLD = $(GCC_PATH)/arm-none-eabi-ld
OBJDUMP = $(GCC_PATH)/arm-none-eabi-objdump.exe
OBJCOPY = $(GCC_PATH)/arm-none-eabi-objcopy.exe
SIZE = $(GCC_PATH)/arm-none-eabi-size.exe

# Common settings ...
# -pedantic				Issue all the mandatory diagnostics listed in the C standard.
# -Wall					Turns on all optional warnings which are desirable for normal code.
# -Wextra				This enables some extra warning flags that are not enabled by �-Wall�
# -Wundef				Warn if an undefined identifier is evaluated in an �#if� directive.
# -Wsign-conversion    	Warn for implicit conversions that may change the sign of an integer value, like assigning a signed integer expression to an unsigned integer variable.
# -Wfloat-equal			Warn if floating-point values are used in equality comparisons.
# -Wmissing-declarations	Warn if a global function is defined without a previous declaration.
# -Wshadow        		Warn whenever a local variable or type declaration shadows another variable, parameter, type, or class member (in C++)
# -Wswitch-default   	Warn whenever a switch statement does not have a default case.
# -Wswitch-enum       	Warn whenever a switch statement has an index of enumerated type and lacks a case for one or more of the named codes of that enumeration.
# -Wcast-align 			Warn whenever a pointer is cast such that the required alignment of the target is increased.
# -Wmissing-include-dirs	Warn if a user-supplied include directory does not exist.
# -Winit-self    		Warn about uninitialized variables that are initialized with themselves.
# -Wa,-adhlns="$@.lst"	generate Listing file with name (Make Target $@).lst e.g. main.o.lst
# -fmessage-length=0	no line-wrapping will be done; each error message will appear on a single line
# -ffunction-sections	Place each function or data item into its own section in the output file.
#						TODO: this slows down assembler/linker and may produce problems with debugging...
#						Only for targets supporting arbitrary sections.               
# -fdata-sections		Place each function or data item into its own section in the output file if the target supports arbitrary sections.
# -mcpu=cortex-m4  		This specifies the name of the target ARM processor.
# -mtune=cortex-m4		Optimize code for cortex m4
# -mfloat-abi=softfp	allows the generation of code using hardware floating-point instructions, but still uses the soft-float calling conventions
# -mfpu=fpv4-sp-d16 	This specifies what floating-point hardware (or hardware emulation) is available on the target.
# -mthumb 				generating code that executes in Thumb states
# -mno-unaligned-access	Disables reading and writing of 16- and 32- bit values from addresses that are not 16- or 32- bit aligned.
# -g3 					includes extra information, such as all the macro definitions present in the program.
# -gdwarf-2				Produce debugging information in DWARF format version 2

# Real-Time C++ addons...
## -mno-long-calls
## -fno-exceptions
## -O2
## -ffast-math

# # C++ Compiler settings ...
# # -c					Compile or assemble the source files, but do not link.
# # -O0					Reduce compilation time and make debugging produce the expected results. 
# # -std=c++11			The 2011 ISO C++ standard plus amendments. Support for C++11 is still experimental.
# # -fno-rtti         	Disable generation of information about every class with virtual functions
# # -fno-exceptions 
# # -fstrict-enums        Allow the compiler to optimize using the assumption that a value of enumerated type can only be one of the values of the enumeration
# # -fno-use-cxa-atexit   atexit instead of __cxa_atexit
# # -fno-use-cxa-get-exception-ptr	Don�t use the __cxa_get_exception_ptr runtime routine.
# # -fno-nonansi-builtins	Disable built-in declarations of functions that are not mandated by ANSI/ISO C.
# # -fno-threadsafe-statics	Do not emit the extra code to use the routines specified in the C++ ABI for thread-safe initialization of local statics.
# # -fno-enforce-eh-specs	Don�t generate code to check for violation of exception specifications at runtime.
# # -ftemplate-depth=1024	Set the maximum instantiation depth for template classes to 1024.
# # -Wzero-as-null-pointer-constant  	Warn when a literal �0� is used as null pointer constant.
            

# Make used parts of newlib reent smaller
# -D _REENT_SMALL

# C Compiler settings ...
# -c					Compile or assemble the source files, but do not link
# -std=gnu99			Use C99 gnu extensions

# -O0					Reduce compilation time and make debugging produce the expected results. 
# OR IN CASE OF RELEASE
# -Os					Optimize for speed and size. 

ifneq ($(findstring release,$(MAKECMDGOALS)),)
CFLAGS = -c -Os
else
CFLAGS = -c -O0
endif

DEFINES = \
	-DXMC4502_F100x768  \
	-DUSE_KIT_XMC4500_RELAX \
	-D_WINSOCK_H \
	-D_REENT_SMALL \
	-DGPL_LICENSE_TERMS_ACCEPTED

CFLAGS += -std=gnu99 -fno-common -Wall -g3
CFLAGS += -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mtune=cortex-m4
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += $(DEFINES)

ASMFLAGS = $(DEFINES) -c -x assembler-with-cpp -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mtune=cortex-m4

LFLAGS = -T"LinkerScripts/XMC4500x768.ld" -nostartfiles --specs=nano.specs -Xlinker --gc-sections -Wl,-Map,"$(PROD_DIR)/$(PROJECT).map" $(DEFINES)

PPFLAGS = -E -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.d=%.o) $@" $(DEFINES)

RESULT ?= B48XMC

INCL = -I$(GCC_PATH)/../arm-none-eabi/include

INCLUDES = \
	-I./Src \
	-I./Include \
	-I./XMCLib/CMSIS/Include \
	-I./XMCLib/CMSIS/Core/Include \
	-I./XMCLib/CMSIS/Infineon/XMC4500_series/Include \
	-I./XMCLib/XMCLib/inc \
	-I./FreeRTOS-Kernel/include \
	-I./FreeRTOS-Kernel/portable/GCC/ARM_CM4F \
	-I./CycloneCommon \
	-I./CycloneTCP \
	-I./CycloneSSL \
	-I./CycloneCRYPTO

ASM_SOURCES = \
	./XMCLib/CMSIS/Infineon/XMC4500_series/Source/GCC/startup_XMC4500.S

C_SOURCES = \
	./XMCLib/CMSIS/Infineon/XMC4500_series/Source/system_xmc4500.c \
	./Src/syscalls.c \
	./Src/main.c \
	./Src/debug.c \
	./CycloneCommon/cpu_endian.c \
	./CycloneCommon/os_port_freertos.c \
	./CycloneCommon/date_time.c \
	./CycloneCommon/str.c \
	./CycloneTCP/core/net.c \
	./CycloneTCP/core/net_mem.c \
	./CycloneTCP/core/net_misc.c \
	./CycloneTCP/drivers/mac/xmc4500_eth_driver.c \
	./CycloneTCP/drivers/phy/ksz8031_driver.c \
	./CycloneTCP/core/nic.c \
	./CycloneTCP/core/ethernet.c \
	./CycloneTCP/core/ethernet_misc.c \
	./CycloneTCP/ipv4/arp.c \
	./CycloneTCP/ipv4/ipv4.c \
	./CycloneTCP/ipv4/ipv4_frag.c \
	./CycloneTCP/ipv4/ipv4_misc.c \
	./CycloneTCP/ipv4/icmp.c \
	./CycloneTCP/igmp/igmp_host.c \
	./CycloneTCP/igmp/igmp_host_misc.c \
	./CycloneTCP/igmp/igmp_common.c \
	./CycloneTCP/ipv6/ipv6.c \
	./CycloneTCP/ipv6/ipv6_frag.c \
	./CycloneTCP/ipv6/ipv6_misc.c \
	./CycloneTCP/ipv6/ipv6_pmtu.c \
	./CycloneTCP/ipv6/icmpv6.c \
	./CycloneTCP/ipv6/mld.c \
	./CycloneTCP/ipv6/ndp.c \
	./CycloneTCP/ipv6/ndp_cache.c \
	./CycloneTCP/ipv6/ndp_misc.c \
	./CycloneTCP/ipv6/slaac.c \
	./CycloneTCP/ipv6/slaac_misc.c \
	./CycloneTCP/core/ip.c \
	./CycloneTCP/core/tcp.c \
	./CycloneTCP/core/tcp_fsm.c \
	./CycloneTCP/core/tcp_misc.c \
	./CycloneTCP/core/tcp_timer.c \
	./CycloneTCP/core/udp.c \
	./CycloneTCP/core/socket.c \
	./CycloneTCP/core/socket_misc.c \
	./CycloneTCP/core/bsd_socket.c \
	./CycloneTCP/core/bsd_socket_misc.c \
	./CycloneTCP/core/raw_socket.c \
	./CycloneTCP/dns/dns_cache.c \
	./CycloneTCP/dns/dns_client.c \
	./CycloneTCP/dns/dns_common.c \
	./CycloneTCP/dns/dns_debug.c \
	./CycloneTCP/mdns/mdns_client.c \
	./CycloneTCP/mdns/mdns_responder.c \
	./CycloneTCP/mdns/mdns_responder_misc.c \
	./CycloneTCP/mdns/mdns_common.c \
	./CycloneTCP/netbios/nbns_client.c \
	./CycloneTCP/netbios/nbns_responder.c \
	./CycloneTCP/netbios/nbns_common.c \
	./CycloneTCP/llmnr/llmnr_client.c \
	./CycloneTCP/llmnr/llmnr_responder.c \
	./CycloneTCP/llmnr/llmnr_common.c \
	./CycloneTCP/dhcp/dhcp_client.c \
	./CycloneTCP/dhcp/dhcp_client_fsm.c \
	./CycloneTCP/dhcp/dhcp_client_misc.c \
	./CycloneTCP/dhcp/dhcp_common.c \
	./CycloneTCP/dhcp/dhcp_debug.c \
	./CycloneTCP/mqtt/mqtt_client.c \
	./CycloneTCP/mqtt/mqtt_client_misc.c \
	./CycloneTCP/mqtt/mqtt_client_packet.c \
	./CycloneTCP/mqtt/mqtt_client_transport.c \
	./CycloneTCP/web_socket/web_socket.c \
	./CycloneTCP/web_socket/web_socket_auth.c \
	./CycloneTCP/web_socket/web_socket_frame.c \
	./CycloneTCP/web_socket/web_socket_misc.c \
	./CycloneTCP/web_socket/web_socket_transport.c \
	./CycloneSSL/tls.c \
	./CycloneSSL/tls_cipher_suites.c \
	./CycloneSSL/tls_handshake.c \
	./CycloneSSL/tls_client.c \
	./CycloneSSL/tls_client_fsm.c \
	./CycloneSSL/tls_client_extensions.c \
	./CycloneSSL/tls_client_misc.c \
	./CycloneSSL/tls_server.c \
	./CycloneSSL/tls_server_fsm.c \
	./CycloneSSL/tls_server_extensions.c \
	./CycloneSSL/tls_server_misc.c \
	./CycloneSSL/tls_common.c \
	./CycloneSSL/tls_extensions.c \
	./CycloneSSL/tls_certificate.c \
	./CycloneSSL/tls_signature.c \
	./CycloneSSL/tls_key_material.c \
	./CycloneSSL/tls_transcript_hash.c \
	./CycloneSSL/tls_cache.c \
	./CycloneSSL/tls_ticket.c \
	./CycloneSSL/tls_ffdhe.c \
	./CycloneSSL/tls_record.c \
	./CycloneSSL/tls_record_encryption.c \
	./CycloneSSL/tls_record_decryption.c \
	./CycloneSSL/tls_misc.c \
	./CycloneSSL/tls13_client.c \
	./CycloneSSL/tls13_client_extensions.c \
	./CycloneSSL/tls13_client_misc.c \
	./CycloneSSL/tls13_server.c \
	./CycloneSSL/tls13_server_extensions.c \
	./CycloneSSL/tls13_server_misc.c \
	./CycloneSSL/tls13_common.c \
	./CycloneSSL/tls13_signature.c \
	./CycloneSSL/tls13_key_material.c \
	./CycloneSSL/tls13_ticket.c \
	./CycloneSSL/tls13_misc.c \
	./CycloneCRYPTO/hash/md5.c \
	./CycloneCRYPTO/hash/sha1.c \
	./CycloneCRYPTO/hash/sha224.c \
	./CycloneCRYPTO/hash/sha256.c \
	./CycloneCRYPTO/hash/sha384.c \
	./CycloneCRYPTO/hash/sha512.c \
	./CycloneCRYPTO/mac/hmac.c \
	./CycloneCRYPTO/cipher/rc4.c \
	./CycloneCRYPTO/cipher/idea.c \
	./CycloneCRYPTO/cipher/des.c \
	./CycloneCRYPTO/cipher/des3.c \
	./CycloneCRYPTO/cipher/aes.c \
	./CycloneCRYPTO/cipher/camellia.c \
	./CycloneCRYPTO/cipher/seed.c \
	./CycloneCRYPTO/cipher/aria.c \
	./CycloneCRYPTO/cipher_modes/cbc.c \
	./CycloneCRYPTO/aead/ccm.c \
	./CycloneCRYPTO/aead/gcm.c \
	./CycloneCRYPTO/cipher/chacha.c \
	./CycloneCRYPTO/mac/poly1305.c \
	./CycloneCRYPTO/aead/chacha20_poly1305.c \
	./CycloneCRYPTO/pkc/dh.c \
	./CycloneCRYPTO/pkc/rsa.c \
	./CycloneCRYPTO/pkc/dsa.c \
	./CycloneCRYPTO/ecc/ec.c \
	./CycloneCRYPTO/ecc/ec_curves.c \
	./CycloneCRYPTO/ecc/ecdh.c \
	./CycloneCRYPTO/ecc/ecdsa.c \
	./CycloneCRYPTO/ecc/eddsa.c \
	./CycloneCRYPTO/ecc/curve25519.c \
	./CycloneCRYPTO/ecc/curve448.c \
	./CycloneCRYPTO/ecc/x25519.c \
	./CycloneCRYPTO/ecc/x448.c \
	./CycloneCRYPTO/ecc/ed25519.c \
	./CycloneCRYPTO/ecc/ed448.c \
	./CycloneCRYPTO/mpi/mpi.c \
	./CycloneCRYPTO/encoding/base64.c \
	./CycloneCRYPTO/encoding/asn1.c \
	./CycloneCRYPTO/encoding/oid.c \
	./CycloneCRYPTO/pkix/pem_import.c \
	./CycloneCRYPTO/pkix/pem_decrypt.c \
	./CycloneCRYPTO/pkix/pem_common.c \
	./CycloneCRYPTO/pkix/pkcs5_decrypt.c \
	./CycloneCRYPTO/pkix/pkcs5_common.c \
	./CycloneCRYPTO/pkix/pkcs8_key_parse.c \
	./CycloneCRYPTO/pkix/x509_key_parse.c \
	./CycloneCRYPTO/pkix/x509_cert_parse.c \
	./CycloneCRYPTO/pkix/x509_cert_validate.c \
	./CycloneCRYPTO/pkix/x509_crl_parse.c \
	./CycloneCRYPTO/pkix/x509_crl_validate.c \
	./CycloneCRYPTO/pkix/x509_sign_parse.c \
	./CycloneCRYPTO/pkix/x509_sign_verify.c \
	./CycloneCRYPTO/pkix/x509_common.c \
	./CycloneCRYPTO/kdf/hkdf.c \
	./CycloneCRYPTO/kdf/pbkdf.c \
	./CycloneCRYPTO/rng/yarrow.c \
	./FreeRTOS-Kernel/portable/GCC/ARM_CM4F/port.c \
	./FreeRTOS-Kernel/list.c \
	./FreeRTOS-Kernel/queue.c \
	./FreeRTOS-Kernel/tasks.c \
	./FreeRTOS-Kernel/timers.c \
	./FreeRTOS-Kernel/portable/memmang/heap_3.c \
	./XMCLib/XMCLib/src/xmc4_scu.c \
	./XMCLib/XMCLib/src/xmc_dsd.c \
	./XMCLib/XMCLib/src/xmc_gpio.c \
	./XMCLib/XMCLib/src/xmc_rtc.c \
	./XMCLib/XMCLib/src/xmc_acmp.c \
	./XMCLib/XMCLib/src/xmc_ebu.c \
	./XMCLib/XMCLib/src/xmc_hrpwm.c \
	./XMCLib/XMCLib/src/xmc_sdmmc.c \
	./XMCLib/XMCLib/src/xmc_bccu.c \
	./XMCLib/XMCLib/src/xmc_ecat.c \
	./XMCLib/XMCLib/src/xmc_i2c.c \
	./XMCLib/XMCLib/src/xmc_spi.c \
	./XMCLib/XMCLib/src/xmc_can.c \
	./XMCLib/XMCLib/src/xmc_eru.c \
	./XMCLib/XMCLib/src/xmc_i2s.c \
	./XMCLib/XMCLib/src/xmc_uart.c \
	./XMCLib/XMCLib/src/xmc_ccu4.c \
	./XMCLib/XMCLib/src/xmc_eth_mac.c \
	./XMCLib/XMCLib/src/xmc_ledts.c \
	./XMCLib/XMCLib/src/xmc_usbd.c  \
	./XMCLib/XMCLib/src/xmc4_eru.c \
	./XMCLib/XMCLib/src/xmc_ccu8.c \
	./XMCLib/XMCLib/src/xmc_eth_phy_dp83848.c \
	./XMCLib/XMCLib/src/xmc_math.c \
	./XMCLib/XMCLib/src/xmc_usbh.c \
	./XMCLib/XMCLib/src/xmc4_flash.c \
	./XMCLib/XMCLib/src/xmc_common.c \
	./XMCLib/XMCLib/src/xmc_eth_phy_ksz8031rnl.c \
	./XMCLib/XMCLib/src/xmc_pau.c \
	./XMCLib/XMCLib/src/xmc_usic.c \
	./XMCLib/XMCLib/src/xmc4_gpio.c \
	./XMCLib/XMCLib/src/xmc_dac.c \
	./XMCLib/XMCLib/src/xmc_eth_phy_ksz8081rnb.c \
	./XMCLib/XMCLib/src/xmc_posif.c \
	./XMCLib/XMCLib/src/xmc_vadc.c \
	./XMCLib/XMCLib/src/xmc4_rtc.c \
	./XMCLib/XMCLib/src/xmc_dma.c \
	./XMCLib/XMCLib/src/xmc_fce.c \
	./XMCLib/XMCLib/src/xmc_prng.c \
	./XMCLib/XMCLib/src/xmc_wdt.c
	#	./CycloneCRYPTO/hardware/stm32f7xx/stm32f7xx_crypto.c \ ################
	# ./CycloneCRYPTO/hardware/stm32f7xx/stm32f7xx_crypto_trng.c \ #############

HEADERS = \
	./Include/os_port_config.h \
	./Include/net_config.h \
	./Include/tls_config.h \
	./Include/crypto_config.h \
	./Include/FreeRTOSConfig.h \
	./Include/xmc_4500_relax.h \
	./CycloneCommon/cpu_endian.h \
	./CycloneCommon/os_port.h \
	./CycloneCommon/os_port_freertos.h \
	./CycloneCommon/date_time.h \
	./CycloneCommon/str.h \
	./CycloneCommon/error.h \
	./CycloneCommon/debug.h \
	./CycloneTCP/core/net.h \
	./CycloneTCP/core/net_mem.h \
	./CycloneTCP/core/net_misc.h \
	./CycloneTCP/drivers/mac/xmc4500_eth_driver.h \
	./CycloneTCP/drivers/phy/ksz8031_driver.h \
	./CycloneTCP/core/nic.h \
	./CycloneTCP/core/ethernet.h \
	./CycloneTCP/core/ethernet_misc.h \
	./CycloneTCP/ipv4/arp.h \
	./CycloneTCP/ipv4/ipv4.h \
	./CycloneTCP/ipv4/ipv4_frag.h \
	./CycloneTCP/ipv4/ipv4_misc.h \
	./CycloneTCP/ipv4/icmp.h \
	./CycloneTCP/igmp/igmp_host.h \
	./CycloneTCP/igmp/igmp_host_misc.h \
	./CycloneTCP/igmp/igmp_common.h \
	./CycloneTCP/ipv6/ipv6.h \
	./CycloneTCP/ipv6/ipv6_frag.h \
	./CycloneTCP/ipv6/ipv6_misc.h \
	./CycloneTCP/ipv6/ipv6_pmtu.h \
	./CycloneTCP/ipv6/icmpv6.h \
	./CycloneTCP/ipv6/mld.h \
	./CycloneTCP/ipv6/ndp.h \
	./CycloneTCP/ipv6/ndp_cache.h \
	./CycloneTCP/ipv6/ndp_misc.h \
	./CycloneTCP/ipv6/slaac.h \
	./CycloneTCP/ipv6/slaac_misc.h \
	./CycloneTCP/core/ip.h \
	./CycloneTCP/core/tcp.h \
	./CycloneTCP/core/tcp_fsm.h \
	./CycloneTCP/core/tcp_misc.h \
	./CycloneTCP/core/tcp_timer.h \
	./CycloneTCP/core/udp.h \
	./CycloneTCP/core/socket.h \
	./CycloneTCP/core/socket_misc.h \
	./CycloneTCP/core/bsd_socket.h \
	./CycloneTCP/core/bsd_socket_misc.h \
	./CycloneTCP/core/raw_socket.h \
	./CycloneTCP/dns/dns_cache.h \
	./CycloneTCP/dns/dns_client.h \
	./CycloneTCP/dns/dns_common.h \
	./CycloneTCP/dns/dns_debug.h \
	./CycloneTCP/mdns/mdns_client.h \
	./CycloneTCP/mdns/mdns_responder.h \
	./CycloneTCP/mdns/mdns_responder_misc.h \
	./CycloneTCP/mdns/mdns_common.h \
	./CycloneTCP/netbios/nbns_client.h \
	./CycloneTCP/netbios/nbns_responder.h \
	./CycloneTCP/netbios/nbns_common.h \
	./CycloneTCP/llmnr/llmnr_client.h \
	./CycloneTCP/llmnr/llmnr_responder.h \
	./CycloneTCP/llmnr/llmnr_common.h \
	./CycloneTCP/dhcp/dhcp_client.h \
	./CycloneTCP/dhcp/dhcp_client_fsm.h \
	./CycloneTCP/dhcp/dhcp_client_misc.h \
	./CycloneTCP/dhcp/dhcp_common.h \
	./CycloneTCP/dhcp/dhcp_debug.h \
	./CycloneTCP/mqtt/mqtt_client.h \
	./CycloneTCP/mqtt/mqtt_client_misc.h \
	./CycloneTCP/mqtt/mqtt_client_packet.h \
	./CycloneTCP/mqtt/mqtt_client_transport.h \
	./CycloneTCP/mqtt/mqtt_common.h \
	./CycloneTCP/web_socket/web_socket.h \
	./CycloneTCP/web_socket/web_socket_auth.h \
	./CycloneTCP/web_socket/web_socket_frame.h \
	./CycloneTCP/web_socket/web_socket_misc.h \
	./CycloneTCP/web_socket/web_socket_transport.h \
	./CycloneSSL/tls.h \
	./CycloneSSL/tls_cipher_suites.h \
	./CycloneSSL/tls_handshake.h \
	./CycloneSSL/tls_client.h \
	./CycloneSSL/tls_client_fsm.h \
	./CycloneSSL/tls_client_extensions.h \
	./CycloneSSL/tls_client_misc.h \
	./CycloneSSL/tls_server.h \
	./CycloneSSL/tls_server_fsm.h \
	./CycloneSSL/tls_server_extensions.h \
	./CycloneSSL/tls_server_misc.h \
	./CycloneSSL/tls_common.h \
	./CycloneSSL/tls_extensions.h \
	./CycloneSSL/tls_certificate.h \
	./CycloneSSL/tls_signature.h \
	./CycloneSSL/tls_key_material.h \
	./CycloneSSL/tls_transcript_hash.h \
	./CycloneSSL/tls_cache.h \
	./CycloneSSL/tls_ticket.h \
	./CycloneSSL/tls_ffdhe.h \
	./CycloneSSL/tls_record.h \
	./CycloneSSL/tls_record_encryption.h \
	./CycloneSSL/tls_record_decryption.h \
	./CycloneSSL/tls_misc.h \
	./CycloneSSL/tls13_client.h \
	./CycloneSSL/tls13_client_extensions.h \
	./CycloneSSL/tls13_client_misc.h \
	./CycloneSSL/tls13_server.h \
	./CycloneSSL/tls13_server_extensions.h \
	./CycloneSSL/tls13_server_misc.h \
	./CycloneSSL/tls13_common.h \
	./CycloneSSL/tls13_signature.h \
	./CycloneSSL/tls13_key_material.h \
	./CycloneSSL/tls13_ticket.h \
	./CycloneSSL/tls13_misc.h \
	./CycloneCRYPTO/core/crypto.h \
	./CycloneCRYPTO/hash/md5.h \
	./CycloneCRYPTO/hash/sha1.h \
	./CycloneCRYPTO/hash/sha224.h \
	./CycloneCRYPTO/hash/sha256.h \
	./CycloneCRYPTO/hash/sha384.h \
	./CycloneCRYPTO/hash/sha512.h \
	./CycloneCRYPTO/mac/hmac.h \
	./CycloneCRYPTO/cipher/rc4.h \
	./CycloneCRYPTO/cipher/idea.h \
	./CycloneCRYPTO/cipher/des.h \
	./CycloneCRYPTO/cipher/des3.h \
	./CycloneCRYPTO/cipher/aes.h \
	./CycloneCRYPTO/cipher/camellia.h \
	./CycloneCRYPTO/cipher/seed.h \
	./CycloneCRYPTO/cipher/aria.h \
	./CycloneCRYPTO/cipher_modes/cbc.h \
	./CycloneCRYPTO/aead/ccm.h \
	./CycloneCRYPTO/aead/gcm.h \
	./CycloneCRYPTO/cipher/chacha.h \
	./CycloneCRYPTO/mac/poly1305.h \
	./CycloneCRYPTO/aead/chacha20_poly1305.h \
	./CycloneCRYPTO/pkc/dh.h \
	./CycloneCRYPTO/pkc/rsa.h \
	./CycloneCRYPTO/pkc/dsa.h \
	./CycloneCRYPTO/ecc/ec.h \
	./CycloneCRYPTO/ecc/ec_curves.h \
	./CycloneCRYPTO/ecc/ecdh.h \
	./CycloneCRYPTO/ecc/ecdsa.h \
	./CycloneCRYPTO/ecc/eddsa.h \
	./CycloneCRYPTO/ecc/curve25519.h \
	./CycloneCRYPTO/ecc/curve448.h \
	./CycloneCRYPTO/ecc/x25519.h \
	./CycloneCRYPTO/ecc/x448.h \
	./CycloneCRYPTO/ecc/ed25519.h \
	./CycloneCRYPTO/ecc/ed448.h \
	./CycloneCRYPTO/mpi/mpi.h \
	./CycloneCRYPTO/encoding/base64.h \
	./CycloneCRYPTO/encoding/asn1.h \
	./CycloneCRYPTO/encoding/oid.h \
	./CycloneCRYPTO/pkix/pem_import.h \
	./CycloneCRYPTO/pkix/pem_decrypt.h \
	./CycloneCRYPTO/pkix/pem_common.h \
	./CycloneCRYPTO/pkix/pkcs5_decrypt.h \
	./CycloneCRYPTO/pkix/pkcs5_common.h \
	./CycloneCRYPTO/pkix/pkcs8_key_parse.h \
	./CycloneCRYPTO/pkix/x509_key_parse.h \
	./CycloneCRYPTO/pkix/x509_cert_parse.h \
	./CycloneCRYPTO/pkix/x509_cert_validate.h \
	./CycloneCRYPTO/pkix/x509_crl_parse.h \
	./CycloneCRYPTO/pkix/x509_crl_validate.h \
	./CycloneCRYPTO/pkix/x509_sign_parse.h \
	./CycloneCRYPTO/pkix/x509_sign_verify.h \
	./CycloneCRYPTO/pkix/x509_common.h \
	./CycloneCRYPTO/kdf/hkdf.h \
	./CycloneCRYPTO/kdf/pbkdf.h \
	./CycloneCRYPTO/rng/yarrow.h \
	./FreeRTOS-Kernel/portable/gcc/arm_cm4f/portmacro.h \
	./FreeRTOS-Kernel/include/croutine.h \
	./FreeRTOS-Kernel/include/FreeRTOS.h \
	./FreeRTOS-Kernel/include/list.h \
	./FreeRTOS-Kernel/include/mpu_wrappers.h \
	./FreeRTOS-Kernel/include/portable.h \
	./FreeRTOS-Kernel/include/projdefs.h \
	./FreeRTOS-Kernel/include/queue.h \
	./FreeRTOS-Kernel/include/semphr.h \
	./FreeRTOS-Kernel/include/stack_macros.h \
	./FreeRTOS-Kernel/include/task.h \
	./FreeRTOS-Kernel/include/timers.h \
	./include//kit_xmc4500_relax.h \
	./XMCLib/CMSIS/Infineon/XMC4500_series/Include/system_xmc4500.h \
	./XMCLib/CMSIS/Infineon/XMC4500_series/Include/xmc4500.h \
	./XMCLib/XMCLib/inc/xmc1_ccu4_map.h \
	./XMCLib/XMCLib/inc/xmc4_scu.h \
	./XMCLib/XMCLib/inc/xmc_ecat_map.h \
	./XMCLib/XMCLib/inc/xmc_posif_map.h \
	./XMCLib/XMCLib/inc/xmc4_usic_map.h \
	./XMCLib/XMCLib/inc/xmc_eru.h \
	./XMCLib/XMCLib/inc/xmc_prng.h \
	./XMCLib/XMCLib/inc/xmc_acmp.h \
	./XMCLib/XMCLib/inc/xmc_eth_mac.h \
	./XMCLib/XMCLib/inc/xmc_rtc.h \
	./XMCLib/XMCLib/inc/xmc_bccu.h \
	./XMCLib/XMCLib/inc/xmc_eth_mac_map.h \
	./XMCLib/XMCLib/inc/xmc_scu.h \
	./XMCLib/XMCLib/inc/xmc_can.h \
	./XMCLib/XMCLib/inc/xmc_eth_phy.h \
	./XMCLib/XMCLib/inc/xmc_sdmmc.h \
	./XMCLib/XMCLib/inc/xmc1_gpio_map.h \
	./XMCLib/XMCLib/inc/xmc_can_map.h \
	./XMCLib/XMCLib/inc/xmc_fce.h \
	./XMCLib/XMCLib/inc/xmc_spi.h \
	./XMCLib/XMCLib/inc/xmc_ccu4.h \
	./XMCLib/XMCLib/inc/xmc_flash.h \
	./XMCLib/XMCLib/inc/xmc_uart.h \
	./XMCLib/XMCLib/inc/xmc_ccu8.h \
	./XMCLib/XMCLib/inc/xmc_gpio.h \
	./XMCLib/XMCLib/inc/xmc_usbd.h \
	./XMCLib/XMCLib/inc/xmc_common.h \
	./XMCLib/XMCLib/inc/xmc_hrpwm.h \
	./XMCLib/XMCLib/inc/xmc_usbd_regs.h \
	./XMCLib/XMCLib/inc/xmc4_ccu4_map.h \
	./XMCLib/XMCLib/inc/xmc_dac.h \
	./XMCLib/XMCLib/inc/xmc_hrpwm_map.h \
	./XMCLib/XMCLib/inc/xmc_usbh.h \
	./XMCLib/XMCLib/inc/xmc4_ccu8_map.h \
	./XMCLib/XMCLib/inc/xmc_device.h \
	./XMCLib/XMCLib/inc/xmc_i2c.h \
	./XMCLib/XMCLib/inc/xmc_usic.h \
	./XMCLib/XMCLib/inc/xmc4_eru_map.h \
	./XMCLib/XMCLib/inc/xmc_dma.h \
	./XMCLib/XMCLib/inc/xmc_i2s.h \
	./XMCLib/XMCLib/inc/xmc_vadc.h \
	./XMCLib/XMCLib/inc/xmc4_flash.h \
	./XMCLib/XMCLib/inc/xmc_dma_map.h \
	./XMCLib/XMCLib/inc/xmc_ledts.h \
	./XMCLib/XMCLib/inc/xmc_vadc_map.h \
	./XMCLib/XMCLib/inc/xmc4_gpio.h \
	./XMCLib/XMCLib/inc/xmc_dsd.h \
	./XMCLib/XMCLib/inc/xmc_math.h \
	./XMCLib/XMCLib/inc/xmc_wdt.h \
	./XMCLib/XMCLib/inc/xmc4_gpio_map.h \
	./XMCLib/XMCLib/inc/xmc_ebu.h \
	./XMCLib/XMCLib/inc/xmc_pau.h \
	./XMCLib/XMCLib/inc/xmc4_rtc.h \
	./XMCLib/XMCLib/inc/xmc_ecat.h \
	./XMCLib/XMCLib/inc/xmc_posif.h

	
	#./CycloneCRYPTO/hardware/stm32f7xx/stm32f7xx_crypto.h \ ############################
	#./CycloneCRYPTO/hardware/stm32f7xx/stm32f7xx_crypto_trng.h \ ##########################

ASM_OBJECTS = $(patsubst %.S, %.o, $(ASM_SOURCES))
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))

OBJS = $(addprefix $(OBJ_DIR)/, $(ASM_OBJECTS))
OBJS += $(addprefix $(OBJ_DIR)/, $(C_OBJECTS))

# The Prerequesite "$(OBJ_DIR)/.f" checks if the .f-File (empty,hidden) exists in the directory
# of the target. If not the directory (and the .f-File) will be created by the target %/.f:.

$(RESULT).elf: $(OBJS) | $(PROD_DIR)/.f
	$(GCC) $(LFLAGS) -o "$(PROD_DIR)/$(RESULT).elf" $(OBJS)
	 

$(RESULT).hex: $(PROD_DIR)/$(RESULT).elf | $(PROD_DIR)/.f
	$(GCC_PATH)/arm-none-eabi-objcopy -O ihex "$(PROD_DIR)/$(RESULT).elf"  "$(PROD_DIR)/$(RESULT).hex"
	 

$(RESULT).lst: $(PROD_DIR)/$(RESULT).elf | $(PROD_DIR)/.f
	$(GCC_PATH)/arm-none-eabi-objdump -h -S "$(PROD_DIR)/$(RESULT).elf" > "$(PROD_DIR)/$(RESULT).lst"

	 

$(RESULT).siz: $(PROD_DIR)/$(RESULT).elf | $(PROD_DIR)/.f
	$(GCC_PATH)/arm-none-eabi-size --format=sysv  "$(PROD_DIR)/$(RESULT).elf"


# The Prerequesite "$$(@D)/.f" checks if the .f-File (empty,hidden) exists in the directory
# of the target. If not the directory (and the .f-File) will be created by the target %/.f:.

# ###old

# $(OBJ_DIR)/%.o: %.c | $(OBJ_DIR)
# 	@echo *** Target: $@ ...building file: $<
# 	@echo *** ... Invoking: ARM-GCC C Compiler
# 	$(GCC) $(CFLAGS) "$<" -o "$<"
# 	@echo *** Finished building: $<

# $(OBJ_DIR)/%.so : %.S | $(OBJ_DIR)
# 	@echo *** Target: $@ ... building Assembler file: $<
# 	@echo *** ... Invoking: ARM-GCC Assembler
# 	$(GCC) $(CFLAGS) "$<" -o "$@"
# 	@echo *** Finished building: $<

# ###old

# target for .c Files
$(OBJ_DIR)/%.o : %.c | $$(@D)/.f
	$(GCC) $(INCL) $(INCLUDES) $(HEADER) $(CFLAGS) -o "$@" "$<"

# target for .S Files (ATTENTION, GCC treats .s and .S differently, this is for .S!)
$(OBJ_DIR)/%.o : %.S | $$(@D)/.f
	$(GCC) $(INCL) $(INCLUDES) $(HEADER) $(ASMFLAGS) -o "$@" "$<"
	
# target for .f helper files	
%/.f : 
	$(MKDIR) -p $(dir $@)
	$(TOUCH) $@
	attrib $@ +h	

$(OBJ_DIR)/%.d : %.c | $$(@D)/.f
	$(GCC) $(INCL) $(INCLUDES) $(HEADER) $(PPFLAGS) -o $(@:.d=.pp) "$<"

# Include Dependencies ...
DEPENDS= $(OBJS:.o=.d)

# look in MAKECMDGOALS for text "clean", "release" or "all", if no one can't be found include dependencies, else do nothing...
INC_DEPENDS = $(findstring clean,$(MAKECMDGOALS))$(findstring release,$(MAKECMDGOALS))$(findstring all,$(MAKECMDGOALS))

ifeq ($(INC_DEPENDS),)
-include $(DEPENDS)
endif

# Default Target *************************************************************
$(RESULT) : $(RESULT).elf $(RESULT).hex $(RESULT).lst $(RESULT).siz


all: $(RESULT)

release: all

#install: all program
	
print:
	@echo *** OBJECTS: $(OBJS)
	@echo *** 
	@echo *** INCLUDES: $(INCL) $(HEADER)
	@echo ***
	
clean:	
	$(RM) -f -R $(OBJ_DIR)
	$(RM) -f -R $(PROD_DIR)

#flash:
#	openocd -f board/stm32f7discovery.cfg -c "init; reset halt; flash write_image erase $(RESULT).bin 0x08000000; reset run; shutdown"

