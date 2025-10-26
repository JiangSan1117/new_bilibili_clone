// lib/pages/create_post_page.dart
// lib/pages/create_post_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/data_service.dart';
import '../../models/post_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/sponsor_ad_widget.dart';

// 交易類型選項 (左邊第一個下拉選單)
const List<String> _transactionTypes = ['共享', '共同', '分享', '交換'];

// 台灣縣市及地區資料
const Map<String, List<String>> _cityData = {
  '臺北市': [
    '中正區',
    '大同區',
    '中山區',
    '松山區',
    '大安區',
    '萬華區',
    '信義區',
    '士林區',
    '北投區',
    '內湖區',
    '南港區',
    '文山區'
  ],
  '新北市': [
    '板橋區',
    '三重區',
    '中和區',
    '永和區',
    '新莊區',
    '新店區',
    '樹林區',
    '鶯歌區',
    '三峽區',
    '淡水區',
    '汐止區',
    '瑞芳區',
    '土城區',
    '蘆洲區',
    '五股區',
    '泰山區',
    '林口區',
    '深坑區',
    '石碇區',
    '坪林區',
    '三芝區',
    '石門區',
    '八里區',
    '平溪區',
    '雙溪區',
    '貢寮區',
    '金山區',
    '萬里區',
    '烏來區'
  ],
  '桃園市': [
    '桃園區',
    '中壢區',
    '大溪區',
    '楊梅區',
    '蘆竹區',
    '大園區',
    '龜山區',
    '八德區',
    '龍潭區',
    '平鎮區',
    '新屋區',
    '觀音區',
    '復興區'
  ],
  '臺中市': [
    '中區',
    '東區',
    '南區',
    '西區',
    '北區',
    '西屯區',
    '南屯區',
    '北屯區',
    '豐原區',
    '東勢區',
    '大甲區',
    '清水區',
    '沙鹿區',
    '梧棲區',
    '后里區',
    '神岡區',
    '潭子區',
    '大雅區',
    '新社區',
    '石岡區',
    '外埔區',
    '大安區',
    '烏日區',
    '大肚區',
    '龍井區',
    '霧峰區',
    '太平區',
    '大里區',
    '和平區'
  ],
  '臺南市': [
    '中西區',
    '東區',
    '南區',
    '北區',
    '安平區',
    '安南區',
    '永康區',
    '歸仁區',
    '新化區',
    '左鎮區',
    '玉井區',
    '楠西區',
    '南化區',
    '仁德區',
    '關廟區',
    '龍崎區',
    '官田區',
    '麻豆區',
    '佳里區',
    '西港區',
    '七股區',
    '將軍區',
    '學甲區',
    '北門區',
    '新營區',
    '後壁區',
    '白河區',
    '東山區',
    '六甲區',
    '下營區',
    '柳營區',
    '鹽水區',
    '善化區',
    '大內區',
    '山上區',
    '新市區',
    '安定區'
  ],
  '高雄市': [
    '新興區',
    '前金區',
    '苓雅區',
    '鹽埕區',
    '鼓山區',
    '旗津區',
    '前鎮區',
    '三民區',
    '楠梓區',
    '小港區',
    '左營區',
    '仁武區',
    '大社區',
    '岡山區',
    '路竹區',
    '阿蓮區',
    '田寮區',
    '燕巢區',
    '橋頭區',
    '梓官區',
    '彌陀區',
    '永安區',
    '湖內區',
    '鳳山區',
    '大寮區',
    '林園區',
    '鳥松區',
    '大樹區',
    '旗山區',
    '美濃區',
    '六龜區',
    '內門區',
    '杉林區',
    '甲仙區',
    '桃源區',
    '那瑪夏區',
    '茂林區',
    '茄萣區'
  ],
  '新竹縣': [
    '竹北市',
    '竹東鎮',
    '新埔鎮',
    '關西鎮',
    '湖口鄉',
    '新豐鄉',
    '芎林鄉',
    '橫山鄉',
    '臺灣鄉',
    '寶山鄉',
    '峨眉鄉',
    '尖石鄉',
    '五峰鄉'
  ],
  '苗栗縣': [
    '苗栗市',
    '苑裡鎮',
    '通霄鎮',
    '竹南鎮',
    '頭份市',
    '後龍鎮',
    '卓蘭鎮',
    '大湖鄉',
    '公館鄉',
    '銅鑼鄉',
    '南庄鄉',
    '頭屋鄉',
    '三義鄉',
    '西湖鄉',
    '造橋鄉',
    '三灣鄉',
    '獅潭鄉',
    '泰安鄉'
  ],
  '彰化縣': [
    '彰化市',
    '員林市',
    '和美鎮',
    '鹿港鎮',
    '溪湖鎮',
    '田中鎮',
    '北斗鎮',
    '二林鎮',
    '線西鄉',
    '伸港鄉',
    '福興鄉',
    '秀水鄉',
    '花壇鄉',
    '芬園鄉',
    '大村鄉',
    '埔鹽鄉',
    '社頭鄉',
    '永靖鄉',
    '埤頭鄉',
    '芳苑鄉',
    '大城鄉',
    '竹塘鄉',
    '溪州鄉',
    '埔心鄉',
    '田尾鄉',
    '二水鄉'
  ],
  '南投縣': [
    '南投市',
    '埔里鎮',
    '草屯鎮',
    '竹山鎮',
    '集集鎮',
    '名間鄉',
    '鹿谷鄉',
    '中寮鄉',
    '魚池鄉',
    '國姓鄉',
    '水里鄉',
    '信義鄉',
    '仁愛鄉'
  ],
  '雲林縣': [
    '斗六市',
    '斗南鎮',
    '虎尾鎮',
    '西螺鎮',
    '土庫鎮',
    '北港鎮',
    '古坑鄉',
    '大埤鄉',
    '莿桐鄉',
    '林內鄉',
    '二崙鄉',
    '崙背鄉',
    '麥寮鄉',
    '東勢鄉',
    '褒忠鄉',
    '臺西鄉',
    '元長鄉',
    '四湖鄉',
    '口湖鄉',
    '水林鄉'
  ],
  '嘉義縣': [
    '太保市',
    '朴子市',
    '布袋鎮',
    '大林鎮',
    '民雄鄉',
    '溪口鄉',
    '新港鄉',
    '六腳鄉',
    '東石鄉',
    '義竹鄉',
    '鹿草鄉',
    '水上鄉',
    '中埔鄉',
    '竹崎鄉',
    '梅山鄉',
    '番路鄉',
    '大埔鄉',
    '阿里山鄉'
  ],
  '屏東縣': [
    '屏東市',
    '潮州鎮',
    '東港鎮',
    '恆春鎮',
    '萬丹鄉',
    '長治鄉',
    '麟洛鄉',
    '九如鄉',
    '里港鄉',
    '鹽埔鄉',
    '高樹鄉',
    '萬巒鄉',
    '內埔鄉',
    '竹田鄉',
    '新埤鄉',
    '枋寮鄉',
    '新園鄉',
    '崁頂鄉',
    '林邊鄉',
    '南州鄉',
    '佳冬鄉',
    '琉球鄉',
    '車城鄉',
    '滿州鄉',
    '霧台鄉',
    '瑪家鄉',
    '三地門鄉',
    '來義鄉',
    '春日鄉',
    '獅子鄉',
    '牡丹鄉',
    '泰武鄉'
  ],
  '宜蘭縣': [
    '宜蘭市',
    '羅東鎮',
    '蘇澳鎮',
    '頭城鎮',
    '礁溪鄉',
    '壯圍鄉',
    '員山鄉',
    '冬山鄉',
    '五結鄉',
    '三星鄉',
    '大同鄉',
    '南澳鄉'
  ],
  '花蓮縣': [
    '花蓮市',
    '鳳林鎮',
    '玉里鎮',
    '新城鄉',
    '吉安鄉',
    '壽豐鄉',
    '光復鄉',
    '豐濱鄉',
    '瑞穗鄉',
    '萬榮鄉',
    '卓溪鄉',
    '富里鄉'
  ],
  '臺東縣': [
    '臺東市',
    '成功鎮',
    '關山鎮',
    '卑南鄉',
    '大武鄉',
    '太麻里鄉',
    '東河鄉',
    '長濱鄉',
    '鹿野鄉',
    '池上鄉',
    '海端鄉',
    '延平鄉',
    '金峰鄉',
    '達仁鄉',
    '蘭嶼鄉',
    '綠島鄉'
  ],
  '澎湖縣': ['馬公市', '湖西鄉', '白沙鄉', '西嶼鄉', '望安鄉', '七美鄉'],
  '金門縣': ['金城鎮', '金湖鎮', '金沙鎮', '金寧鄉', '烈嶼鄉', '烏坵鄉'],
  '連江縣': ['南竿鄉', '北竿鄉', '莒光鄉', '東引鄉'],
  '基隆市': ['仁愛區', '信義區', '中正區', '中山區', '安樂區', '暖暖區', '七堵區'],
  '新竹市': ['東區', '北區', '香山區'],
  '嘉義市': ['東區', '西區'],
};

class MediaItem {
  final String path;
  final bool isVideo;
  final String? thumbnailPath;

  MediaItem({
    required this.path,
    this.isVideo = false,
    this.thumbnailPath,
  });
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 交易類型
  String? _selectedType;

  // 地點狀態
  String? _selectedCity;
  String? _selectedDistrict;

  // 媒體文件列表 (圖片和影片)
  List<MediaItem> _selectedMedia = [];

  // 表單驗證狀態
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  // --- 輔助函式：贊助區 ---
  Widget _buildFixedSponsorAd(String location, BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.primary)),
      alignment: Alignment.center,
      child: Text(
        '贊助區廣告 ($location)',
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- 權限與媒體處理邏輯 ---

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    final PermissionStatus status = Platform.isIOS
        ? await Permission.photos.request()
        : await Permission.storage.request();
    return status.isGranted;
  }

  // 拍照功能
  Future<void> _takePhoto() async {
    if (!await _requestCameraPermission()) {
      _showPermissionDeniedDialog('需要相機權限才能拍照，請至設定頁開啟。');
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
        _addMediaItem(MediaItem(path: photo.path));
      }
    } catch (e) {
      _showErrorDialog('拍照失敗: $e');
    }
  }

  // 錄影功能
  Future<void> _takeVideo() async {
    if (!await _requestCameraPermission()) {
      _showPermissionDeniedDialog('需要相機和麥克風權限才能錄影，請至設定頁開啟。');
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        _addMediaItem(MediaItem(path: video.path, isVideo: true));
      }
    } catch (e) {
      _showErrorDialog('錄影失敗: $e');
    }
  }

  // 從相簿選擇媒體
  Future<void> _pickFromGallery() async {
    if (!await _requestStoragePermission()) {
      _showPermissionDeniedDialog('需要存儲權限才能選擇檔案，請至設定頁開啟。');
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
            _addMediaItem(MediaItem(path: file.path!, isVideo: isVideo));
          }
        }
      }
    } catch (e) {
      _showErrorDialog('檔案選擇失敗: $e');
    }
  }

  void _addMediaItem(MediaItem mediaItem) {
    if (_selectedMedia.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能選擇 9 個檔案')),
      );
      return;
    }

    setState(() {
      _selectedMedia.add(mediaItem);
    });
  }

  void _removeMediaItem(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('權限不足'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('前往設定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- 介面元件 ---

  /// 媒體選擇區域
  Widget _buildMediaPickerArea() {
    final int remainingSlots = 9 - _selectedMedia.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已選擇的媒體顯示區域
        if (_selectedMedia.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 10.0),
            child: Text(
              '已選擇的媒體',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _selectedMedia.length,
              itemBuilder: (context, index) {
                return _buildMediaPreview(index);
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '已選擇 ${_selectedMedia.length} 個檔案',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // 媒體選擇按鈕區域 - 移到最底下
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 10.0),
          child: Text(
            '添加媒體 (最多 9 個)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildMediaActionButtons(),
        ),
      ],
    );
  }

  /// 媒體預覽項目
  Widget _buildMediaPreview(int index) {
    final media = _selectedMedia[index];

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: media.isVideo
              ? _buildVideoPreview(media)
              : _buildImagePreview(media),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMediaItem(index),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
        if (media.isVideo) ...[
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '影片',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(MediaItem media) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(media.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildVideoPreview(MediaItem media) {
    return Stack(
      children: [
        Container(
          color: Colors.black12,
          child: const Center(
            child: Icon(Icons.videocam, color: Colors.grey, size: 40),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_filled, color: Colors.white, size: 30),
        ),
      ],
    );
  }

  /// 媒體操作按鈕
  Widget _buildMediaActionButtons() {
    return Row(
      children: [
        _buildMediaActionButton(
          icon: Icons.photo_camera,
          label: '拍照',
          onTap: _takePhoto,
        ),
        const SizedBox(width: 8),
        _buildMediaActionButton(
          icon: Icons.videocam,
          label: '錄影',
          onTap: _takeVideo,
        ),
        const SizedBox(width: 8),
        _buildMediaActionButton(
          icon: Icons.photo_library,
          label: '上傳',
          onTap: _pickFromGallery,
        ),
      ],
    );
  }

  Widget _buildMediaActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // --- 表單驗證 ---

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入標題';
    }
    if (value.trim().length < 3) {
      return '標題至少需要 3 個字元';
    }
    if (value.trim().length > 50) {
      return '標題不能超過 50 個字元';
    }
    return null;
  }

  String? _validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入內容';
    }
    if (value.trim().length < 10) {
      return '內容至少需要 10 個字元';
    }
    if (value.trim().length > 2000) {
      return '內容不能超過 2000 個字元';
    }
    return null;
  }

  String? _validateType() {
    if (_selectedType == null) {
      return '請選擇類型';
    }
    return null;
  }


  String? _validateLocation() {
    if (_selectedCity == null || _selectedDistrict == null) {
      return '請選擇地點';
    }
    return null;
  }

  bool _validateForm() {
    final errors = [
      _validateTitle(_titleController.text),
      _validateContent(_contentController.text),
      _validateType(),
      _validateLocation(),
    ].where((error) => error != null).toList();

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first!),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // --- 發布邏輯 ---
  Future<void> _submitPost() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 模擬上傳過程
      await _uploadMediaFiles();
      await _savePostToDatabase();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文章發布成功！'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('發布失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _uploadMediaFiles() async {
    // 模擬上傳過程
    for (final media in _selectedMedia) {
      debugPrint('上傳檔案: ${media.path} (${media.isVideo ? '影片' : '圖片'})');
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _savePostToDatabase() async {
    try {
      // 創建新的文章對象
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        author: AuthService.userDisplayName ?? '匿名用戶',
        authorId: AuthService.userId ?? 'unknown',
        username: AuthService.userDisplayName ?? '匿名用戶',
        category: '未分類',
        mainTab: _selectedType!,
        images: _selectedMedia.map((m) => m.path).toList(),
        videos: [],
        likes: 0,
        comments: 0,
        views: 0,
        city: '$_selectedCity $_selectedDistrict',
        type: _selectedType!,
        postImageUrl: _selectedMedia.isNotEmpty ? _selectedMedia.first.path : null,
        createdAt: DateTime.now(),
      );

      // 保存到數據服務
      await DataService.savePost(post);
      
      debugPrint('--- 發布文章資訊 ---');
      debugPrint('類型: $_selectedType');
      debugPrint('地點: $_selectedCity $_selectedDistrict');
      debugPrint('標題: ${_titleController.text}');
      debugPrint('內容: ${_contentController.text}');
      debugPrint('媒體數量: ${_selectedMedia.length}');
      debugPrint('圖片: ${_selectedMedia.where((m) => !m.isVideo).length}');
      debugPrint('影片: ${_selectedMedia.where((m) => m.isVideo).length}');
    } catch (e) {
      throw Exception('保存文章失敗: ${e.toString()}');
    }
  }

  // --- 其他 UI 元件 (保持不變) ---

  Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomDropdown<String>(
              value: _selectedType,
              items: _transactionTypes,
              hint: '選擇類型',
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdowns() {
    final List<String> cityList = _cityData.keys.toList();
    final List<String> districtList =
        _selectedCity != null ? (_cityData[_selectedCity] ?? []) : [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomDropdown<String>(
              value: _selectedCity,
              items: cityList,
              hint: '選擇縣市',
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                  _selectedDistrict = null;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCustomDropdown<String>(
              value: _selectedCity != null ? _selectedDistrict : null,
              items: districtList,
              hint: '選擇地區',
              onChanged: _selectedCity != null
                  ? (String? newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                      });
                    }
                  : null,
              isDisabled: _selectedCity == null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?>? onChanged,
    bool isDisabled = false,
  }) {
    final color = isDisabled ? Colors.grey.shade400 : Colors.grey.shade300;
    final hintStyle = TextStyle(
        color: isDisabled ? Colors.grey.shade600 : Colors.grey.shade600);
    final textStyle = TextStyle(
        fontSize: 16,
        color: isDisabled ? Colors.grey.shade700 : Colors.black87);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: hintStyle),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isDisabled ? Colors.grey.shade500 : Colors.grey),
          style: textStyle,
          items: items.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 防止鍵盤彈出時贊助區移動
      appBar: AppBar(
        title: Text('發布新內容', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A) 
            : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  onPressed: _submitPost,
                  child: Text(
                    '發布',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          // 1. 內容輸入區 (可滾動)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一組下拉選單：交易類型
                  _buildTypeDropdown(),

                  // 第二組下拉選單：縣市 + 地區
                  _buildLocationDropdowns(),

                  // 輸入標題
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '輸入標題：如「共享我的單車優惠券」',
                        border: const UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        errorText: _validateTitle(_titleController.text),
                      ),
                      maxLength: 50,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // 內容輸入
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: '輸入內容：詳述物品、交換條件或共享方式、地點等',
                        border: InputBorder.none,
                        errorText: _validateContent(_contentController.text),
                      ),
                      maxLines: 8,
                      minLines: 4,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const Divider(height: 1, color: Colors.grey),

                  // 媒體選擇區域
                  _buildMediaPickerArea(),

                  const Divider(height: 1, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
