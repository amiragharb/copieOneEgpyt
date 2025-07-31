import 'package:flutter/material.dart';
import 'dart:math';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation_rotation;
  late Animation<double> animation_radius_in;
  late Animation<double> animation_radius_out;

  final double initialRadius = 80.0;
  double radius = 20.0;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));

    animation_rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_radius_in = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.57, 1.0, curve: Curves.elasticIn)));

    animation_radius_out = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.25, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_radius_out.value * initialRadius;
        }
      });
    });

    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      child: Center(
        child: Stack(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: new ExactAssetImage('images/logotransparents.png'),
                    ),
                  ),
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(pi / 4),
                  radius * sin(pi / 4),
                ),
                child:
                    /* Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/cardiogram.png'),
                    ),
                  ),
                ),*/
                    Dot(
                  radius: 5.0,
                  color: Colors.redAccent,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(2 * pi / 4),
                  radius * sin(2 * pi / 4),
                ),
                child: /*Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/lung.png'),
                    ),
                  ),
                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(3 * pi / 4),
                  radius * sin(3 * pi / 4),
                ),
                child: /*Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/baby-boy.png'),
                    ),
                  ),

                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(4 * pi / 4),
                  radius * sin(4 * pi / 4),
                ),
                child: /*Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/brain.png'),
                    ),
                  ),
                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.purple,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(5 * pi / 4),
                  radius * sin(5 * pi / 4),
                ),
                child:/* Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/ear.png'),
                    ),
                  ),
                ),*/  Dot(
                  radius: 5.0,
                  color: Colors.amberAccent,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(6 * pi / 4),
                  radius * sin(6 * pi / 4),
                ),
                child: /*Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/eye.png'),
                    ),
                  ),

                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.blue,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(7 * pi / 4),
                  radius * sin(7 * pi / 4),
                ),
                child:/* Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/toothbrush.png'),
                    ),
                  ),
                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            RotationTransition(
              turns: animation_rotation,
              child: Transform.translate(
                offset: Offset(
                  radius * cos(8 * pi / 4),
                  radius * sin(8 * pi / 4),
                ),
                child: /*Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: Image(
                      image: new ExactAssetImage('assets/cat.png'),
                    ),
                  ),
                ),*/ Dot(
                  radius: 5.0,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;

  Dot({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
