library record_linux;

import 'dart:async';
import 'package:record_platform_interface/record_platform_interface.dart';

/// Stub implementation of RecordLinux for compatibility with Flutter master channel
/// This is a placeholder that provides minimal implementation to satisfy the interface
class RecordLinux extends RecordPlatform {
  @override
  Future<void> cancel(String recorderId) async {}

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Future<Amplitude> getAmplitude(String recorderId) async {
    return Amplitude(current: -160.0, max: -160.0);
  }

  @override
  Future<bool> hasPermission() async {
    return false; // Linux not supported in this stub
  }

  @override
  Future<bool> isEncoderSupported(
      String recorderId, AudioEncoder encoder) async {
    return false;
  }

  @override
  Future<bool> isPaused(String recorderId) async {
    return false;
  }

  @override
  Future<bool> isRecording(String recorderId) async {
    return false;
  }

  @override
  Future<List<InputDevice>> listInputDevices() async {
    return [];
  }

  @override
  Future<void> pause(String recorderId) async {}

  @override
  Future<void> resume(String recorderId) async {}

  @override
  Future<void> start(
    String recorderId,
    RecordConfig config, {
    required String path,
  }) async {
    throw UnsupportedError(
        'Recording is not supported on Linux with this stub');
  }

  @override
  Stream<RecordState> onStateChanged(String recorderId) {
    return const Stream.empty();
  }

  @override
  Future<String?> stop(String recorderId) async {
    return null;
  }

  @override
  Stream<Uint8List> startStream(String recorderId, RecordConfig config) {
    throw UnsupportedError(
        'Stream recording is not supported on Linux with this stub');
  }
}
