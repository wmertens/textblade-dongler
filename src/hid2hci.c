#include <stdio.h>
#include <libusb-1.0/libusb.h>

int main (int argc, char ** argv) {
  char data[] = { 0x01, 0x05, 0, 0, 0, 0, 0, 0, 0 };
  libusb_init(NULL);
  libusb_device_handle* h = libusb_open_device_with_vid_pid(NULL, 0x0a12, 0x100b);
  if (!h) {
    printf("No device in HID mode found\n");
  } else {
    libusb_detach_kernel_driver(h, 0);
    printf("%d\n", libusb_claim_interface(h, 0));
    libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT|LIBUSB_REQUEST_TYPE_CLASS|LIBUSB_RECIPIENT_INTERFACE, LIBUSB_REQUEST_GET_CONFIGURATION, 0x0301, 0, data, 9, 10000);
    libusb_release_interface(h, 0);
    libusb_close(h);
  }
  libusb_exit(NULL);
  return 0;
}
