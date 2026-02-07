import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

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

  // Must match your training input size (common: 224 for MobileNet)
  static const int _inputSize = 224;

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

      final xfile = await _picker.pickImage(source: source, imageQuality: 90);

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

    // Load and preprocess image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Convert to normalized float array
    final input = Float32List(_inputSize * _inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        double norm(int v) => (v / 127.5) - 1.0;

        input[pixelIndex++] = norm(img.getRed(pixel));
        input[pixelIndex++] = norm(img.getGreen(pixel));
        input[pixelIndex++] = norm(img.getBlue(pixel));
      }
    }

    final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

    // Create output tensor
    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final numClasses = outputShape[1];

    final output = Float32List(numClasses).reshape([1, numClasses]);

    interpreter.run(inputTensor, output);
    final raw = output[0] as List<double>;
    final probs = softmax(raw);

    for (int i = 0; i < probs.length; i++) {
      debugPrint('${_labels[i]}: ${(probs[i] * 100).toStringAsFixed(2)}%');
    }


    // Find best label
    // final probs = output[0];
    int bestIdx = 0;
    double bestProb = probs[0];

    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestProb) {
        bestProb = probs[i];
        bestIdx = i;
      }
    }

    final label = (bestIdx < _labels.length) ? _labels[bestIdx] : "unknown";
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
    // Adjust any time — this is your app’s rules.
    switch (label) {
      case 'biological':
        return WasteBin.biodegradable;

      case 'cardboard':
      case 'paper':
      case 'plastic':
      case 'metal':
      case 'brown-glass':
      case 'green-glass':
      case 'white-glass':
        return WasteBin.recyclable;

      case 'clothes':
      case 'shoes':
        return WasteBin.reusable;

      case 'battery':
      case 'trash':
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
}
