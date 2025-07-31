import 'dart:async';
import 'dart:ui';

import 'package:egpycopsversion4/l10n/messages_all.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  String get email {
    return Intl.message('Email', name: 'email');
  }

  String get password {
    return Intl.message('Password', name: 'password');
  }

  String get login {
    return Intl.message('Login', name: 'login');
  }

  String get forgotYourPassword {
    return Intl.message('Forgot your Password?', name: 'forgotYourPassword');
  }

  String get donNotHaveAccount {
    return Intl.message('Don\'t have Account?', name: 'donNotHaveAccount');
  }

  String get createOne {
    return Intl.message('Create one', name: 'createOne');
  }

  String get forgotPassword {
    return Intl.message('Forgot Password', name: 'forgotPassword');
  }

  String get emailWithAstric {
    return Intl.message('Email*', name: 'emailWithAstric');
  }

  String get send {
    return Intl.message('Send', name: 'send');
  }

  String get createNewAccount {
    return Intl.message('Create new account', name: 'createNewAccount');
  }

  String get accountTypeWithAstric {
    return Intl.message('Account Type*', name: 'accountTypeWithAstric');
  }

  String get firstNameWithAstric {
    return Intl.message('First Name*', name: 'firstNameWithAstric');
  }

  String get lastNameWithAstric {
    return Intl.message('Last Name*', name: 'lastNameWithAstric');
  }

  String get fullNameWithAstric {
    return Intl.message('Full Name*', name: 'fullNameWithAstric');
  }

  String get none {
    return Intl.message('None', name: 'none');
  }

  String get family {
    return Intl.message('Family', name: 'family');
  }

  String get personal {
    return Intl.message('Personal', name: 'personal');
  }

  String get relationshipWithAstric {
    return Intl.message('Relationship*', name: 'relationshipWithAstric');
  }

  String get husband {
    return Intl.message('Husband', name: 'husband');
  }

  String get wife {
    return Intl.message('Wife', name: 'wife');
  }

  String get son {
    return Intl.message('Son', name: 'son');
  }

  String get daughter {
    return Intl.message('Daughter', name: 'daughter');
  }

  String get nationalIdWithAstric {
    return Intl.message('National ID*', name: 'nationalIdWithAstric');
  }

  String get mobileWithAstric {
    return Intl.message('Mobile*', name: 'mobileWithAstric');
  }

  String get mobile {
    return Intl.message('Mobile', name: 'mobile');
  }

  String get addressWithAstric {
    return Intl.message('Address*', name: 'addressWithAstric');
  }

  String get churchOfAttendanceWithAstric {
    return Intl.message('Church of Attendance*',
        name: 'churchOfAttendanceWithAstric');
  }

  String get genderWithAstric {
    return Intl.message('Gender*', name: 'genderWithAstric');
  }

  String get male {
    return Intl.message('Male', name: 'male');
  }

  String get female {
    return Intl.message('Female', name: 'female');
  }

  String get next {
    return Intl.message('Next', name: 'next');
  }

  String get deaconWithAstric {
    return Intl.message('Deacon*', name: 'deaconWithAstric');
  }

  String get createPassword {
    return Intl.message('Create password', name: 'createPassword');
  }

  String get passwordWithAstric {
    return Intl.message('Password*', name: 'passwordWithAstric');
  }

  String get confirmPasswordWithAstric {
    return Intl.message('Confirm Password*', name: 'confirmPasswordWithAstric');
  }

  String get register {
    return Intl.message('Register', name: 'register');
  }

  String get termsAndConditionsTitle {
    return Intl.message('By creating EGY Copts account, you agree to the',
        name: 'termsAndConditionsTitle');
  }

  String get termsAndConditions {
    return Intl.message('terms and conditions', name: 'termsAndConditions');
  }

  String get privacyPolicy {
    return Intl.message('privacy policy', name: 'privacyPolicy');
  }

  String get and {
    return Intl.message('and', name: 'and');
  }

  String get pleaseEnterYourEmail {
    return Intl.message('Please enter your Email',
        name: 'pleaseEnterYourEmail');
  }

  String get pleaseEnterYourPassword {
    return Intl.message('Please enter your Password',
        name: 'pleaseEnterYourPassword');
  }

  String get pleaseEnterYourFirstName {
    return Intl.message('Please enter your First Name',
        name: 'pleaseEnterYourFirstName');
  }

  String get pleaseEnterYourLastName {
    return Intl.message('Please enter your Last Name',
        name: 'pleaseEnterYourLastName');
  }

  String get pleaseEnterYourFullName {
    return Intl.message('Please enter your Full Name',
        name: 'pleaseEnterYourFullName');
  }

  String get pleaseEnterYourFullNameThreeWords {
    return Intl.message('Please enter your Full Name',
        name: 'pleaseEnterYourFullNameThreeWords');
  }

  String get pleaseEnterYourNationalId {
    return Intl.message('Please enter your National ID',
        name: 'pleaseEnterYourNationalId');
  }

  String get pleaseEnterYourMobile {
    return Intl.message('Please enter your Mobile',
        name: 'pleaseEnterYourMobile');
  }

  String get pleaseEnterYourAddress {
    return Intl.message('Please enter your Address',
        name: 'pleaseEnterYourAddress');
  }

  String get pleaseEnterYourChurchOfAttendance {
    return Intl.message('Please enter your Church of attendance',
        name: 'pleaseEnterYourChurchOfAttendance');
  }

  String get pleaseChooseAccountType {
    return Intl.message('Please choose Account type',
        name: 'pleaseChooseAccountType');
  }

  String get pleaseChooseRelationship {
    return Intl.message('Please choose Relationship',
        name: 'pleaseChooseRelationship');
  }

  String get chooseRelationship {
    return Intl.message('Choose Relationship', name: 'chooseRelationship');
  }

  String get pleaseChooseGender {
    return Intl.message('Please choose Gender', name: 'pleaseChooseGender');
  }

  String get pleaseChooseDeacon {
    return Intl.message('Please choose Deacon', name: 'pleaseChooseDeacon');
  }

  String get pleaseEnterCorrectNationalId {
    return Intl.message('Please enter correct National ID',
        name: 'pleaseEnterCorrectNationalId');
  }

  String get pleaseEnterAValidMobileNumber {
    return Intl.message('Please enter a valid Mobile Number',
        name: 'pleaseEnterAValidMobileNumber');
  }

  String get areYouSureOfExitFromEGYCopts {
    return Intl.message('Are you sure of Exit from EGY Copts?',
        name: 'areYouSureOfExitFromEGYCopts');
  }

  String get yes {
    return Intl.message('Yes', name: 'yes');
  }

  String get no {
    return Intl.message('No', name: 'no');
  }

  String get governorate {
    return Intl.message('Governorate', name: 'governorate');
  }

  String get church {
    return Intl.message('Church', name: 'church');
  }

  String get holyLiturgyDate {
    return Intl.message('Date', name: 'holyLiturgyDate');
  }

  String get thereAre {
    return Intl.message('There are', name: 'thereAre');
  }

  String get thereIs {
    return Intl.message('There is', name: 'thereIs');
  }

  String get availableSeats {
    return Intl.message('available seats', name: 'availableSeats');
  }

  String get availableSeatSingular {
    return Intl.message('available seat', name: 'availableSeatSingular');
  }

  String get availableSeat {
    return Intl.message('available seats', name: 'availableSeat');
  }

  String get version {
    return Intl.message('Version 1.0.22', name: 'version');
  }

  String get home {
    return Intl.message('Home', name: 'home');
  }

  String get language {
    return Intl.message('Language', name: 'language');
  }

  String get changePassword {
    return Intl.message('Change Password', name: 'changePassword');
  }

  String get logout {
    return Intl.message('Logout', name: 'logout');
  }

  String get newBooking {
    return Intl.message('New Booking', name: 'newBooking');
  }

  String get myBookings {
    return Intl.message('Bookings', name: 'myBookings');
  }

  String get myFamily {
    return Intl.message('Family', name: 'myFamily');
  }

  String get myProfile {
    return Intl.message('Profile', name: 'myProfile');
  }

  String get notifications {
    return Intl.message('Notifications', name: 'notifications');
  }

  String get chooseFamilyMembers {
    return Intl.message('Choose Family Members', name: 'chooseFamilyMembers');
  }

  String get chooseFamilyMembers2 {
    return Intl.message('Choose Family Members', name: 'chooseFamilyMembers2');
  }

  String get time {
    return Intl.message('Time', name: 'time');
  }

  String get backToHome {
    return Intl.message('Back to Home', name: 'backToHome');
  }

  String get bookedSuccessfully {
    return Intl.message('Booked Successfully', name: 'bookedSuccessfully');
  }

  String get bookingNumber {
    return Intl.message('Booking number', name: 'bookingNumber');
  }

  String get pleaseSaveBookingNumber {
    return Intl.message('Please save Booking number',
        name: 'pleaseSaveBookingNumber');
  }

  String get liturgyDate {
    return Intl.message('Date', name: 'liturgyDate');
  }

  String get liturgyTime {
    return Intl.message('Time', name: 'liturgyTime');
  }

  String get addFamilyMember {
    return Intl.message('Add Family Member', name: 'addFamilyMember');
  }

  String get editFamilyMember {
    return Intl.message('Edit Family Member', name: 'editFamilyMember');
  }

  String get save {
    return Intl.message('Save', name: 'save');
  }

  String get currentPasswordWithAstric {
    return Intl.message('Current Password*', name: 'currentPasswordWithAstric');
  }

  String get newPasswordWithAstric {
    return Intl.message('New Password*', name: 'newPasswordWithAstric');
  }

  String get confirmNewPasswordWithAstric {
    return Intl.message('Confirm New Password*',
        name: 'confirmNewPasswordWithAstric');
  }

  String get pleaseEnterYourCurrentPassword {
    return Intl.message('Please enter your current password',
        name: 'pleaseEnterYourCurrentPassword');
  }

  String get pleaseEnterNewPassword {
    return Intl.message('Please enter new password',
        name: 'pleaseEnterNewPassword');
  }

  String get pleaseConfirmYourNewPassword {
    return Intl.message('Please confirm your new password',
        name: 'pleaseConfirmYourNewPassword');
  }

  String get passwordCannotBeLessThan8 {
    return Intl.message('Password can\'t be less than 8',
        name: 'passwordCannotBeLessThan8');
  }

  String get sorryThisEmailIsUsedBefore {
    return Intl.message('Sorry this email is used before',
        name: 'sorryThisEmailIsUsedBefore');
  }

  String get passwordDoesNotMatch {
    return Intl.message('Password doesn\'t match',
        name: 'passwordDoesNotMatch');
  }

  String get accountCreatedSuccessfully {
    return Intl.message(
        'Account Created Successfully, Please check your mail to verify your account',
        name: 'accountCreatedSuccessfully');
  }

  String get errorConnectingWithServer {
    return Intl.message('Error connecting with server',
        name: 'errorConnectingWithServer');
  }

  String get emailOrPasswordIsNotCorrect {
    return Intl.message('Email or Password is not correct',
        name: 'emailOrPasswordIsNotCorrect');
  }

  String get accountIsNotActivated {
    return Intl.message('Account isn\'t activated',
        name: 'accountIsNotActivated');
  }

  String get emailAndPasswordDoesNotMatch {
    return Intl.message('Email and Password doesn\'t match',
        name: 'emailAndPasswordDoesNotMatch');
  }

  String get pleaseWait {
    return Intl.message('Please wait', name: 'pleaseWait');
  }

  String get familyMembers {
    return Intl.message('Family Members', name: 'familyMembers');
  }

  String get noMembersFound {
    return Intl.message('No Members found', name: 'noMembersFound');
  }

  String get deletedSuccessfully {
    return Intl.message('Deleted Successfully', name: 'deletedSuccessfully');
  }

  String get addedSuccessfully {
    return Intl.message('Added Successfully', name: 'addedSuccessfully');
  }

  String get doYouWantToDeleteThisMember {
    return Intl.message('Do you want to delete this member?',
        name: 'doYouWantToDeleteThisMember');
  }

  String get duplicatedNationalID {
    return Intl.message('Duplicated National ID', name: 'duplicatedNationalID');
  }

  String get passwordUpdatedSuccessfully {
    return Intl.message('Password updated successfully',
        name: 'passwordUpdatedSuccessfully');
  }

  String get completeInformation {
    return Intl.message('Complete Information', name: 'completeInformation');
  }

  String get book {
    return Intl.message('Book', name: 'book');
  }

  String get noSeatsAvailable {
    return Intl.message('Sorry, No available dates', name: 'noSeatsAvailable');
  }

  String get editBooking {
    return Intl.message('Edit Booking', name: 'editBooking');
  }

  String get sorryYouCannotEditThisBooking {
    return Intl.message('Sorry you can\'t edit this booking',
        name: 'sorryYouCannotEditThisBooking');
  }

  String get noBookingFound {
    return Intl.message('No Bookings found', name: 'noBookingFound');
  }

  String get pleaseChooseAtLeastFamilyMember {
    return Intl.message('Please choose at least 1 family member',
        name: 'pleaseChooseAtLeastFamilyMember');
  }

  String get sorryYouCannotBookBefore {
    return Intl.message('Sorry you can\'t book before',
        name: 'sorryYouCannotBookBefore');
  }

  String get savedSuccessfully {
    return Intl.message('Saved Successfully', name: 'savedSuccessfully');
  }

  String get cancelBooking {
    return Intl.message('Cancel Booking', name: 'cancelBooking');
  }

  String get cancelledSuccessfully {
    return Intl.message('Cancelled Successfully',
        name: 'cancelledSuccessfully');
  }

  String get doYouWantToCancelThisBooking {
    return Intl.message('Do you want to cancel this booking?',
        name: 'doYouWantToCancelThisBooking');
  }

  String get pleaseChooseBookingDate {
    return Intl.message('Please choose booking date',
        name: 'pleaseChooseBookingDate');
  }

  String get pleaseChooseChurch {
    return Intl.message('Please choose church', name: 'pleaseChooseChurch');
  }

  String get pleaseChooseGovernorate {
    return Intl.message('Please choose governorate',
        name: 'pleaseChooseGovernorate');
  }

  String get bookADate {
    return Intl.message('Book a date', name: 'bookADate');
  }

  String get bookingInformation {
    return Intl.message('Booking information', name: 'bookingInformation');
  }

  String get chooseAttendingPersons {
    return Intl.message('Choose attending persons',
        name: 'chooseAttendingPersons');
  }

  String get confirmBooking {
    return Intl.message('Confirm Booking', name: 'confirmBooking');
  }

  String get pleaseCompleteAllInformation {
    return Intl.message('Please complete all Information',
        name: 'pleaseCompleteAllInformation');
  }

  String get loginUser {
    return Intl.message('Login', name: 'loginUser');
  }

  String get cannotDeleteBecauseThisUserIsLinkedToBookings {
    return Intl.message('Can\'t delete because this user is linked to Bookings',
        name: 'cannotDeleteBecauseThisUserIsLinkedToBookings');
  }

  String get validationRefresh {
    return Intl.message('Refresh', name: 'validationRefresh');
  }

  String get accountValidation {
    return Intl.message('Account validation', name: 'accountValidation');
  }

  String get accountNotValidated {
    return Intl.message('Account not validated', name: 'accountNotValidated');
  }

  String get pleaseCheckYourEmailToValidateYourAccount {
    return Intl.message('Please check your email to validate your account',
        name: 'pleaseCheckYourEmailToValidateYourAccount');
  }

  String get resendValidationEmail {
    return Intl.message('Resend validation email',
        name: 'resendValidationEmail');
  }

  String get emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount {
    return Intl.message(
        'Email was sent to you, Please check your email to validate your account',
        name: 'emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount');
  }

  String get chooseHolyLiturgyDate {
    return Intl.message('Choose Date', name: 'chooseHolyLiturgyDate');
  }

  String get chooseHolyLiturgyDate2 {
    return Intl.message('Choose Date', name: 'chooseHolyLiturgyDate2');
  }

  String get modify {
    return Intl.message('Modify', name: 'modify');
  }

  String get anEmailHasBeenSentToYouPleaseCheckYourInbox {
    return Intl.message(
        'An email has been sent to you, Please check your inbox',
        name: 'anEmailHasBeenSentToYouPleaseCheckYourInbox');
  }

  String get emailNotFoundPleaseCheckYourEmail {
    return Intl.message('Email not found, Please check your email',
        name: 'emailNotFoundPleaseCheckYourEmail');
  }

  String get errorConnectingToTheInternet {
    return Intl.message('Error connecting to the Internet',
        name: 'errorConnectingToTheInternet');
  }

  String get pressRetryToTryAgain {
    return Intl.message('Press retry to try again',
        name: 'pressRetryToTryAgain');
  }

  String get retry {
    return Intl.message('Retry', name: 'retry');
  }

  String get youCannotBookBecauseYouHaveABookingOnTheSameTime {
    return Intl.message(
        'You can\'t book because you have a booking on the same time',
        name: 'youCannotBookBecauseYouHaveABookingOnTheSameTime');
  }

  String get countryWithAstric {
    return Intl.message('Country*', name: 'countryWithAstric');
  }

  String get pleaseChooseCountry {
    return Intl.message('Please choose Country', name: 'pleaseChooseCountry');
  }

  String get live {
    return Intl.message('Live', name: 'live');
  }

  String get noVideosFound {
    return Intl.message('Currently not available', name: 'noVideosFound');
  }

  String get settings {
    return Intl.message('Settings', name: 'settings');
  }

  String get newsCategories {
    return Intl.message('New categories', name: 'newsCategories');
  }

  String get noNewsFound {
    return Intl.message('No news found', name: 'noNewsFound');
  }

  String get by {
    return Intl.message('By:', name: 'by');
  }

  String get newsDetails {
    return Intl.message('News details', name: 'newsDetails');
  }

  String get videoDetails {
    return Intl.message('Video Details', name: 'videoDetails');
  }

  String get bookingType {
    return Intl.message('Booking type', name: 'bookingType');
  }

  String get choose {
    return Intl.message('Choose', name: 'choose');
  }

  String get details {
    return Intl.message('Details', name: 'details');
  }

  String get youAreNotRegisteredInThisChurchMembership {
    return Intl.message('You are not registered in church membership for this church', name: 'youAreNotRegisteredInThisChurchMembership');
  }

  String get pleaseChooseAttendanceType {
    return Intl.message('Please choose attendance type', name: 'pleaseChooseAttendanceType');
  }

  String get person {
    return Intl.message('Person', name: 'person');
  }

  String get deacon {
    return Intl.message('Deacon', name: 'deacon');
  }

  String get attendanceType {
    return Intl.message('Attendance type', name: 'attendanceType');
  }

  String get chosenPersonIsNotaDeacon {
    return Intl.message('Chosen person isn\'t a deacon', name: 'chosenPersonIsNotaDeacon');
  }

  String get name {
    return Intl.message('Name', name: 'name');
  }

  String get nationalId {
    return Intl.message('National ID', name: 'nationalId');
  }

  String get nationalIdPhoto {
    return Intl.message('National ID photo', name: 'nationalIdPhoto');
  }

  String get news {
    return Intl.message('News', name: 'news');
  }
}

class SpecificLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final Locale overriddenLocale;

  SpecificLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.load(overriddenLocale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<_DefaultCupertinoLocalizations>(
          _DefaultCupertinoLocalizations(locale));

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class _DefaultCupertinoLocalizations extends DefaultCupertinoLocalizations {
  final Locale locale;

  _DefaultCupertinoLocalizations(this.locale);
}
