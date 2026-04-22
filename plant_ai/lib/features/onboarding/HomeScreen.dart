import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Profile/NotificationScreen.dart';
import 'AI/ChatBotAIScreen.dart'; // Sửa lại đường dẫn nếu cần  
import 'Effect/CustomBottomNavBar.dart'; // File BottomBar rời của ông
import 'Effect/PlantSearchOverlay.dart'; // File tìm kiếm Overlay
import '../../../core/API/UserAPI.dart'; 
import 'PlantProfile/CoffeeRustScreen.dart';
import 'PlantProfile/CoffeeMinerScreen.dart';
import 'PlantProfile/CoffeePhomaScreen.dart';
import 'PlantProfile/RiceLeafHispaScreen.dart';
import 'PlantProfile/RiceLeafBlastScreen.dart';
import 'PlantProfile/RiceLeafBrownSpotScreen.dart';
import 'PlantProfile/RiceLeafScaldScreen.dart';
import 'Effect/ScanTutorialScreen.dart';
import 'HandBook/ArticleDetailScreen.dart';
import 'HandBook/DiseaseControlDetailScreen.dart';
import 'HandBook/PestControlDetailScreen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 1. THÊM MIXIN ĐỂ QUẢN LÝ ANIMATION
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  
  // --- ANIMATION CONTROLLERS ---
  late AnimationController _controller;
  
  late Animation<Offset> _headerSlideAnim;       // Header trượt xuống
  late Animation<double> _headerContentFadeAnim; // Nội dung Header hiện ra
  late Animation<Offset> _bottomBarSlideAnim;    // Footer trượt lên

  // --- MÀU SẮC ---
  final Color colorBg = const Color(0xFFF2FDEB);
  final Color colorGreenDark = const Color(0xFF80A252); 
  final Color colorGreenLight = const Color(0xFFBFD1A8);
  final Color colorFilterSelected = const Color(0xFF90A955);
  final Color colorFilterUnselected = const Color(0xFFD4E0B1);

  // --- DATA ---
  String userName = "Đang tải...";
  String? userAvatar;
  bool isLoading = true;
  String currentUserEmail = ""; 
  int _selectedIndex = 0;
  String _currentKeyword = "";


  // --- FILTER DATA (MỚI) ---
  // 1. Danh mục đang chọn (Mặc định là "Tất cả")
  String _selectedCategory = "Tất cả";
  final List<String> _categories = ["Tất cả", "Cây cà phê", "Cây lúa"];
final List<Map<String, String>> _allDiseases = [
    {
      "title": "Bệnh Đạo Ôn",
      "image": "assets/Plant/RiceBlast1.jpg",
      "type": "Cây lúa"
    },
    {
      "title": "Bệnh Phoma",
      "image": "assets/Plant/Leaf_Phoma.jpg",
      "type": "Cây cà phê"
    },
    {
      "title": "Miner",
      "image": "assets/Plant/coffee-leaf-miner.jpg",
      "type": "Cây cà phê"
    },
    {
      "title": "Rỉ sắt cà phê",
      "image": "assets/Plant/Coffee-Rust-Disease.jpg",
      "type": "Cây cà phê"
    },
    {
      "title": "Bọ gai ăn lúa",
      "image": "assets/Plant/Hispa_RiceLeaf.jpg",
      "type": "Cây lúa"
    },
    {
      "title": "Bệnh Đốm Nâu",
      "image": "assets/Plant/RiceLeaf_BrownSpot.jpg",
      "type": "Cây lúa"
    },
    {
      "title": "Bệnh bỏng lá lúa",
      "image": "assets/Plant/RiceLeaf_Scald.jpg",
      "type": "Cây lúa"
    }
  ];



  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();

    // 2. CẤU HÌNH ANIMATION (TỔNG THỜI GIAN: 2 GIÂY)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    );

    // Kịch bản 1: Header Slide (Chạy trong 50% thời gian đầu: 0s -> 1s)
    // Trượt từ Offset(0, -1) (Bên trên màn hình) xuống Offset(0, 0)
    _headerSlideAnim = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ));

    // Kịch bản 2: Header Content Fade (Chạy trong 50% thời gian sau: 1s -> 2s)
    // Hiện từ 0.0 -> 1.0, CHỈ BẮT ĐẦU khi Header đã trượt xuống xong
    _headerContentFadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        ));

    // Kịch bản 3: Body Fade (Chạy xuyên suốt 2s)
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ));
        
    // Kịch bản 4: BottomBar Slide (Chạy xuyên suốt 2s từ dưới lên)
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ));

    // Bắt đầu chạy phim!
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Hủy controller khi thoát màn hình
    super.dispose();
  }
  
  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('current_user_email');
    
    if (email != null && email.isNotEmpty) {
      setState(() => currentUserEmail = email);
      await _fetchUserProfile(); // Chỉ gọi API khi đã có email thật
    } else {
      setState(() {
        userName = "Khách";
        isLoading = false;
      });
    }
  }
  
  Future<void> _fetchUserProfile() async {
    try {
      var userMap = await UserAPI.getUserByEmail(currentUserEmail);

      if (mounted) {
        setState(() {
          if (userMap != null) {
            // 1. Lấy dữ liệu từ DB ra (có thể key của ông là 'username' hoặc 'name')
            String? fetchedName = userMap['username'] ?? userMap['name'];
            String? fetchedEmail = userMap['email'];
            userAvatar = userMap['avatar'];
            // 2. Logic ưu tiên: Username -> Email -> "User"
            if (fetchedName != null && fetchedName.trim().isNotEmpty) {
              userName = fetchedName; // Ưu tiên 1: Lấy tên
            } else if (fetchedEmail != null && fetchedEmail.trim().isNotEmpty) {
              userName = fetchedEmail; // Ưu tiên 2: Lấy Email
            }
          } else {
            userName = "User"; // Nếu không tìm thấy UserMap trong DB
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi HomeScreen: $e");
      if (mounted) {
        setState(() {
          userName = "Lỗi kết nối";
          isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Developer đã chọn tab: $index");
  }

  void _openSearchOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PlantSearchOverlay(initialKeyword: _currentKeyword);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((result) {
      // KHI NGƯỜI DÙNG BẤM CHỌN 1 BỆNH TỪ OVERLAY, KẾT QUẢ SẼ RƠI VÀO ĐÂY (result)
      if (result != null && result.isNotEmpty) {
        setState(() {
          _currentKeyword = result; // Cập nhật lại chữ trên thanh search ở HomeScreen
        });

        // 🚀 BỘ ĐỊNH TUYẾN CHUYỂN TRANG DỰA THEO TÊN BỆNH
        if (result == "Rỉ sắt cà phê") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeeRustScreen()));
        } 
        else if (result == "Miner") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeeMinerScreen()));
        } 
        else if (result == "Bệnh Phoma") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeePhomaScreen()));
        } 
        else if (result == "Bệnh đạo ôn") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceBlastScreen()));
        } 
        else if (result == "Bọ gai hại lúa") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceHispaScreen()));
        } 
        else if (result == "Bệnh Đốm Nâu") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceBrownSpotScreen()));
        }
        else if (result == "Bệnh bỏng lá lúa") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceLeafScaldScreen()));
        } 
        else {
          // Các bệnh chưa có màn hình chi tiết (Vàng lùn, Cháy lá...)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Đang cập nhật dữ liệu cho: $result")),
                ],
              ),
              behavior: SnackBarBehavior.floating, 
              backgroundColor: Colors.black87,
              margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20), // Né nút Scan ra
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      
      // 🚀 NÂNG CẤP LÊN CUSTOM SCROLL VIEW ĐỂ LÀM HIỆU ỨNG APPLE
      body: CustomScrollView(
        // Hiệu ứng kéo nảy cao su chuẩn của iOS
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), 
        slivers: [
          // 1. HEADER DÍNH LÊN TOP (STICKY)
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true, // Chốt chặn Header luôn nằm trên cùng khi kéo xuống
            stretch: true, // Kéo lố lên trên cùng sẽ có hiệu ứng giãn Header ra
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 110.0, // Chiều cao khi đứng yên
            collapsedHeight: 85.0, // Chiều cao khi thu gọn lại lúc cuộn
            flexibleSpace: _buildGradientHeader(), // Gọi hàm vẽ Header vào đây
          ),

          // 2. PHẦN NỘI DUNG CUỘN BÊN DƯỚI
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100), // Khoảng trống cho BottomBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildPromoBanner(),
                  const SizedBox(height: 20),
                  _buildDiseaseInfoSection(),
                  const SizedBox(height: 30),
                  _buildHandbookSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // BOTTOM BAR & NÚT SCAN GIỮ NGUYÊN BÊN DƯỚI NÀY
      floatingActionButton: SlideTransition(
        position: _bottomBarSlideAnim,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          height: 64,
          width: 64,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScanTutorialScreen()),
              );
            },
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.black54, size: 28),
                Text("Scan", style: GoogleFonts.roboto(fontSize: 9, color: Colors.black54))
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SlideTransition(
        position: _bottomBarSlideAnim,
        child: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  // --- WIDGET HEADER (ANIMATION KÉP: SLIDE + FADE CONTENT) ---
  // --- WIDGET HEADER (ĐÃ TỐI ƯU CHO SLIVER APP BAR) ---
  Widget _buildGradientHeader() {
    return SlideTransition(
      position: _headerSlideAnim,
      child: Container(
        // Đã xóa bỏ padding cứng, dùng SafeArea ở dưới để tự căn chỉnh
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          // Thêm bóng đổ 3D để khi cuộn list bên dưới chui vào gầm nhìn rất nét
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.58, 1.0],
            colors: [
              Colors.white, 
              colorGreenLight,
              colorGreenDark,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false, // Bỏ an toàn đáy
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
            child: FadeTransition(
              opacity: _headerContentFadeAnim,
              child: Row(
                children: [
                  Container(
                    width: 50, 
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                        ], 
                    ),
                    child: ClipOval( 
                      child: _buildAvatarImage(),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
                      children: [
                        Text(
                          isLoading ? "Đang kết nối..." : "$userName",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                 GestureDetector(
                    onTap: () {
                      // 🚀 ĐÂY NÈ: Lệnh chuyển trang kỳ diệu
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatBotAIScreen()),
                      );
                    },
                    child: _buildGlassIcon(Icons.smart_toy_outlined),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      // 🚀 Lệnh chuyển sang trang thông báo
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none, // Để cái chấm đỏ không bị cắt
                      children: [
                        _buildGlassIcon(Icons.notifications_none),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5), // Thêm viền trắng cho nổi bật
                            ),
                            child: const Text(
                              "1", 
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 8, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HÀM XỬ LÝ ẢNH AVATAR THÔNG MINH ---
  Widget _buildAvatarImage() {
    final String? path = userAvatar; 

    // 1. Kiểm tra rỗng, null hoặc chỉ có khoảng trắng -> Trả về Logo mặc định
    if (path == null || path.trim().isEmpty) {
      return Image.asset(
        'assets/images/Icon_user.png',
        fit: BoxFit.cover,
      );
    }

    // 2. Nếu có dữ liệu, kiểm tra nguồn ảnh
    if (path.startsWith('http')) {
      // ƯU TIÊN 1: Ảnh mạng từ URL
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    } else {
      // ƯU TIÊN 2: Ảnh cục bộ trong máy (Dùng sau khi người dùng vừa Edit xong)
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    }
  }

  Widget _buildGlassIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  // --- CÁC WIDGET DƯỚI KHÔNG THAY ĐỔI ---

  Widget _buildSearchBar() {
    bool hasKeyword = _currentKeyword.isNotEmpty;
    return GestureDetector(
      onTap: _openSearchOverlay,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 50,
        decoration: BoxDecoration(
          color: hasKeyword ? Colors.white : const Color(0xFFE1F0D6),
          borderRadius: BorderRadius.circular(25),
          border: hasKeyword ? Border.all(color: const Color(0xFF80A252)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Icon(Icons.search, color: hasKeyword ? const Color(0xFF80A252) : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasKeyword ? _currentKeyword : "Tìm kiếm loại bệnh",
                style: GoogleFonts.roboto(
                  color: hasKeyword ? Colors.black87 : Colors.grey[600],
                  fontWeight: hasKeyword ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasKeyword)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentKeyword = "";
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return GestureDetector(
      onTap: () {
        // Bấm vào banner sẽ bay sang trang Hướng dẫn
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanTutorialScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/PlantAI_banner.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseInfoSection() {
    List<Map<String, String>> filteredList;
    if (_selectedCategory == "Tất cả") {
      filteredList = _allDiseases;
    } else {
      filteredList = _allDiseases.where((item) => item['type'] == _selectedCategory).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Thông tin bệnh cây trồng mới", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        
        const SizedBox(height: 12),

        // --- HÀNG NÚT BẤM (FILTER) ---
        SizedBox(
          height: 35, 
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10), 
            itemBuilder: (context, index) {
              final category = _categories[index];              
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorFilterSelected : colorFilterUnselected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: GoogleFonts.roboto(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        // 🚀 ĐÃ BỎ SIZEDBOX(height: 220) VÀ THAY BẰNG GRIDVIEW
        // --- DANH SÁCH BỆNH ĐÃ LỌC (DẠNG LƯỚI) ---
        filteredList.isEmpty 
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text("Không có dữ liệu", style: GoogleFonts.roboto(color: Colors.grey))),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Lùi vào 2 bên mép
            child: GridView.builder(
              shrinkWrap: true, // 🛑 RẤT QUAN TRỌNG: Báo cho GridView biết tự co giãn chiều cao theo nội dung, không được tràn
              physics: const NeverScrollableScrollPhysics(), // 🛑 Tắt tính năng tự cuộn của GridView, để trang màn hình tổng cuộn
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: filteredList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,       // Hiển thị 2 cột
                crossAxisSpacing: 15,    // Khoảng cách giữa 2 cột
                mainAxisSpacing: 15,     // Khoảng cách giữa các hàng trên/dưới
                childAspectRatio: 0.85,  // Chỉnh tỷ lệ khung hình thẻ (nếu thẻ bị lẹm chữ thì giảm số này xuống 0.8 hoặc 0.75)
              ),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildDiseaseCard(
                  item['title']!, 
                  item['image']!,
                  () { 
                    if (item['title'] == "Rỉ sắt cà phê") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeeRustScreen()));
                    }
                    else if (item['title'] == "Miner") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeeMinerScreen()));
                    }
                    else if (item['title'] == "Bệnh Phoma") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CoffeePhomaScreen()));
                    }
                    else if (item['title'] == "Bọ gai ăn lúa") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceHispaScreen()));
                    }
                    else if (item['title'] == "Bệnh Đạo Ôn") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceBlastScreen()));
                    }
                    else if (item['title'] == "Bệnh Đốm Nâu") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceBrownSpotScreen()));
                    }
                    else if (item['title'] == "Bệnh bỏng lá lúa") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiceLeafScaldScreen()));
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Chưa cập nhật dữ liệu cho: ${item['title']}"),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
                        ),
                      );
                    }
                  }
                );
              },
            ),
          ),
      ],
    );
  }
  // --- WIDGET CẨM NANG CHĂM SÓC ---
  Widget _buildHandbookSection() {
    final List<Map<String, String>> guides = [
      {
        "title": "Bí quyết phòng bệnh mùa mưa",
        "subtitle": "Bảo vệ cây trồng khỏi nấm",
        "tag": "Mẹo hay",
        "image": "assets/Hanbook/LeafRain.jpg",
      },
      {
        "title": "Kỹ thuật bón phân hữu cơ",
        "subtitle": "Tối ưu hóa năng suất",
        "tag": "Kỹ thuật",
        "image": "assets/Hanbook/Chamsoc.jpg",
      },
      {
        "title": "Nhận biết sớm sâu bệnh",
        "subtitle": "Dấu hiệu trên mặt lá",
        "tag": "Kiến thức",
        "image": "assets/Hanbook/Chamsoccaysau.jpg",
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cẩm nang chăm sóc", 
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
        
        const SizedBox(height: 15),

        // 🚀 ĐÃ TĂNG CHIỀU CAO TỪ 110 LÊN 125 ĐỂ KHÔNG BỊ TRÀN CHỮ
        SizedBox(
          height: 125, 
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: guides.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final guide = guides[index];
              return GestureDetector(
                onTap: () {
                  // 🚀 2. VIẾT LOGIC CHUYỂN TRANG Ở ĐÂY
                  if (guide['title'] == "Bí quyết phòng bệnh mùa mưa") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ArticleDetailScreen()),
                    );
                  }
                  if (guide['title'] == "Kỹ thuật bón phân hữu cơ") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Diseasecontroldetailscreen()),
                    );
                  } 
                  if (guide['title'] == "Nhận biết sớm sâu bệnh") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PestControlDetailScreen()),
                    );
                  } 
                },
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    // Ảnh bìa
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                      child: Image.asset(
                        guide['image']!,
                        width: 100,
                        height: 125, // 🚀 Ảnh cũng phải cao theo khung (125)
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100, height: 125, color: Colors.grey[200],
                          child: const Icon(Icons.article, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: Padding(
                        // 🚀 GIẢM PADDING DỌC (VERTICAL) ĐỂ CHỮ CÓ THÊM CHỖ THỞ
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: colorGreenLight.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                              child: Text(guide['tag']!, 
                                style: GoogleFonts.roboto(fontSize: 10, color: colorGreenDark, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 6), // Đã thu hẹp khoảng cách
                            Text(guide['title']!, 
                              style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), 
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(guide['subtitle']!, 
                              style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]), 
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildDiseaseCard(String title, String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFCFE1B9), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), 
                topRight: Radius.circular(20), 
                bottomRight: Radius.circular(50) // Tạo góc vát chéo
              ),
              child: imageUrl.startsWith('http') ? Image.network(
                imageUrl, 
                height: 110, // Hạ chiều cao ảnh xuống để lấy chỗ cho Text
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey[300], 
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey, size: 30),
                        SizedBox(height: 4),
                        Text("Lỗi ảnh", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF80A252)),
                    ),
                  );
                },
              ) : Image.asset( 
                imageUrl,
                height: 110, // Hạ chiều cao ảnh xuống
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110, width: double.infinity, color: Colors.grey[300], 
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                        SizedBox(height: 4),
                        Text("Sai tên file", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Expanded giúp phần text tự lấp đầy không gian còn lại
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    Text(
                      title, 
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87.withOpacity(0.7)),
                      maxLines: 1, // Tránh rớt dòng làm bể _buildHandbookSection()
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text("Xem chi tiết", style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold)), 
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 8)
                      ]
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}