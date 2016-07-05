#include <stdio.h>
#include <libusb-1.0/libusb.h>

int main (int argc, char ** argv) {
  char data[] = { 0x01, 0x05, 0, 0, 0, 0, 0, 0, 0 };
  libusb_init(NULL);
  /* using the default pskeys, devices from the factory are a12:100d in HID mode */
  libusb_device_handle* h = libusb_open_device_with_vid_pid(NULL, 0x0a12, 0x100b);
  if (!h)
    /* Alternatively, a12:100c can be set by the dongler to prevent CSR's software
       stack from auto-switching to HCI mode */
    h = libusb_open_device_with_vid_pid(NULL, 0x0a12, 0x100c);
  if (!h)
    /* TDK corp. uses 04bf:100b for the same dongle sold in the USA.  Detect this case. */
    h = libusb_open_device_with_vid_pid(NULL, 0x04bf, 0x100b);
  if (!h) {
    printf("No device in HID mode found\n");
  } else {
    libusb_detach_kernel_driver(h, 0);
    printf("This should say 0: %d\n", libusb_claim_interface(h, 0));
    libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT|LIBUSB_REQUEST_TYPE_CLASS|LIBUSB_RECIPIENT_INTERFACE, LIBUSB_REQUEST_SET_CONFIGURATION, 0x0301, 0, data, 9, 10000);
    libusb_release_interface(h, 0);
    libusb_close(h);
  }
  libusb_exit(NULL);
  return 0;
}
