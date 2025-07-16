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
/// import 'i18n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Hub'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @yourCropIcon.
  ///
  /// In en, this message translates to:
  /// **'Your Crop Icon'**
  String get yourCropIcon;

  /// No description provided for @yourCrop.
  ///
  /// In en, this message translates to:
  /// **'YOUR CROP'**
  String get yourCrop;

  /// No description provided for @yourCropHub.
  ///
  /// In en, this message translates to:
  /// **'Your Crop'**
  String get yourCropHub;

  /// No description provided for @yourHubCrop.
  ///
  /// In en, this message translates to:
  /// **'Your Hub'**
  String get yourHubCrop;

  /// No description provided for @buySell.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell Securely Online.'**
  String get buySell;

  /// No description provided for @loginToCrop.
  ///
  /// In en, this message translates to:
  /// **'Login to YOUR CROP'**
  String get loginToCrop;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordCondition.
  ///
  /// In en, this message translates to:
  /// **'Password must not be less than 6 characters'**
  String get passwordCondition;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get continueWith;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get warning;

  /// No description provided for @finishRegisteration.
  ///
  /// In en, this message translates to:
  /// **'Please finish your user registration!'**
  String get finishRegisteration;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get ok;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInfo;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter your contact details to continue'**
  String get enterDetails;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name'**
  String get enterName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get enterUsername;

  /// No description provided for @enterUserMail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Email'**
  String get enterUserMail;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// No description provided for @enterpassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterpassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get wrongPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Password'**
  String get confirmYourPassword;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get fetchingLocation;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @gotNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get gotNoLocation;

  /// No description provided for @locationServiceDisable.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServiceDisable;

  /// No description provided for @enableLocationService.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services in settings.'**
  String get enableLocationService;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitApp;

  /// No description provided for @confirmExit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExit;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get no;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @homeIcon.
  ///
  /// In en, this message translates to:
  /// **'Home Icon'**
  String get homeIcon;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @chatIcon.
  ///
  /// In en, this message translates to:
  /// **'Chat Icon'**
  String get chatIcon;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @favoritesIcon.
  ///
  /// In en, this message translates to:
  /// **'Favorites Icon'**
  String get favoritesIcon;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @profileIcon.
  ///
  /// In en, this message translates to:
  /// **'Profile Icon'**
  String get profileIcon;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location: '**
  String get location;

  /// No description provided for @locationNew.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationNew;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @damascus.
  ///
  /// In en, this message translates to:
  /// **'Damascus'**
  String get damascus;

  /// No description provided for @aleppo.
  ///
  /// In en, this message translates to:
  /// **'Aleppo'**
  String get aleppo;

  /// No description provided for @homs.
  ///
  /// In en, this message translates to:
  /// **'Homs'**
  String get homs;

  /// No description provided for @hama.
  ///
  /// In en, this message translates to:
  /// **'Hama'**
  String get hama;

  /// No description provided for @latakia.
  ///
  /// In en, this message translates to:
  /// **'Latakia'**
  String get latakia;

  /// No description provided for @tartus.
  ///
  /// In en, this message translates to:
  /// **'Tartus'**
  String get tartus;

  /// No description provided for @baniyas.
  ///
  /// In en, this message translates to:
  /// **'Baniyas'**
  String get baniyas;

  /// No description provided for @idlib.
  ///
  /// In en, this message translates to:
  /// **'Idlib'**
  String get idlib;

  /// No description provided for @deirezzor.
  ///
  /// In en, this message translates to:
  /// **'Deir ez-Zor'**
  String get deirezzor;

  /// No description provided for @alhasakah.
  ///
  /// In en, this message translates to:
  /// **'Al-Hasakah'**
  String get alhasakah;

  /// No description provided for @qamishli.
  ///
  /// In en, this message translates to:
  /// **'Qamishli'**
  String get qamishli;

  /// No description provided for @raqqa.
  ///
  /// In en, this message translates to:
  /// **'Raqqa'**
  String get raqqa;

  /// No description provided for @daraa.
  ///
  /// In en, this message translates to:
  /// **'Daraa'**
  String get daraa;

  /// No description provided for @adsuwayda.
  ///
  /// In en, this message translates to:
  /// **'As-Suwayda'**
  String get adsuwayda;

  /// No description provided for @quenitra.
  ///
  /// In en, this message translates to:
  /// **'Quneitra'**
  String get quenitra;

  /// No description provided for @almayadin.
  ///
  /// In en, this message translates to:
  /// **'Al-Mayadin'**
  String get almayadin;

  /// No description provided for @albakamal.
  ///
  /// In en, this message translates to:
  /// **'Al-Bukamal'**
  String get albakamal;

  /// No description provided for @rifdimashq.
  ///
  /// In en, this message translates to:
  /// **'Rif Dimashq'**
  String get rifdimashq;

  /// No description provided for @afrin.
  ///
  /// In en, this message translates to:
  /// **'Afrin'**
  String get afrin;

  /// No description provided for @manbij.
  ///
  /// In en, this message translates to:
  /// **'Manbij'**
  String get manbij;

  /// No description provided for @tellabyad.
  ///
  /// In en, this message translates to:
  /// **'Tell Abyad'**
  String get tellabyad;

  /// No description provided for @asalayn.
  ///
  /// In en, this message translates to:
  /// **'Ras al-Ayn'**
  String get asalayn;

  /// No description provided for @kobani.
  ///
  /// In en, this message translates to:
  /// **'Kobani'**
  String get kobani;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @noPost.
  ///
  /// In en, this message translates to:
  /// **'No featured posts to view.'**
  String get noPost;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data.'**
  String get failedToLoad;

  /// No description provided for @flameIcon.
  ///
  /// In en, this message translates to:
  /// **'Flame Icon'**
  String get flameIcon;

  /// No description provided for @popularPost.
  ///
  /// In en, this message translates to:
  /// **'Popular Posts'**
  String get popularPost;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @plantIcon.
  ///
  /// In en, this message translates to:
  /// **'Plant Icon'**
  String get plantIcon;

  /// No description provided for @farmingTip.
  ///
  /// In en, this message translates to:
  /// **'Farming Tip of the Day'**
  String get farmingTip;

  /// No description provided for @farmingDyTip.
  ///
  /// In en, this message translates to:
  /// **'Perfect day for soil preparation and planting seedlings. Moisture levels are optimal.'**
  String get farmingDyTip;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'Explore our Products'**
  String get exploreProducts;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'usd'**
  String get usd;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'euro'**
  String get euro;

  /// No description provided for @lira.
  ///
  /// In en, this message translates to:
  /// **'lira'**
  String get lira;

  /// No description provided for @syp.
  ///
  /// In en, this message translates to:
  /// **'ل.س'**
  String get syp;

  /// No description provided for @usd2.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get usd2;

  /// No description provided for @euro2.
  ///
  /// In en, this message translates to:
  /// **'€'**
  String get euro2;

  /// No description provided for @lira2.
  ///
  /// In en, this message translates to:
  /// **'₺'**
  String get lira2;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @addProducts.
  ///
  /// In en, this message translates to:
  /// **'Add pictures for your Product'**
  String get addProducts;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @addUpToFour.
  ///
  /// In en, this message translates to:
  /// **'Add up to 4 photos for more views!'**
  String get addUpToFour;

  /// No description provided for @addPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Post Title'**
  String get addPostTitle;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get typeHere;

  /// No description provided for @postTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Post title is required.'**
  String get postTitleRequired;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select Your City'**
  String get selectCity;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required.'**
  String get cityRequired;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @enterVillage.
  ///
  /// In en, this message translates to:
  /// **'Enter Village'**
  String get enterVillage;

  /// No description provided for @villageRequired.
  ///
  /// In en, this message translates to:
  /// **'Village is required.'**
  String get villageRequired;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @oliveOil.
  ///
  /// In en, this message translates to:
  /// **'Olive Oil'**
  String get oliveOil;

  /// No description provided for @liveStock.
  ///
  /// In en, this message translates to:
  /// **'Live Stock'**
  String get liveStock;

  /// No description provided for @grainSeeds.
  ///
  /// In en, this message translates to:
  /// **'Grains & Seeds'**
  String get grainSeeds;

  /// No description provided for @fertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get fertilizers;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @landServices.
  ///
  /// In en, this message translates to:
  /// **'Land Services'**
  String get landServices;

  /// No description provided for @equipments.
  ///
  /// In en, this message translates to:
  /// **'Equipments'**
  String get equipments;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @workerServices.
  ///
  /// In en, this message translates to:
  /// **'Worker Services'**
  String get workerServices;

  /// No description provided for @pesticides.
  ///
  /// In en, this message translates to:
  /// **'Pesticides'**
  String get pesticides;

  /// No description provided for @animalsFeed.
  ///
  /// In en, this message translates to:
  /// **'Animal Feed'**
  String get animalsFeed;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @genderRequires.
  ///
  /// In en, this message translates to:
  /// **'Gender is required.'**
  String get genderRequires;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select a Gender'**
  String get selectGender;

  /// No description provided for @categoryRequires.
  ///
  /// In en, this message translates to:
  /// **'Category is required.'**
  String get categoryRequires;

  /// No description provided for @averageWeight.
  ///
  /// In en, this message translates to:
  /// **'Average Weight (in kgs)'**
  String get averageWeight;

  /// No description provided for @enterAverageWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter Average Weight in kilograms'**
  String get enterAverageWeight;

  /// No description provided for @enterAverageWeightRequires.
  ///
  /// In en, this message translates to:
  /// **'Average weight is required.'**
  String get enterAverageWeightRequires;

  /// No description provided for @numberMust.
  ///
  /// In en, this message translates to:
  /// **'Must be a number.'**
  String get numberMust;

  /// No description provided for @weighNotNegative.
  ///
  /// In en, this message translates to:
  /// **'Weight cannot be negative.'**
  String get weighNotNegative;

  /// No description provided for @weighNotExceed.
  ///
  /// In en, this message translates to:
  /// **'Weight cannot exceed.'**
  String get weighNotExceed;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age (in years)'**
  String get age;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age in years'**
  String get enterAge;

  /// No description provided for @ageRequires.
  ///
  /// In en, this message translates to:
  /// **'Age is required.'**
  String get ageRequires;

  /// No description provided for @ageNotNegative.
  ///
  /// In en, this message translates to:
  /// **'Age cannot be negative.'**
  String get ageNotNegative;

  /// No description provided for @ageNotExceed.
  ///
  /// In en, this message translates to:
  /// **'Age cannot exceed.'**
  String get ageNotExceed;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get enterQuantity;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required.'**
  String get quantityRequired;

  /// No description provided for @mustWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a whole number.'**
  String get mustWholeNumber;

  /// No description provided for @quantityLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be at least 1.'**
  String get quantityLeastOne;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @syria.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get syria;

  /// No description provided for @syriaC.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get syriaC;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Price'**
  String get enterPrice;

  /// No description provided for @priceRequires.
  ///
  /// In en, this message translates to:
  /// **'Price is required.'**
  String get priceRequires;

  /// No description provided for @priceNotNegative.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be negative.'**
  String get priceNotNegative;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload an image!'**
  String get uploadImage;

  /// No description provided for @uploadFourImagesOnly.
  ///
  /// In en, this message translates to:
  /// **'Can\'t upload more than 4 images!'**
  String get uploadFourImagesOnly;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apples'**
  String get apple;

  /// No description provided for @cheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get cheese;

  /// No description provided for @pomegranates.
  ///
  /// In en, this message translates to:
  /// **'Pomegranates'**
  String get pomegranates;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search Categories'**
  String get searchCategories;

  /// No description provided for @popularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get popularCategories;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @lastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message...'**
  String get lastMessage;

  /// No description provided for @usernameSpace.
  ///
  /// In en, this message translates to:
  /// **'User Name...........'**
  String get usernameSpace;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong:'**
  String get somethingWrong;

  /// No description provided for @itsAvalabe.
  ///
  /// In en, this message translates to:
  /// **'Hi its available'**
  String get itsAvalabe;

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessage;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Would you like to contact an admin?'**
  String get contactAdmin;

  /// No description provided for @allChats.
  ///
  /// In en, this message translates to:
  /// **'All Chats'**
  String get allChats;

  /// No description provided for @initialName.
  ///
  /// In en, this message translates to:
  /// **'initialName'**
  String get initialName;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'defaultCurrency'**
  String get defaultCurrency;

  /// No description provided for @currencyExchange.
  ///
  /// In en, this message translates to:
  /// **'Currency Exchange'**
  String get currencyExchange;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @notLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch the dialer for'**
  String get notLaunchDialer;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found or has been deleted'**
  String get postNotFound;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes:'**
  String get likes;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views:'**
  String get views;

  /// No description provided for @managePost.
  ///
  /// In en, this message translates to:
  /// **'Manage Posts'**
  String get managePost;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get post;

  /// No description provided for @noUserPost.
  ///
  /// In en, this message translates to:
  /// **'User has no posts!'**
  String get noUserPost;

  /// No description provided for @cantChat.
  ///
  /// In en, this message translates to:
  /// **'Can\'t chat with yourself'**
  String get cantChat;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @whatsappNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp not installed'**
  String get whatsappNotInstalled;

  /// No description provided for @verifiedSeller.
  ///
  /// In en, this message translates to:
  /// **'Verified Seller'**
  String get verifiedSeller;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model:'**
  String get model;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle here'**
  String get subtitle;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Post Title'**
  String get postTitle;

  /// No description provided for @postTitleRequires.
  ///
  /// In en, this message translates to:
  /// **'Post title is required.'**
  String get postTitleRequires;

  /// No description provided for @selectYourCity.
  ///
  /// In en, this message translates to:
  /// **'Select Your City'**
  String get selectYourCity;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @changeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change Your Address'**
  String get changeAddress;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enterAddress;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully!'**
  String get changesSuccess;

  /// No description provided for @addressRequires.
  ///
  /// In en, this message translates to:
  /// **'Address is required.'**
  String get addressRequires;

  /// No description provided for @phoneNumberRequires.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get phoneNumberRequires;

  /// No description provided for @nameRequires.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get nameRequires;

  /// No description provided for @validPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get validPhoneNumber;

  /// No description provided for @nameMustHaveThreeLetters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters.'**
  String get nameMustHaveThreeLetters;

  /// No description provided for @changeDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Change Display Name'**
  String get changeDisplayName;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error;

  /// No description provided for @errorsCorrection.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form.'**
  String get errorsCorrection;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'Form data is invalid.'**
  String get invalidData;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @postDetails.
  ///
  /// In en, this message translates to:
  /// **'Post details...'**
  String get postDetails;

  /// No description provided for @haveNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'You have no favorite posts yet!'**
  String get haveNoFavorites;

  /// No description provided for @favoritesLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading favorites.'**
  String get favoritesLoadingError;

  /// No description provided for @myFavoritesPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Post Title'**
  String get myFavoritesPostTitle;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Do you have a suggestion or found a bug? Let us know in the field below.'**
  String get suggestions;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @maxChars.
  ///
  /// In en, this message translates to:
  /// **'Max 120 Characters'**
  String get maxChars;

  /// No description provided for @bug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get bug;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get submitFeedback;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @feedbackRequires.
  ///
  /// In en, this message translates to:
  /// **'Feedback is required.'**
  String get feedbackRequires;

  /// No description provided for @describeExperience.
  ///
  /// In en, this message translates to:
  /// **'Describe your experience here... '**
  String get describeExperience;

  /// No description provided for @yourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get yourExperience;

  /// No description provided for @sendYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Us Your Feedback!'**
  String get sendYourFeedback;

  /// No description provided for @speechRecognition.
  ///
  /// In en, this message translates to:
  /// **'Initializing speech recognition...'**
  String get speechRecognition;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters (1)'**
  String get filters;

  /// No description provided for @filteredSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Filtered Search Result'**
  String get filteredSearchResults;

  /// No description provided for @searchBy.
  ///
  /// In en, this message translates to:
  /// **'Search by:'**
  String get searchBy;

  /// No description provided for @startingListen.
  ///
  /// In en, this message translates to:
  /// **'Starting to listen...'**
  String get startingListen;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @tryInitializing.
  ///
  /// In en, this message translates to:
  /// **'Would you like to try reinitializing?'**
  String get tryInitializing;

  /// No description provided for @inputSelected.
  ///
  /// In en, this message translates to:
  /// **'• No default voice input app selected'**
  String get inputSelected;

  /// No description provided for @speechServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'• Speech services are disabled'**
  String get speechServiceDisabled;

  /// No description provided for @googleAppNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'• Google app is not installed or updated'**
  String get googleAppNotInstalled;

  /// No description provided for @failedRecognition.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize speech recognition'**
  String get failedRecognition;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition unavailable'**
  String get speechUnavailable;

  /// No description provided for @speechRecognitionIssue.
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition Issue'**
  String get speechRecognitionIssue;

  /// No description provided for @microphonePermissionNotGranted.
  ///
  /// In en, this message translates to:
  /// **'• Microphone permissions not granted'**
  String get microphonePermissionNotGranted;

  /// No description provided for @speechNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not working. This might be because:'**
  String get speechNotWorking;

  /// No description provided for @pressMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Ready! Press the microphone to start speaking...'**
  String get pressMicrophone;

  /// No description provided for @speechError.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available. Please install Google app or enable speech services in your device Settings > Apps > Default apps > Voice input.'**
  String get speechError;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Agree Terms & Conditions'**
  String get agreeTerms;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use Policy.'**
  String get terms;

  /// No description provided for @continueAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to '**
  String get continueAgree;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **' Choose Preferred Language\''**
  String get chooseLanguage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farmers Hub! Buy & Sell Fruits, Vegetables, Livestock, & More – All Securely Online.'**
  String get welcome;

  /// No description provided for @managePosts.
  ///
  /// In en, this message translates to:
  /// **'Manage Posts'**
  String get managePosts;

  /// No description provided for @allPost.
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get allPost;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @youSure.
  ///
  /// In en, this message translates to:
  /// **'Are you Sure?'**
  String get youSure;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sureForDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post? Once deleted, the data will be permanently removed.'**
  String get sureForDeletePost;

  /// No description provided for @yourPostDetails.
  ///
  /// In en, this message translates to:
  /// **'Post details...'**
  String get yourPostDetails;

  /// No description provided for @youPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Post Title'**
  String get youPostTitle;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @postHistory.
  ///
  /// In en, this message translates to:
  /// **'Post History'**
  String get postHistory;

  /// No description provided for @accountVerification.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get accountVerification;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @noLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch'**
  String get noLaunch;

  /// No description provided for @customerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get customerSupport;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @profileInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfo;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout of account'**
  String get logout;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @lookingForMore.
  ///
  /// In en, this message translates to:
  /// **'Looking for more as you want!'**
  String get lookingForMore;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty.'**
  String get requiredField;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'This field requires a valid email address.'**
  String get validEmail;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Mobile Number'**
  String get invalidNumber;

  /// No description provided for @titleS.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleS;

  /// No description provided for @categoryS.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryS;

  /// No description provided for @cityS.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityS;

  /// No description provided for @villageS.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get villageS;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission & Membership'**
  String get commission;

  /// No description provided for @rateus.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @reviewBy.
  ///
  /// In en, this message translates to:
  /// **'Review by'**
  String get reviewBy;

  /// No description provided for @syriaLabel.
  ///
  /// In en, this message translates to:
  /// **'Syria (ل.س)'**
  String get syriaLabel;

  /// No description provided for @usdLabel.
  ///
  /// In en, this message translates to:
  /// **'Usd (\$)'**
  String get usdLabel;

  /// No description provided for @euroLabel.
  ///
  /// In en, this message translates to:
  /// **'Euro (€)'**
  String get euroLabel;

  /// No description provided for @liraLabel.
  ///
  /// In en, this message translates to:
  /// **'Lira (₺)'**
  String get liraLabel;

  /// No description provided for @allahMubarak.
  ///
  /// In en, this message translates to:
  /// **'Allah You\'re Mubarak'**
  String get allahMubarak;

  /// No description provided for @sellProduct.
  ///
  /// In en, this message translates to:
  /// **'Sell your product at 1% commission Only at Mahsolek. The fee is a trust owed by the advertiser, whether the sale is made for By or because of the site, the value of which is explained as follows'**
  String get sellProduct;

  /// No description provided for @commitToThat.
  ///
  /// In en, this message translates to:
  /// **'I commit to that'**
  String get commitToThat;

  /// No description provided for @confirmD.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmD;

  /// No description provided for @monthlyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit Reached'**
  String get monthlyLimitReached;

  /// No description provided for @monthlyLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'You have reached your limit of 2 posts per month. Subscribe now to post without limits.'**
  String get monthlyLimitLabel;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 4 photos.'**
  String get addPhotos;

  /// No description provided for @safetyGuidelines.
  ///
  /// In en, this message translates to:
  /// **'1 - Contact the person you intend to meet via the app or another secure means before the actual meeting to ensure their credibility.\n- It is preferable that the specified meeting place be in well-known, populated public places.\n- Before the meeting, inform a trusted person of the meeting details, such as the place and time, and inform them that you will be in contact with them after the meeting.\n\n2 - It is always preferable to have someone accompanying you during the meeting. Especially if the meeting is with a stranger.\n\n3 - Avoid sharing sensitive personal information during the first meeting, such as home addresses or financial information.\n\n4 - The identities of agricultural landowners and buyers must be verified before any agreement. Methods such as official ID verification or land ownership documents may be used.\n\n5 - Users should remember that the primary purpose of the application is to facilitate buying and selling processes and not to get involved in unrelated transactions.'**
  String get safetyGuidelines;

  /// No description provided for @nothingToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to see here'**
  String get nothingToSeeHere;

  /// No description provided for @startAConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with any of the sellers.\nYour chats will show here.'**
  String get startAConversation;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reportAd.
  ///
  /// In en, this message translates to:
  /// **'Report a violating ad'**
  String get reportAd;

  /// No description provided for @enterReport.
  ///
  /// In en, this message translates to:
  /// **'Enter your report here...'**
  String get enterReport;

  /// No description provided for @reportToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Report to admin'**
  String get reportToAdmin;

  /// No description provided for @searchByCountries.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchByCountries;

  /// No description provided for @commissionMembership.
  ///
  /// In en, this message translates to:
  /// **'Commission of Membership'**
  String get commissionMembership;

  /// No description provided for @sellProductCommission.
  ///
  /// In en, this message translates to:
  /// **'Sell your product at 1% commission\nOnly at Mahsolek. The fee is a trust owed by the\nadvertiser, whether the sale is made for By or\nbecause of the site, the value of which is\nexplained as follows'**
  String get sellProductCommission;

  /// No description provided for @calculateCommission.
  ///
  /// In en, this message translates to:
  /// **'Calculate Commission'**
  String get calculateCommission;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Sale Price'**
  String get salePrice;

  /// No description provided for @totalComission.
  ///
  /// In en, this message translates to:
  /// **'Total Commission'**
  String get totalComission;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @onlinePayment.
  ///
  /// In en, this message translates to:
  /// **'How to Pay First Method'**
  String get onlinePayment;

  /// No description provided for @onlinePayment2.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get onlinePayment2;

  /// No description provided for @sendCopyReceipt.
  ///
  /// In en, this message translates to:
  /// **'Send Copy Receipt'**
  String get sendCopyReceipt;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get upload;

  /// No description provided for @sendingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Sending receipt...'**
  String get sendingReceipt;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get emailSent;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email!'**
  String get checkEmail;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
