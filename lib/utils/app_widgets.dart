// lib/utils/app_widgets.dart

import 'package:flutter/material.dart';

// 輔助函式：構造子頁面的通用 AppBar
AppBar subpageAppBar(String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0.5,
  );
}

// 輔助函式：構造【固定】贊助區 (全版面、無框、零間隙)
Widget buildFixedSponsorAd(String location, BuildContext context) {
  return Container(
    height: 60,
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.zero, // 確保與上下元件間隙為 0
    padding: EdgeInsets.zero, // 確保容器本身無邊距
    decoration: const BoxDecoration(
      color: Color(0xFFFFFBEB), // 淺黃色背景，無邊框
    ),
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        '贊助區廣告 ($location)',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.orange.shade700, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// 輔助方法：構造我的頁面列表項目 (最小間隙)
Widget buildListItem(
    BuildContext context, String title, IconData icon, Widget? page) {
  return InkWell(
    onTap: () {
      if (page != null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => page));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('點擊了 $title')));
      }
    },
    child: Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // 縮小垂直 padding
      margin: EdgeInsets.zero, // 確保零間隙
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}
