#pragma comment (lib, "Setupapi.lib")

#include <iostream>
#include <windows.h>
#include <intrin.h>
#include "hidapi.h"

#pragma pack(push, 1)
struct LED_SET_REPORT
{
	BYTE report_id;
	USHORT wasd;
	USHORT other;
};
#pragma pack(pop)

LED_SET_REPORT report_data;
hid_device *handle = nullptr;

LRESULT CALLBACK WindowProcedure(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	switch (uMsg) {
		case WM_COMMAND:
			USHORT brightness = static_cast<USHORT>(lParam);
			switch (wParam) {
				case 0:
					report_data.other = brightness;
					break;
				case 1:
					report_data.wasd = brightness;
					break;
			}

			std::cout << "wasd=" << report_data.wasd << " other=" << report_data.other << std::endl;
			hid_send_feature_report(handle, (unsigned char*)&report_data, 5);
			return 0;
	}

	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

int main() {
#ifdef NDEBUG
	// hide the console window (it does flash for a bit but it doesnt bother me)
	FreeConsole();
#endif

	// init report data
	report_data.report_id = 0x07;
	report_data.wasd = 0x2000;
	report_data.other = 0;

	// init hidapi
	if (hid_init()) {
		std::cout << "failed to initialize hidapi" << std::endl;
		return 1;
	}

	// find and use first device that allows us to send feature 0x07
	struct hid_device_info *devs = hid_enumerate(0x046d, 0xc24d);
	struct hid_device_info *cur_dev = devs;
	while (cur_dev) {
		std::cout << "trying to open: " << cur_dev->path << std::endl;

		handle = hid_open_path(cur_dev->path);
		if (handle) {
			int res = hid_send_feature_report(handle, (unsigned char*)&report_data, 5);
			if (res > 0)
				break;

			std::cout << "failed sending data" << std::endl;
			hid_close(handle);
		}

		cur_dev = cur_dev->next;
	}
	hid_free_enumeration(devs);

	if (!handle) {
		std::cout << "Failed to find suitable device" << std::endl;
		return 1;
	}

	// create a message only window
	WNDCLASS windowClass = {};
	windowClass.lpfnWndProc = WindowProcedure;
	windowClass.lpszClassName = L"KeyboardBacklightThing";
	if (!RegisterClass(&windowClass)) {
		std::cout << "Failed to register window class" << std::endl;
		return 1;
	}

	HWND messageWindow = CreateWindow(windowClass.lpszClassName, windowClass.lpszClassName, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, 0, 0);
	if (!messageWindow) {
		std::cout << "Failed to create message-only window" << std::endl;
		return 1;
	}

	MSG msg;
	while (GetMessage(&msg, 0, 0, 0) > 0) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return msg.wParam;
}