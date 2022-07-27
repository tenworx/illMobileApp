import 'package:flutter/material.dart';
import 'package:outlook/constants.dart';
import 'package:outlook/responsive.dart';

class Cost extends StatelessWidget {
  const Cost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height * 0.95,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image(
                    image: AssetImage('assets/images/aboutus.jpg'),
                    height: Responsive.isMobile(context)
                        ? height * 0.4
                        : height * 0.65,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: Responsive.isMobile(context)
                              ? height * 0.2
                              : height * 0.26),
                      child: Text(
                        'Cost',
                        style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 35 : 50,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                height: Responsive.isMobile(context) ? height * 0.55 : height,
                width: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          child: Text(
                            'Our Pricing',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.red, width: 5))),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.015
                                : Responsive.isMobile(context)
                                    ? 10
                                    : MediaQuery.of(context).size.width * 0.01,
                            right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: DataTable(
                                  border: TableBorder.all(width: 1),
                                  headingTextStyle: TextStyle(fontSize: 24),
                                  columnSpacing:
                                      MediaQuery.of(context).size.width * 0.4,
                                  columns: [
                                    DataColumn(
                                        label: Center(child: Text('Pricing'))),
                                    DataColumn(label: Text(''))
                                  ],
                                  rows: [
                                    DataRow(cells: [
                                      DataCell(Text('Base Price')),
                                      DataCell(Text('\$349.00'))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('')),
                                      DataCell(Text(''))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Time Of Appointment')),
                                      DataCell(Text(''))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('10:01 PM to 12:59 AM')),
                                      DataCell(Text('\$25.00'))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('1:00 AM to 8:00 AM')),
                                      DataCell(Text('\$100.00'))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('')),
                                      DataCell(Text(''))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Drive Time')),
                                      DataCell(Text(''))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('16 to 29 mins')),
                                      DataCell(Text('\$50.00'))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('30 to 59 mins')),
                                      DataCell(Text('\$100.00'))
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('60 to 89 mins')),
                                      DataCell(Text('\$200.00'))
                                    ])
                                  ]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 70,
                width: double.infinity,
                color: kTitleTextColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        Text('  info@medavex.org',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
