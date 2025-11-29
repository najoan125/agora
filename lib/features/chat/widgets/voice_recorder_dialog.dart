import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class VoiceRecorderDialog extends StatefulWidget {
  final Function(String path, int duration) onStop;

  const VoiceRecorderDialog({Key? key, required this.onStop}) : super(key: key);

  @override
  State<VoiceRecorderDialog> createState() => _VoiceRecorderDialogState();
}

class _VoiceRecorderDialogState extends State<VoiceRecorderDialog> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _path;
  Timer? _timer;
  int _recordDuration = 0;
  
  // 음성 세기 측정
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _currentAmplitude = 0.0;
  final List<double> _amplitudeHistory = List.generate(20, (_) => 0.0, growable: true);
  bool _amplitudeWorking = false; // amplitude 기능 작동 여부

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      print('🎤 Checking microphone permission...');
      
      if (await _audioRecorder.hasPermission()) {
        print('✅ Permission granted');
        
        // Get temporary directory path
        String recordPath;
        if (kIsWeb) {
          // For web, use a simple path (the recorder will handle it internally)
          recordPath = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          print('🌐 Web platform - using simple path: $recordPath');
        } else {
          // For mobile, use proper temporary directory
          final directory = await getTemporaryDirectory();
          recordPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          print('📱 Mobile platform - using path: $recordPath');
        }
        
        _path = recordPath;
        print('📁 Recording path: $_path');

        await _audioRecorder.start(const RecordConfig(), path: _path!);
        print('🔴 Recording started');

        if (mounted) {
          setState(() {
            _isRecording = true;
            _recordDuration = 0;
          });

          _startTimer();
          _startAmplitudeListener();
          print('⏱️ Timer started');
        }
      } else {
        print('❌ Permission denied');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error starting recording: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹음 시작 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('⏹️ Stopping recording...');
      _amplitudeSubscription?.cancel();
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      print('⏱️ Timer cancelled');

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      print('📍 Recorded path: $path');
      if (path != null && path.isNotEmpty) {
        if (kIsWeb) {
          // On web, the path might be a blob URL or data URL
          print('✅ Web recording completed, path: $path');
          print('📊 Recording duration: $_recordDuration seconds');
          widget.onStop(path, _recordDuration);
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // On mobile, verify file exists
          try {
            final file = File(path);
            if (await file.exists()) {
              final fileSize = await file.length();
              print('✅ File exists, size: $fileSize bytes');
              print('📊 Recording duration: $_recordDuration seconds');
              widget.onStop(path, _recordDuration);
              if (mounted) {
                Navigator.pop(context);
              }
            } else {
              print('❌ File does not exist at path: $path');
              throw Exception('녹음 파일을 찾을 수 없습니다');
            }
          } catch (e) {
            print('⚠️ File verification failed (might be web): $e');
            // If file verification fails, still try to use the path
            // This might happen on web where File() doesn't work
            widget.onStop(path, _recordDuration);
            if (mounted) {
              Navigator.pop(context);
            }
          }
        }
      } else {
        print('❌ Recording path is null or empty');
        throw Exception('녹음이 제대로 저장되지 않았습니다');
      }
    } catch (e, stackTrace) {
      print('❌ Error stopping recording: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹음 저장 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startAmplitudeListener() {
    print('🎵 Starting amplitude listener...');
    try {
      _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen(
        (amplitude) {
          if (mounted) {
            if (!_amplitudeWorking) {
              print('✅ Amplitude working! First value: ${amplitude.current} dB');
              setState(() {
                _amplitudeWorking = true;
              });
            }
            
            setState(() {
              // amplitude.current는 -160 ~ 0 dB 범위
              // 0.0 ~ 1.0 범위로 정규화
              final normalized = (amplitude.current + 160) / 160;
              _currentAmplitude = normalized.clamp(0.0, 1.0);
              
              // 히스토리 업데이트 (왼쪽으로 시프트)
              _amplitudeHistory.removeAt(0);
              _amplitudeHistory.add(_currentAmplitude);
            });
          }
        },
        onError: (error) {
          print('❌ Amplitude error: $error');
          setState(() {
            _amplitudeWorking = false;
          });
        },
        onDone: () {
          print('✅ Amplitude stream done');
        },
      );
      
      // 3초 후에도 amplitude가 작동하지 않으면 경고
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_amplitudeWorking) {
          print('⚠️ Amplitude not working after 3 seconds - using fallback animation');
        }
      });
    } catch (e) {
      print('❌ Error starting amplitude listener: $e');
      setState(() {
        _amplitudeWorking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 마이크 아이콘 (음성 세기에 따라 크기 변화)
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            child: Icon(
              Icons.mic,
              size: 48 + (_currentAmplitude * 12),
              color: Color.lerp(Colors.red, Colors.red.shade900, _currentAmplitude),
            ),
          ),
          const SizedBox(height: 16),
          // 웨이브폼 시각화
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _amplitudeWorking
                  ? List.generate(20, (index) {
                      final amplitude = _amplitudeHistory[index];
                      return Container(
                        width: 3,
                        height: 10 + (amplitude * 50),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.purple.shade200,
                            Colors.purple.shade600,
                            amplitude,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    })
                  : [
                      // Fallback: 펄스 애니메이션
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '🎤 녹음 중... (음성 세기 측정 불가)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatDuration(_recordDuration),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('녹음 중...'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _audioRecorder.cancel();
            _timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _stopRecording,
          child: const Text('보내기'),
        ),
      ],
    );
  }
}
