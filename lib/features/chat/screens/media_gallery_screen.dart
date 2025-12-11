import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../models/chat_message.dart';

// Helper class to represent individual images with metadata
class _ImageItem {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final DateTime time;
  final int imageIndex; // Index within the message's imageBytesList
  
  _ImageItem({
    this.imageBytes,
    this.imageUrl,
    required this.time,
    this.imageIndex = 0,
  });
}

class MediaGalleryScreen extends StatelessWidget {
  final List<ChatMessage> messages;
  final int initialTabIndex;

  const MediaGalleryScreen({
    super.key,
    required this.messages,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '보관함',
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: '사진/동영상'),
              Tab(text: '파일'),
              Tab(text: '링크'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMediaTab(context),
            _buildFileTab(),
            _buildLinkTab(),
          ],
        ),
      ),
    );
  }

  Map<String, List<ChatMessage>> _groupMessagesByDate(List<ChatMessage> messages) {
    final Map<String, List<ChatMessage>> grouped = {};
    for (var message in messages) {
      final date = "${message.time.year}. ${message.time.month.toString().padLeft(2, '0')}. ${message.time.day.toString().padLeft(2, '0')}";
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(message);
    }
    return grouped;
  }

  Map<String, List<_ImageItem>> _groupImagesByDate(List<ChatMessage> messages) {
    final Map<String, List<_ImageItem>> grouped = {};
    
    for (var message in messages) {
      final date = "${message.time.year}. ${message.time.month.toString().padLeft(2, '0')}. ${message.time.day.toString().padLeft(2, '0')}";
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      
      // Handle imageBytesList (multiple images)
      if (message.imageBytesList != null && message.imageBytesList!.isNotEmpty) {
        for (int i = 0; i < message.imageBytesList!.length; i++) {
          grouped[date]!.add(_ImageItem(
            imageBytes: message.imageBytesList![i],
            time: message.time,
            imageIndex: i,
          ));
        }
      }
      // Handle single imageBytes (backward compatibility)
      else if (message.imageBytes != null) {
        grouped[date]!.add(_ImageItem(
          imageBytes: message.imageBytes!,
          time: message.time,
        ));
      }
      // Handle network image
      else if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
        grouped[date]!.add(_ImageItem(
          imageUrl: message.imageUrl!,
          time: message.time,
        ));
      }
    }
    
    return grouped;
  }

  Widget _buildMediaTab(BuildContext context) {
    final groupedImages = _groupImagesByDate(messages);
    
    if (groupedImages.isEmpty) {
      return const Center(child: Text('사진/동영상이 없습니다.', style: TextStyle(color: Colors.black)));
    }

    final sortedDates = groupedImages.keys.toList()..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: [
        // Grouped Media Grid
        for (var date in sortedDates) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final imageItem = groupedImages[date]![index];
                  return GestureDetector(
                    onTap: () => _openFullScreenImageItem(context, imageItem),
                    child: _buildThumbnail(imageItem),
                  );
                },
                childCount: groupedImages[date]!.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildThumbnail(_ImageItem item) {
    if (item.imageBytes != null) {
      return Image.memory(
        item.imageBytes!,
        fit: BoxFit.cover,
      );
    } else if (item.imageUrl != null) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image));
        },
      );
    }
    return Container(color: Colors.grey[300]);
  }

  void _openFullScreenImageItem(BuildContext context, _ImageItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
          backgroundColor: Colors.black,
          body: Center(
            child: item.imageBytes != null
                ? Image.memory(item.imageBytes!)
                : Image.network(item.imageUrl!),
          ),
        ),
      ),
    );
  }

  Widget _buildFileTab() {
    final fileMessages = messages.where((m) => 
      m.fileName != null || (m.filesList != null && m.filesList!.isNotEmpty)
    ).toList();
    fileMessages.sort((a, b) => b.time.compareTo(a.time));

    if (fileMessages.isEmpty) {
      return const Center(child: Text('파일이 없습니다.', style: TextStyle(color: Colors.black)));
    }

    final groupedFiles = _groupMessagesByDate(fileMessages);
    final sortedDates = groupedFiles.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final msgs = groupedFiles[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...msgs.expand((message) {
              if (message.filesList != null && message.filesList!.isNotEmpty) {
                 return message.filesList!.map((fileInfo) {
                   final name = fileInfo['name'] as String? ?? 'Unknown File';
                   final size = fileInfo['size'] as int?;
                   return _buildFileTile(name, size);
                 });
              } else if (message.fileName != null) {
                return [_buildFileTile(message.fileName!, message.fileSize)];
              }
              return <Widget>[];
            }),
          ],
        );
      },
    );
  }
  
  Widget _buildFileTile(String name, int? size) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
      title: Text(name, style: const TextStyle(color: Colors.black)),
      subtitle: size != null
          ? Text('${(size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.download, size: 20, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildLinkTab() {
    final urlRegExp = RegExp(
        r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');

    final linkMessages = messages.where((m) => urlRegExp.hasMatch(m.text)).toList();
    linkMessages.sort((a, b) => b.time.compareTo(a.time));

    if (linkMessages.isEmpty) {
      return const Center(child: Text('링크가 없습니다.', style: TextStyle(color: Colors.black)));
    }

    final groupedLinks = _groupMessagesByDate(linkMessages);
    final sortedDates = groupedLinks.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final links = groupedLinks[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...links.map((message) {
              final match = urlRegExp.firstMatch(message.text);
              final url = match?.group(0) ?? message.text;
              return ListTile(
                leading: const Icon(Icons.link, color: Colors.grey),
                title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black)),
                subtitle: Text(message.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                onTap: () {},
              );
            }),
          ],
        );
      },
    );
  }
}
