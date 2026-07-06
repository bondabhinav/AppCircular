import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String name;
  final Color color, btnColor;
  final VoidCallback onPressed;
  const CardWidget({
    super.key,
    required this.name,
    required this.color,
    required this.btnColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQD5-iT2qq-hExKNkJmcZKaKJmpZGZAgLH7eUKF_PAT0g&usqp=CAU&ec=48600112',
                  ),
                  radius: 50.0,
                ),
                SizedBox(height: 10.0),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                btnColor,
                              ),
                              //padding: MaterialStateProperty.all(EdgeInsets.all(50)),
                              textStyle: WidgetStateProperty.all(
                                TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            onPressed: onPressed,
                            child: const Text('Submit'),
                          ),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Employee Code : 5032',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Designation : PPRT',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Session : 2022 - 2023',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
