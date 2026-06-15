import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class PlanScreen extends StatefulWidget {
  final String destinationName;
  final int daysCount;
  final String? planId;

  const PlanScreen({
    super.key,
    required this.destinationName,
    required this.daysCount,
    this.planId,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int selectedDay = 1; // State untuk hari yang dipilih
  Map<int, List<Map<String, String>>> tripData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.planId != null ? 'itinerary_${widget.planId}' : null;
    
    String? savedItineraryJson;
    if (key != null) {
      savedItineraryJson = prefs.getString(key);
    }

    if (savedItineraryJson != null) {
      try {
        final decoded = jsonDecode(savedItineraryJson) as Map<String, dynamic>;
        final Map<int, List<Map<String, String>>> loaded = {};
        decoded.forEach((dayStr, listRaw) {
          final day = int.tryParse(dayStr) ?? 1;
          final list = (listRaw as List).map((item) {
            return Map<String, String>.from(item as Map);
          }).toList();
          loaded[day] = list;
        });
        setState(() {
          tripData = loaded;
          _isLoading = false;
        });
        return;
      } catch (e) {
        debugPrint("Error loading saved itinerary: $e");
      }
    }

    // Ambil full 7-day data untuk kota yang dipilih
    final Map<int, List<Map<String, String>>> fullItinerary = _getItineraryForCity(widget.destinationName);
    
    // Potong data sesuai dengan daysCount yang diminta user
    final Map<int, List<Map<String, String>>> generated = {};
    for (int day = 1; day <= widget.daysCount; day++) {
      if (fullItinerary.containsKey(day)) {
        generated[day] = List<Map<String, String>>.from(
          fullItinerary[day]!.map((item) => Map<String, String>.from(item))
        );
      } else {
        // Fallback jika hari melebihi data, ambil list random/generic
        generated[day] = [
          {"time": "09.00 AM", "title": "Exploration Day", "loc": widget.destinationName, "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Lunch at Local Restaurant", "loc": widget.destinationName, "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Sunset View & Relaxing Walk", "loc": widget.destinationName, "img": "bali.jpg"},
        ];
      }
    }

    setState(() {
      tripData = generated;
      _isLoading = false;
    });

    if (key != null) {
      _saveItinerary();
    }
  }

  Future<void> _saveItinerary() async {
    if (widget.planId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'itinerary_${widget.planId}';
      
      final Map<String, dynamic> toSave = {};
      tripData.forEach((day, list) {
        toSave[day.toString()] = list;
      });
      
      await prefs.setString(key, jsonEncode(toSave));
    } catch (e) {
      debugPrint("Error saving itinerary: $e");
    }
  }

  void _deleteDestination(int index) {
    setState(() {
      tripData[selectedDay]!.removeAt(index);
    });
    _saveItinerary();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Destination deleted")),
    );
  }

  void _editDestination(int index) {
    final item = tripData[selectedDay]![index];
    final titleController = TextEditingController(text: item['title']);
    final timeController = TextEditingController(text: item['time']);
    final locController = TextEditingController(text: item['loc']);
    final currentImg = item['img'] ?? '';

    File? newPhotoFile;
    Uint8List? newPhotoBytes;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        bool isUploading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFCFAEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Edit Destination",
                style: TextStyle(
                  fontFamily: 'Chango',
                  fontSize: 18,
                  color: AppColors.deepOcean,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview gambar saat ini atau yang baru dipilih
                    Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: (kIsWeb ? newPhotoBytes != null : newPhotoFile != null)
                            ? (kIsWeb
                                ? DecorationImage(
                                    image: MemoryImage(newPhotoBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: FileImage(newPhotoFile!),
                                    fit: BoxFit.cover,
                                  ))
                            : (currentImg.isNotEmpty
                                ? DecorationImage(
                                    image: currentImg.startsWith('dest-')
                                        ? NetworkImage('${ApiService.baseUrl}/uploads/$currentImg') as ImageProvider
                                        : AssetImage('assets/images/$currentImg') as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: (newPhotoBytes == null && newPhotoFile == null && currentImg.isEmpty)
                          ? const Center(child: Icon(Icons.image, size: 40, color: Colors.grey))
                          : null,
                    ),

                    // Tombol Upload Photo
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF9E6),
                        foregroundColor: AppColors.deepOcean,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            if (kIsWeb) {
                              final bytes = await image.readAsBytes();
                              setDialogState(() {
                                newPhotoBytes = bytes;
                              });
                            } else {
                              setDialogState(() {
                                newPhotoFile = File(image.path);
                              });
                            }
                          }
                        } catch (e) {
                          debugPrint("Error picking dialog image: $e");
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Photo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 15),

                    _buildDialogField("Destination Name", titleController),
                    const SizedBox(height: 15),
                    _buildDialogField("Arrival Time", timeController),
                    const SizedBox(height: 15),
                    _buildDialogField("Location/Area", locController),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluebird,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          final newTitle = titleController.text.trim();
                          final newTime = timeController.text.trim();
                          final newLoc = locController.text.trim();

                          if (newTitle.isEmpty || newTime.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Destination and Time cannot be empty")),
                            );
                            return;
                          }

                          setDialogState(() {
                            isUploading = true;
                          });

                          // Upload if a new photo has been picked
                          String finalImg = currentImg;
                          if (kIsWeb && newPhotoBytes != null) {
                            final uploaded = await ApiService.uploadDestinationPhoto(bytes: newPhotoBytes);
                            if (uploaded != null) {
                              finalImg = uploaded;
                            }
                          } else if (newPhotoFile != null) {
                            final uploaded = await ApiService.uploadDestinationPhoto(filePath: newPhotoFile!.path);
                            if (uploaded != null) {
                              finalImg = uploaded;
                            }
                          }

                          setState(() {
                            tripData[selectedDay]![index] = {
                              ...tripData[selectedDay]![index],
                              'title': newTitle,
                              'time': newTime,
                              'loc': newLoc,
                              'img': finalImg,
                            };
                          });
                          _saveItinerary();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Destination updated")),
                          );
                        },
                  child: isUploading
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Confirm",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF10537D),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.deepOcean,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTripScheduleView();
  }

  Widget _buildTripScheduleView() {
    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: Column(
        children: [
          _buildHeader(),
          _buildDaySelector(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.bluebird),
                    )
                  : (tripData[selectedDay] == null || tripData[selectedDay]!.isEmpty
                      ? const Center(
                          child: Text(
                            "No activities scheduled for this day",
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 100),
                          itemCount: tripData[selectedDay]!.length,
                          itemBuilder: (context, index) {
                            final item = tripData[selectedDay]![index];
                            return _buildScheduleItem(
                              index,
                              index + 1,
                              item['time']!,
                              item['title']!,
                              item['loc']!,
                              item['img']!,
                            );
                          },
                        )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: Color(0xFFC7E3EA), // Warna biru header explore
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(200, 30),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // KEMBALI
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.deepOcean,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.destinationName,
                  style: const TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 22,
                    color: AppColors.deepOcean,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "A complete day-by-day guide for your next journey",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10537D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final days = tripData.keys.toList()..sort();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: days.map((day) {
            bool active = selectedDay == day;
            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.coralGlow : const Color(0xFFFEF9E6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.coralGlow.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  "Day $day",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: active
                        ? Colors.white
                        : AppColors.coralGlow.withOpacity(0.4),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    int index,
    int num,
    String time,
    String title,
    String loc,
    String img,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9E6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$num",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.deepOcean,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9E6),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepOcean,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF10537D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF10537D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _editDestination(index),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 14, color: AppColors.bluebird),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.bluebird,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _deleteDestination(index),
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: img.startsWith('dest-')
                        ? Image.network(
                            '${ApiService.baseUrl}/uploads/$img',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 65,
                                height: 65,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/$img',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 65,
                                height: 65,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DATABASE ITINERARY 7 HARI UNTUK SEMUA KOTA ---
  Map<int, List<Map<String, String>>> _getItineraryForCity(String cityName) {
    final name = cityName.toLowerCase();

    if (name.contains('thousand') || name.contains('seribu') || name.contains('jakarta')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Marina Ancol Depart", "loc": "North Jakarta", "img": "harbor.jpeg"},
          {"time": "10.00 AM", "title": "Macan Island Eco Resort", "loc": "Thousand Islands", "img": "pulauseribu.jpg"},
          {"time": "01.00 PM", "title": "Coral Snorkeling Activity", "loc": "Macan Island", "img": "manta.webp"},
          {"time": "05.00 PM", "title": "Sunset Cruise", "loc": "Thousand Islands", "img": "padar.jpeg"},
          {"time": "07.30 PM", "title": "Seafood BBQ Dinner", "loc": "Resort Beach", "img": "kmpngujung.jpeg"},
        ],
        2: [
          {"time": "08.00 AM", "title": "Kayaking Adventure", "loc": "Thousand Islands", "img": "gili.jpg"},
          {"time": "11.00 AM", "title": "Coral Sanctuary Tour", "loc": "Thousand Islands", "img": "hill.webp"},
          {"time": "02.00 PM", "title": "Island Hopping (Sepa Island)", "loc": "Thousand Islands", "img": "pulauseribu.jpg"},
          {"time": "05.00 PM", "title": "Beach Volleyball & Sunset", "loc": "Beachfront", "img": "shill.webp"},
          {"time": "08.00 PM", "title": "Bonfire Night & Music", "loc": "Eco Resort", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.30 AM", "title": "Sunrise Yoga on Beach", "loc": "Thousand Islands", "img": "rajaampat.jpg"},
          {"time": "11.00 AM", "title": "Souvenir & Local Craft Hunt", "loc": "Waisai Market", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Return Speedboat to Ancol", "loc": "Marina Ancol", "img": "harbor.jpeg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Visit Bidadari Island", "loc": "Bidadari Island", "img": "pulauseribu.jpg"},
          {"time": "12.00 PM", "title": "Lunch at Island Cafe", "loc": "Bidadari Island", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Fort Martello History Tour", "loc": "Kelor Island", "img": "puncak.webp"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Snorkeling at Puteri Island", "loc": "Puteri Island", "img": "manta.webp"},
          {"time": "01.00 PM", "title": "Undersea Tunnel Walk", "loc": "Puteri Island", "img": "sumba.webp"},
          {"time": "04.00 PM", "title": "Beachside Cycling", "loc": "Puteri Island", "img": "gili.jpg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Water Sports Session", "loc": "Sepa Island", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Lunch at Beach Canopy", "loc": "Sepa Island", "img": "food.jpg"},
          {"time": "04.30 PM", "title": "Relaxing Spa Treatment", "loc": "Macan Island", "img": "healing.webp"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Sunrise Photography Walk", "loc": "Thousand Islands", "img": "padar.jpeg"},
          {"time": "11.00 AM", "title": "Check-out & Farewell Lunch", "loc": "Macan Island", "img": "food.jpg"},
          {"time": "02.00 PM", "title": "Speedboat back to Jakarta Marina", "loc": "Marina Ancol", "img": "harbor.jpeg"},
        ],
      };
    } else if (name.contains('malioboro') || name.contains('yogyakarta') || name.contains('jogja') || name.contains('tempo gelato')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Gudeg Yu Djum Breakfast", "loc": "Wijilan, Yogyakarta", "img": "food.jpg"},
          {"time": "10.00 AM", "title": "Keraton Yogyakarta", "loc": "Sultan Palace", "img": "malioboro.jpg"},
          {"time": "01.00 PM", "title": "Taman Sari Water Castle", "loc": "Patehan, Yogyakarta", "img": "malioboro.jpg"},
          {"time": "04.00 PM", "title": "Fort Vredeburg Museum", "loc": "Malioboro", "img": "malioboro.jpg"},
          {"time": "06.00 PM", "title": "Sunset Walk Malioboro Street", "loc": "Yogyakarta", "img": "malioboro.jpg"},
          {"time": "08.00 PM", "title": "Charcoal Coffee Lik Man", "loc": "Tugu Station", "img": "tempogelato.jpg"},
        ],
        2: [
          {"time": "08.00 AM", "title": "Prambanan Temple Tour", "loc": "Sleman, Yogyakarta", "img": "malioboro.jpg"},
          {"time": "12.00 PM", "title": "Lunch at Kopi Klotok", "loc": "Kaliurang, Yogyakarta", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Pine Forest Mangunan", "loc": "Bantul, Yogyakarta", "img": "adventure.jpg"},
          {"time": "05.00 PM", "title": "Parangtritis Beach Sunset", "loc": "Bantul, Yogyakarta", "img": "tempogelato.jpg"},
          {"time": "07.30 PM", "title": "Dinner at House of Raminten", "loc": "Kota Baru", "img": "tempogelato.jpg"},
        ],
        3: [
          {"time": "04.30 AM", "title": "Sunrise Borobudur Temple", "loc": "Magelang", "img": "malioboro.jpg"},
          {"time": "09.00 AM", "title": "Mount Merapi Lava Tour (Jeep)", "loc": "Kaliurang", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Tempo Gelato Dessert", "loc": "Prawirotaman", "img": "tempogelato.jpg"},
          {"time": "03.00 PM", "title": "Yogyakarta Tugu (Departure)", "loc": "Yogyakarta", "img": "tempogelato.jpg"},
        ],
        4: [
          {"time": "08.30 AM", "title": "Walk through Beringharjo Market", "loc": "Malioboro", "img": "malioboro.jpg"},
          {"time": "11.30 AM", "title": "Lunch at Selasar Kartika", "loc": "Yogyakarta", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Museum Ullen Sentalu", "loc": "Kaliurang", "img": "adventure.jpg"},
          {"time": "06.00 PM", "title": "Mangkubumi Evening Coffee", "loc": "Yogyakarta", "img": "tempogelato.jpg"},
        ],
        5: [
          {"time": "09.00 AM", "title": "Affandi Art Museum", "loc": "Yogyakarta", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Local Bakpia Making Class", "loc": "Pathok, Yogyakarta", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Sunset at Ratu Boko Palace", "loc": "Sleman", "img": "malioboro.jpg"},
          {"time": "07.30 PM", "title": "Dinner with Ramayana Ballet", "loc": "Prambanan", "img": "atlantis.jpeg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Hiking at Nglanggeran Volcano", "loc": "Gunungkidul", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Swim at Drini Beach", "loc": "Gunungkidul", "img": "bali.jpg"},
          {"time": "05.00 PM", "title": "Heha Sky View Sunset", "loc": "Gunungkidul", "img": "tempogelato.jpg"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Taman Pintar Science Center", "loc": "Yogyakarta", "img": "adventure.jpg"},
          {"time": "11.30 AM", "title": "Batik Shopping Kotagede", "loc": "Yogyakarta", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Tugu Station (Final Departure)", "loc": "Yogyakarta", "img": "tempogelato.jpg"},
        ],
      };
    } else if (name.contains('gili') || name.contains('lombok')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Bangsal Harbor Depart", "loc": "North Lombok", "img": "harbor.jpeg"},
          {"time": "10.00 AM", "title": "Bicycle Rental & Island Tour", "loc": "Gili Trawangan", "img": "gili.jpg"},
          {"time": "01.00 PM", "title": "Snorkeling with Sea Turtles", "loc": "Gili Trawangan", "img": "manta.webp"},
          {"time": "05.00 PM", "title": "Sunset Swing Ombak Sunset", "loc": "Gili Trawangan", "img": "gili.jpg"},
          {"time": "07.30 PM", "title": "Gili Trawangan Night Market", "loc": "Gili Trawangan", "img": "kmpngujung.jpeg"},
        ],
        2: [
          {"time": "08.00 AM", "title": "Scuba Diving at Meno Wall", "loc": "Gili Meno", "img": "manta.webp"},
          {"time": "11.30 AM", "title": "Gili Meno Lake & Sanctuary", "loc": "Gili Meno", "img": "gili.jpg"},
          {"time": "02.00 PM", "title": "Island Hopping Gili Air", "loc": "Gili Air", "img": "gili.jpg"},
          {"time": "05.30 PM", "title": "Sunset Yoga on Beach", "loc": "Gili Air", "img": "gili.jpg"},
          {"time": "07.30 PM", "title": "Beachfront Seafood Dinner", "loc": "Gili Air", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.30 AM", "title": "Paddleboarding at Sunrise", "loc": "Gili Trawangan", "img": "gili.jpg"},
          {"time": "11.00 AM", "title": "Souvenir & T-Shirt Shopping", "loc": "Art Shop", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Public Boat to Lombok Mainland", "loc": "Bangsal Harbor", "img": "harbor.jpeg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Kuta Beach Lombok Walk", "loc": "South Lombok", "img": "bali.jpg"},
          {"time": "12.00 PM", "title": "Lunch at local Sasak cafe", "loc": "Kuta Lombok", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Sade Traditional Sasak Village", "loc": "Lombok", "img": "sumba.webp"},
          {"time": "06.00 PM", "title": "Sunset at Merese Hill", "loc": "South Lombok", "img": "hill.webp"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Benang Stokel Waterfall", "loc": "Central Lombok", "img": "lembahharau.jpg"},
          {"time": "11.00 AM", "title": "Benang Kelambu Waterfall Walk", "loc": "Central Lombok", "img": "lembahharau.jpg"},
          {"time": "02.30 PM", "title": "Sukarara Weaving Village", "loc": "Central Lombok", "img": "souvenir.webp"},
          {"time": "06.00 PM", "title": "Senggigi Beach Sunset walk", "loc": "West Lombok", "img": "padar.jpeg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Surfing Lesson at Selong Belanak", "loc": "South Lombok", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Lunch at Beachside warung", "loc": "Selong Belanak", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Mawun Beach relaxing swim", "loc": "South Lombok", "img": "gili.jpg"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Sunrise at Sembalun Valley", "loc": "Mount Rinjani Foot", "img": "puncak.webp"},
          {"time": "12.00 PM", "title": "Soto Lombok Lunch", "loc": "Mataram", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Lombok International Airport (Departure)", "loc": "South Lombok", "img": "airport.jpg"},
        ],
      };
    } else if (name.contains('sumba')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Tambolaka Airport Arrival", "loc": "Southwest Sumba", "img": "airport.jpg"},
          {"time": "10.30 AM", "title": "Weekuri Lagoon (Swimming)", "loc": "Southwest Sumba", "img": "sumba.webp"},
          {"time": "01.30 PM", "title": "Mandorak Beach Exploration", "loc": "Southwest Sumba", "img": "sumba.webp"},
          {"time": "04.30 PM", "title": "Sunset at Bukit Lendongara", "loc": "Southwest Sumba", "img": "sumba.webp"},
          {"time": "07.30 PM", "title": "Traditional Dinner at Resort", "loc": "Resort", "img": "atlantis.jpeg"},
        ],
        2: [
          {"time": "08.30 AM", "title": "Ratenggaro Traditional Village", "loc": "Southwest Sumba", "img": "sumba.webp"},
          {"time": "12.00 PM", "title": "Lunch at Pero Beach", "loc": "Southwest Sumba", "img": "sumba.webp"},
          {"time": "02.30 PM", "title": "Lapopu Waterfall Hike", "loc": "Central Sumba", "img": "sumba.webp"},
          {"time": "05.30 PM", "title": "Walakiri Beach Dancing Trees", "loc": "East Sumba", "img": "sumba.webp"},
          {"time": "08.00 PM", "title": "Stargazing at Bukit Tenau", "loc": "East Sumba", "img": "sumba.webp"},
        ],
        3: [
          {"time": "08.00 AM", "title": "Bukit Wairinding Sunrise", "loc": "East Sumba", "img": "sumba.webp"},
          {"time": "11.00 AM", "title": "Ikat Weaving Center Visit", "loc": "Waingapu", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Departure Waingapu Airport", "loc": "Waingapu", "img": "airport.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Bukit Tanarara Savanna Hill", "loc": "East Sumba", "img": "sumba.webp"},
          {"time": "12.00 PM", "title": "Lunch at Waingapu Local Resto", "loc": "Waingapu", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Londa Lima Beach relax", "loc": "East Sumba", "img": "bali.jpg"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Tanggedu Waterfall trek", "loc": "East Sumba", "img": "lembahharau.jpg"},
          {"time": "01.00 PM", "title": "Picnic Lunch at Tanggedu", "loc": "Tanggedu", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Sunset at Puru Kambera Beach", "loc": "East Sumba", "img": "sumba.webp"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Kampung Tarung Cultural Visit", "loc": "Waikabubak", "img": "sumba.webp"},
          {"time": "01.00 PM", "title": "Lunch at Waikabubak Town", "loc": "West Sumba", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Praigi Waterfall swim", "loc": "West Sumba", "img": "lembahharau.jpg"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Kodi Traditional Market walk", "loc": "Southwest Sumba", "img": "souvenir.webp"},
          {"time": "11.00 AM", "title": "Check-out Waingapu Hotel", "loc": "Waingapu", "img": "food.jpg"},
          {"time": "01.30 PM", "title": "Waingapu Airport departure", "loc": "Waingapu", "img": "airport.jpg"},
        ],
      };
    } else if (name.contains('bali') || name.contains('ubud') || name.contains('sunday market') || name.contains('gigi susu')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Gigi Susu Bali Bakery", "loc": "Ubud, Bali", "img": "gigisusu.jpg"},
          {"time": "10.00 AM", "title": "Sacred Monkey Forest", "loc": "Ubud, Bali", "img": "bali.jpg"},
          {"time": "01.00 PM", "title": "Ubud Palace & Art Market", "loc": "Ubud, Bali", "img": "bali.jpg"},
          {"time": "03.30 PM", "title": "Campuhan Ridge Walk", "loc": "Ubud, Bali", "img": "bali.jpg"},
          {"time": "06.00 PM", "title": "Balinese Dance Show", "loc": "Ubud Palace", "img": "bali.jpg"},
          {"time": "08.00 PM", "title": "Dinner at Bebek Bengil", "loc": "Ubud, Bali", "img": "food.jpg"},
        ],
        2: [
          {"time": "08.00 AM", "title": "Tegalalang Rice Terrace", "loc": "Ubud, Bali", "img": "bali.jpg"},
          {"time": "11.00 AM", "title": "Tirta Empul Holy Water Temple", "loc": "Ubud, Bali", "img": "bali.jpg"},
          {"time": "01.30 PM", "title": "Lunch with Batur Volcano View", "loc": "Kintamani, Bali", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Tegenungan Waterfall", "loc": "Gianyar, Bali", "img": "bali.jpg"},
          {"time": "06.00 PM", "title": "Sunday Market Crafts Hunt", "loc": "Ubud, Bali", "img": "sundaymarket.jpg"},
          {"time": "08.00 PM", "title": "Fine Dining at Locavore", "loc": "Ubud, Bali", "img": "food.jpg"},
        ],
        3: [
          {"time": "08.30 AM", "title": "Balinese Cooking Class", "loc": "Ubud Village", "img": "food.jpg"},
          {"time": "01.00 PM", "title": "Traditional Spa and Massage", "loc": "Ubud Spa", "img": "healing.webp"},
          {"time": "04.00 PM", "title": "Souvenir & Coffee Shopping", "loc": "Ubud Art Center", "img": "souvenir.webp"},
          {"time": "06.00 PM", "title": "Head to Hotel in Kuta/Seminyak", "loc": "Kuta, Bali", "img": "airport.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Kuta Beach Surfing Lesson", "loc": "Kuta Beach", "img": "adventure.jpg"},
          {"time": "12.30 PM", "title": "Lunch at Seminyak Local Cafe", "loc": "Seminyak", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Pura Tanah Lot Sunset View", "loc": "Tanah Lot", "img": "bali.jpg"},
          {"time": "07.30 PM", "title": "Seafood BBQ dinner", "loc": "Jimbaran Bay", "img": "kmpngujung.jpeg"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Sanur Beach Sunrise walk", "loc": "Sanur", "img": "harbor.jpeg"},
          {"time": "10.00 AM", "title": "Fast Boat to Nusa Penida", "loc": "Sanur Harbor", "img": "harbor.jpeg"},
          {"time": "11.30 AM", "title": "Kelingking Beach Iconic Cliff", "loc": "Nusa Penida", "img": "bali.jpg"},
          {"time": "03.00 PM", "title": "Broken Beach & Angel Billabong", "loc": "Nusa Penida", "img": "rajaampat.jpg"},
          {"time": "05.30 PM", "title": "Sunset at Crystal Bay", "loc": "Nusa Penida", "img": "rajaampatsunset.jpg"},
        ],
        6: [
          {"time": "08.30 AM", "title": "Snorkeling at Manta Point", "loc": "Nusa Penida", "img": "manta.webp"},
          {"time": "12.00 PM", "title": "Local Grilled Fish Lunch", "loc": "Nusa Penida", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Return Fast Boat to Sanur", "loc": "Sanur Harbor", "img": "harbor.jpeg"},
          {"time": "05.00 PM", "title": "Pura Uluwatu Kecak Dance Show", "loc": "Uluwatu", "img": "bali.jpg"},
        ],
        7: [
          {"time": "09.00 AM", "title": "Morning Swim at Seminyak Beach", "loc": "Seminyak", "img": "gili.jpg"},
          {"time": "11.30 AM", "title": "Souvenir Shopping Krisna Bali", "loc": "Denpasar", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Denpasar Airport Departure", "loc": "Kuta, Bali", "img": "airport.jpg"},
        ],
      };
    } else if (name.contains('raja ampat')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Sorong Harbor (Ferry to Waisai)", "loc": "Sorong Gateway", "img": "harbor.jpeg"},
          {"time": "11.00 AM", "title": "Check-in Homestay", "loc": "Waisai, Raja Ampat", "img": "rajaampat.jpg"},
          {"time": "02.00 PM", "title": "Snorkeling at Friwen Wall", "loc": "Friwen Island", "img": "manta.webp"},
          {"time": "05.00 PM", "title": "Raja Ampat Sunset Point", "loc": "Waisai", "img": "rajaampatsunset.jpg"},
          {"time": "07.30 PM", "title": "Fresh Fish BBQ Dinner", "loc": "Homestay Beach", "img": "kmpngujung.jpeg"},
        ],
        2: [
          {"time": "07.00 AM", "title": "Wayag Island Hike", "loc": "Wayag Archipelago", "img": "rajaampat.jpg"},
          {"time": "12.00 PM", "title": "Picnic Lunch on Wayag Beach", "loc": "Wayag Beach", "img": "rajaampat.jpg"},
          {"time": "02.30 PM", "title": "Swim with Baby Blacktip Sharks", "loc": "Wayag Shore", "img": "manta.webp"},
          {"time": "05.00 PM", "title": "Sunset Cruise & Dolphin Watch", "loc": "Raja Ampat Seas", "img": "rajaampatsunset.jpg"},
          {"time": "08.00 PM", "title": "Local Music & Bonfire Night", "loc": "Homestay", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.00 AM", "title": "Piaynemo Viewpoint Climb", "loc": "Piaynemo Island", "img": "rajaampat.jpg"},
          {"time": "11.00 AM", "title": "Sauwandarek Village Walk", "loc": "Sauwandarek", "img": "rajaampat.jpg"},
          {"time": "02.00 PM", "title": "Ferry Ride back to Sorong", "loc": "Waisai Harbor", "img": "harbor.jpeg"},
        ],
        4: [
          {"time": "08.30 AM", "title": "Bird Watching (Red Bird of Paradise)", "loc": "Sawinggrai Village", "img": "adventure.jpg"},
          {"time": "11.30 AM", "title": "Local village lunch experience", "loc": "Sawinggrai", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Snorkeling under Sawinggrai Pier", "loc": "Sawinggrai", "img": "manta.webp"},
        ],
        5: [
          {"time": "09.00 AM", "title": "Explore Pasir Timbul (Sandbar)", "loc": "Raja Ampat", "img": "taka.jpeg"},
          {"time": "12.00 PM", "title": "Lunch at Friwen Homestay", "loc": "Friwen Island", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Relaxing afternoon at Friwen Beach", "loc": "Friwen Island", "img": "rajaampat.jpg"},
        ],
        6: [
          {"time": "08.30 AM", "title": "Snorkeling at Cape Kri (Top Marine Spot)", "loc": "Kri Island", "img": "manta.webp"},
          {"time": "01.00 PM", "title": "Lunch at Kri Island eco cabin", "loc": "Kri Island", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Sunset kayaking around homestay", "loc": "Kri Island", "img": "rajaampatsunset.jpg"},
        ],
        7: [
          {"time": "08.00 AM", "title": "Pack up & Sorong public boat", "loc": "Waisai Harbor", "img": "harbor.jpeg"},
          {"time": "11.30 AM", "title": "Local culinary lunch in Sorong", "loc": "Sorong", "img": "food.jpg"},
          {"time": "01.30 PM", "title": "Sorong Airport (Final Departure)", "loc": "Sorong", "img": "airport.jpg"},
        ],
      };
    } else if (name.contains('pangalengan') || name.contains('bandung')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Breakfast at Tjiboeni Coffee", "loc": "Pangalengan", "img": "food.jpg"},
          {"time": "10.00 AM", "title": "Cukul Tea Plantation Sunrise", "loc": "Cukul Hill", "img": "pangalenganrafting.jpg"},
          {"time": "01.00 PM", "title": "Pangalengan River Rafting", "loc": "Palayangan River", "img": "pangalenganrafting.jpg"},
          {"time": "04.00 PM", "title": "Situ Cileunca Lakeside Relax", "loc": "Situ Cileunca", "img": "pangalenganrafting.jpg"},
          {"time": "07.00 PM", "title": "Dinner at Mountain Cabin", "loc": "Pangalengan Cabin", "img": "atlantis.jpeg"},
        ],
        2: [
          {"time": "08.30 AM", "title": "Wayang Windu Panenjoan Skywalk", "loc": "Wayang Windu", "img": "pangalenganrafting.jpg"},
          {"time": "12.00 PM", "title": "Lunch at local Sundanese resto", "loc": "Pangalengan", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Pine Forest Rahong Camp", "loc": "Rahong Forest", "img": "adventure.jpg"},
          {"time": "05.00 PM", "title": "Sunset hike at Cukul Hill", "loc": "Pangalengan", "img": "pangalenganrafting.jpg"},
          {"time": "08.00 PM", "title": "Stargazing & Campfire Session", "loc": "Pine Forest Camp", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.00 AM", "title": "Strawberry Picking Tour", "loc": "Pangalengan Farms", "img": "food.jpg"},
          {"time": "10.30 AM", "title": "Souvenir Shop (Kartika Sari)", "loc": "Bandung City", "img": "souvenir.webp"},
          {"time": "01.00 PM", "title": "Return to Bandung Train Station", "loc": "Bandung", "img": "tempogelato.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Tangkuban Perahu Crater Tour", "loc": "Lembang, Bandung", "img": "adventure.jpg"},
          {"time": "12.30 PM", "title": "Lunch at Sindang Reret Lembang", "loc": "Lembang", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Floating Market Lembang walk", "loc": "Lembang", "img": "pangalenganrafting.jpg"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Dusun Bambu Eco Green Park", "loc": "Lembang", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Lunch by the Lembang lake", "loc": "Lembang", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Farm House Lembang visit", "loc": "Lembang", "img": "pangalenganrafting.jpg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Walk through Braga historical street", "loc": "Bandung City", "img": "malioboro.jpg"},
          {"time": "12.00 PM", "title": "Lunch at Braga Permai Cafe", "loc": "Jalan Braga", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Saung Angklung Udjo Performance", "loc": "Padasuka, Bandung", "img": "adventure.jpg"},
        ],
        7: [
          {"time": "09.00 AM", "title": "Factory Outlet Shopping", "loc": "Jalan Riau, Bandung", "img": "souvenir.webp"},
          {"time": "12.00 PM", "title": "Lunch at Kartika Sari cafe", "loc": "Bandung", "img": "food.jpg"},
          {"time": "02.00 PM", "title": "Bandung Train Station Departure", "loc": "Bandung", "img": "tempogelato.jpg"},
        ],
      };
    } else if (name.contains('dieng') || name.contains('sikunir')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Wonosobo Mie Ongklok Breakfast", "loc": "Dieng Plateau", "img": "food.jpg"},
          {"time": "10.00 AM", "title": "Arjuna Temple Complex Walk", "loc": "Dieng Temple", "img": "bukitsikunir.jpg"},
          {"time": "01.00 PM", "title": "Sikidang Geothermal Crater", "loc": "Sikidang", "img": "bukitsikunir.jpg"},
          {"time": "04.30 PM", "title": "Sunset at Telaga Warna Lake", "loc": "Telaga Warna", "img": "bukitsikunir.jpg"},
          {"time": "07.00 PM", "title": "Dinner near Dieng Plateau", "loc": "Dieng Town", "img": "kmpngujung.jpeg"},
        ],
        2: [
          {"time": "04.00 AM", "title": "Bukit Sikunir Sunrise Hike", "loc": "Sikunir Hill", "img": "bukitsikunir.jpg"},
          {"time": "08.00 AM", "title": "Breakfast at Sikunir Basecamp", "loc": "Sikunir Camp", "img": "food.jpg"},
          {"time": "11.00 AM", "title": "Batu Pandang View Point Climb", "loc": "Ratapan Angin", "img": "bukitsikunir.jpg"},
          {"time": "02.00 PM", "title": "Dieng Plateau Theater Movie", "loc": "Theater Center", "img": "bukitsikunir.jpg"},
          {"time": "05.00 PM", "title": "Sunset at Bukit Sidengkeng", "loc": "Sidengkeng", "img": "bukitsikunir.jpg"},
          {"time": "08.00 PM", "title": "Warm Tea & local Carica fruits", "loc": "Wonosobo Hotel", "img": "tempogelato.jpg"},
        ],
        3: [
          {"time": "08.30 AM", "title": "Telaga Pengilon Scenic Walk", "loc": "Telaga Pengilon", "img": "bukitsikunir.jpg"},
          {"time": "11.00 AM", "title": "Carica Fruit Pack Souvenirs", "loc": "Dieng Shop", "img": "souvenir.webp"},
          {"time": "01.00 PM", "title": "Departure back to Wonosobo Town", "loc": "Wonosobo", "img": "tempogelato.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Explore Mount Prau Basecamp", "loc": "Patakbanteng", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Lunch at local home restaurant", "loc": "Dieng", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Visit Telaga Menjer Lake", "loc": "Garung, Wonosobo", "img": "bukitsikunir.jpg"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Trekking in Tieng Viewing Post", "loc": "Kejajar, Wonosobo", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Lunch with Mountain Sumbing View", "loc": "Tieng", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Relax at Tambi Tea Garden", "loc": "Tambi", "img": "bukitsikunir.jpg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Explore Dringo Lake (The Highest)", "loc": "Dieng Plateau", "img": "bukitsikunir.jpg"},
          {"time": "01.00 PM", "title": "Lunch in Dieng central area", "loc": "Dieng", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Sirawe Hot Springs soak", "loc": "Dieng", "img": "healing.webp"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Morning walks in Wonosobo Town Square", "loc": "Wonosobo", "img": "adventure.jpg"},
          {"time": "11.00 AM", "title": "Buy local Carica & Tempe Kemul", "loc": "Wonosobo Shop", "img": "souvenir.webp"},
          {"time": "01.30 PM", "title": "Departure from Wonosobo", "loc": "Wonosobo", "img": "tempogelato.jpg"},
        ],
      };
    } else if (name.contains('harau') || name.contains('sumatra')) {
      return {
        1: [
          {"time": "08.00 AM", "title": "Arrival Minangkabau Airport", "loc": "Padang Gateway", "img": "airport.jpg"},
          {"time": "10.30 AM", "title": "Scenic Drive to Lembah Harau", "loc": "West Sumatra", "img": "lembahharau.jpg"},
          {"time": "01.00 PM", "title": "Check-in Harau Eco Homestay", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "03.30 PM", "title": "Harau Valley Cliffs Hike", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "06.00 PM", "title": "Sunset at Harau Canyon", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "08.00 PM", "title": "Traditional Padang Rice Dinner", "loc": "Homestay Resto", "img": "food.jpg"},
        ],
        2: [
          {"time": "08.30 AM", "title": "Sarasah Bunta Waterfall Hop", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "12.00 PM", "title": "Picnic Lunch inside Canyon", "loc": "Harau Canyon", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Rock Climbing / Valley Trekking", "loc": "Lembah Harau", "img": "adventure.jpg"},
          {"time": "05.30 PM", "title": "Sunset Walk through Rice Fields", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "08.00 PM", "title": "Minang Cultural Storytelling", "loc": "Eco Lodge", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.00 AM", "title": "Harau Viewpoint Sunrise Hike", "loc": "Lembah Harau", "img": "lembahharau.jpg"},
          {"time": "11.00 AM", "title": "Keripik Sanjai Spicy Chips Shop", "loc": "Payakumbuh", "img": "souvenir.webp"},
          {"time": "02.00 PM", "title": "Head back to Padang Airport", "loc": "Padang", "img": "airport.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Explore Kelok 9 Flyover Bridge", "loc": "Payakumbuh", "img": "adventure.jpg"},
          {"time": "12.30 PM", "title": "Lunch at Sate Padang shop", "loc": "Payakumbuh", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Visit Ngalau Indah Cave", "loc": "Payakumbuh", "img": "lembahharau.jpg"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Bukittinggi City Tour (Jam Gadang)", "loc": "Bukittinggi", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Lunch at Nasi Kapau Bukittinggi", "loc": "Bukittinggi", "img": "food.jpg"},
          {"time": "02.30 PM", "title": "Explore Lobang Jepang (Japanese Cave)", "loc": "Bukittinggi", "img": "lembahharau.jpg"},
          {"time": "04.30 PM", "title": "Ngarai Sianok Panoramic walk", "loc": "Bukittinggi", "img": "lembahharau.jpg"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Lake Maninjau Panoramic Drive", "loc": "Agam, West Sumatra", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Lunch at lakeside cafe", "loc": "Lake Maninjau", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Visit Puncak Lawang viewpoint", "loc": "Agam", "img": "lembahharau.jpg"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Istano Basa Pagaruyung Palace", "loc": "Batusangkar", "img": "adventure.jpg"},
          {"time": "12.00 PM", "title": "Bika Padang traditional dessert", "loc": "Padang Panjang", "img": "food.jpg"},
          {"time": "03.00 PM", "title": "Minangkabau Airport departure", "loc": "Padang", "img": "airport.jpg"},
        ],
      };
    } else {
      // Default: Labuan Bajo
      return {
        1: [
          {"time": "08.00 AM", "title": "Komodough Breakfast", "loc": "Soekarno Hatta, Labuan Bajo", "img": "komodough.webp"},
          {"time": "10.00 AM", "title": "Exotic Komodo Souvenir Shop", "loc": "Yohanis Sahadun, Labuan Bajo", "img": "souvenir.webp"},
          {"time": "12.30 AM", "title": "Carpenter Café & Roastery", "loc": "Soekarno Hatta, Labuan Bajo", "img": "carpenter.jpeg"},
          {"time": "03.00 PM", "title": "Puncak Waringin Lookout", "loc": "Komodo, Labuan Bajo", "img": "puncak.webp"},
          {"time": "05.30 PM", "title": "Amelia Hill Sunset Point", "loc": "Komodo, Labuan Bajo", "img": "hill.webp"},
          {"time": "07.30 PM", "title": "Kampung Ujung Seafood Dinner", "loc": "Soekarno Hatta, Labuan Bajo", "img": "kmpngujung.jpeg"},
        ],
        2: [
          {"time": "06.30 AM", "title": "Labuan Bajo Harbor Depart", "loc": "Marina Waterfront, Labuan Bajo", "img": "harbor.jpeg"},
          {"time": "08.00 AM", "title": "Padar Island Trekking", "loc": "Komodo National Park", "img": "padar.jpeg"},
          {"time": "10.30 PM", "title": "Pink Beach Snorkeling", "loc": "Komodo National Park", "img": "pinkb.jpeg"},
          {"time": "01.00 PM", "title": "Komodo Island Ranger Tour", "loc": "Komodo National Park", "img": "komodo.jpeg"},
          {"time": "03.30 PM", "title": "Taka Makassar Sandbar visit", "loc": "Komodo National Park", "img": "taka.jpeg"},
          {"time": "05.00 PM", "title": "Manta Point Drift Dive", "loc": "Komodo National Park", "img": "manta.webp"},
          {"time": "07.30 PM", "title": "Atlantis on The Rock Dinner", "loc": "Komodo, Labuan Bajo", "img": "atlantis.jpeg"},
        ],
        3: [
          {"time": "08.30 AM", "title": "Le Pirate Restaurant & Cafe", "loc": "Komodo, Labuan Bajo", "img": "lepirate.avif"},
          {"time": "10.00 AM", "title": "Sylvia Hill Trekking", "loc": "Komodo, Labuan Bajo", "img": "shill.webp"},
          {"time": "12.30 PM", "title": "Sei Sapi Lejong Lunch", "loc": "Yohanis Sahadun, Labuan Bajo", "img": "sei.webp"},
          {"time": "03.00 PM", "title": "Waterfront Marina Walk", "loc": "Soekarno Hatta, Labuan Bajo", "img": "marina.jpeg"},
          {"time": "05.30 PM", "title": "Komodo International Airport", "loc": "Komodo, Labuan Bajo", "img": "airport.jpg"},
        ],
        4: [
          {"time": "09.00 AM", "title": "Boat trip to Rinca Island", "loc": "Komodo National Park", "img": "komodo.jpeg"},
          {"time": "12.30 PM", "title": "Lunch on the boat deck", "loc": "Rinca Waters", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Explore Kalong Island Sunset", "loc": "Komodo National Park", "img": "hill.webp"},
        ],
        5: [
          {"time": "08.30 AM", "title": "Cunca Wulang Canyon Waterfall", "loc": "Mbeliling Forest", "img": "lembahharau.jpg"},
          {"time": "01.00 PM", "title": "Lunch in forest campsite", "loc": "Mbeliling", "img": "food.jpg"},
          {"time": "03.30 PM", "title": "Gua Rangko Cave swimming", "loc": "Labuan Bajo North", "img": "manta.webp"},
        ],
        6: [
          {"time": "09.00 AM", "title": "Trekking in Liang Bua Cave", "loc": "Ruteng, Flores", "img": "adventure.jpg"},
          {"time": "01.00 PM", "title": "Lunch at Ruteng local restaurant", "loc": "Ruteng", "img": "food.jpg"},
          {"time": "04.00 PM", "title": "Sunset View over Spiderweb Rice Fields", "loc": "Cancar", "img": "puncak.webp"},
        ],
        7: [
          {"time": "08.30 AM", "title": "Wae Rebo Traditional Village hike", "loc": "Manggarai, Flores", "img": "sumba.webp"},
          {"time": "12.00 PM", "title": "Lunch inside Mbaru Niang traditional house", "loc": "Wae Rebo", "img": "food.jpg"},
          {"time": "02.00 PM", "title": "Waerebo village departure", "loc": "Flores", "img": "airport.jpg"},
        ],
      };
    }
  }
}
