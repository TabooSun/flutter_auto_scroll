import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_scroll/flutter_auto_scroll.dart';

class DraggableSample extends StatefulWidget {
  final String title;

  final Axis scrollDirection;

  const DraggableSample({
    Key key,
    this.title,
    this.scrollDirection,
  }) : super(key: key);

  @override
  _DraggableSampleState createState() => _DraggableSampleState();
}

class _DraggableSampleState extends State<DraggableSample> {
  List<List<DraggableItem>> items;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    items = List.generate(
      10,
      (index) => List.generate(5, (index) => DraggableItem()),
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Scrollbar(
            child: ListView(
              scrollDirection: widget.scrollDirection,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              children: items
                  .asMap()
                  .map((key, value) {
                    return MapEntry(
                      key,
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DragTarget<DraggableItem>(
                          onWillAccept: (data) => true,
                          onAccept: (item) {
                            items
                                .singleWhere(
                                    (element) => element.any((x) => x == item))
                                .remove(item);
                            items[key].add(item);
                            setState(() {});
                          },
                          builder: (context, candidates, rejectedDatum) =>
                              Container(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            width: 300,
                            height: 300,
                            color: Colors.red,
                            child: Wrap(
                              children: value
                                  .map((data) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DraggableAutoScroll(
                                          scrollDirection:
                                              widget.scrollDirection,
                                          constraints: constraints,
                                          scrollController: scrollController,
                                          child: Draggable<DraggableItem>(
                                            maxSimultaneousDrags: 1,
                                            feedback: Icon(Icons.access_time),
                                            childWhenDragging:
                                                const SizedBox.shrink(),
                                            data: data,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              color: Colors.green,
                                              child: Text(data.name),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .values
                  .toList(),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshList,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

final faker = Faker();

class DraggableItem {
  final String name = faker.person.name();

  DraggableItem();
}
