// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Forgot your Password?`
  String get forgotYourPassword {
    return Intl.message(
      'Forgot your Password?',
      name: 'forgotYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't have Account?`
  String get donNotHaveAccount {
    return Intl.message(
      'Don\'t have Account?',
      name: 'donNotHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create one`
  String get createOne {
    return Intl.message('Create one', name: 'createOne', desc: '', args: []);
  }

  /// `Forgot Password`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email*`
  String get emailWithAstric {
    return Intl.message('Email*', name: 'emailWithAstric', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Create new account`
  String get createNewAccount {
    return Intl.message(
      'Create new account',
      name: 'createNewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Account Type*`
  String get accountTypeWithAstric {
    return Intl.message(
      'Account Type*',
      name: 'accountTypeWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `First Name*`
  String get firstNameWithAstric {
    return Intl.message(
      'First Name*',
      name: 'firstNameWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Last Name*`
  String get lastNameWithAstric {
    return Intl.message(
      'Last Name*',
      name: 'lastNameWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Full Name*`
  String get fullNameWithAstric {
    return Intl.message(
      'Full Name*',
      name: 'fullNameWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Family`
  String get family {
    return Intl.message('Family', name: 'family', desc: '', args: []);
  }

  /// `Personal`
  String get personal {
    return Intl.message('Personal', name: 'personal', desc: '', args: []);
  }

  /// `Relationship*`
  String get relationshipWithAstric {
    return Intl.message(
      'Relationship*',
      name: 'relationshipWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Husband`
  String get husband {
    return Intl.message('Husband', name: 'husband', desc: '', args: []);
  }

  /// `Wife`
  String get wife {
    return Intl.message('Wife', name: 'wife', desc: '', args: []);
  }

  /// `Son`
  String get son {
    return Intl.message('Son', name: 'son', desc: '', args: []);
  }

  /// `Daughter`
  String get daughter {
    return Intl.message('Daughter', name: 'daughter', desc: '', args: []);
  }

  /// `National ID*`
  String get nationalIdWithAstric {
    return Intl.message(
      'National ID*',
      name: 'nationalIdWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Mobile*`
  String get mobileWithAstric {
    return Intl.message(
      'Mobile*',
      name: 'mobileWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get mobile {
    return Intl.message('Mobile', name: 'mobile', desc: '', args: []);
  }

  /// `Address*`
  String get addressWithAstric {
    return Intl.message(
      'Address*',
      name: 'addressWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Church of Attendance*`
  String get churchOfAttendanceWithAstric {
    return Intl.message(
      'Church of Attendance*',
      name: 'churchOfAttendanceWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Gender*`
  String get genderWithAstric {
    return Intl.message(
      'Gender*',
      name: 'genderWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Deacon*`
  String get deaconWithAstric {
    return Intl.message(
      'Deacon*',
      name: 'deaconWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Create password`
  String get createPassword {
    return Intl.message(
      'Create password',
      name: 'createPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password*`
  String get passwordWithAstric {
    return Intl.message(
      'Password*',
      name: 'passwordWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password*`
  String get confirmPasswordWithAstric {
    return Intl.message(
      'Confirm Password*',
      name: 'confirmPasswordWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `By creating EGY Copts account, you agree to the`
  String get termsAndConditionsTitle {
    return Intl.message(
      'By creating EGY Copts account, you agree to the',
      name: 'termsAndConditionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `terms and conditions`
  String get termsAndConditions {
    return Intl.message(
      'terms and conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message('and', name: 'and', desc: '', args: []);
  }

  /// `Please enter your Email`
  String get pleaseEnterYourEmail {
    return Intl.message(
      'Please enter your Email',
      name: 'pleaseEnterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Password`
  String get pleaseEnterYourPassword {
    return Intl.message(
      'Please enter your Password',
      name: 'pleaseEnterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your First Name`
  String get pleaseEnterYourFirstName {
    return Intl.message(
      'Please enter your First Name',
      name: 'pleaseEnterYourFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Last Name`
  String get pleaseEnterYourLastName {
    return Intl.message(
      'Please enter your Last Name',
      name: 'pleaseEnterYourLastName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Full Name`
  String get pleaseEnterYourFullName {
    return Intl.message(
      'Please enter your Full Name',
      name: 'pleaseEnterYourFullName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Full Name`
  String get pleaseEnterYourFullNameThreeWords {
    return Intl.message(
      'Please enter your Full Name',
      name: 'pleaseEnterYourFullNameThreeWords',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your National ID`
  String get pleaseEnterYourNationalId {
    return Intl.message(
      'Please enter your National ID',
      name: 'pleaseEnterYourNationalId',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Mobile`
  String get pleaseEnterYourMobile {
    return Intl.message(
      'Please enter your Mobile',
      name: 'pleaseEnterYourMobile',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Address`
  String get pleaseEnterYourAddress {
    return Intl.message(
      'Please enter your Address',
      name: 'pleaseEnterYourAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Church of attendance`
  String get pleaseEnterYourChurchOfAttendance {
    return Intl.message(
      'Please enter your Church of attendance',
      name: 'pleaseEnterYourChurchOfAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Please choose Account type`
  String get pleaseChooseAccountType {
    return Intl.message(
      'Please choose Account type',
      name: 'pleaseChooseAccountType',
      desc: '',
      args: [],
    );
  }

  /// `Please choose Relationship`
  String get pleaseChooseRelationship {
    return Intl.message(
      'Please choose Relationship',
      name: 'pleaseChooseRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Choose Relationship`
  String get chooseRelationship {
    return Intl.message(
      'Choose Relationship',
      name: 'chooseRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Please choose Gender`
  String get pleaseChooseGender {
    return Intl.message(
      'Please choose Gender',
      name: 'pleaseChooseGender',
      desc: '',
      args: [],
    );
  }

  /// `Please choose Deacon`
  String get pleaseChooseDeacon {
    return Intl.message(
      'Please choose Deacon',
      name: 'pleaseChooseDeacon',
      desc: '',
      args: [],
    );
  }

  /// `Please enter correct National ID`
  String get pleaseEnterCorrectNationalId {
    return Intl.message(
      'Please enter correct National ID',
      name: 'pleaseEnterCorrectNationalId',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid Mobile Number`
  String get pleaseEnterAValidMobileNumber {
    return Intl.message(
      'Please enter a valid Mobile Number',
      name: 'pleaseEnterAValidMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure of Exit from EGY Copts?`
  String get areYouSureOfExitFromEGYCopts {
    return Intl.message(
      'Are you sure of Exit from EGY Copts?',
      name: 'areYouSureOfExitFromEGYCopts',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Governorate`
  String get governorate {
    return Intl.message('Governorate', name: 'governorate', desc: '', args: []);
  }

  /// `Church`
  String get church {
    return Intl.message('Church', name: 'church', desc: '', args: []);
  }

  /// `Date`
  String get holyLiturgyDate {
    return Intl.message('Date', name: 'holyLiturgyDate', desc: '', args: []);
  }

  /// `There are`
  String get thereAre {
    return Intl.message('There are', name: 'thereAre', desc: '', args: []);
  }

  /// `There is`
  String get thereIs {
    return Intl.message('There is', name: 'thereIs', desc: '', args: []);
  }

  /// `available seats`
  String get availableSeats {
    return Intl.message(
      'available seats',
      name: 'availableSeats',
      desc: '',
      args: [],
    );
  }

  /// `available seats`
  String get availableSeat {
    return Intl.message(
      'available seats',
      name: 'availableSeat',
      desc: '',
      args: [],
    );
  }

  /// `available seat`
  String get availableSeatSingular {
    return Intl.message(
      'available seat',
      name: 'availableSeatSingular',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.22`
  String get version {
    return Intl.message('Version 1.0.22', name: 'version', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `New Booking`
  String get newBooking {
    return Intl.message('New Booking', name: 'newBooking', desc: '', args: []);
  }

  /// `Bookings`
  String get myBookings {
    return Intl.message('Bookings', name: 'myBookings', desc: '', args: []);
  }

  /// `Family`
  String get myFamily {
    return Intl.message('Family', name: 'myFamily', desc: '', args: []);
  }

  /// `Profile`
  String get myProfile {
    return Intl.message('Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Choose Family Members`
  String get chooseFamilyMembers {
    return Intl.message(
      'Choose Family Members',
      name: 'chooseFamilyMembers',
      desc: '',
      args: [],
    );
  }

  /// `Choose Family Members`
  String get chooseFamilyMembers2 {
    return Intl.message(
      'Choose Family Members',
      name: 'chooseFamilyMembers2',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Back to Home`
  String get backToHome {
    return Intl.message('Back to Home', name: 'backToHome', desc: '', args: []);
  }

  /// `Booked Successfully`
  String get bookedSuccessfully {
    return Intl.message(
      'Booked Successfully',
      name: 'bookedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Booking number`
  String get bookingNumber {
    return Intl.message(
      'Booking number',
      name: 'bookingNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please save Booking number`
  String get pleaseSaveBookingNumber {
    return Intl.message(
      'Please save Booking number',
      name: 'pleaseSaveBookingNumber',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get liturgyDate {
    return Intl.message('Date', name: 'liturgyDate', desc: '', args: []);
  }

  /// `Time`
  String get liturgyTime {
    return Intl.message('Time', name: 'liturgyTime', desc: '', args: []);
  }

  /// `Add Family Member`
  String get addFamilyMember {
    return Intl.message(
      'Add Family Member',
      name: 'addFamilyMember',
      desc: '',
      args: [],
    );
  }

  /// `Edit Family Member`
  String get editFamilyMember {
    return Intl.message(
      'Edit Family Member',
      name: 'editFamilyMember',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Current Password*`
  String get currentPasswordWithAstric {
    return Intl.message(
      'Current Password*',
      name: 'currentPasswordWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `New Password*`
  String get newPasswordWithAstric {
    return Intl.message(
      'New Password*',
      name: 'newPasswordWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password*`
  String get confirmNewPasswordWithAstric {
    return Intl.message(
      'Confirm New Password*',
      name: 'confirmNewPasswordWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your current password`
  String get pleaseEnterYourCurrentPassword {
    return Intl.message(
      'Please enter your current password',
      name: 'pleaseEnterYourCurrentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter new password`
  String get pleaseEnterNewPassword {
    return Intl.message(
      'Please enter new password',
      name: 'pleaseEnterNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your new password`
  String get pleaseConfirmYourNewPassword {
    return Intl.message(
      'Please confirm your new password',
      name: 'pleaseConfirmYourNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password can't be less than 8`
  String get passwordCannotBeLessThan8 {
    return Intl.message(
      'Password can\'t be less than 8',
      name: 'passwordCannotBeLessThan8',
      desc: '',
      args: [],
    );
  }

  /// `Sorry this email is used before`
  String get sorryThisEmailIsUsedBefore {
    return Intl.message(
      'Sorry this email is used before',
      name: 'sorryThisEmailIsUsedBefore',
      desc: '',
      args: [],
    );
  }

  /// `Password doesn't match`
  String get passwordDoesNotMatch {
    return Intl.message(
      'Password doesn\'t match',
      name: 'passwordDoesNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Account Created Successfully, Please check your mail to verify your account`
  String get accountCreatedSuccessfully {
    return Intl.message(
      'Account Created Successfully, Please check your mail to verify your account',
      name: 'accountCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Error connecting with server`
  String get errorConnectingWithServer {
    return Intl.message(
      'Error connecting with server',
      name: 'errorConnectingWithServer',
      desc: '',
      args: [],
    );
  }

  /// `Email or Password is not correct`
  String get emailOrPasswordIsNotCorrect {
    return Intl.message(
      'Email or Password is not correct',
      name: 'emailOrPasswordIsNotCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Account isn't activated`
  String get accountIsNotActivated {
    return Intl.message(
      'Account isn\'t activated',
      name: 'accountIsNotActivated',
      desc: '',
      args: [],
    );
  }

  /// `Email and Password doesn't match`
  String get emailAndPasswordDoesNotMatch {
    return Intl.message(
      'Email and Password doesn\'t match',
      name: 'emailAndPasswordDoesNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Please wait`
  String get pleaseWait {
    return Intl.message('Please wait', name: 'pleaseWait', desc: '', args: []);
  }

  /// `Family Members`
  String get familyMembers {
    return Intl.message(
      'Family Members',
      name: 'familyMembers',
      desc: '',
      args: [],
    );
  }

  /// `No Members found`
  String get noMembersFound {
    return Intl.message(
      'No Members found',
      name: 'noMembersFound',
      desc: '',
      args: [],
    );
  }

  /// `Deleted Successfully`
  String get deletedSuccessfully {
    return Intl.message(
      'Deleted Successfully',
      name: 'deletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Added Successfully`
  String get addedSuccessfully {
    return Intl.message(
      'Added Successfully',
      name: 'addedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete this member?`
  String get doYouWantToDeleteThisMember {
    return Intl.message(
      'Do you want to delete this member?',
      name: 'doYouWantToDeleteThisMember',
      desc: '',
      args: [],
    );
  }

  /// `Duplicated National ID`
  String get duplicatedNationalID {
    return Intl.message(
      'Duplicated National ID',
      name: 'duplicatedNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully`
  String get passwordUpdatedSuccessfully {
    return Intl.message(
      'Password updated successfully',
      name: 'passwordUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Complete Information`
  String get completeInformation {
    return Intl.message(
      'Complete Information',
      name: 'completeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Book`
  String get book {
    return Intl.message('Book', name: 'book', desc: '', args: []);
  }

  /// `Sorry, No available dates`
  String get noSeatsAvailable {
    return Intl.message(
      'Sorry, No available dates',
      name: 'noSeatsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Edit Booking`
  String get editBooking {
    return Intl.message(
      'Edit Booking',
      name: 'editBooking',
      desc: '',
      args: [],
    );
  }

  /// `Sorry you can't edit this booking`
  String get sorryYouCannotEditThisBooking {
    return Intl.message(
      'Sorry you can\'t edit this booking',
      name: 'sorryYouCannotEditThisBooking',
      desc: '',
      args: [],
    );
  }

  /// `No Bookings found`
  String get noBookingFound {
    return Intl.message(
      'No Bookings found',
      name: 'noBookingFound',
      desc: '',
      args: [],
    );
  }

  /// `Please choose at least 1 family member`
  String get pleaseChooseAtLeastFamilyMember {
    return Intl.message(
      'Please choose at least 1 family member',
      name: 'pleaseChooseAtLeastFamilyMember',
      desc: '',
      args: [],
    );
  }

  /// `Sorry you can't book before`
  String get sorryYouCannotBookBefore {
    return Intl.message(
      'Sorry you can\'t book before',
      name: 'sorryYouCannotBookBefore',
      desc: '',
      args: [],
    );
  }

  /// `Saved Successfully`
  String get savedSuccessfully {
    return Intl.message(
      'Saved Successfully',
      name: 'savedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Booking`
  String get cancelBooking {
    return Intl.message(
      'Cancel Booking',
      name: 'cancelBooking',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Successfully`
  String get cancelledSuccessfully {
    return Intl.message(
      'Cancelled Successfully',
      name: 'cancelledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to cancel this booking?`
  String get doYouWantToCancelThisBooking {
    return Intl.message(
      'Do you want to cancel this booking?',
      name: 'doYouWantToCancelThisBooking',
      desc: '',
      args: [],
    );
  }

  /// `Please choose booking date`
  String get pleaseChooseBookingDate {
    return Intl.message(
      'Please choose booking date',
      name: 'pleaseChooseBookingDate',
      desc: '',
      args: [],
    );
  }

  /// `Please choose church`
  String get pleaseChooseChurch {
    return Intl.message(
      'Please choose church',
      name: 'pleaseChooseChurch',
      desc: '',
      args: [],
    );
  }

  /// `Please choose governorate`
  String get pleaseChooseGovernorate {
    return Intl.message(
      'Please choose governorate',
      name: 'pleaseChooseGovernorate',
      desc: '',
      args: [],
    );
  }

  /// `Book a date`
  String get bookADate {
    return Intl.message('Book a date', name: 'bookADate', desc: '', args: []);
  }

  /// `Booking information`
  String get bookingInformation {
    return Intl.message(
      'Booking information',
      name: 'bookingInformation',
      desc: '',
      args: [],
    );
  }

  /// `Choose attending persons`
  String get chooseAttendingPersons {
    return Intl.message(
      'Choose attending persons',
      name: 'chooseAttendingPersons',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Booking`
  String get confirmBooking {
    return Intl.message(
      'Confirm Booking',
      name: 'confirmBooking',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all Information`
  String get pleaseCompleteAllInformation {
    return Intl.message(
      'Please complete all Information',
      name: 'pleaseCompleteAllInformation',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginUser {
    return Intl.message('Login', name: 'loginUser', desc: '', args: []);
  }

  /// `Can't delete because this user is linked to Bookings`
  String get cannotDeleteBecauseThisUserIsLinkedToBookings {
    return Intl.message(
      'Can\'t delete because this user is linked to Bookings',
      name: 'cannotDeleteBecauseThisUserIsLinkedToBookings',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get validationRefresh {
    return Intl.message(
      'Refresh',
      name: 'validationRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Account validation`
  String get accountValidation {
    return Intl.message(
      'Account validation',
      name: 'accountValidation',
      desc: '',
      args: [],
    );
  }

  /// `Account not validated`
  String get accountNotValidated {
    return Intl.message(
      'Account not validated',
      name: 'accountNotValidated',
      desc: '',
      args: [],
    );
  }

  /// `Please check your email to validate your account`
  String get pleaseCheckYourEmailToValidateYourAccount {
    return Intl.message(
      'Please check your email to validate your account',
      name: 'pleaseCheckYourEmailToValidateYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Resend validation email`
  String get resendValidationEmail {
    return Intl.message(
      'Resend validation email',
      name: 'resendValidationEmail',
      desc: '',
      args: [],
    );
  }

  /// `Email was sent to you, Please check your email to validate your account`
  String get emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount {
    return Intl.message(
      'Email was sent to you, Please check your email to validate your account',
      name: 'emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Choose Holy Liturgy Date`
  String get chooseHolyLiturgyDate {
    return Intl.message(
      'Choose Holy Liturgy Date',
      name: 'chooseHolyLiturgyDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose Date`
  String get chooseHolyLiturgyDate2 {
    return Intl.message(
      'Choose Date',
      name: 'chooseHolyLiturgyDate2',
      desc: '',
      args: [],
    );
  }

  /// `Modify`
  String get modify {
    return Intl.message('Modify', name: 'modify', desc: '', args: []);
  }

  /// `An email has been sent to you, Please check your inbox`
  String get anEmailHasBeenSentToYouPleaseCheckYourInbox {
    return Intl.message(
      'An email has been sent to you, Please check your inbox',
      name: 'anEmailHasBeenSentToYouPleaseCheckYourInbox',
      desc: '',
      args: [],
    );
  }

  /// `Email not found, Please check your email`
  String get emailNotFoundPleaseCheckYourEmail {
    return Intl.message(
      'Email not found, Please check your email',
      name: 'emailNotFoundPleaseCheckYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Error connecting to the Internet`
  String get errorConnectingToTheInternet {
    return Intl.message(
      'Error connecting to the Internet',
      name: 'errorConnectingToTheInternet',
      desc: '',
      args: [],
    );
  }

  /// `Press retry to try again`
  String get pressRetryToTryAgain {
    return Intl.message(
      'Press retry to try again',
      name: 'pressRetryToTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `You can't book because you have a booking on the same time`
  String get youCannotBookBecauseYouHaveABookingOnTheSameTime {
    return Intl.message(
      'You can\'t book because you have a booking on the same time',
      name: 'youCannotBookBecauseYouHaveABookingOnTheSameTime',
      desc: '',
      args: [],
    );
  }

  /// `Country*`
  String get countryWithAstric {
    return Intl.message(
      'Country*',
      name: 'countryWithAstric',
      desc: '',
      args: [],
    );
  }

  /// `Please choose Country`
  String get pleaseChooseCountry {
    return Intl.message(
      'Please choose Country',
      name: 'pleaseChooseCountry',
      desc: '',
      args: [],
    );
  }

  /// `Live`
  String get live {
    return Intl.message('Live', name: 'live', desc: '', args: []);
  }

  /// `Currently not available`
  String get noVideosFound {
    return Intl.message(
      'Currently not available',
      name: 'noVideosFound',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `News categories`
  String get newsCategories {
    return Intl.message(
      'News categories',
      name: 'newsCategories',
      desc: '',
      args: [],
    );
  }

  /// `No news found`
  String get noNewsFound {
    return Intl.message(
      'No news found',
      name: 'noNewsFound',
      desc: '',
      args: [],
    );
  }

  /// `By:`
  String get by {
    return Intl.message('By:', name: 'by', desc: '', args: []);
  }

  /// `News details`
  String get newsDetails {
    return Intl.message(
      'News details',
      name: 'newsDetails',
      desc: '',
      args: [],
    );
  }

  /// `Video Details`
  String get videoDetails {
    return Intl.message(
      'Video Details',
      name: 'videoDetails',
      desc: '',
      args: [],
    );
  }

  /// `Booking type`
  String get bookingType {
    return Intl.message(
      'Booking type',
      name: 'bookingType',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get choose {
    return Intl.message('Choose', name: 'choose', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `You are not registered in church membership for this church`
  String get youAreNotRegisteredInThisChurchMembership {
    return Intl.message(
      'You are not registered in church membership for this church',
      name: 'youAreNotRegisteredInThisChurchMembership',
      desc: '',
      args: [],
    );
  }

  /// `Please choose attendance type`
  String get pleaseChooseAttendanceType {
    return Intl.message(
      'Please choose attendance type',
      name: 'pleaseChooseAttendanceType',
      desc: '',
      args: [],
    );
  }

  /// `Person`
  String get person {
    return Intl.message('Person', name: 'person', desc: '', args: []);
  }

  /// `Deacon`
  String get deacon {
    return Intl.message('Deacon', name: 'deacon', desc: '', args: []);
  }

  /// `Attendance type`
  String get attendanceType {
    return Intl.message(
      'Attendance type',
      name: 'attendanceType',
      desc: '',
      args: [],
    );
  }

  /// `Chosen person isn't a deacon`
  String get chosenPersonIsNotaDeacon {
    return Intl.message(
      'Chosen person isn\'t a deacon',
      name: 'chosenPersonIsNotaDeacon',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `National ID`
  String get nationalId {
    return Intl.message('National ID', name: 'nationalId', desc: '', args: []);
  }

  /// `National ID photo`
  String get nationalIdPhoto {
    return Intl.message(
      'National ID photo',
      name: 'nationalIdPhoto',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get news {
    return Intl.message('News', name: 'news', desc: '', args: []);
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Remember me`
  String get rememberMe {
    return Intl.message('Remember me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Do you want to exit?`
  String get doYouWantExit {
    return Intl.message(
      'Do you want to exit?',
      name: 'doYouWantExit',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Please choose the type of attendance for booking.`
  String get chooseAttendanceTypeDescription {
    return Intl.message(
      'Please choose the type of attendance for booking.',
      name: 'chooseAttendanceTypeDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
