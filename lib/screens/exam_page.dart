import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({Key? key}) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Bu Haftaki kalan Sınavlar'),
        ),
        body: buildExamList());
  }

  SafeArea buildExamList() {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('exams').snapshots(),
              builder: (context, snapshot) {
                final exams = snapshot.data?.docs;

                if (exams == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (exams.isEmpty) {
                  return const Center(
                    child: Text('Halihazırda bir sınaıvnız yoktur '),
                  );
                }

                return ListView.builder(
                  itemCount: exams.length,
                  padding: const EdgeInsets.all(15),
                  itemBuilder: (context, index) {
                    final exam = exams[index];

                    return Card(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('exams')
                              .doc(exam.id)
                              .delete();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                exam['exam'],
                                style: TextStyle(color: Colors.blue),
                              ),
                              const Divider(),
                              Text(
                                DateFormat('dd//MM//yyyy HH:mm')
                                    .format(exam['createdAt'].toDate()),
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )),
            buildTextField(),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildSubmitButton() => ElevatedButton(
      onPressed: () {
        FirebaseFirestore.instance
            .collection('exams')
            .add({'exam': controller.text, 'createdAt': Timestamp.now()});
        controller.clear();
      },
      child: const Icon(Icons.add));

  Padding buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Olan sınavınızı giriniz',
        ),
        controller: controller,
      ),
    );
  }
}
