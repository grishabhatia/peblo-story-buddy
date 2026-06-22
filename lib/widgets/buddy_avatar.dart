import 'package:flutter/material.dart';

class BuddyAvatar extends StatefulWidget {
  final bool isCelebrating;
  final bool isListening;

  const BuddyAvatar({
    super.key,
    this.isCelebrating = false,
    this.isListening = false,
  });

  @override
  State<BuddyAvatar> createState() => _BuddyAvatarState();
}

class _BuddyAvatarState extends State<BuddyAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BuddyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCelebrating && !oldWidget.isCelebrating) {
      _bounceController.animateTo(1.0,
          duration: Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        widget.isCelebrating ? -30 : 0,
        0,
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: widget.isCelebrating
                ? [Colors.amber, Colors.orange]
                : [Colors.blue[300]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.isCelebrating ? '🌟' : '🤖',
              style: TextStyle(fontSize: 60),
            ),
            if (widget.isListening)
              Positioned(
                bottom: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: Icon(Icons.volume_up, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }
}