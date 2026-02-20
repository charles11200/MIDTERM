import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/saved_address.dart';

class AddressPickerScreen extends StatefulWidget {
  const AddressPickerScreen({super.key, this.initial});

  final SavedAddress? initial;

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final _labelCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();

  late LatLng _pin;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _labelCtrl.text = init?.label ?? "Home";
    _addrCtrl.text = init?.addressLine ?? "";
    _pin = LatLng(init?.lat ?? 15.0489, init?.lng ?? 120.6960);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final label = _labelCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    if (label.isEmpty || addr.isEmpty) return;

    Navigator.pop(
      context,
      SavedAddress(
        label: label,
        addressLine: addr,
        lat: _pin.latitude,
        lng: _pin.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId("pin"),
      position: _pin,
      draggable: true,
      onDragEnd: (p) => setState(() => _pin = p),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Saved Address"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text("Save"),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _labelCtrl,
                    placeholder: "Label (Home / Dorm / Work)",
                    padding: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _addrCtrl,
                    placeholder: "Enter full address",
                    padding: const EdgeInsets.all(12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _pin, zoom: 16),
                markers: {marker},
                onTap: (p) => setState(() => _pin = p),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Tip: Tap the map or drag the pin to set your delivery destination.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}