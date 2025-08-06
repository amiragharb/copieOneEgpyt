import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your Password?'**
  String get forgotYourPassword;

  /// No description provided for @donNotHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have Account?'**
  String get donNotHaveAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @emailWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Email*'**
  String get emailWithAstric;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @accountTypeWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Account Type*'**
  String get accountTypeWithAstric;

  /// No description provided for @firstNameWithAstric.
  ///
  /// In en, this message translates to:
  /// **'First Name*'**
  String get firstNameWithAstric;

  /// No description provided for @lastNameWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Last Name*'**
  String get lastNameWithAstric;

  /// No description provided for @fullNameWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Full Name*'**
  String get fullNameWithAstric;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @relationshipWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Relationship*'**
  String get relationshipWithAstric;

  /// No description provided for @husband.
  ///
  /// In en, this message translates to:
  /// **'Husband'**
  String get husband;

  /// No description provided for @wife.
  ///
  /// In en, this message translates to:
  /// **'Wife'**
  String get wife;

  /// No description provided for @son.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get son;

  /// No description provided for @daughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get daughter;

  /// No description provided for @nationalIdWithAstric.
  ///
  /// In en, this message translates to:
  /// **'National ID*'**
  String get nationalIdWithAstric;

  /// No description provided for @mobileWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Mobile*'**
  String get mobileWithAstric;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @addressWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Address*'**
  String get addressWithAstric;

  /// No description provided for @churchOfAttendanceWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Church of Attendance*'**
  String get churchOfAttendanceWithAstric;

  /// No description provided for @genderWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Gender*'**
  String get genderWithAstric;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @deaconWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Deacon*'**
  String get deaconWithAstric;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get createPassword;

  /// No description provided for @passwordWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Password*'**
  String get passwordWithAstric;

  /// No description provided for @confirmPasswordWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password*'**
  String get confirmPasswordWithAstric;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @termsAndConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'By creating EGY Copts account, you agree to the'**
  String get termsAndConditionsTitle;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicy;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @pleaseEnterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your First Name'**
  String get pleaseEnterYourFirstName;

  /// No description provided for @pleaseEnterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Last Name'**
  String get pleaseEnterYourLastName;

  /// No description provided for @pleaseEnterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Full Name'**
  String get pleaseEnterYourFullName;

  /// No description provided for @pleaseEnterYourFullNameThreeWords.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Full Name'**
  String get pleaseEnterYourFullNameThreeWords;

  /// No description provided for @pleaseEnterYourNationalId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your National ID'**
  String get pleaseEnterYourNationalId;

  /// No description provided for @pleaseEnterYourMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Mobile'**
  String get pleaseEnterYourMobile;

  /// No description provided for @pleaseEnterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Address'**
  String get pleaseEnterYourAddress;

  /// No description provided for @pleaseEnterYourChurchOfAttendance.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Church of attendance'**
  String get pleaseEnterYourChurchOfAttendance;

  /// No description provided for @pleaseChooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Please choose Account type'**
  String get pleaseChooseAccountType;

  /// No description provided for @pleaseChooseRelationship.
  ///
  /// In en, this message translates to:
  /// **'Please choose Relationship'**
  String get pleaseChooseRelationship;

  /// No description provided for @chooseRelationship.
  ///
  /// In en, this message translates to:
  /// **'Choose Relationship'**
  String get chooseRelationship;

  /// No description provided for @pleaseChooseGender.
  ///
  /// In en, this message translates to:
  /// **'Please choose Gender'**
  String get pleaseChooseGender;

  /// No description provided for @pleaseChooseDeacon.
  ///
  /// In en, this message translates to:
  /// **'Please choose Deacon'**
  String get pleaseChooseDeacon;

  /// No description provided for @pleaseEnterCorrectNationalId.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct National ID'**
  String get pleaseEnterCorrectNationalId;

  /// No description provided for @pleaseEnterAValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Mobile Number'**
  String get pleaseEnterAValidMobileNumber;

  /// No description provided for @areYouSureOfExitFromEGYCopts.
  ///
  /// In en, this message translates to:
  /// **'Are you sure of Exit from EGY Copts?'**
  String get areYouSureOfExitFromEGYCopts;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get church;

  /// No description provided for @holyLiturgyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get holyLiturgyDate;

  /// No description provided for @thereAre.
  ///
  /// In en, this message translates to:
  /// **'There are'**
  String get thereAre;

  /// No description provided for @thereIs.
  ///
  /// In en, this message translates to:
  /// **'There is'**
  String get thereIs;

  /// No description provided for @availableSeats.
  ///
  /// In en, this message translates to:
  /// **'There are {count} available seats'**
  String availableSeats(String count);

  /// No description provided for @availableSeat.
  ///
  /// In en, this message translates to:
  /// **'available seat'**
  String get availableSeat;

  /// No description provided for @availableSeatSingular.
  ///
  /// In en, this message translates to:
  /// **'There is {count} available seat'**
  String availableSeatSingular(String count);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.22'**
  String get version;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @newBooking.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get newBooking;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get myBookings;

  /// No description provided for @myFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get myFamily;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get myProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @chooseFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Choose Family Members'**
  String get chooseFamilyMembers;

  /// No description provided for @chooseFamilyMembers2.
  ///
  /// In en, this message translates to:
  /// **'Choose Family Members'**
  String get chooseFamilyMembers2;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @bookedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booked Successfully'**
  String get bookedSuccessfully;

  /// No description provided for @bookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Booking number'**
  String get bookingNumber;

  /// No description provided for @pleaseSaveBookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Please save Booking number'**
  String get pleaseSaveBookingNumber;

  /// No description provided for @liturgyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get liturgyDate;

  /// No description provided for @liturgyTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get liturgyTime;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @editFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Member'**
  String get editFamilyMember;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currentPasswordWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Current Password*'**
  String get currentPasswordWithAstric;

  /// No description provided for @newPasswordWithAstric.
  ///
  /// In en, this message translates to:
  /// **'New Password*'**
  String get newPasswordWithAstric;

  /// No description provided for @confirmNewPasswordWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password*'**
  String get confirmNewPasswordWithAstric;

  /// No description provided for @pleaseEnterYourCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterYourCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @pleaseConfirmYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmYourNewPassword;

  /// No description provided for @passwordCannotBeLessThan8.
  ///
  /// In en, this message translates to:
  /// **'Password can\'t be less than 8'**
  String get passwordCannotBeLessThan8;

  /// No description provided for @sorryThisEmailIsUsedBefore.
  ///
  /// In en, this message translates to:
  /// **'Sorry this email is used before'**
  String get sorryThisEmailIsUsedBefore;

  /// No description provided for @passwordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Password doesn\'t match'**
  String get passwordDoesNotMatch;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account Created Successfully, Please check your mail to verify your account'**
  String get accountCreatedSuccessfully;

  /// No description provided for @errorConnectingWithServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect with the server.\nPlease check your internet connection and try again.'**
  String get errorConnectingWithServer;

  /// No description provided for @emailOrPasswordIsNotCorrect.
  ///
  /// In en, this message translates to:
  /// **'Email or Password is not correct'**
  String get emailOrPasswordIsNotCorrect;

  /// No description provided for @accountIsNotActivated.
  ///
  /// In en, this message translates to:
  /// **'Account isn\'t activated'**
  String get accountIsNotActivated;

  /// No description provided for @emailAndPasswordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Email and Password doesn\'t match'**
  String get emailAndPasswordDoesNotMatch;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No Members found'**
  String get noMembersFound;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted Successfully'**
  String get deletedSuccessfully;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Added Successfully'**
  String get addedSuccessfully;

  /// No description provided for @doYouWantToDeleteThisMember.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this member?'**
  String get doYouWantToDeleteThisMember;

  /// No description provided for @duplicatedNationalID.
  ///
  /// In en, this message translates to:
  /// **'Duplicated National ID'**
  String get duplicatedNationalID;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @completeInformation.
  ///
  /// In en, this message translates to:
  /// **'Complete Information'**
  String get completeInformation;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @noSeatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Sorry, No available dates'**
  String get noSeatsAvailable;

  /// No description provided for @editBooking.
  ///
  /// In en, this message translates to:
  /// **'Edit Booking'**
  String get editBooking;

  /// No description provided for @sorryYouCannotEditThisBooking.
  ///
  /// In en, this message translates to:
  /// **'Sorry you can\'t edit this booking'**
  String get sorryYouCannotEditThisBooking;

  /// No description provided for @noBookingFound.
  ///
  /// In en, this message translates to:
  /// **'No Bookings found'**
  String get noBookingFound;

  /// No description provided for @pleaseChooseAtLeastFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Please choose at least 1 family member'**
  String get pleaseChooseAtLeastFamilyMember;

  /// No description provided for @sorryYouCannotBookBefore.
  ///
  /// In en, this message translates to:
  /// **'Sorry you can\'t book before'**
  String get sorryYouCannotBookBefore;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved Successfully'**
  String get savedSuccessfully;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @cancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Successfully'**
  String get cancelledSuccessfully;

  /// No description provided for @doYouWantToCancelThisBooking.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel this booking?'**
  String get doYouWantToCancelThisBooking;

  /// No description provided for @pleaseChooseBookingDate.
  ///
  /// In en, this message translates to:
  /// **'Please choose booking date'**
  String get pleaseChooseBookingDate;

  /// No description provided for @pleaseChooseChurch.
  ///
  /// In en, this message translates to:
  /// **'Please choose church'**
  String get pleaseChooseChurch;

  /// No description provided for @pleaseChooseGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Please choose governorate'**
  String get pleaseChooseGovernorate;

  /// No description provided for @bookADate.
  ///
  /// In en, this message translates to:
  /// **'Book a date'**
  String get bookADate;

  /// No description provided for @bookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking information'**
  String get bookingInformation;

  /// No description provided for @chooseAttendingPersons.
  ///
  /// In en, this message translates to:
  /// **'Choose attending persons'**
  String get chooseAttendingPersons;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @pleaseCompleteAllInformation.
  ///
  /// In en, this message translates to:
  /// **'Please complete all Information'**
  String get pleaseCompleteAllInformation;

  /// No description provided for @loginUser.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginUser;

  /// No description provided for @cannotDeleteBecauseThisUserIsLinkedToBookings.
  ///
  /// In en, this message translates to:
  /// **'Can\'t delete because this user is linked to Bookings'**
  String get cannotDeleteBecauseThisUserIsLinkedToBookings;

  /// No description provided for @validationRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get validationRefresh;

  /// No description provided for @accountValidation.
  ///
  /// In en, this message translates to:
  /// **'Account validation'**
  String get accountValidation;

  /// No description provided for @accountNotValidated.
  ///
  /// In en, this message translates to:
  /// **'Account not validated'**
  String get accountNotValidated;

  /// No description provided for @pleaseCheckYourEmailToValidateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to validate your account'**
  String get pleaseCheckYourEmailToValidateYourAccount;

  /// No description provided for @resendValidationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend validation email'**
  String get resendValidationEmail;

  /// No description provided for @emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Email was sent to you, Please check your email to validate your account'**
  String get emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount;

  /// No description provided for @chooseHolyLiturgyDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Holy Liturgy Date'**
  String get chooseHolyLiturgyDate;

  /// No description provided for @chooseHolyLiturgyDate2.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get chooseHolyLiturgyDate2;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @anEmailHasBeenSentToYouPleaseCheckYourInbox.
  ///
  /// In en, this message translates to:
  /// **'An email has been sent to you, Please check your inbox'**
  String get anEmailHasBeenSentToYouPleaseCheckYourInbox;

  /// No description provided for @emailNotFoundPleaseCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Email not found, Please check your email'**
  String get emailNotFoundPleaseCheckYourEmail;

  /// No description provided for @errorConnectingToTheInternet.
  ///
  /// In en, this message translates to:
  /// **'Error connecting to the Internet'**
  String get errorConnectingToTheInternet;

  /// No description provided for @pressRetryToTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Press retry to try again'**
  String get pressRetryToTryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @youCannotBookBecauseYouHaveABookingOnTheSameTime.
  ///
  /// In en, this message translates to:
  /// **'You can\'t book because you have a booking on the same time'**
  String get youCannotBookBecauseYouHaveABookingOnTheSameTime;

  /// No description provided for @countryWithAstric.
  ///
  /// In en, this message translates to:
  /// **'Country*'**
  String get countryWithAstric;

  /// No description provided for @pleaseChooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Please choose Country'**
  String get pleaseChooseCountry;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No live videos or courses are available at the moment.\nCheck back later for new content.'**
  String get noVideosFound;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newsCategories.
  ///
  /// In en, this message translates to:
  /// **'News categories'**
  String get newsCategories;

  /// No description provided for @noNewsFound.
  ///
  /// In en, this message translates to:
  /// **'No news found'**
  String get noNewsFound;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By:'**
  String get by;

  /// No description provided for @newsDetails.
  ///
  /// In en, this message translates to:
  /// **'News details'**
  String get newsDetails;

  /// No description provided for @videoDetails.
  ///
  /// In en, this message translates to:
  /// **'Video Details'**
  String get videoDetails;

  /// No description provided for @bookingType.
  ///
  /// In en, this message translates to:
  /// **'Booking type'**
  String get bookingType;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @youAreNotRegisteredInThisChurchMembership.
  ///
  /// In en, this message translates to:
  /// **'You are not registered in church membership for this church'**
  String get youAreNotRegisteredInThisChurchMembership;

  /// No description provided for @pleaseChooseAttendanceType.
  ///
  /// In en, this message translates to:
  /// **'Please choose attendance type'**
  String get pleaseChooseAttendanceType;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @deacon.
  ///
  /// In en, this message translates to:
  /// **'Deacon'**
  String get deacon;

  /// No description provided for @attendanceType.
  ///
  /// In en, this message translates to:
  /// **'Attendance type'**
  String get attendanceType;

  /// No description provided for @chosenPersonIsNotaDeacon.
  ///
  /// In en, this message translates to:
  /// **'Chosen person isn\'t a deacon'**
  String get chosenPersonIsNotaDeacon;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @nationalIdPhoto.
  ///
  /// In en, this message translates to:
  /// **'National ID photo'**
  String get nationalIdPhoto;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @doYouWantExit.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit?'**
  String get doYouWantExit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @chooseAttendanceTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Please choose the type of attendance for booking.'**
  String get chooseAttendanceTypeDescription;

  /// No description provided for @chooseAttendanceType.
  ///
  /// In en, this message translates to:
  /// **'Choose Attendance Type'**
  String get chooseAttendanceType;

  /// No description provided for @availableSeatsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are {count} available seats'**
  String availableSeatsMessage(String count);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @locationInformation.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Success'**
  String get bookingSuccess;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @watchLiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch live streams and courses'**
  String get watchLiveSubtitle;

  /// No description provided for @videoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Video loading failed'**
  String get videoLoadFailed;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @watchLive.
  ///
  /// In en, this message translates to:
  /// **'Watch Live'**
  String get watchLive;

  /// No description provided for @streaming.
  ///
  /// In en, this message translates to:
  /// **'STREAMING'**
  String get streaming;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'RECORDED'**
  String get recorded;

  /// No description provided for @noDateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No date available'**
  String get noDateAvailable;

  /// No description provided for @connectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionErrorTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noVideosFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Live Videos'**
  String get noVideosFoundTitle;

  /// No description provided for @videoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video not available'**
  String get videoNotAvailable;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @liveStreaming.
  ///
  /// In en, this message translates to:
  /// **'LIVE STREAMING'**
  String get liveStreaming;

  /// No description provided for @recordedVideo.
  ///
  /// In en, this message translates to:
  /// **'RECORDED VIDEO'**
  String get recordedVideo;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @videoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Video Not Found'**
  String get videoNotFound;

  /// No description provided for @loadingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Loading calendar...'**
  String get loadingCalendar;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get pleaseTryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
