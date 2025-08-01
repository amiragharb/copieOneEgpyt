import 'package:flutter/material.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/editBookingDetails.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewBookingDetailsActivity extends StatefulWidget {
  final String remAttendanceCount;
  final String churchRemarks;
  final String courseRemarks;
  final String courseDateAr;
  final String courseDateEn;
  final String courseTimeAr;
  final String courseTimeEn;
  final String churchNameAr;
  final String churchNameEn;
  final String coupleID;
  final List<EditFamilyMember> familyMembers;
  final String registrationNumber;
  final String courseTypeName;
  final int attendanceTypeID;
  final String attendanceTypeNameAr;
  final String attendanceTypeNameEn;
  final bool allowEdit;

  const ViewBookingDetailsActivity(
    this.remAttendanceCount,
    this.churchRemarks,
    this.courseRemarks,
    this.courseDateAr,
    this.courseDateEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchNameAr,
    this.churchNameEn,
    this.coupleID,
    this.familyMembers,
    this.registrationNumber,
    this.courseTypeName,
    this.attendanceTypeID,
    this.attendanceTypeNameAr,
    this.attendanceTypeNameEn,
    this.allowEdit, {
    Key? key,
  }) : super(key: key);

  @override
  _ViewBookingDetailsActivityState createState() => _ViewBookingDetailsActivityState();
}

class _ViewBookingDetailsActivityState extends State<ViewBookingDetailsActivity> {
  String myLanguage = "en";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myLanguage = prefs.getString('language') ?? "en";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDarkColor.withOpacity(0.05),
              Colors.white,
              primaryColor.withOpacity(0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryDarkColor,
                      primaryColor,
                      logoBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDarkColor.withOpacity(0.25),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking Details",
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View your reservation information",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Registration Number Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: logoBlue.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: logoBlue.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              color: logoBlue,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)?.bookingNumber ?? "Booking Number",
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryDarkColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.registrationNumber,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'cocon-next-arabic-regular',
                                fontWeight: FontWeight.w700,
                                color: logoBlue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Church Information Card
                      _buildInfoCard(
                        title: "Church Information",
                        icon: Icons.church,
                        children: [
                          _buildInfoRow(
                            "Church Name",
                            myLanguage == "en" ? widget.churchNameEn : widget.churchNameAr,
                          ),
                          _buildInfoRow(
                            "Course Type",
                            widget.courseTypeName,
                          ),
                        ],
                      ),

                      // Date & Time Card
                      _buildInfoCard(
                        title: "Schedule Information",
                        icon: Icons.schedule,
                        children: [
                          _buildInfoRow(
                            "Date",
                            myLanguage == "en" ? widget.courseDateEn : widget.courseDateAr,
                          ),
                          _buildInfoRow(
                            "Time",
                            myLanguage == "en" ? widget.courseTimeEn : widget.courseTimeAr,
                          ),
                        ],
                      ),

                      // Attendance Information Card
                      if (widget.attendanceTypeID != 0)
                        _buildInfoCard(
                          title: "Attendance Information",
                          icon: Icons.people,
                          children: [
                            _buildInfoRow(
                              "Attendance Type",
                              myLanguage == "ar" ? widget.attendanceTypeNameAr : widget.attendanceTypeNameEn,
                            ),
                            _buildInfoRow(
                              "Remaining Seats",
                              widget.remAttendanceCount,
                            ),
                          ],
                        ),

                      // Family Members Card
                      if (widget.familyMembers.isNotEmpty)
                        _buildInfoCard(
                          title: "Family Members",
                          icon: Icons.family_restroom,
                          children: [
                            ...widget.familyMembers.map((member) => 
                              _buildFamilyMemberRow(member)
                            ).toList(),
                          ],
                        ),

                      // Remarks Card
                      if (widget.churchRemarks.isNotEmpty || widget.courseRemarks.isNotEmpty)
                        _buildInfoCard(
                          title: "Additional Information",
                          icon: Icons.notes,
                          children: [
                            if (widget.churchRemarks.isNotEmpty)
                              _buildInfoRow("Church Remarks", widget.churchRemarks),
                            if (widget.courseRemarks.isNotEmpty)
                              _buildInfoRow("Course Remarks", widget.courseRemarks),
                          ],
                        ),

                      // Edit Permission Status
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.allowEdit ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.allowEdit ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.allowEdit ? Icons.edit : Icons.lock,
                              color: widget.allowEdit ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.allowEdit 
                                  ? "This booking can be edited"
                                  : "This booking cannot be edited",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.allowEdit ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryDarkColor.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'cocon-next-arabic-regular',
                  fontWeight: FontWeight.w600,
                  color: primaryDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 14,
                color: primaryDarkColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not specified" : value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'cocon-next-arabic-regular',
                fontWeight: FontWeight.w600,
                color: primaryDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberRow(EditFamilyMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: logoBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: logoBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: logoBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${member.accountMemberNameAr ?? 'Unknown'} (${member.personRelationNameEn ?? member.personRelationNameAr ?? 'Family'})",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'cocon-next-arabic-regular',
                fontWeight: FontWeight.w500,
                color: primaryDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
