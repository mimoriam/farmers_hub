import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/services/speech_service.dart';
import 'package:farmers_hub/utils/time_format.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/screens/details/details_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FilteredResultsScreen extends StatefulWidget {
  String searchQuery;

  SearchOption selectedSearchOption;

  SortOption selectedSortOption;

  FilteredResultsScreen({
    super.key,
    this.searchQuery = "",
    this.selectedSearchOption = SearchOption.title,
    this.selectedSortOption = SortOption.descending,
  });

  @override
  State<FilteredResultsScreen> createState() => _FilteredResultsScreenState();
}

enum SearchOption { title, category, city, village }

// Enum for sort options
enum SortOption { ascending, descending }

class _FilteredResultsScreenState extends State<FilteredResultsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;

  final FirebaseService firebaseService = FirebaseService();

  // final SpeechService _speechService = SpeechService();
  //
  // String _recognizedText = 'Initializing speech recognition...';
  // bool _isListening = false;
  // bool _isInitialized = false;
  // bool _isInitializing = true;
  // String _errorMessage = '';
  // List<LocaleName> _availableLocales = [];
  // String? _selectedLocale;

  // Direct speech_to_text implementation instead of using SpeechService
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isListening = false;

  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  SearchOption _selectedChip = SearchOption.title;

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    var results;

    if (widget.selectedSearchOption == SearchOption.title) {
      results = await firebaseService.searchPosts(
        query,
        descending: widget.selectedSortOption == SortOption.descending,
      );
    } else if (widget.selectedSearchOption == SearchOption.category) {
      results = await firebaseService.searchPosts(
        query,
        isCategorySearch: true,
        descending: widget.selectedSortOption == SortOption.descending,
      );
    } else if (widget.selectedSearchOption == SearchOption.city) {
      results = await firebaseService.searchPostsByCity(
        query,
        descending: widget.selectedSortOption == SortOption.descending,
      );
    } else if (widget.selectedSearchOption == SearchOption.village) {
      results = await firebaseService.searchPostsByVillage(
        query,
        descending: widget.selectedSortOption == SortOption.descending,
      );
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String? query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query != null && query.isNotEmpty) {
        await _performSearch(query);
      } else if (mounted) {
        setState(() {
          _searchResults = [];
          _hasSearched = false; // Reset to initial state if search is cleared
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // _initializeSpeech();
    _initSpeech();
    // If the screen is opened with an initial search query, perform the search
    if (widget.searchQuery.isNotEmpty) {
      _performSearch(widget.searchQuery);
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;

    setState(() {
      _isListening = true;
      _lastWords = '';
    });

    print("AAAA STARTED");

    // await Future.delayed(const Duration(milliseconds: 3000), () {});

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: "en_US", // You can change this to your preferred locale
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );

    print("AAA AENDED");
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      // Update the search field with recognized text
      _formKey.currentState?.patchValue({'search': _lastWords});
      // Trigger search
      _onSearchChanged(_lastWords);
    });

    print(_lastWords);
  }

  /// Toggle speech recognition
  void _toggleListening() async {
    if (!_speechEnabled) {
      _showSpeechNotAvailableDialog();
      return;
    }

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _showSpeechNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Recognition Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Speech recognition is not available. This might be because:'),
            const SizedBox(height: 10),
            const Text('• Microphone permissions not granted'),
            const Text('• Speech services are disabled'),
            const Text('• Device does not support speech recognition'),
            const SizedBox(height: 10),
            const Text('Please check your device settings and try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initSpeech();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        print('Speech error: ${errorNotification.errorMsg}');
        setState(() {
          _isListening = false;
        });
      },
      onStatus: (status) {
        print('Speech status: $status');
        setState(() {
          _isListening = status == 'listening';
        });
      },
    );

    if (!_speechEnabled) {
      print('Speech recognition not available');
    }

    setState(() {});
  }

  // Future<void> _initializeSpeech() async {
  //   setState(() {
  //     _isInitializing = true;
  //     _recognizedText = 'Initializing speech recognition...';
  //   });
  //
  //   _speechService.onSpeechResult = (text) {
  //     setState(() {
  //       _recognizedText = text.isEmpty ? 'Listening...' : text;
  //       _formKey.currentState?.patchValue({'search': text});
  //       _onSearchChanged(text);
  //     });
  //   };
  //
  //   _speechService.onError = (error) {
  //     setState(() {
  //       _errorMessage = error;
  //     });
  //   };
  //
  //   _speechService.onListeningStateChanged = (isListening) {
  //     setState(() {
  //       _isListening = isListening;
  //       if (isListening) {
  //         _recognizedText = 'Listening...';
  //         _errorMessage = '';
  //       }
  //     });
  //   };
  //
  //   _speechService.onLocalesLoaded = (locales) {
  //     setState(() {
  //       _availableLocales = locales;
  //       _selectedLocale = _speechService.currentLocale;
  //     });
  //   };
  //
  //   bool available = await _speechService.checkAvailability();
  //   if (!available) {
  //     setState(() {
  //       _isInitializing = false;
  //       _isInitialized = false;
  //       _errorMessage =
  //       'Speech recognition not available. Please install Google app or enable speech services in your device Settings > Apps > Default apps > Voice input.';
  //       _recognizedText = 'Speech recognition unavailable';
  //     });
  //     return;
  //   }
  //
  //   bool initialized = await _speechService.initialize();
  //
  //   setState(() {
  //     _isInitializing = false;
  //     _isInitialized = initialized;
  //
  //     if (initialized) {
  //       _recognizedText = 'Ready! Press the microphone to start speaking...';
  //       _errorMessage = '';
  //       _availableLocales = _speechService.availableLocales;
  //       _selectedLocale = _speechService.currentLocale;
  //     } else {
  //       _errorMessage = _speechService.errorMessage;
  //       _recognizedText = 'Failed to initialize speech recognition';
  //     }
  //   });
  // }

  // Future<void> _initializeSpeech() async {
  //   setState(() {
  //     _isInitializing = true;
  //     _recognizedText = 'Initializing speech recognition...';
  //   });
  //
  //   print("AAAA");
  //
  //   // Set up callbacks before initialization
  //   _speechService.onSpeechResult = (text) {
  //     setState(() {
  //       _recognizedText = text.isEmpty ? 'Listening...' : text;
  //     });
  //   };
  //
  //   _speechService.onError = (error) {
  //     setState(() {
  //       _errorMessage = error;
  //     });
  //   };
  //
  //   _speechService.onListeningStateChanged = (isListening) {
  //     setState(() {
  //       _isListening = isListening;
  //       if (isListening) {
  //         _recognizedText = 'Listening...';
  //         _errorMessage = '';
  //       }
  //     });
  //   };
  //
  //   _speechService.onLocalesLoaded = (locales) {
  //     setState(() {
  //       _availableLocales = locales;
  //       _selectedLocale = _speechService.currentLocale;
  //     });
  //   };
  //
  //   // Check availability first
  //   bool available = await _speechService.checkAvailability();
  //   if (!available) {
  //     setState(() {
  //       _isInitializing = false;
  //       _isInitialized = false;
  //       _errorMessage =
  //           'Speech recognition not available. Please install Google app or enable speech services in your device Settings > Apps > Default apps > Voice input.';
  //       _recognizedText = 'Speech recognition unavailable';
  //     });
  //     return;
  //   }
  //
  //   // Initialize the service
  //   bool initialized = await _speechService.initialize();
  //
  //   setState(() {
  //     _isInitializing = false;
  //     _isInitialized = initialized;
  //
  //     if (initialized) {
  //       _recognizedText = 'Ready! Press the microphone to start speaking...';
  //       _errorMessage = '';
  //       _availableLocales = _speechService.availableLocales;
  //       _selectedLocale = _speechService.currentLocale;
  //     } else {
  //       _errorMessage = _speechService.errorMessage;
  //       _recognizedText = 'Failed to initialize speech recognition';
  //     }
  //   });
  // }

  // void _clearText() {
  //   setState(() {
  //     _recognizedText = 'Ready! Press the microphone to start speaking...';
  //     _errorMessage = '';
  //   });
  // }

  // void _showRetryDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Speech Recognition Issue'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Speech recognition is not working. This might be because:'),
  //           const SizedBox(height: 10),
  //           const Text('• Google app is not installed or updated'),
  //           const Text('• Speech services are disabled'),
  //           const Text('• Microphone permissions not granted'),
  //           const Text('• No default voice input app selected'),
  //           const SizedBox(height: 10),
  //           const Text('Would you like to try reinitializing?'),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _initializeSpeech();
  //           },
  //           child: const Text('Retry'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showLocaleDialog() {
  //   if (_availableLocales.isEmpty) return;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Language'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: _availableLocales.length,
  //           itemBuilder: (context, index) {
  //             final locale = _availableLocales[index];
  //             return ListTile(
  //               title: Text(locale.name),
  //               subtitle: Text(locale.localeId),
  //               leading: Radio<String>(
  //                 value: locale.localeId,
  //                 groupValue: _selectedLocale,
  //                 onChanged: (value) {
  //                   setState(() {
  //                     _selectedLocale = value;
  //                   });
  //                   _speechService.setLocale(value!);
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    // _speechService.dispose();
    _speechToText.stop();
    _debounce?.cancel();
    super.dispose();
  }
  //
  // void _toggleListening() async {
  //   if (!_isInitialized) {
  //     _showRetryDialog();
  //     return;
  //   }
  //
  //   if (_isListening) {
  //     await _speechService.stopListening();
  //   } else {
  //     setState(() {
  //       _recognizedText = 'Starting to listen...';
  //       _errorMessage = '';
  //     });
  //
  //     await _speechService.startListening(
  //       localeId: _selectedLocale,
  //       listenFor: const Duration(seconds: 30),
  //       pauseFor: const Duration(seconds: 2),
  //     );
  //   }
  // }

  // SearchOption _selectedSearchOption = SearchOption.title;
  SortOption _selectedSortOption = SortOption.ascending;

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulWidget to manage the state within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: scaffoldBackgroundColor,
              // title: const Text('Search & Sort Options'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Search by:', style: TextStyle(fontWeight: FontWeight.bold)),

                  RadioListTile<SearchOption>(
                    title: const Text('Title'),
                    value: SearchOption.title,
                    groupValue: widget.selectedSearchOption,
                    activeColor: onboardingColor,
                    onChanged: (SearchOption? value) {
                      setState(() {
                        if (mounted) {
                          widget.selectedSearchOption = value!;
                        }
                      });
                    },
                  ),

                  RadioListTile<SearchOption>(
                    title: const Text('Category'),
                    value: SearchOption.category,
                    groupValue: widget.selectedSearchOption,
                    activeColor: onboardingColor,
                    onChanged: (SearchOption? value) {
                      setState(() {
                        if (mounted) {
                          widget.selectedSearchOption = value!;
                        }
                      });
                    },
                  ),

                  // // const Divider(),
                  // const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                  //
                  // RadioListTile<SortOption>(
                  //   title: const Text('Ascending'),
                  //   value: SortOption.ascending,
                  //   groupValue: _selectedSortOption,
                  //   activeColor: onboardingColor,
                  //   onChanged: (SortOption? value) {
                  //     setState(() {
                  //       if (mounted) {
                  //         _selectedSortOption = value!;
                  //       }
                  //     });
                  //   },
                  // ),
                  //
                  // RadioListTile<SortOption>(
                  //   title: const Text('Descending'),
                  //   value: SortOption.descending,
                  //   groupValue: _selectedSortOption,
                  //   activeColor: onboardingColor,
                  //   onChanged: (SortOption? value) {
                  //     setState(() {
                  //       if (mounted) {
                  //         _selectedSortOption = value!;
                  //       }
                  //     });
                  //   },
                  // ),
                ],
              ),
              // actions: <Widget>[
              //   TextButton(
              //     child: const Text('Done'),
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<String> q = widget.searchQuery.split(' ');
    // String qs = widget.searchQuery;
    //
    // if (q[1] == "&") {
    //   setState(() {
    //     widget.searchQuery = q[0];
    //   });
    // }
    final List<Map<String, dynamic>> popularPostsData = const [
      {
        "image_url": "images/backgrounds/cow_2.png",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },

      {
        "image_url": "images/backgrounds/goat.png",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 0,
        "posted_ago": "02 Months Ago",
        "views": 274,
      },

      {
        "image_url": "images/backgrounds/fertilizers_spray.jpg",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 4,
        "posted_ago": "02 Months Ago",
        "views": 274,
      },

      {
        "image_url": "images/backgrounds/man_with_stick.png",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },

      {
        "image_url": "images/backgrounds/tools_and_equipments_bg.jpg",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 48,
        "posted_ago": "02 Months Ago",
        "views": 521,
      },

      {
        "image_url": "images/backgrounds/bull_and_cow.png",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 48,
        "posted_ago": "02 Months Ago",
        "views": 221,
      },
    ];

    bool selectedTitle = true;

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Filtered Search Result",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   _isInitialized
                  //       ? (_isListening ? 'Listening...' : 'Ready to listen')
                  //       : 'Speech recognition unavailable',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     color:
                  //         _isInitialized
                  //             ? (_isListening ? Colors.green.shade700 : Colors.blue.shade700)
                  //             : Colors.red.shade700,
                  //   ),
                  // ),
                  //
                  // Text(_recognizedText),
                  //
                  // if (_errorMessage.isNotEmpty)
                  //   Container(
                  //     padding: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: Colors.red.shade100,
                  //       borderRadius: BorderRadius.circular(8),
                  //       border: Border.all(color: Colors.red.shade300),
                  //     ),
                  //     child: Text(
                  //       _errorMessage,
                  //       style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                  //     ),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 14),
                    child: FormBuilderTextField(
                      name: "search",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 13.69,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                      initialValue: widget.searchQuery.isEmpty ? "" : widget.searchQuery,
                      // initialValue: qs.isEmpty ? "" : widget.searchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 13.69,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                        // suffixIcon: IconButton(
                        //   // icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                        //   icon: Icon(
                        //     _isListening ? Icons.mic_outlined : Icons.mic_none,
                        //     color: _isInitialized ? (_isListening ? Colors.green : Colors.blue) : Colors.red,
                        //     // color: onboardingColor,
                        //   ),
                        //   // icon: const Icon(Icons.sort_outlined, color: onboardingColor),
                        //   onPressed: _isInitializing ? null : _toggleListening,
                        //   // onPressed: _showOptionsDialog,
                        // ),

                        // suffixIcon: IconButton(
                        //   icon: Icon(
                        //     _isListening ? Icons.mic_off : Icons.mic,
                        //     color: _isInitialized
                        //         ? (_isListening ? Colors.red : onboardingColor)
                        //         : Colors.grey,
                        //   ),
                        //   onPressed: _isInitializing ? null : _toggleListening,
                        // ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                        ),
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     _isListening ? Icons.mic : Icons.mic_none,
                  //     color: _speechEnabled
                  //         ? (_isListening ? Colors.red : onboardingColor)
                  //         : Colors.grey,
                  //   ),
                  //   onPressed: _speechEnabled ? _toggleListening : _showSpeechNotAvailableDialog,
                  // ),

                  // Chip(
                  //   backgroundColor: onboardingColor,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  //   label: Text(
                  //     "Filters (1)",
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 10, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(width: 2),

                        FilterChip(
                          checkmarkColor: Colors.white,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                widget.selectedSearchOption = SearchOption.title;
                                widget.searchQuery = "";
                                _formKey.currentState?.patchValue({"search": ""});
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: widget.selectedSearchOption == SearchOption.title,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "Title",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        FilterChip(
                          checkmarkColor: Colors.white,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                widget.selectedSearchOption = SearchOption.category;
                                widget.searchQuery = "";
                                // _formKey.currentState?.reset();
                                _formKey.currentState?.patchValue({"search": ""});
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: widget.selectedSearchOption == SearchOption.category,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "Category",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        FilterChip(
                          checkmarkColor: Colors.white,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                widget.selectedSearchOption = SearchOption.city;
                                widget.searchQuery = "";
                                _formKey.currentState?.patchValue({"search": ""});
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: widget.selectedSearchOption == SearchOption.city,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "City",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        FilterChip(
                          checkmarkColor: Colors.white,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                widget.selectedSearchOption = SearchOption.village;
                                widget.searchQuery = "";
                                _formKey.currentState?.patchValue({"search": ""});
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: widget.selectedSearchOption == SearchOption.village,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "Village",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            FilterChip(
                              checkmarkColor: Colors.white,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    widget.selectedSortOption = SortOption.descending;
                                    widget.searchQuery = "";
                                    _formKey.currentState?.patchValue({"search": ""});
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              selected: widget.selectedSortOption == SortOption.descending,
                              selectedColor: onboardingColor,
                              backgroundColor: Colors.grey[300],
                              label: Text(
                                "Descending",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            SizedBox(width: 8),

                            FilterChip(
                              checkmarkColor: Colors.white,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    widget.selectedSortOption = SortOption.ascending;
                                    widget.searchQuery = "";
                                    // _formKey.currentState?.reset();
                                    _formKey.currentState?.patchValue({"search": ""});
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              selected: widget.selectedSortOption == SortOption.ascending,
                              selectedColor: onboardingColor,
                              backgroundColor: Colors.grey[300],
                              label: Text(
                                "Ascending",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 18, top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Results',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        Text(
                          'Results (${_searchResults.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onboardingTextColor,
                            height: 1.40,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // _searchResults.isEmpty
                  //     ? Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 10),
                  //       child: SizedBox(
                  //         height: MediaQuery.of(context).size.height * 0.5,
                  //         child: Container(alignment: Alignment.center, child: Text("No results")),
                  //       ),
                  //     )
                  //     : Container(),
                  _searchResults.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  // border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                  // borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                                  child: Icon(
                                    Icons.search_outlined, // An icon that fits the context
                                    color: Colors.grey[700],
                                    size: 36.0,
                                  ),
                                ),
                              ),

                              // const SizedBox(height: 10.0),

                              const Text(
                                'No search results',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    // child: SingleChildScrollView(
                    //   child: ListView.builder(
                    //     shrinkWrap: true,
                    //     itemCount: _searchResults.length,
                    //
                    //     itemBuilder: (BuildContext context, int index) {
                    //       final postData = _searchResults[index].data() as Map<String, dynamic>;
                    //           final postId = _searchResults[index].id;
                    //
                    //           // return ProductCard(postData: popularPostsData[index]);
                    //           return ProductCard(
                    //             postData: postData,
                    //             postId: postId,
                    //             firebaseService: firebaseService,
                    //           );
                    //     }
                    //   ),
                    // ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      // Important to make GridView work inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // Number of columns
                        crossAxisSpacing: 4.0, // Horizontal space between cards
                        mainAxisSpacing: 12.0, // Vertical space between cards
                        // childAspectRatio: 0.78, // Adjust to fit content (width / height)
                        // IMPORTANT: You'll likely need to adjust the item height.
                        // A GridView item defaults to a square aspect ratio (1.0).
                        // A full-width square will be very tall. Adjust this ratio to make
                        // your items look more like list items (wider than they are tall).
                        childAspectRatio: 3, // Example: Item is 3x wider than it is tall.
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final postData = _searchResults[index].data() as Map<String, dynamic>;
                        final postId = _searchResults[index].id;


                        // return ProductCard(postData: popularPostsData[index]);
                        return ProductCard2(
                          postData: postData,
                          postId: postId,
                          firebaseService: firebaseService,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard2 extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  final FirebaseService firebaseService;

  const ProductCard2({
    super.key,
    required this.postData,
    required this.postId,
    required this.firebaseService,
  });

  @override
  State<ProductCard2> createState() => _ProductCard2State();
}

class _ProductCard2State extends State<ProductCard2> {
  @override
  Widget build(BuildContext context) {
    final location = widget.postData['location'] as Map<String, dynamic>? ?? {};
    final city = location['city'] as String? ?? 'N/A';
    final price = widget.postData['price']?.toString() ?? '0';
    final likes = widget.postData['likes']?.toString() ?? '0';
    final views = widget.postData['views']?.toString() ?? '0';
    final List<String> imageUrls = List<String>.from(widget.postData['imageUrls'] ?? []);
    final title = widget.postData["title"]?.toString() ?? '0';

    final currentUserId = widget.firebaseService.currentUser?.uid;
    final List<dynamic> likedBy = widget.postData['likedBy'] ?? [];
    final bool isLiked = currentUserId != null && likedBy.contains(currentUserId);

    final createdAtTimestamp = widget.postData['createdAt'] as Timestamp?;
    final postedAgoText = createdAtTimestamp != null
        ? formatTimeAgo(createdAtTimestamp)
        : 'Just now';

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailsScreen(postId: widget.postId, didComeFromManagedPosts: false),
            ),
          ).then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
      child: Stack(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1, //* Changed flex to 1 for the image
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6.0),
                          bottomLeft: Radius.circular(6.0),
                        ),
                        child: Image.network(
                          imageUrls.first,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Positioned(
                      //   top: 8,
                      //   right: 8,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(6),
                      //     decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      //     child: Icon(
                      //       isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      //       color: isLiked ? Colors.red : Colors.grey,
                      //       size: 18,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1, //* Changed flex to 2 for the stats
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: onboardingColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // TODO COMMIT HERE
                        Text(
                          '\$$price',
                          style: GoogleFonts.poppins(
                            color: onboardingColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: popularPostsLocationTextColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                city,
                                style: GoogleFonts.poppins(
                                  color: popularPostsLocationTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          //* Likes and Views are now in the same row
                          children: [
                            Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              likes,
                              style: GoogleFonts.poppins(
                                color: popularPostsLocationTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.visibility_outlined, size: 16, color: onboardingColor),
                            const SizedBox(width: 4),
                            Text(
                              views,
                              style: GoogleFonts.poppins(
                                color: popularPostsLocationTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_outlined,
                              size: 16,
                              color: popularPostsLocationTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              postedAgoText,
                              style: GoogleFonts.poppins(
                                color: popularPostsLocationTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                color: isLiked ? Colors.red : Colors.grey,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  final FirebaseService firebaseService;

  const ProductCard({
    super.key,
    required this.postData,
    required this.postId,
    required this.firebaseService,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final location = widget.postData['location'] as Map<String, dynamic>? ?? {};
    final city = location['city'] as String? ?? 'N/A';
    final price = widget.postData['price']?.toString() ?? '0';
    final likes = widget.postData['likes']?.toString() ?? '0';
    final views = widget.postData['views']?.toString() ?? '0';
    final List<String> imageUrls = List<String>.from(widget.postData['imageUrls'] ?? []);

    final currentUserId = widget.firebaseService.currentUser?.uid;
    final List<dynamic> likedBy = widget.postData['likedBy'] ?? [];
    final bool isLiked = currentUserId != null && likedBy.contains(currentUserId);

    final createdAtTimestamp = widget.postData['createdAt'] as Timestamp?;
    final postedAgoText = createdAtTimestamp != null
        ? formatTimeAgo(createdAtTimestamp)
        : 'Just now';

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailsScreen(postId: widget.postId, didComeFromManagedPosts: false),
            ),
          ).then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
      child: Container(
        // width: 170,
        // height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F8A8A8A),
              spreadRadius: 0,
              blurRadius: 9,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),

                    // child: Image.asset(
                    //   "images/backgrounds/cow_2.png",
                    //   height: 120,
                    //   width: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                    child: Image.network(
                      imageUrls.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),

                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Divider(color: dividerColor),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$$price',
                    style: GoogleFonts.poppins(
                      color: onboardingColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: popularPostsLocationTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          // widget.postData['location'],
                          city,
                          style: GoogleFonts.poppins(
                            color: popularPostsLocationTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // const Spacer(), // Pushes likes to the right if location text is short
                      Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['likes'].toString(),
                        likes,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: popularPostsLocationTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['createdAt'].toString(),
                        postedAgoText,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Pushes views to the right
                      const Icon(Icons.visibility_outlined, size: 16, color: onboardingColor),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['views'].toString(),
                        views,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
