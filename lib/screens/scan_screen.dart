import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

Future<Float32List> preprocessImage(Map<String, dynamic> params) async {
  final Uint8List bytes = params['bytes'];
  final int inputSize = params['inputSize'];

  final image = img.decodeImage(bytes)!;

  final resizedImage = img.copyResize(
    image,
    width: inputSize,
    height: inputSize,
  );

  final input = Float32List(inputSize * inputSize * 3);
  int pixelIndex = 0;

  for (int y = 0; y < inputSize; y++) {
    for (int x = 0; x < inputSize; x++) {
      final pixel = resizedImage.getPixel(x, y);

      input[pixelIndex++] = img.getRed(pixel) / 255.0;
      input[pixelIndex++] = img.getGreen(pixel) / 255.0;
      input[pixelIndex++] = img.getBlue(pixel) / 255.0;
    }
  }

  return input;
}

enum WasteBin { biodegradable, recyclable, nonRecyclable, reusable }

class WasteResult {
  final String label;
  final double confidence;
  final WasteBin bin;
  final String message;

  WasteResult({
    required this.label,
    required this.confidence,
    required this.bin,
    required this.message,
  });
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _modelPath = 'assets/models/garbage_classification_model.tflite';
  static const _labelsPath = 'assets/models/labels.txt';

  final ImagePicker _picker = ImagePicker();

  Interpreter? _interpreter;
  List<String> _labels = [];

  File? _imageFile;
  bool _loading = false;
  WasteResult? _result;
  String? _error;

  // Must match your training input size (common: 229 for MobileNet)
  static const int _inputSize = 299;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _initModel() async {
    try {
      // Load labels
      final labelsStr = await rootBundle.loadString(_labelsPath);
      _labels = labelsStr
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Load interpreter
      final options = InterpreterOptions()
        ..threads = 2; // keep stable on Windows/Android
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

      setState(() {});
    } catch (e) {
      setState(() {
        _error = "Failed to load model: $e";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
        _result = null;
      });

      final xfile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (xfile == null) {
        setState(() => _loading = false);
        return;
      }

      final file = File(xfile.path);
      setState(() => _imageFile = file);

      final res = await _runInference(file);
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _loading = false;
      });
    }
  }

  Future<WasteResult> _runInference(File imageFile) async {
  final interpreter = _interpreter;
  if (interpreter == null) {
    throw Exception("Interpreter not loaded yet.");
  }
  if (_labels.isEmpty) {
    throw Exception("Labels not loaded.");
  }

  final bytes = await imageFile.readAsBytes();

  /// 🧠 Run heavy preprocessing in background isolate
  final input = await compute(preprocessImage, {
    'bytes': bytes,
    'inputSize': _inputSize,
  });

  final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

  final output = List.filled(4, 0.0).reshape([1, 4]);

  /// ⚡ Fast TFLite inference (safe on main thread)
  interpreter.run(inputTensor, output);

  final probs = List<double>.from(output[0]);

  /// 🔍 Get best class
  int bestIdx = 0;
  double bestProb = probs[0];

  for (int i = 1; i < probs.length; i++) {
    if (probs[i] > bestProb) {
      bestProb = probs[i];
      bestIdx = i;
    }
  }

  final label = (bestIdx < _labels.length) ? _labels[bestIdx] : "unknown";

  /// 🎯 Confidence threshold
  if (bestProb < 0.60) {
    return WasteResult(
      label: "unknown",
      confidence: bestProb,
      bin: WasteBin.nonRecyclable,
      message: "Hmm… I’m not sure. Try another picture 😊",
    );
  }

  final bin = _mapLabelToBin(label);
  final msg = _buildKidMessage(label, bin);

  return WasteResult(
    label: label,
    confidence: bestProb,
    bin: bin,
    message: msg,
  );
}

  List<double> softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((x) => x / sum).toList();
  }

  WasteBin _mapLabelToBin(String label) {
    switch (label) {
      case 'biodegradable':
        return WasteBin.biodegradable;
      case 'recyclable':
        return WasteBin.recyclable;
      case 'reusable':
        return WasteBin.reusable;
      case 'non-recyclable':
      default:
        return WasteBin.nonRecyclable;
    }
  }

  String _binName(WasteBin bin) {
    switch (bin) {
      case WasteBin.biodegradable:
        return "Biodegradable";
      case WasteBin.recyclable:
        return "Recyclable";
      case WasteBin.nonRecyclable:
        return "Non-recyclable";
      case WasteBin.reusable:
        return "Reusable";
    }
  }

  String _buildKidMessage(String label, WasteBin bin) {
    // Friendly “kid” phrasing
    final niceName = label.replaceAll('-', ' ');
    return "I think this is $niceName.\nPut it in the ${_binName(bin)} bin!";
  }

  @override
  Widget build(BuildContext context) {
    // no AppBar (as you prefer)
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _error != null
              ? Center(
                  child: Text(_error!, style: const TextStyle(fontSize: 16)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Scan Waste",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // image preview
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _imageFile == null
                              ? const Center(
                                  child: Text("Pick an image to classify"),
                                )
                              : Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_loading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                    ],

                    if (_result != null) ...[
                      Text(
                        _result!.message,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _buildBinResult(_result!.bin),
                      const SizedBox(height: 6),
                      Text(
                        "Confidence: ${(100 * _result!.confidence).toStringAsFixed(1)}%",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () => _pickImage(ImageSource.camera),
                            child: const Text("Camera"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                            child: const Text("Gallery"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBinResult(WasteBin bin) {
    Color color;
    IconData icon;
    String name = _binName(bin);

    switch (bin) {
      case WasteBin.biodegradable:
        color = Colors.green;
        icon = Icons.eco;
        break;
      case WasteBin.recyclable:
        color = Colors.blue;
        icon = Icons.recycling;
        break;
      case WasteBin.reusable:
        color = Colors.orange;
        icon = Icons.autorenew;
        break;
      case WasteBin.nonRecyclable:
      default:
        color = Colors.red;
        icon = Icons.delete;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

