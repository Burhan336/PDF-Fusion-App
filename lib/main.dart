import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_reducer/splash_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PickedFile>? _images;
  File? _pdf;
  int _pdfPage = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.storage,
      ].request();
      print(statuses[Permission.photos]);
      print(statuses[Permission.storage]);
    }
  }

  Future getImages() async {
    final pickedFiles = await ImagePicker().getMultiImage();

    setState(() {
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        _images = pickedFiles;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pickedFiles.length} image(s) selected.'),
          ),
        );
      } else {
        print('No images selected.');
      }
    });
  }

  Future generatePDF() async {
    if (_images != null && _images!.isNotEmpty) {
      final pdf = pw.Document();

      for (var imageFile in _images!) {
        final image = pw.MemoryImage(
          File(imageFile.path).readAsBytesSync(),
        );

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Image(image),
            ),
          ),
        );
      }

      final output = await getTemporaryDirectory();
      _pdf = File("${output.path}/example.pdf");

      await _pdf!.writeAsBytes(await pdf.save());
      print("PDF Generated!");

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('PDF Generated'),
          content: Text('PDF has been generated. Do you want to open it?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _pdfPage = 0;
                });
              },
            ),
          ],
        ),
      );
    } else {
      print("No images selected!");
    }
  }

  void viewSelectedImages() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _images?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_images![index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openPDF() async {
    if (_pdf != null) {
      setState(() {
        _pdfPage = 0;
      });
    } else {
      print("No PDF generated!");
    }
  }

  Future savePDF() async {
    if (_pdf != null) {
      final Directory? directory = await getExternalStorageDirectory();
      final String? path = directory?.path;
      final String? initialName = _pdf!.path.split('/').last;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController nameController =
          TextEditingController(text: initialName);

          return AlertDialog(
            title: Text('Save PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter the new name for the PDF:'),
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'New Name'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () async {
                  String newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    String newPath = '$path/$newName.pdf';
                    File newFile = await _pdf!.copy(newPath);

                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('PDF Saved'),
                        content: Text(
                            'PDF saved at ${newFile.path}. Do you want to download it?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Download'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Share.shareFiles([newFile.path]);
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid name.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      print("No PDF generated!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('PDF Maker'),
        centerTitle: true,
      ),
      body: _pdf != null
          ? PDFView(
        filePath: _pdf!.path,
        onViewCreated: (PDFViewController pdfViewController) {
          setState(() {
            _pdfViewController = pdfViewController;
          });
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 700,
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  buildIconButton(
                    icon: Icons.photo,
                    label: 'Select Images',
                    onPressed: getImages,
                  ),
                  buildIconButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Generate PDF',
                    onPressed: generatePDF,
                  ),
                  buildIconButton(
                    icon: Icons.open_in_browser,
                    label: 'Open PDF',
                    onPressed: openPDF,
                  ),
                  buildIconButton(
                    icon: Icons.save_alt,
                    label: 'Save PDF',
                    onPressed: savePDF,
                  ),
                  buildIconButton(
                    icon: Icons.image,
                    label: 'View Images',
                    onPressed: viewSelectedImages,
                  ),
                  buildIconButton(
                    icon: Icons.record_voice_over,
                    label: 'Speech to PDF',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 40,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).accentColor,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(12.0),
          elevation: 2,
          shadowColor: Colors.black,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
