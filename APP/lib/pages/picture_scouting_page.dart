import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../widgets/camera_capture/camera_capture_service.dart';

import '../models/tournament.dart';
import 'not_found_page.dart';

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
        builder: (context, tournaments) {
          Tournament? tournament = null;
          try {
            for (final _tournament in tournaments.requireData) {
              if (_tournament.key == eventKey) {
                tournament = _tournament;
                break;
              }
            }
            if (tournament == null) {
              return NotFoundPage();
            }
            return PictureScoutingPage(
              team: int.parse(teamKey.substring(3)),
              eventCode: tournament.key,
            );
          } catch (error) {
            return NotFoundPage();
          }
        });
  }

  @override
  _PictureScoutingPageState createState() => _PictureScoutingPageState();
}

class _PictureScoutingPageState extends State<PictureScoutingPage> {
  img.Image? _image;
  bool _isLoading = false;

  Future<void> _captureImage(BuildContext context) async {
    final cameraCaptureService = createCameraCaptureService();
    final image = await cameraCaptureService.getImage(context);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _postImage(BuildContext context) async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    // try {
    await apiService.post_image(_image!, widget.eventCode, widget.team);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded successfully')),
    );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Failed to upload image: $e')),
    //   );
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PolarForecastAppBar(),
        body: Column(
          children: [
            Text('${widget.team} Pictures'),
            if (_image != null)
              Image.memory(
                Uint8List.fromList(img.encodeJpg(_image!)),
                height: 200,
                width: 200,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _captureImage(context),
              child: Text('Capture Image'),
            ),
            if (_image != null)
              ElevatedButton(
                onPressed: () => _postImage(context),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Upload Image'),
              ),
          ],
        ));
  }
}
