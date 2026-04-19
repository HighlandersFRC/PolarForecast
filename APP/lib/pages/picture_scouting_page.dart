import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../widgets/camera_capture/camera_capture_service.dart';
import '../models/tournament.dart';
import 'not_found_page.dart';

Uint8List encodeImageToJpg(img.Image image) {
  return Uint8List.fromList(img.encodeJpg(image));
}

extension GalleryImage on CameraCaptureService {
  Future<img.Image?> pickImageFromGallery(BuildContext context) async {
    return null;
  }
}

class PictureScoutingPage extends StatefulWidget {
  final String eventCode;
  final int team;

  PictureScoutingPage({required this.eventCode, required this.team});

  static Widget fromKeys(
      BuildContext context, String eventKey, String teamKey) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tournaments = apiService.fetchTournaments();
    return FutureBuilder(
      future: tournaments,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return NotFoundPage();

        Tournament? tournament;
        try {
          for (final _tournament in snapshot.data!) {
            if (_tournament.key == eventKey) {
              tournament = _tournament;
              break;
            }
          }
          if (tournament == null) return NotFoundPage();

          return PictureScoutingPage(
            team: int.parse(teamKey.substring(3)),
            eventCode: tournament.key,
          );
        } catch (error) {
          return NotFoundPage();
        }
      },
    );
  }

  @override
  _PictureScoutingPageState createState() => _PictureScoutingPageState();
}

class _PictureScoutingPageState extends State<PictureScoutingPage> {
  final List<String> _sections = [
    'full_robot',
    'shooter',
    'intake',
    'feeder',
    'wires'
  ];
  late Map<String, List<Uint8List?>> _sectionEncodedImages;
  late Map<String, List<bool>> _sectionUploading;
  late Map<String, bool> _capturing;
  List<PictureData> _takenPictures = [];
  final Map<String, String> teamNames = {};

  @override
  void initState() {
    super.initState();
    _sectionEncodedImages = {for (var section in _sections) section: []};
    _sectionUploading = {for (var section in _sections) section: []};
    _capturing = {for (var section in _sections) section: false};
    _fetchTeamNumber(widget.team.toString());
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService
        .fetchTeamImages(
      int.parse(widget.eventCode.substring(0, 4)),
      widget.eventCode.substring(4),
      'frc${widget.team}',
    )
        .then((_pictures) {
      if (mounted)
        setState(() {
          _takenPictures = _pictures;
        });
      _takenPictures = _pictures;
    });
  }

  Future<void> _fetchTeamNumber(String teamNumber) async {
    if (teamNames.containsKey(teamNumber)) return;
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final nickname = await apiService.fetchTeamNicknames('frc$teamNumber');
      if (mounted) {
        setState(() {
          teamNames[teamNumber] = nickname;
        });
      }
    } catch (e) {}
  }

  Future<void> _showImageSourceActionSheet(String section) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title:
                    Text('Take Picture', style: TextStyle(fontFamily: 'Font')),
                onTap: () {
                  Navigator.of(context).pop();
                  _captureImage(section);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title:
                    Text('From Gallery', style: TextStyle(fontFamily: 'Font')),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(section);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureImage(String section) async {
    final cameraCaptureService = createCameraCaptureService();
    setState(() {
      _capturing[section] = true;
    });
    var image = await cameraCaptureService.getImage(context);
    setState(() {
      if (image != null) _sectionEncodedImages[section]!.add(image);
      _sectionUploading[section]!.add(false);
      _capturing[section] = false;
    });
  }

  Future<void> _pickImage(String section) async {
    final cameraCaptureService = createCameraCaptureService();
    setState(() {
      _capturing[section] = true;
    });
    final image = await cameraCaptureService.pickImageFromGallery(context);
    setState(() {
      if (image != null) _sectionEncodedImages[section]!.add(image);
      _sectionUploading[section]!.add(false);
      _capturing[section] = false;
    });
  }

  void _removeImage(String section, int index) {
    setState(() {
      _sectionEncodedImages[section]!.removeAt(index);
      _sectionUploading[section]!.removeAt(index);
    });
  }

  Future<void> _uploadImage(String section, int index) async {
    setState(() {
      _sectionUploading[section]![index] = true;
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.post_image(
        _sectionEncodedImages[section]![index]!,
        widget.eventCode,
        widget.team,
        section,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$section Image ${index + 1} uploaded successfully',
              style: TextStyle(fontFamily: 'Font')),
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('<?xml') || errorMessage.contains('<Error>')) {
        errorMessage = 'An error occurred while uploading. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to upload $section Image ${index + 1}: $errorMessage',
              style: TextStyle(fontFamily: 'Font')),
        ),
      );
    } finally {
      setState(() {
        _sectionUploading[section]![index] = false;
      });
    }
  }

  Future<void> _uploadAllImages() async {
    for (String section in _sections) {
      for (int i = 0; i < _sectionEncodedImages[section]!.length; i++) {
        if (!_sectionUploading[section]![i]) {
          await _uploadImage(section, i);
        }
      }
    }
  }

  Widget _buildImageCard(String section, int index) {
    final bytes = _sectionEncodedImages[section]![index];
    final uploading = _sectionUploading[section]![index];

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.memory(
                bytes!,
                fit: BoxFit.cover,
              ),
            ),

            // 🔥 Delete button
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => _removeImage(section, index),
                ),
              ),
            ),

            // 🔥 Upload overlay
            if (uploading)
              Container(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImageCard(PictureData picture) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                picture.link,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  picture.scout_info.first_name ??
                      "Scout ${picture.scout_info.team_number}",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(String section) {
    return GestureDetector(
      onTap: !_capturing[section]!
          ? () => _showImageSourceActionSheet(section)
          : null,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Center(
          child: _capturing[section]!
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "Add Image",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSection(String section) {
    List<Widget> cards = [];

    for (final picture in _takenPictures) {
      if (picture.image_type == section) {
        cards.add(_buildNetworkImageCard(picture));
      }
    }

    for (int i = 0; i < _sectionEncodedImages[section]!.length; i++) {
      cards.add(_buildImageCard(section, i));
    }

    // ➕ Add card
    cards.add(_buildAddCard(section));

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Section Chip Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              section.replaceAll("_", " ").toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ),

          SizedBox(height: 12),

          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: cards,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool anyUploading = _sections.any(
      (section) => _sectionUploading[section]!.any((u) => u),
    );

    return Scaffold(
      appBar: PolarForecastAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: anyUploading ? null : _uploadAllImages,
        icon: Icon(Icons.cloud_upload),
        label: Text("Upload All"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Header
            Text(
              "Team ${widget.team} | ${teamNames[widget.team.toString()] ?? ""}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Robot Photos",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 20),

            // 🔥 Sections
            Expanded(
              child: ListView.builder(
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  return _buildSection(_sections[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
