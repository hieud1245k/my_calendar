import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _events = [
    {"dy": 100.0, "height": 120.0, "name": "Event 1"},
    {"dy": 300.0, "height": 60.0, "name": "Event 2"},
    {"dy": 600.0, "height": 100.0, "name": "Event 3"},
    {"dy": 720.0, "height": 120.0, "name": "Event 4"},
  ];
  late ScrollController scrollController;
  int focusIndex = -1;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Stack(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 45,
                      child: Column(children: _buildTimeRows()),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Colors.black26,
                    ),
                    Expanded(child: Column(children: _buildFrameRows())),
                  ],
                ),
              ),
              ..._events.map((e) {
                double height = e["height"];
                return Positioned(
                  left: 46,
                  top: e["dy"],
                  right: 16,
                  child: LongPressDraggable(
                    onDragEnd: (details) {
                      double newDy =
                          ((details.offset.dy + scrollController.offset - 20) ~/
                              20) *
                          20;
                      if (canMove(e["name"], newDy, height)) {
                        setState(() {
                          e["dy"] = newDy;
                        });
                      }
                    },
                    feedback: Container(
                      width: MediaQuery.of(context).size.width - 16 - 50,
                      height: height,
                      margin: const EdgeInsets.all(2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: height <= 20 ? 0 : 8,
                      ),
                      color: Colors.blue.withValues(alpha: 0.5),
                      child: Text(
                        e["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    child: Container(
                      height: height,
                      margin: const EdgeInsets.all(2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: height <= 20 ? 0 : 8,
                      ),
                      color: Colors.blue,
                      child: Stack(
                        children: [
                          Text(
                            e["name"],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _events.remove(e);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.black38,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimeRows() {
    List<Widget> timeRows = [];
    for (var i = 0; i <= 24; i++) {
      if (i % 24 == 0) {
        timeRows.add(
          SizedBox(
            height: 2 * 20,
            child: i == 0
                ? const Text(
                    "12 am",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  )
                : null,
          ),
        );
      } else {
        timeRows.add(
          Container(
            height: 4 * 20,
            alignment: Alignment.center,
            child: Text(
              i > 12
                  ? "${i % 12} pm"
                  : i == 12
                  ? "12 pm"
                  : "$i am",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        );
      }
    }
    return timeRows;
  }

  List<Widget> _buildFrameRows() {
    List<Widget> frameRows = [];
    for (var i = 0; i < 24 * 4; i++) {
      frameRows.add(
        Divider(
          color: i % 4 == 0
              ? Colors.black26
              : i % 2 == 0
              ? Colors.black12
              : Colors.transparent,
          height: 1,
          thickness: 1,
        ),
      );
      frameRows.add(_buildFrame(i));
    }
    return frameRows;
  }

  Widget _buildFrame(int index) {
    return Listener(
      onPointerDown: (event) {
        focusIndex = -1;
        debugPrint("down");
      },
      onPointerMove: (event) {
        if (focusIndex == index) {
          var e = _events.last;
          double originDy = e["origin_dy"];
          double newDy = event.position.dy + scrollController.offset - 20;
          if (newDy >= originDy) {
            setState(() {
              e["dy"] = originDy;
              e["height"] = getHeightRow(newDy - originDy);
            });
          } else {
            double newHeight = getHeightRow(originDy - newDy);
            setState(() {
              e["dy"] = originDy - newHeight;
              e["height"] = newHeight + 20; // 20 is current frame event
            });
          }
        }
      },
      onPointerUp: (event) {
        focusIndex = -1;
        var e = _events.last;
        if (!canMove(e["name"], e["dy"], e["height"])) {
          setState(() {
            _events.removeLast();
          });
        }
      },
      child: InkWell(
        onLongPress: () {
          focusIndex = index;
          debugPrint("long press");
          setState(() {
            _events.add({
              "dy": index * 20.0,
              "origin_dy": index * 20.0,
              "height": 20.0,
              "name": "Event new $index",
            });
          });
        },
        child: const SizedBox(width: double.infinity, height: 19),
      ),
    );
  }

  bool isContain(double dy, double height, double oDy, double oHeight) {
    return isInside(dy, height, oDy) && isInside(dy, height, oDy + oHeight);
  }

  bool isInside(double dy, double height, double oDy) {
    return dy <= oDy && oDy <= dy + height;
  }

  bool canMove(String name, double dy, double height) {
    if (dy < 0 || dy + height > 24 * 4 * 20) {
      return false;
    }
    for (var event in _events) {
      if (event["name"] != name) {
        double eventDy = event["dy"];
        double eventHeight = event["height"];
        if (isInside(eventDy, eventHeight, dy) ||
            isInside(eventDy, eventHeight, dy + height) ||
            isContain(dy, height, eventDy, eventHeight)) {
          return false;
        }
      }
    }
    return true;
  }

  double getHeightRow(double value) {
    if (value % 20 != 0) {
      return (value ~/ 20) * 20 + 20;
    }
    return value;
  }
}
