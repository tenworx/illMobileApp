import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:outlook/controller/buttoncontroller.dart';
import 'package:outlook/controller/datecontroller.dart';
import 'package:intl/intl.dart';
import 'package:outlook/screens/web_checkout.dart';
import '../components/booking_details.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../constants.dart';
import '../controller/datepickercontroller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingScreen extends StatefulWidget {
  final data;
  final docid;
  BookingScreen({required this.data, required this.docid});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

bool flag = false;
DateTime? to;
DateTime? from;
List<String> finaltime = [];
Position? currentLocation;

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        currentLocation = value;
      });
    });
    // TODO: implement initState
    super.initState();
    finaltime = [];
    // PaymentService.init();
    String month =
        '${DateTime.now().month < 10 ? '0${DateTime.now().month}' : DateTime.now().month}';
    String day =
        '${DateTime.now().day < 10 ? '0${DateTime.now().day}' : DateTime.now().day}';
    DateTime to1 = DateFormat.jm().parse(widget.data['to']);
    DateTime from1 = DateFormat.jm().parse(widget.data['from']);
    final to2 = DateFormat("HH:mm").format(to1);
    final from2 = DateFormat("HH:mm").format(from1);
    to = DateTime.parse('${DateTime.now().year}-$month-$day $to2:04Z');
    from = DateTime.parse('${DateTime.now().year}-$month-$day $from2:04Z');
    DateTime time = from!;
    finaltime.add(widget.data['from']);
    while (time.isBefore(to!)) {
      time = time.add(Duration(hours: 1, minutes: 30));
      print(time);
      DateTime tempDate =
          DateFormat("hh:mm").parse('${time.hour}:${time.minute}');
      var dateFormat = DateFormat("h:mm a");
      String datee = dateFormat.format(tempDate);
      finaltime.add(datee);
    }
  }

  Map<String, dynamic>? paymentIntentData;

  String? selectedTime;
  String date = "";
  var schedule;

  Future<void> makePayment() async {
    try {
      paymentIntentData = await Get.put(ButtonController())
          .createPaymentIntent('50', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      if (kIsWeb) {
        if (flag == false) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select available day')));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WebViewExample(
                    selectedTime: selectedTime,
                    date: date,
                    instanceUser: FirebaseAuth.instance.currentUser!.uid,
                    name: widget.data['name'],
                    docid: widget.docid,
                  )));
        }

        print("web");
      } else {
        if (flag == false) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select available day')));
        } else {
          await Stripe.instance
              .initPaymentSheet(
                  paymentSheetParameters: SetupPaymentSheetParameters(
                      paymentIntentClientSecret:
                          paymentIntentData!['client_secret'],
                      style: ThemeMode.light,
                      merchantDisplayName: 'Sagheer Ahmed'))
              .then((value) {});
          displayPaymentSheet();
        }
      }

      ///now finally display payment sheeet

    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayWeb(BuildContext context) {}

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ))
          .then((newValue) async {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());

        await FirebaseFirestore.instance.collection("appointments").doc().set({
          "docname": widget.data['name'],
          "docid": widget.docid,
          "patientid": FirebaseAuth.instance.currentUser!.uid,
          "time": selectedTime,
          "date": date,
          "status": 'pending'
        }).then((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Appointment Booked Successfully!')));
        });
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("paid successfully"),
          backgroundColor: Colors.black12,
        ));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flag = false;
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.keyboard_backspace,
            color: Color.fromRGBO(33, 45, 82, 1),
          ),
        ),
        title: Text(
          "Select Appointment Date",
          style: TextStyle(
            color: Color.fromRGBO(33, 45, 82, 1),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where(
                'status',
                isEqualTo: 'pending',
              )
              .snapshots(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(widget.data['days'].replaceAll(',', ' ')),
                    Container(
                      height: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: GetX<DatePickerController>(
                          init: DatePickerController(),
                          builder: (_) {
                            return SfDateRangePicker(
                              // monthViewSettings:
                              selectionColor: (_.booking().color),
                              enablePastDates: false,
                              minDate: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day + 1),
                              headerStyle: DateRangePickerHeaderStyle(
                                  backgroundColor: kPrimaryColor,
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(color: Colors.white)),
                              onSelectionChanged: (value) {
                                String day = widget.data['days'];
                                DateFormat formatter =
                                    DateFormat.yMMMMEEEEd('en_US');
                                setState(() {
                                  date = formatter.format(value.value);
                                  for (var i = 0;
                                      i < snapshot.data!.docs.length;
                                      i++) {
                                    if (snapshot.data!.docs[i]['date'] ==
                                        date) {
                                      finaltime.removeWhere((element) =>
                                          element ==
                                          snapshot.data!.docs[i]['time']);
                                    }
                                    if (finaltime.contains(
                                        snapshot.data!.docs[i]['time'])) {
                                      continue;
                                    } else if (date !=
                                        snapshot.data!.docs[i]['date']) {
                                      finaltime
                                          .add(snapshot.data!.docs[i]['time']);
                                    }
                                  }
                                });
                                for (var i = 0;
                                    i < day.split(',').length;
                                    i++) {
                                  if (day
                                      .split(',')[i]
                                      .contains(date.split(',')[0])) {
                                    print('found');
                                    Get.find<DatePickerController>()
                                        .updateColor(kPrimaryColor);
                                    setState(() {
                                      flag = true;
                                    });
                                    break;
                                  } else {
                                    Get.find<DatePickerController>()
                                        .updateColor(Colors.red);
                                    flag = false;
                                  }
                                }

                                Get.find<DateController>().updateBooking(date);
                              },
                            );
                          }),
                    ),
                    GetX<DateController>(
                      init: DateController(),
                      builder: (_) {
                        return BookingDetails(_.booking().date);
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Appointment Time:  ',
                          style: TextStyle(fontSize: 16, color: kTextColor),
                        ),
                        DropdownButton<String>(
                            hint: selectedTime == null
                                ? Text(finaltime[0])
                                : Text(
                                    selectedTime!,
                                    style: TextStyle(
                                      color: kTextColor,
                                    ),
                                  ),
                            iconSize: 30.0,
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 16),
                            items: finaltime.map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  selectedTime = val!;
                                },
                              );
                            }),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        int charge1 = 0;
                        int charge2 = 0;
                        DateTime date = DateFormat.jm().parse(selectedTime!);
                        print(date);
                        double cost = 349;
                        double drivetime = 0;
                        calculateCost().then((value) {
                          print(value);
                          if (date.hour > 22 && date.hour < 1) {
                            setState(() {
                              charge2 = 25;
                              cost = cost + 25;
                            });
                          } else if (date.hour > 1 && date.hour < 8) {
                            setState(() {
                              charge2 = 100;
                              cost = cost + 100;
                            });
                          }
                          setState(() {
                            drivetime = (value / 0.58);
                          });
                          if (drivetime > 16 && drivetime < 30) {
                            setState(() {
                              charge1 = 50;
                              cost = cost + 50;
                            });
                          } else if (drivetime > 30 && drivetime < 60) {
                            setState(() {
                              charge1 = 100;
                              cost = cost + 100;
                            });
                          } else if (drivetime > 60 && drivetime < 90) {
                            setState(() {
                              charge1 = 200;
                              cost = cost + 200;
                            });
                          } else if (drivetime > 90) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Service Currently not available in your area')));
                          }
                          print('drivetime is $drivetime');
                          print('price is $cost');
                          showDialog(
                              context: (context),
                              builder: (context) => showDetails(cost.toString(),
                                  charge1.toString(), charge2.toString()));
                        });
                        // if(kIsWeb){
                        //   Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //           builder:
                        //               (context) =>
                        //               PaymentScreen()));
                        // }
                        // else{
                        //   await makePayment();
                        //
                        // }
                        // if (flag == false) {
                        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //       content: Text('Please select available day')));
                        // }
                        // else {
                        //   FirebaseFirestore.instance
                        //       .collection("appointments")
                        //       .doc()
                        //       .set({
                        //     "docname": widget.data['name'],
                        //     "docid": widget.docid,
                        //     "patientid": FirebaseAuth.instance.currentUser!.uid,
                        //     "time": selectedTime!,
                        //     "date": date,
                        //     "status": 'pending'
                        //   }).then((_) {
                        //     Navigator.pop(context);
                        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //         content:
                        //         Text('Appointment Booked Successfully!')));
                        //   });
                        // }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(169, 176, 185, 0.42),
                              spreadRadius: 0,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Confirm Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  bool dateflag = false;
  Future calculateCost() async {
    double distInKm = 0;
    await FirebaseFirestore.instance
        .collection('admin')
        .doc('SQfPgIfFDGMujE3rtkPyLvIPdFo1')
        .get()
        .then((value) async {
      double distInMeters = await Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          value['lat'],
          value['lng']);
      print(distInMeters);
      distInKm = distInMeters / 1000;
      print(distInKm);
    });
    return distInKm;
  }

  Widget showDetails(String cost, String charges1, String charges2) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: AlertDialog(
        alignment: Alignment.center,
        titleTextStyle: TextStyle(fontSize: 24),
        title: Center(child: Text('Booking Details')),
        content: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Divider(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Doctor Name: ${widget.data['name']}',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Appointment Date: $date',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Appointment Time: $selectedTime',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            Divider(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              'Bill',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Base Price: 349',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Drive cost: $charges1',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Extra Charges: $charges2',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
            Divider(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              'Total Cost: $cost',
              style: TextStyle(color: kTitleTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel')),
          TextButton(
              onPressed: () async {
                await makePayment();
              },
              child: Text('Ok'))
        ],
      ),
    );
  }
}
