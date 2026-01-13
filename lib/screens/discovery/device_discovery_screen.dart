// stateful widget DeviceDiscoveryScreen
//import 'package:android_remote_pro/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:universal_remote/components/bottom_sheet.dart';
import 'package:universal_remote/components/bottomsheet_handle.dart';
import 'package:universal_remote/components/buttons.dart';
import 'package:universal_remote/components/discovered_list_item.dart';
import 'package:universal_remote/components/spacer.dart';
import 'package:universal_remote/components/texts.dart';
import 'package:universal_remote/controllers/fire_tv_controller.dart';
import 'package:universal_remote/controllers/lg_controller.dart';
import 'package:universal_remote/controllers/roku_controller.dart';
import 'package:universal_remote/helpers/routes.dart';
import 'package:universal_remote/models/fire_tv_device.dart';
import 'package:universal_remote/screens/discovery/manual_ip_bottomsheet.dart';
import 'package:universal_remote/services/dialog_service.dart';
import 'package:universal_remote/theme/light.dart';
//import 'package:android_remote_pro/android_remote_pro.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io'; // Needed for InternetAddress
import '../../models/roku_device.dart';
import 'package:udp/udp.dart';
import 'dart:convert';
import 'package:upnp2/upnp.dart' as upnp;
import 'package:upnp2/router.dart' as ur;


class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  //DialogService dialogService = DialogService();

  // NSD discovery variables
  // We now keep a list of active discoveries because we are running multiple scans at once

  UDP? _udpReceiver;
  final List<String> _foundDeviceIds = [];
  final List<nsd.Discovery> _activeDiscoveries = [];
  final List<nsd.Service> _services = [];
  final disc = upnp.DeviceDiscoverer();
  bool _isScanning = false;
  String _selectedPlatform = 'android_tv'; // Default platform
  FireTVController fireTVController = Get.find();
  RokuController rokuController = Get.find();
  DialogService dialogService = DialogService();
  LGController lgController = Get.find();

  static const String _rokuSearchRequest =
      'M-SEARCH * HTTP/1.1\r\n'
      'Host: 239.255.255.250:1900\r\n'
      'Man: "ssdp:discover"\r\n'
      'ST: roku:ecp\r\n'
      '\r\n';

  @override
  void initState() {
    super.initState();

    // Get platform argument from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('platform')) {
      _selectedPlatform = args['platform'] as String;
    }

    _startDiscovery();
  }

  @override
  void dispose() {
    _stopDiscovery();
    super.dispose();
  }

  // Get service types based on selected platform
  List<String> _getServiceTypesForPlatform() {
    switch (_selectedPlatform) {
      case 'android_tv':
        return [
          '_androidtvremote._tcp',
          '_googlecast._tcp',
        ];
      case 'fire_tv':
        return [
          '_amzn-wplay._tcp',
        ];
      case 'roku':
        return [
          '_roku._tcp',
          '_ecp._tcp', // Roku External Control Protocol
        ];
      case 'samsung_tizen':
        return [
          '_samsung-remote._tcp',
          '_smartview._tcp',
        ];
      case 'lg_webos':
        return [
          '_webos._tcp',
          //'_airplay._tcp',
        ];
      default:
        // Fallback to Android TV if unknown platform
        return [
          '_androidtvremote._tcp',
          '_googlecast._tcp',
        ];
    }
  }

  Future<void> _startDiscovery() async {
    // Check and request permissions
    Permission.nearbyWifiDevices.request();
    Permission.appTrackingTransparency.request();


    if (await Permission.location.request().isDenied ||
        await Permission.bluetoothScan.request().isDenied) {
      //dialogService.showErrorMessage(
      //    "Location and Bluetooth permissions are required for device discovery");
      return;
    }

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _services.clear();
    });
    if (_selectedPlatform == 'roku') {
      _startRokuSSDPDiscovery();
      searchForRokuDevices();
      //searchRouters();
      return;
    }

    try {
      // Get platform-specific service types
      final targetServices = _getServiceTypesForPlatform();

      // Loop through every service type and start a listener
      for (final type in targetServices) {
        // print("Starting scan for: $type");

        // We capture the discovery object so we can stop it later
        final discovery = await nsd.startDiscovery(type);
        _activeDiscoveries.add(discovery);

        discovery.addServiceListener((service, status) {
          if (status == nsd.ServiceStatus.found) {
            _addUniqueDevice(service);
          } else if (status == nsd.ServiceStatus.lost) {
            // Optional: You might want to remove them, but in a multi-scan scenario
            // it's often better to keep them unless you are sure, as one protocol might drop
            // while another is still valid.
            setState(() {
              _services.removeWhere((s) => s.name == service.name);
            });
          }
        });
      }
    } catch (e) {
      print("Failed to start discovery: $e");
      // Don't show error dialog immediately as one failure shouldn't stop others
      dialogService.showErrorMessage("Partial discovery failure: $e");

      // If everything failed, stop scanning UI
      if (_activeDiscoveries.isEmpty) {
        setState(() {
          _isScanning = false;
        });
      }
      throw StateError("Failed to start discovery: $e");
    }
  }

  Future<void> searchForRokuDevices() async {
    // 1. Bind to an ephemeral (random) port to receive responses
    // We use Endpoint.any() so we can listen on all interfaces.
    _udpReceiver = await UDP.bind(Endpoint.any(port: Port(65000)));
    print('Listening on local port: ${_udpReceiver?.socket?.port}');

    // 2. Listen for responses BEFORE sending the request
    _udpReceiver?.asStream().listen((Datagram? datagram) {
      if (datagram != null) {
        final response = String.fromCharCodes(datagram.data);
        _parseRokuResponse(response);
      }
    });

    // 3. Define the Multicast Endpoint (Roku standard: 239.255.255.250:1900)
    final multicastEndpoint = Endpoint.multicast(
      InternetAddress("239.255.255.250"),
      port: Port(1900),
    );

    // 4. Send the M-SEARCH packet
    print("Sending M-SEARCH...");
    try {
      await _udpReceiver?.send(
        utf8.encode(_rokuSearchRequest),
        multicastEndpoint,
      );
      print("Sent MSearch");
    } catch (e) {
      print("Error sending multicast: $e");
    }

    // Optional: Send multiple times as UDP is unreliable
    await Future.delayed(Duration(milliseconds: 500));
    await _udpReceiver?.send(
      utf8.encode(_rokuSearchRequest),
      multicastEndpoint,
    );
    print("Resent MSearch");

  }

  void _parseRokuResponse(String response) {
    // Roku Docs: "The response has the following format... Location: ..."
    // We need to parse headers to find the Location URL.

    // 1. Basic check if it's an HTTP 200 OK from a Roku
    if (response.contains("200 OK") && response.contains("roku:ecp")) {

      // 2. Extract Location Header
      final locationMatch = RegExp(r'Location: (.*)', caseSensitive: false).firstMatch(response);
      final usnMatch = RegExp(r'USN: (.*)', caseSensitive: false).firstMatch(response);

      if (locationMatch != null) {
        String location = locationMatch.group(1)!.trim();
        String usn = usnMatch?.group(1)?.trim() ?? location;

        if (!_foundDeviceIds.contains(usn)) {
          _foundDeviceIds.add(usn);
          print("Found Roku: $location");
          // TODO: Add to your UI list here using your existing controller logic
          // e.g. _addUniqueDevice(...)
          var uri = Uri.parse(location);
          _services.add(nsd.Service(
            name: usn,
            host: uri.host,
            port: 8060,
          ));
          setState(() {});

        }
      }
    }
  }

  // --- ROKU SPECIFIC SSDP LOGIC ---
  Future<void> _startRokuSSDPDiscovery() async {
    try {
      print("Starting Roku SSDP Scan...");

      // Roku devices broadcast this specific URN
      // Using 'upnp:rootdevice' also works but catches everything (routers, etc)
      const rokuTarget = 'urn:roku-com:device:player:1-0';
      await disc.start(ipv6: false);
      disc.quickDiscoverClients().listen((client) async {
        try {
          final dev = await client.getDevice();
          _services.add(nsd.Service(
            name: dev?.friendlyName ?? "Unknown Device",
            host: dev?.urlBase,
            port: 8060,
          ));
          dialogService.showSuccessMessage('Found device: ${dev!.friendlyName}: ${dev.url} | ${dev.manufacturer}');
          print('Found device: ${dev!.friendlyName}: ${dev.url}');
          setState(() {});
        } catch (e, stack) {
          print('ERROR: $e - ${client.location}');
          print(stack);
        }
      });


    } catch (e) {
      print("Roku SSDP Failed: $e");

      setState(() {
        _isScanning = false;
      });
      throw StateError('Roku SSDP Failed: $e');
    }
  }

  void searchRouters() async {
    await for (var router in ur.Router.findAll()) {
      final address = await router.getExternalIpAddress();
      print('Router ${Uri.parse(router.device!.url!).host}:');
      print('  External IP Address: $address');
      final totalBytesSent = await router.getTotalBytesSent();
      print('  Total Bytes Sent: $totalBytesSent bytes');
      final totalBytesReceived = await router.getTotalBytesReceived();
      print('  Total Bytes Received: $totalBytesReceived bytes');
      final totalPacketsSent = await router.getTotalPacketsSent();
      print('  Total Packets Sent: $totalPacketsSent bytes');
      final totalPacketsReceived = await router.getTotalPacketsReceived();
      print('  Total Packets Received: $totalPacketsReceived bytes');
    }
  }

  // Helper to avoid duplicates (e.g. if a TV has both AirPlay and GoogleCast)
// Modified helper to accept a manual IP (needed for SSDP adapter)
  void _addUniqueDevice(nsd.Service newService, {String? manualIp}) {
    final alreadyExists = _services.any((existing) {
      // 1. IP Matching
      String? existingIp;
      String? newIp = manualIp;

      if (existing.addresses != null && existing.addresses!.isNotEmpty) {
        existingIp = existing.addresses!.first.address;
      }

      // If we didn't get a manual IP, try to grab from service object
      if (newIp == null &&
          newService.addresses != null &&
          newService.addresses!.isNotEmpty) {
        newIp = newService.addresses!.first.address;
      }

      if (existingIp != null && newIp != null) {
        if (existingIp == newIp) return true;
      }

      // 2. Name Matching
      if (existing.name == newService.name) return true;

      return false;
    });

    if (!alreadyExists) {
      // If we have a manual IP (from SSDP), we need to ensure the service object has it
      // Since 'addresses' is often read-only or final in nsd.Service depending on version,
      // we might need to rely on the UI using the 'host' field if we populated it.

      // However, the original UI uses `service.addresses!.first`.
      // We must mock that for the adapter to work cleanly.
      if (manualIp != null &&
          (newService.addresses == null || newService.addresses!.isEmpty)) {
        // Create a new service object with the address injected if possible
        // Or just rely on the fact that we passed 'host' in the constructor above
        // and update the UI to look at 'host' if addresses is empty.

        // Mocking the address list for the UI:
        try {
          // We can't easily modify the final list of a library class.
          // So we will just add it, but we need to update the UI builder to look at 'host' as fallback.
        } catch (e) {}
      }

      if (mounted) {
        setState(() {
          _services.add(newService);
        });
      }
    }
  }

  Future<void> _stopDiscovery() async {
    // Stop every single active discovery session
    for (final discovery in _activeDiscoveries) {
      await nsd.stopDiscovery(discovery);
    }
    if (_selectedPlatform == "roku") {
      //await server.stop();
      disc.stop();
    }
    _activeDiscoveries.clear();

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Get.back();
                        },
                      ),
                      UIText.bold(text: "Connect Device"),
                      Icon(
                        Icons.help,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Space.ten(),
              Image(
                image: AssetImage("assets/images/wifi.gif"),
                height: 150,
                width: 200,
              ),
              Space.ten(),
              UIText.xxLarge(
                text: _isScanning ? "Scanning for TVs..." : "Scan Complete",
              ),
              Space.ten(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: UIText.medium(
                  text:
                      "Make sure your TV and phone are on the same WiFi network.",
                  alignment: TextAlign.center,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: UiBottomSheet(
                height: Get.height / 2,
                backgroundColor: UIThemeLight.gray700,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Handle()],
                    ),
                    Space.ten(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UIText.largeBold(
                          text: "Discovered Devices",
                          color: Colors.white,
                        ),
                        Badge(
                          label: UIText.mediumBold(
                            text: "${_services.length} found",
                            color: UIThemeLight.primary,
                          ),
                          backgroundColor:
                              UIThemeLight.primary.withOpacity(0.15),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        )
                      ],
                    ),
                    Space.ten(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];

                          // Handle missing IP gracefully
                          String ip = "Resolving...";
                          if (service.addresses != null &&
                              service.addresses!.isNotEmpty) {
                            ip = service.addresses!.first.address ??
                                "Unknown IP";
                          }
                          print(service.toString());

                          return DiscoveredListItem(
                            logo: _getIconForService(service.type),
                            deviceName: service.name ?? "Unknown Device",
                            deviceIp: "$ip:${service.port}",
                            onConnect: () {
                              // Navigate to remote screen with device details
                              if (_selectedPlatform == "fire_tv") {
                                HapticFeedback.lightImpact();
                                fireTVController.connectToDevice(
                                  FireTVDevice(
                                      name: service.name ?? "Unknown Device",
                                      ip: ip,
                                      port: 5555,
                                      //port: service.port ?? 0,
                                      id: ip),
                                );
                              }

                              if (_selectedPlatform == "roku") {
                                HapticFeedback.lightImpact();

                                final rokuDevice = RokuDevice(
                                  name: service.name ?? "Roku Device",
                                  ip: ip,
                                  port: 8060,
                                );

                                // Initiate Handshake
                                rokuController.connectToDevice(rokuDevice);
                              }

                              if (_selectedPlatform == "lg") {
                                HapticFeedback.lightImpact();
                                lgController.connectToDevice(ip).then((_) {
                                  Get.toNamed(Routes.lgRemote);
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Divider(
                      thickness: 0.2,
                    ),
                    Space.vNormal(),
                    GenericButton(
                      label: "Enter IP Address Manually",
                      backgroundColor: UIThemeLight.primary.withOpacity(0.15),
                      onPressed: () async {
                        String? ipAddress = await Get.bottomSheet(
                          ManualIpBottomsheet(),
                          isScrollControlled: true
                        );
                        if(ipAddress != null && ipAddress.isNotEmpty){
                          if(_selectedPlatform == "fire_tv"){
                            HapticFeedback.lightImpact();
                            fireTVController.connectToDevice(
                              FireTVDevice(
                                  name: "Amazon Fire TV",
                                  ip: ipAddress,
                                  port: 5555,
                                  //port: service.port ?? 0,
                                  id: ipAddress),
                            );
                          }
                          if(_selectedPlatform == "roku"){
                            HapticFeedback.lightImpact();
                            print("Connecting Roku");
                            final rokuDevice = RokuDevice(
                              name: "Roku Device",
                              ip: ipAddress,
                              port: 8060,
                            );

                            // Initiate Handshake
                            rokuController.connectToDevice(rokuDevice);
                          }

                          if (_selectedPlatform == "lg") {
                            HapticFeedback.lightImpact();
                            lgController.connectToDevice(ipAddress).then((_) {
                              Get.toNamed(Routes.lgRemote);
                            });
                          }

                        }
                      },
                    )
                  ],
                )),
          )
        ],
      ),
    ));
  }

  // Helper to give different icons based on device type
  Widget _getIconForService(String? type) {
    if (type == null) return Icon(Icons.tv, color: Colors.white, size: 32);

    // You can customize colors here or add more precise icons
    if (type.contains('android') || type.contains('googlecast')) {
      return Icon(Icons.android, color: Colors.greenAccent, size: 32);
    }
    if (type.contains('amzn')) {
      return Icon(Icons.shopping_cart,
          color: Colors.orangeAccent, size: 32); // Fire TV
    }
    if (type.contains('airplay')) {
      return Icon(Icons.apple, color: Colors.white, size: 32);
    }

    return Icon(Icons.tv, color: Colors.white, size: 32);
  }
}
