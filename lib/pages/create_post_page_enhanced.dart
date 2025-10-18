// lib/pages/create_post_page_enhanced.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_service.dart';
import '../services/real_api_service.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';

// 交易類型選項
const List<String> _transactionTypes = ['共享', '共同', '分享', '交換'];

// 類別選項
const List<String> _categories = ['飲食', '穿著', '居住', '交通', '教育', '娛樂'];



// 台灣縣市及地區資料
const Map<String, List<String>> _cityData = {
  '臺北市': ['中正區', '大同區', '中山區', '松山區', '大安區', '萬華區', '信義區', '士林區', '北投區', '內湖區', '南港區', '文山區'],
  '新北市': ['板橋區', '三重區', '中和區', '永和區', '新莊區', '新店區', '樹林區', '鶯歌區', '三峽區', '淡水區', '汐止區', '瑞芳區', '土城區', '蘆洲區', '五股區', '泰山區', '林口區', '深坑區', '石碇區', '坪林區', '三芝區', '石門區', '八里區', '平溪區', '雙溪區', '貢寮區', '金山區', '萬里區', '烏來區'],
  '桃園市': ['桃園區', '中壢區', '大溪區', '楊梅區', '蘆竹區', '大園區', '龜山區', '八德區', '龍潭區', '平鎮區', '新屋區', '觀音區', '復興區'],
  '臺中市': ['中區', '東區', '南區', '西區', '北區', '西屯區', '南屯區', '北屯區', '豐原區', '東勢區', '大甲區', '清水區', '沙鹿區', '梧棲區', '后里區', '神岡區', '潭子區', '大雅區', '新社區', '石岡區', '外埔區', '大安區', '烏日區', '大肚區', '龍井區', '霧峰區', '太平區', '大里區', '和平區'],
  '臺南市': ['中西區', '東區', '南區', '北區', '安平區', '安南區', '永康區', '歸仁區', '新化區', '左鎮區', '玉井區', '楠西區', '南化區', '仁德區', '關廟區', '龍崎區', '官田區', '麻豆區', '佳里區', '西港區', '七股區', '將軍區', '學甲區', '北門區', '新營區', '後壁區', '白河區', '東山區', '六甲區', '下營區', '柳營區', '鹽水區', '善化區', '大內區', '山上區', '新市區', '安定區'],
  '高雄市': ['新興區', '前金區', '苓雅區', '鹽埕區', '鼓山區', '旗津區', '前鎮區', '三民區', '楠梓區', '小港區', '左營區', '仁武區', '大社區', '東沙群島', '南沙群島', '岡山區', '路竹區', '阿蓮區', '田寮區', '燕巢區', '橋頭區', '梓官區', '彌陀區', '永安區', '湖內區', '鳳山區', '大寮區', '林園區', '鳥松區', '大樹區', '旗山區', '美濃區', '六龜區', '內門區', '杉林區', '甲仙區', '桃源區', '那瑪夏區', '茂林區'],
};

class MediaItem {
  final String path;
  final bool isVideo;

  MediaItem({required this.path, this.isVideo = false});
}

class CreatePostPageEnhanced extends StatefulWidget {
  const CreatePostPageEnhanced({super.key});

  @override
  State<CreatePostPageEnhanced> createState() => _CreatePostPageEnhancedState();
}

class _CreatePostPageEnhancedState extends State<CreatePostPageEnhanced> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 表單狀態
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedDistrict;
  List<MediaItem> _selectedMedia = [];
  
  // UI狀態
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 表單驗證
  String? _validateTitle(String value) {
    if (value.trim().isEmpty) {
      return '請輸入標題';
    }
    if (value.trim().length < 5) {
      return '標題至少需要5個字符';
    }
    return null;
  }

  String? _validateContent(String value) {
    if (value.trim().isEmpty) {
      return '請輸入內容';
    }
    if (value.trim().length < 10) {
      return '內容至少需要10個字符';
    }
    return null;
  }

  bool _isFormValid() {
    return _validateTitle(_titleController.text) == null &&
           _validateContent(_contentController.text) == null &&
           _selectedType != null &&
           _selectedCategory != null &&
           _selectedCity != null &&
           _selectedDistrict != null;
  }

  // 權限請求
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.photos.request();
    return status == PermissionStatus.granted;
  }

  // 媒體處理
  Future<void> _takePhoto() async {
    if (!await _requestCameraPermission()) {
      _showSnackBar('需要相機權限才能拍照');
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedMedia.add(MediaItem(path: photo.path));
        });
      }
    } catch (e) {
      _showSnackBar('拍照失敗: $e');
    }
  }

  Future<void> _takeVideo() async {
    if (!await _requestCameraPermission()) {
      _showSnackBar('需要相機權限才能錄影');
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5), // 限制5分鐘
      );

      if (video != null) {
        setState(() {
          _selectedMedia.add(MediaItem(path: video.path, isVideo: true));
        });
      }
    } catch (e) {
      _showSnackBar('錄影失敗: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (!await _requestStoragePermission()) {
      _showSnackBar('需要存儲權限才能選擇檔案');
      return;
    }

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'heic', 'mp4', 'mov'],
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.path != null) {
            final isVideo = file.extension?.toLowerCase() == 'mp4' ||
                file.extension?.toLowerCase() == 'mov';
            setState(() {
              _selectedMedia.add(MediaItem(path: file.path!, isVideo: isVideo));
            });
          }
        }
      }
    } catch (e) {
      _showSnackBar('選擇檔案失敗: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }


  // 提交文章
  Future<void> _submitPost() async {
    if (!_isFormValid()) {
      _showSnackBar('請填寫完整資訊');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 準備圖片和視頻URL列表
      List<String> imageUrls = [];
      List<String> videoUrls = [];
      
      for (final media in _selectedMedia) {
        if (media.isVideo) {
          // 對於視頻，使用模擬URL
          videoUrls.add('https://picsum.photos/seed/video${media.path.hashCode}/400');
        } else {
          // 對於圖片，使用實際的圖片URL（基於文件路徑生成唯一URL）
          final imageUrl = 'https://picsum.photos/seed/${media.path.hashCode.abs()}/400/300';
          imageUrls.add(imageUrl);
          print('📸 生成圖片URL: $imageUrl');
        }
      }
      
      print('📸 最終圖片列表: $imageUrls');
      print('🎥 最終視頻列表: $videoUrls');

      // 使用真實API發布文章
      final result = await RealApiService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory ?? '未分類',
        mainTab: _selectedType ?? '共享',
        type: _selectedType ?? '共享',
        city: '$_selectedCity $_selectedDistrict',
        images: imageUrls,
        videos: videoUrls,
      );

      if (result['success'] == true) {
        _showSnackBar('發布成功！');
        Navigator.of(context).pop(true); // 傳遞 true 表示發布成功
      } else {
        _showSnackBar('發布失敗: ${result['error'] ?? '未知錯誤'}');
      }
    } catch (e) {
      _showSnackBar('發布失敗: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('發布新內容', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          _isSubmitting
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _isFormValid() ? _submitPost : null,
                  child: Text(
                    '發布',
                    style: TextStyle(
                      color: _isFormValid() 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 交易類型和類別選擇
                  _buildTypeAndCategorySelection(),
                  
                  const SizedBox(height: 16),
                  
                  
                  const SizedBox(height: 16),
                  
                  // 地理位置選擇
                  _buildLocationSelection(),
                  
                  const SizedBox(height: 16),
                  
                  // 標題輸入
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: '標題',
                      hintText: '輸入文章標題',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: _validateTitle(_titleController.text),
                    ),
                    maxLength: 50,
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 內容輸入
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: '內容',
                      hintText: '詳細描述您的分享內容',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: _validateContent(_contentController.text),
                    ),
                    maxLines: 6,
                    minLines: 4,
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 媒體選擇
                  _buildMediaSelection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAndCategorySelection() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: '類型',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _transactionTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: '類別',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _categories.map((category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
      ],
    );
  }


  Widget _buildLocationSelection() {
    final cityList = _cityData.keys.toList();
    final districtList = _selectedCity != null 
        ? _cityData[_selectedCity] ?? []
        : <String>[];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: '縣市',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: cityList.map((city) => DropdownMenuItem(
              value: city,
              child: Text(city),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedDistrict = null;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: InputDecoration(
              labelText: '地區',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: districtList.map((district) => DropdownMenuItem(
              value: district,
              child: Text(district),
            )).toList(),
            onChanged: _selectedCity != null ? (value) {
              setState(() {
                _selectedDistrict = value;
              });
            } : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '媒體檔案 (可選)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        
        // 已選擇的媒體預覽
        if (_selectedMedia.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMedia.length,
              itemBuilder: (context, index) {
                final media = _selectedMedia[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: media.isVideo
                            ? Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.play_circle_outline, size: 40),
                              )
                            : Image.file(
                                File(media.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // 選擇媒體按鈕
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takeVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('錄影'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('選擇檔案'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
