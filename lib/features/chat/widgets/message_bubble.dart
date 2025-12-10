import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme.dart';
import '../../../core/utils/file_download_helper.dart';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/ai_provider.dart';
import '../../../data/services/ai_service.dart';

class MessageBubble extends ConsumerStatefulWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final String? userImage;
  final String? senderName;
  final Uint8List? imageBytes;
  final List<Uint8List>? imageBytesList;
  final String? imageUrl;
  final String? fileName;
  final int? fileSize;
  final String? filePath;
  final Uint8List? fileBytes;
  final List<Map<String, dynamic>>? filesList;
  final String? audioPath;
  final Duration? audioDuration;
  final List<String> reactions;
  final Function(String) onReactionSelected;
  final Function(String)? onDelete;
  final Function(String message, String senderName)? onReply;
  final Function(String)? onForward;
  final Function(String)? onPin;
  final bool enableOptions;
  final String? replyToId;
  final String? replyToSender;
  final String? replyToContent;
  final Function(String)? onReplyTap;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    this.userImage,
    this.senderName,
    this.imageBytes,
    this.imageBytesList,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.fileBytes,
    this.filesList,
    this.audioPath,
    this.audioDuration,
    this.reactions = const [],
    required this.onReactionSelected,
    this.onDelete,
    this.onReply,
    this.onForward,
    this.onPin,
    this.enableOptions = true,
    this.replyToId,
    this.replyToSender,
    this.replyToContent,
    this.onReplyTap,
  }) : super(key: key);

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isTranslated = false;
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (widget.audioPath != null) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath!));
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이모지 반응 바
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildReactionEmoji('👍'),
                      _buildReactionEmoji('❤️'),
                      _buildReactionEmoji('😂'),
                      _buildReactionEmoji('😮'),
                      _buildReactionEmoji('😢'),
                      _buildReactionEmoji('😡'),
                    ],
                  ),
                ),
                // 메뉴 그룹 1 (답장, 전달)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMenuOption(Icons.reply, '답장', () {
                        widget.onReply?.call(widget.message, widget.senderName ?? '상대방');
                      }),
                      const Divider(height: 1, color: Color(0xFFE5E5EA)),
                      _buildMenuOption(Icons.forward, '전달', () {
                        widget.onForward?.call(widget.message);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 메뉴 그룹 2 (복사, 고정, 번역)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMenuOption(Icons.copy, '복사', () {
                        Clipboard.setData(ClipboardData(text: widget.message));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메시지가 복사되었습니다.')),
                        );
                      }),
                      const Divider(height: 1, color: Color(0xFFE5E5EA)),
                      _buildMenuOption(Icons.push_pin, '고정', () {
                        widget.onPin?.call(widget.message);
                      }),
                      const Divider(height: 1, color: Color(0xFFE5E5EA)),
                      _buildMenuOption(Icons.translate, _isTranslated ? '원문 보기' : '번역', () {
                        if (_isTranslated) {
                          setState(() {
                            _isTranslated = false;
                          });
                        } else {
                          // 언어 선택 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('번역할 언어 선택'),
                              children: [
                                '영어',
                                '한국어',
                                '일본어',
                                '중국어',
                                '스페인어',
                                '프랑스어',
                                '독일어'
                              ].map((lang) => SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _translateTo(lang);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 24.0),
                                      child: Text(lang,
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                  ))
                                  .toList(),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
                // 삭제 버튼 (내 메시지인 경우)
                if (widget.isMe && widget.onDelete != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMenuOption(Icons.delete, '삭제', () {
                      _showDeleteConfirmation(context);
                    }, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _translateTo(String targetLang) async {
    // 로딩 표시
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI가 번역 중입니다...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      
      final result = await aiService.translateMessage(
        message: widget.message,
        targetLanguage: targetLang,
      );

      result.when(
        success: (translated) {
          if (mounted) {
            setState(() {
              _translatedText = '[$targetLang 번역] $translated';
              _isTranslated = true;
            });
          }
        },
        failure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('번역 실패: ${error.displayMessage}')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('번역 오류: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call(widget.message);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionEmoji(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.pop(context);
          widget.onReactionSelected(emoji);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, VoidCallback onTap, {Color color = Colors.black87}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(fontSize: 17, color: color, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = _isTranslated && _translatedText != null
        ? _translatedText!
        : widget.message;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상대방 프로필 이미지 (내 메시지가 아닐 때)
          if (!widget.isMe && (widget.userImage != null || widget.senderName != null)) ...[
             Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                image: widget.userImage != null && widget.userImage!.startsWith('http')
                    ? DecorationImage(
                        image: NetworkImage(widget.userImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.userImage == null || !widget.userImage!.startsWith('http')
                  ? Center(child: Text(widget.userImage ?? widget.senderName?[0] ?? '?', style: const TextStyle(fontSize: 16)))
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // 보낸 사람 이름 (내 메시지가 아니고 이름이 있을 때)
              if (!widget.isMe && widget.senderName != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.senderName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 시간 표시 (내 메시지일 때 왼쪽)
                  if (widget.isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],

                  // 메시지 버블 (슬라이드 답장 기능 추가)
                  Dismissible(
                    key: ValueKey('dismiss_${widget.message}_${widget.time}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      widget.onReply?.call(widget.message, widget.senderName ?? '상대방');
                      // 실제 삭제가 일어나지 않도록 false 반환
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.transparent,
                    ),
                    child: GestureDetector(
                      onLongPress: widget.enableOptions ? () => _showMessageOptions(context) : null,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? const Color(0xFF0095F6)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
                            bottomRight: Radius.circular(widget.isMe ? 4 : 20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 답장 메시지 표시 (Explicit fields or parsing)
                            if (widget.replyToId != null && widget.replyToSender != null) ...[
                               GestureDetector(
                                onTap: () {
                                  if (widget.onReplyTap != null && widget.replyToId != null) {
                                    widget.onReplyTap!(widget.replyToId!);
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.replyToSender}에게 답장',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isMe ? Colors.white.withOpacity(0.9) : const Color(0xFF0095F6),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.replyToContent ?? '메시지',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.isMe ? Colors.white.withOpacity(0.7) : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Divider(
                                      height: 1, 
                                      color: widget.isMe ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3)
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ] else if (displayMessage.startsWith('///REPLY///')) ...[
                              Builder(
                                builder: (context) {
                                  // 답장 포맷 파싱: ///REPLY///{name}///{message}///\n{content}
                                  final parts = displayMessage.split('///');
                                  if (parts.length >= 4) {
                                    final replySender = parts[2];
                                    final replyContent = parts[3];
                                    
                                    return GestureDetector(
                                       // Parsing mode doesn't support ID-based jump easily unless ID is embedded. 
                                       // Assuming new system uses explicit fields.
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$replySender에게 답장',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: widget.isMe ? Colors.white.withOpacity(0.9) : const Color(0xFF0095F6),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            replyContent,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: widget.isMe ? Colors.white.withOpacity(0.7) : Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Divider(
                                            height: 1, 
                                            color: widget.isMe ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3)
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                            // 이미지
                            if (widget.imageBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  widget.imageBytes!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (widget.imageUrl != null)
                             Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.imageUrl!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          // 파일
                          if (widget.fileName != null)
                            GestureDetector(
                              onTap: () {
                                if (widget.fileBytes != null || widget.filePath != null) {
                                  FileDownloadHelper.downloadFile(
                                    fileBytes: widget.fileBytes ?? Uint8List(0),
                                    fileName: widget.fileName!,
                                    filePath: widget.filePath,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.insert_drive_file,
                                          color: Colors.blue, size: 24),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.fileName!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (widget.fileSize != null)
                                            Text(
                                              '${(widget.fileSize! / 1024).toStringAsFixed(1)} KB',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // 오디오
                          if (widget.audioPath != null)
                            Container(
                              width: 200,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                                    onPressed: _playPause,
                                    color: Colors.blue,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(
                                          value: _totalDuration.inMilliseconds > 0
                                              ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
                                              : 0.0,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration == Duration.zero && widget.audioDuration != null ? widget.audioDuration! : _totalDuration)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 텍스트 메시지
                          if (displayMessage.isNotEmpty && (widget.audioPath == null || displayMessage != '음성 메모'))
                          if (displayMessage.isNotEmpty && (widget.audioPath == null || displayMessage != '음성 메모'))
                            Builder(
                              builder: (context) {
                                // 파싱된 메시지 (답장 부분 제외)
                                String content = displayMessage;
                                if (content.startsWith('///REPLY///')) {
                                  final parts = content.split('///');
                                  if (parts.length >= 5) { // separator 3 times + newline
                                    // parts[0] is empty, parts[1] is REPLY, parts[2] is name, parts[3] is message, parts[4] starts with \n
                                     // The content is after the third /// and usually \n
                                     final index = content.indexOf('\n');
                                     if(index != -1) {
                                       content = content.substring(index + 1);
                                     }
                                  }
                                } else if (content.startsWith('↳ 답장: "')) {
                                   // Backward compatibility
                                  final RegExp regex = RegExp(r'^↳ 답장: "(.*)"\n(.*)', dotAll: true);
                                  final match = regex.firstMatch(content);
                                  if (match != null) {
                                    content = match.group(2) ?? content;
                                  }
                                }

                                return Text(
                                  content,
                                  style: TextStyle(
                                    color: widget.isMe ? Colors.white : Colors.black,
                                    fontSize: 15,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  // 시간 표시 (상대방 메시지일 때 오른쪽)
                  if (!widget.isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // 반응 표시
              if (widget.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Wrap(
                    spacing: 4,
                    children: widget.reactions.map((emoji) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
