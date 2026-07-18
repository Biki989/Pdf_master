import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../providers/pdf_provider.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _performDownload();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _performDownload();
            },
          );
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _handleDownload() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      _performDownload();
    }
  }

  void _performDownload() async {
    final provider = Provider.of<PdfProvider>(context, listen: false);
    if (provider.resultFile == null) return;
    
    try {
      final text = "File available at: ${provider.resultFile!.path}";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download Action Failed")));
    }
  }

  void _shareFile() {
    final provider = Provider.of<PdfProvider>(context, listen: false);
    if (provider.resultFile != null) {
      Share.shareXFiles([XFile(provider.resultFile!.path)], text: 'Check out this file! Processed by PDF Master Tools.');
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfProvider>(context);
    
    if (provider.state == ProcessingState.error) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(provider.errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    provider.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final file = provider.resultFile;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Column(
        children: [
          Expanded(
            child: file != null && file.path.toLowerCase().endsWith('.pdf')
                ? PDFView(
                    filePath: file.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: false,
                  )
                : const Center(child: Text("Preview not available (e.g. zip file)")),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareFile,
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _handleDownload,
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    provider.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Process Another File"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
