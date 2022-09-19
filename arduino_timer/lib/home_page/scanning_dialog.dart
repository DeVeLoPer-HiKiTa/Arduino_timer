import 'package:arduino_timer/home_page/available_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../connection_provider.dart';

class ScanningDialog extends StatelessWidget {
  const ScanningDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child:
              BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
            buildWhen: (previous, current) {
              return previous.devices.length != current.devices.length;
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      state.isScanning ? 'Busqueda...' : 'Encontrado',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DevicesList(devices: state.devices),
                  ),
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ),
        )
      ],
    );
  }
}

class DevicesList extends StatelessWidget {
  const DevicesList({Key? key, required this.devices}) : super(key: key);

  final List<BluetoothDevice> devices;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Text('Equipos no encontrado');
    }

    return ListView.builder(
      itemCount: devices.length,
      shrinkWrap: true,
      itemBuilder: itemBuilder,
    );
  }

  Widget itemBuilder(context, index) {
    final device = devices[index];

    return AvailableDevice(
      device: device,
      onConnect: () async {
        onAvailableDeviceSelected(
          context,
          device,
        );
      },
    );
  }

  Future<void> onAvailableDeviceSelected(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    final connectionProvider = context.read<BluetoothConnectionCubit>();
    connectionProvider.connectTo(device).then(
      (value) {
        Navigator.pop(context);
      },
    );
  }
}
