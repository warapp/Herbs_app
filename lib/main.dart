import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/img003.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/img0000.png',
                  width: 360,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SecondPage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img005.jpg'), // เพิ่มรูปภาพพื้นหลัง img005.jpg
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
  child: _imageBytes == null
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10), // ระยะห่างด้านล่างระหว่างปุ่ม
              child: ElevatedButton(
                onPressed: () {
                  _openCamera(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(), // ทำให้ปุ่มเป็นรูปทรงกลม
                  padding: EdgeInsets.all(60), // ปรับขนาดปุ่ม
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/img33.png',
                      width: 120,
                      height: 120,
                    ),
                    Text('Camera'),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10), // ระยะห่างด้านล่างระหว่างปุ่ม
              child: ElevatedButton(
                onPressed: () {
                  _openGallery(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(), // ทำให้ปุ่มเป็นรูปทรงกลม
                  padding: EdgeInsets.all(60), // ปรับขนาดปุ่ม
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/img44.png',
                      width: 120,
                      height: 120,
                    ),
                    Text('Gallery'),
                  ],
                ),
              ),
            ),
          ],
        )
      : Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/img005.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Image.memory(
                  _imageBytes!,
                  width: 400,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      _postImage();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), // ทำให้ปุ่มเป็นรูปทรงกลม
                      padding: EdgeInsets.all(20), // ปรับขนาดปุ่ม
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
),

      ),
    );
  }

  void _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(bytes);
      });
    }
  }

  void _openGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(bytes);
      });
    }
  }

  void _postImage() async {
    if (_imageBytes != null) {
      String base64Image = base64Encode(_imageBytes!);
      final url = 'http://158.108.112.10:8000/predict_herb_grade';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'base64str': base64Image}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              resultJson: response.body,
              base64Image: base64Image,
            ),
          ),
        );
      } else {
        print('Failed to post image. Error code: ${response.statusCode}');
      }
    }
  }
}



class ResultPage extends StatelessWidget {
  final String resultJson;
  final String base64Image;

  ResultPage({required this.resultJson, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result = jsonDecode(resultJson)['data'];

    String grade = result?['grade'] ?? 'N/A';
    double similarityPercent = result?['similarity_percent'] ?? 0.0;
    String similarityPercentString = similarityPercent.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img001.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // แสดงรูปภาพจากข้อมูล base64
              Image.memory(
                base64Decode(base64Image),
                width: 200, // ปรับขนาดรูปภาพตามที่ต้องการ
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
              'Grade: $grade',
               style: TextStyle(
               color: Colors.white,
               fontSize: 24, // ปรับขนาดข้อความใหญ่ขึ้น
               fontFamily: 'Arial', // เลือกแบบอักษรตามที่ต้องการ
                 fontWeight: FontWeight.bold, // ตั้งค่าความหนาของข้อความ
                ),
              ),
              Text(
             'Similarity Percent: $similarityPercentString',
              style: TextStyle(
              color: Colors.white,
              fontSize: 20, // ปรับขนาดข้อความใหญ่ขึ้น
              fontFamily: 'Arial', // เลือกแบบอักษรตามที่ต้องการ
              fontStyle: FontStyle.italic, // ตั้งค่ารูปแบบการเขียนข้อความเป็นตัวเอียง
             ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

