import 'package:flexischool/models/upload_doc_response.dart';
import 'package:flutter/material.dart';

class FileTable extends StatelessWidget {
  final List<UploadDocResponse> files;
  final Function(String,int) onRemove;

  const FileTable({super.key, required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      border: TableBorder.all(),
      children: [
        const TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'File Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Remove',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        for (int index = 0; index < files.length; index++)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(files[index].fileNAME ?? ""),
                ),
              ),
              TableCell(
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemove(files[index].fileNAME ?? "",index),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
