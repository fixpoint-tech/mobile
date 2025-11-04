import 'package:flutter/material.dart';

class CustomChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80, // custom height
      titleSpacing: 0,
      title: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
          child: Row(
            children: [
              // BACK BUTTON
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD9D9D9),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(width: 12),

              // AVATAR
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFFF7489),
              ),

              const SizedBox(width: 12),

              // TITLE + SUBTITLE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Pizza Oven Malfunction",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Kottawa Branch, Sri Lanka",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
