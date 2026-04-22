import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// --- IMPORT DỊCH VỤ & API ---
import '../../../core/services/Checkin/JWT.dart'; 
import '../../../core/services/ChatAI_service.dart'; 
import '../../../core/API/ChatHistoryAPI.dart'; 
import '../../../core/API/connection/chat_session_model.dart';

class ChatBotAIScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatBotAIScreen({super.key, this.initialMessage});

  @override
  State<ChatBotAIScreen> createState() => _ChatBotAIScreenState();
}

class _ChatBotAIScreenState extends State<ChatBotAIScreen> {
  final Color plantGreen = const Color(0xFF8DAA5B);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 🚀 BIẾN QUẢN LÝ TRẠNG THÁI & DỮ LIỆU
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false; 
  bool _isLoading = false;
  bool _isSending = false;
  String? _currentSessionId; // ID của phiên chat hiện tại
  List<ChatSessionModel> _realChatHistory = []; // Danh sách lịch sử tải từ MongoDB

  @override
  void initState() {
    super.initState();
    _fetchChatSessions(); // Tải lịch sử ngay khi mở màn hình
    
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    } 
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 🚀 TẢI LỊCH SỬ TỪ MONGODB
  Future<void> _fetchChatSessions() async {
    setState(() => _isLoading = true);
    String? userId = await JWTService.getUserId();
    if (userId != null) {
      final history = await ChatHistoryAPI.getHistory(userId);
      if (mounted) {
        setState(() {
          _realChatHistory = history;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // 🚀 GỬI VÀ LƯU TIN NHẮN
  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    // 1. Hiện tin nhắn User
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isTyping = true; 
    });
    
    _messageController.clear();
    _scrollToBottom();

    // 2. GỌI GEMINI XỬ LÝ
    String aiResponse = await ChatAPI.getAIResponse(_messages);
    
    // 3. Nhận phản hồi
    if (mounted) {
      setState(() {
        _isTyping = false; 
        _messages.add({"role": "ai", "content": aiResponse});
      });
      _scrollToBottom();

      // 4.  LƯU VÀO MONGODB
      String? userId = await JWTService.getUserId();
      if (userId != null) {
        // Tạo tiêu đề từ câu hỏi đầu tiên
        String chatTitle = _messages.first["content"].toString();
        if (chatTitle.length > 30) chatTitle = "${chatTitle.substring(0, 30)}...";

        final session = ChatSessionModel(
          userId: userId,
          title: chatTitle,
          updatedAt: DateTime.now(),
          messages: _messages,
        );

        // Gọi API lưu & nhận ID
        String? savedId = await ChatHistoryAPI.saveSession(_currentSessionId, session);
        if (savedId != null) {
          _currentSessionId = savedId;
          _fetchChatSessions(); // Làm mới Sidebar
        }
      }
    }
  }

  // 🚀 XÓA LỊCH SỬ CHAT
  void _deleteChatSession(String sessionId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa cuộc trò chuyện?"),
        content: const Text("Dữ liệu sẽ bị xóa vĩnh viễn và không thể khôi phục."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await ChatHistoryAPI.deleteSession(sessionId);
      if (success && mounted) {
        setState(() {
          _realChatHistory.removeWhere((s) => s.id == sessionId);
          // Nếu đang xóa đoạn chat hiện tại trên màn hình -> Dọn dẹp màn hình
          if (_currentSessionId == sessionId) {
            _currentSessionId = null;
            _messages.clear();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa đoạn chat")));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() {
    Navigator.pop(context); // Đóng Drawer
    setState(() {
      _currentSessionId = null; // Đặt lại ID để tạo phiên mới
      _messages.clear(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Chuyên gia AI", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18)),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history, color: Colors.black54), 
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: _buildHistorySidebar(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty 
              ? _buildWelcomeScreen() 
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return _buildMessageRow(msg["role"] == "ai", msg["content"]);
                  },
                ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- 🎨 SIDEBAR LỊCH SỬ CHAT (DYNAMIC TỪ MONGODB) ---
  Widget _buildHistorySidebar() {
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
                  side: BorderSide(color: Colors.grey.shade300), minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: Text("Đoạn chat mới", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onPressed: _startNewChat,
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _realChatHistory.isEmpty
                  ? Center(child: Text("Chưa có lịch sử trò chuyện", style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _realChatHistory.length,
                      itemBuilder: (context, index) {
                        final session = _realChatHistory[index];
                        bool isActive = session.id == _currentSessionId;
                        return _buildHistoryItem(session, isActive);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ChatSessionModel session, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey.shade200 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.chat_bubble_outline, size: 18, color: isActive ? Colors.black87 : Colors.black54),
        title: Text(
          session.title, 
          style: GoogleFonts.inter(fontSize: 14, color: isActive ? Colors.black87 : Colors.black54, fontWeight: isActive ? FontWeight.w500 : FontWeight.normal),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        // 🚀 THÙNG RÁC XÓA LỊCH SỬ NẰM Ở ĐÂY
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
          onPressed: () {
            Navigator.pop(context); // Đóng sidebar
            _deleteChatSession(session.id!); // Gọi hàm xóa
          },
        ),
        onTap: () {
          Navigator.pop(context); // Đóng sidebar
          setState(() {
            _currentSessionId = session.id;
            _messages = List<Map<String, dynamic>>.from(session.messages); 
          });
          _scrollToBottom();
        },
      ),
    );
  }

  // --- CÁC WIDGET GIAO DIỆN CHAT KHÁC GIỮ NGUYÊN NHƯ CŨ CỦA ÔNG ---
  Widget _buildMessageRow(bool isAi, String message) {
    return Container(
      width: double.infinity,
      color: isAi ? const Color(0xFFF7F7F8) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: isAi ? plantGreen : Colors.blueGrey, borderRadius: BorderRadius.circular(4)),
            child: Icon(isAi ? Icons.psychology_outlined : Icons.person_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MarkdownBody(
              data: message,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF374151), height: 1.6),
                strong: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87),
                blockSpacing: 10.0,
                listBullet: const TextStyle(color: Color(0xFF8DAA5B), fontSize: 18), 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 60, color: plantGreen),
            const SizedBox(height: 16),
            Text("Tôi có thể giúp gì cho vườn của bạn?", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
              children: [
                _buildPromptChip("Cách trị bệnh rỉ sắt?"),
                _buildPromptChip("Lịch bón phân mùa mưa"),
                _buildPromptChip("Thuốc sinh học cho lúa"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return ActionChip(
      label: Text(text, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
      backgroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _sendMessage(text),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1, maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Nhắn tin cho Chuyên gia AI...", hintStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: plantGreen, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      color: const Color(0xFFF7F7F8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30, decoration: BoxDecoration(color: plantGreen, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Padding(padding: EdgeInsets.only(top: 6), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)))
        ],
      ),
    );
  }
}