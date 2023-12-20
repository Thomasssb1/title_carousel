import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'carousel_image.dart';

/// The carousel widget which displays multiple [CarouselImage] widgets
class TitleCarousel extends StatefulWidget {
  /// The list of [CarouselImage] widgets to display
  final List<CarouselImage> images;

  /// The width of the indicator section
  final double? indicatorWidth;

  /// The duration that each image is displayed
  final Duration? duration;

  /// The decoration of the indicator dots
  final BoxDecoration? dotDecoration;

  /// The color of the selected indicator dot
  final Color selectedColor;

  /// The threshold for the luminance of the image to determine the color of the text overlay
  ///
  /// If the luminance is greater than the threshold, the text overlay will be dark
  final double threshold;

  /// The padding of the indicator section
  final EdgeInsets? indicatorPadding;

  /// The carousel widget which displays multiple [CarouselImage] widgets
  TitleCarousel(
      {Key? key,
      required this.images,
      this.indicatorWidth = 300,
      this.duration = const Duration(seconds: 3),
      BoxDecoration? dotDecoration,
      this.selectedColor = Colors.red,
      this.threshold = 0.3,
      this.indicatorPadding = const EdgeInsets.only(bottom: 100)})
      : dotDecoration = dotDecoration ??
            BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2 * pi),
                border: Border.all(color: Colors.black, width: 2)),
        super(key: key);

  @override
  State<TitleCarousel> createState() => _TitleCarouselState(
      images: images,
      indicatorWidth: indicatorWidth!,
      duration: duration!,
      dDecoration: dotDecoration!,
      selectedColor: selectedColor,
      threshold: threshold,
      indicatorPadding: indicatorPadding!);
}

class _TitleCarouselState extends State<TitleCarousel> {
  late List<CarouselImage> images;
  late double indicatorWidth;
  late Duration duration;
  late BoxDecoration dDecoration;
  late Color selectedColor;
  late Color textColor;
  late double threshold;
  late EdgeInsets indicatorPadding;

  int _currentImage = 0;
  final double _gap = 10;
  bool _paused = false;
  List<_Indicator> _dots = [];

  _TitleCarouselState(
      {required this.images,
      required this.indicatorWidth,
      required this.duration,
      required this.dDecoration,
      required this.selectedColor,
      required this.threshold,
      required this.indicatorPadding});

  void _generateDots() {
    for (int i = 0; i < images.length; i++) {
      _dots.add(_Indicator(selectedColour: selectedColor, dot: dDecoration));
      if (i == 0) _dots[0].setSelected(true);
    }
  }

  void _changeImage() {
    if (mounted) {
      setState(() {
        _dots[_currentImage].setSelected(false);
        _currentImage = (_currentImage + 1) % images.length;
        _dots[_currentImage].setSelected(true);
      });
    } else {
      pause();
    }
  }

  void pause() {
    _paused = true;
    if (mounted) {
      setState(() {});
    }
  }

  void play() {
    _paused = false;
    if (mounted) {
      setState(() {});
    }
    _schedule();
  }

  void setTextColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  Timer _schedule() => Timer.periodic(duration, (timer) {
        if (_paused) {
          timer.cancel();
        } else {
          _changeImage();
        }
      });

  void _setLuminance() async {
    for (int i = 0; i < images.length; i++) {
      if (images[i].titleOverlay != null &&
          images[i].titleOverlay!.computeLuminance!) {
        images[i].setLuminance(threshold);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _generateDots();
    _schedule();
    _setLuminance();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      images[_currentImage],
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              width: indicatorWidth,
              child: Padding(
                  padding: indicatorPadding,
                  child: Row(
                      children: List.generate(_dots.length, (index) {
                    return AnimatedContainer(
                      margin: EdgeInsets.only(left: (index > 0) ? _gap : 0),
                      duration: duration,
                      decoration: _dots[index].getDot(),
                      width: ((indicatorWidth - ((images.length - 1) * _gap)) /
                              (images.length + 0.5)) *
                          ((index == _currentImage) ? 1.5 : 1),
                      height: 10,
                    );
                  })))))
    ]);
  }
}

class _Indicator {
  late BoxDecoration _dot;
  late Color _unselectedColour;
  late Color _selectedColour;

  void setSelected(bool selected) {
    _dot = _dot.copyWith(color: selected ? _selectedColour : _unselectedColour);
  }

  BoxDecoration getDot() => _dot;

  _Indicator({required Color selectedColour, required BoxDecoration dot}) {
    _selectedColour = selectedColour;
    _unselectedColour = dot.color!;
    _dot = dot;
  }
}
