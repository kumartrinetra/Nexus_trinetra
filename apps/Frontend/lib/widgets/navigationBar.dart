
import 'package:flutter/material.dart';

NavigationBar myNavigationBar(List<String> navNames)
{
  return NavigationBar(destinations: navNames.map((name) => NavigationBarElement(name)).toList());}


Container NavigationBarElement(String name)
  {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          
        ),
        
        child: Text(name),
      );
  }