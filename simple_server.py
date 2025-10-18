#!/usr/bin/env python3
import http.server
import socketserver
import json
from urllib.parse import urlparse, parse_qs

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        if self.path == '/api/auth/register':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                print(f"收到註冊請求: {data}")
                
                self.send_response(201)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                
                response = {
                    "message": "註冊成功 (Python測試服務器)",
                    "token": "test_token_12345",
                    "user": {
                        "id": "test_user_id",
                        "email": data.get('email'),
                        "nickname": data.get('nickname')
                    }
                }
                
                self.wfile.write(json.dumps(response).encode('utf-8'))
                
            except Exception as e:
                print(f"處理請求錯誤: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    PORT = 8080
    with socketserver.TCPServer(("", PORT), CORSHTTPRequestHandler) as httpd:
        print(f"測試服務器運行在端口 {PORT}")
        print(f"訪問 http://localhost:{PORT}/test_flutter_cors.html")
        httpd.serve_forever()



