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

  @override
  void initState() {
    super.initState();
    _sectionEncodedImages = {for (var section in _sections) section: []};
    _sectionUploading = {for (var section in _sections) section: []};
    _capturing = {for (var section in _sections) section: false};
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
    final encodedBytes = _sectionEncodedImages[section]![index];
    final isUploading = _sectionUploading[section]![index];

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 220,
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${section.toUpperCase()} Image ${index + 1}',
                        style: TextStyle(
                            fontFamily: 'Font',
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => _removeImage(section, index),
                    icon: Icon(Icons.delete, color: Colors.white),
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: encodedBytes != null
                        ? Image.memory(encodedBytes, fit: BoxFit.cover)
                        : Center(child: CircularProgressIndicator()),
                  ),
                  if (isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha(128),
                        child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImageCard(PictureData picture) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 220,
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'By ${picture.scout_info.first_name ?? 'scout on ${picture.scout_info.team_number}'}',
                      style: TextStyle(
                          fontFamily: 'Font',
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Image.network(
              picture.link,
              loadingBuilder: (context, child, event) {
                if (event == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator.adaptive(
                      value: event.cumulativeBytesLoaded /
                          event.expectedTotalBytes!,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String section) {
    List<Widget> cards = [];
    for (final picture in _takenPictures) {
      if (picture.image_type == section)
        cards.add(_buildNetworkImageCard(picture));
    }
    for (int index = 0;
        index < _sectionEncodedImages[section]!.length;
        index++) {
      cards.add(_buildImageCard(section, index));
    }
    cards.add(
      GestureDetector(
        onTap: !_capturing[section]!
            ? () => _showImageSourceActionSheet(section)
            : () {},
        child: Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 220,
            height: 270,
            child: Center(
              child: _capturing[section]!
                  ? CircularProgressIndicator(color: Colors.blue)
                  : Icon(Icons.add_a_photo, size: 60, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(section.toUpperCase(),
                style:
                    TextStyle(fontFamily: 'Font', fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 12),
          Container(
            height: 280,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cards,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool anyUploading = _sections.any(
      (section) => _sectionUploading[section]!.any((uploading) => uploading),
    );
    return Scaffold(
      appBar: PolarForecastAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Team ${widget.team} Pictures',
              style: TextStyle(fontFamily: 'Font', fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Capture, select, remove, and upload images for each section.',
              style: TextStyle(fontFamily: 'Font', fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.blue,
            ),
            Expanded(
              child: ListView(
                children:
                    _sections.map((section) => _buildSection(section)).toList(),
              ),
            ),
            ElevatedButton.icon(
              onPressed: anyUploading ? null : _uploadAllImages,
              icon: Icon(Icons.cloud_upload),
              label: Text('Upload All', style: TextStyle(fontFamily: 'Font')),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
