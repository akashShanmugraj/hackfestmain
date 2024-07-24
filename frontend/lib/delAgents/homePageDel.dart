import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/utilities.dart';

// This is the type used by the popup menu below.
enum DeliveryMenu { History, Settings, ProfileView, Logout }

class homePageDel extends StatelessWidget {
  const homePageDel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeliveryMenu? selectedMenu;

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              PopupMenuButton<DeliveryMenu>(
                onSelected: (DeliveryMenu result) {
                  selectedMenu = result;
                  // Handle navigation or other actions based on the selected menu item
                  switch (selectedMenu) {
                    case DeliveryMenu.History:
                      break;
                    case DeliveryMenu.Settings:
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => settings()));
                    case DeliveryMenu.ProfileView:
                      Navigator.pushNamed(context, '/profile');
                      break;
                    case DeliveryMenu.Logout:
                      Navigator.pushNamed(context, '/');
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<DeliveryMenu>>[
                  const PopupMenuItem<DeliveryMenu>(
                    value: DeliveryMenu.History,
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('History'),
                    ),
                  ),
                  const PopupMenuItem<DeliveryMenu>(
                    value: DeliveryMenu.Settings,
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem<DeliveryMenu>(
                    value: DeliveryMenu.ProfileView,
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile View'),
                    ),
                  ),
                  const PopupMenuItem<DeliveryMenu>(
                    value: DeliveryMenu.Logout,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
                child: Icon(
                  Icons.menu,
                  size: 40,
                  color: Color.fromRGBO(0, 224, 255, 1),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 380,
                  height: 300,
                  color: Colors.grey,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(child: Text('map')),
                  ),
                ),
                SizedBox(height: 10),
                Option(label: 'Available Routes', route: '/available'),
                Option(label: 'Accepted Route', route: '/claimed'),
                Option(label: 'Completed Delivery ', route: '/completed_del'),
                Option(label: 'Completed Routes', route: '/completed_routes'),
                //SizedBox(height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: homePageDel(),
  ));
}
