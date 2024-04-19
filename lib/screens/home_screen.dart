import 'package:flutter/material.dart';
import 'package:quinto_assignment6/helpers/geo_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextStyle styleLight(double size) => TextStyle(
        color: Colors.white,
        fontSize: size,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(r"Hiker's Watch"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: GeoHelper.isPermissionGranted(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data found'),
            );
          }

          final isGranted = snapshot.data!;

          if (!isGranted) {
            return Center(
                child: ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Grant Permission'),
            ));
          }
          return const MainWidget();
        },
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = SizedBox(height: 20.0);

    return FutureBuilder(
      future: GeoHelper.getLocationDetails(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('No data found'),
          );
        }

        final data = snapshot.data!;

        return Column(
          children: [
            Image.network(
              data['weather']['icon'],
              fit: BoxFit.fill,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;

                final p = progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null;
                return Center(
                  child: CircularProgressIndicator(
                    value: p,
                  ),
                );
              },
            ),
            Text(
              data['locality'],
              style: theme.textTheme.titleLarge,
            ),
            gap,
            WeatherDetails(
              temp: data['weather']['temp'],
              humidity: data['weather']['humidity'],
              feelsLike: data['weather']['feels_like'],
              weather: data['weather']['type'],
            ),
            gap,
            Expanded(
              child: LocationDetails(
                place: data['place'],
                latitude: data['latitude'],
                longitude: data['longitude'],
                altitude: data['altitude'],
                accuracy: data['accuracy'],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LocationDetails extends StatelessWidget {
  const LocationDetails({
    super.key,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
  });

  final String place;
  final double latitude, longitude, altitude, accuracy;

  TextStyle styleLight(double size) => TextStyle(
        color: Colors.white,
        fontSize: size,
      );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 20.0);
    const clipRadius = Radius.circular(16.0);
    const divider = Divider(
      color: Colors.white,
      thickness: 1.0,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: clipRadius,
        topRight: clipRadius,
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.blue.shade400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: styleLight(16.0),
            ),
            const SizedBox(height: 20.0),
            LocationTile(
              title: 'Address',
              content: place,
              crossAlign: CrossAxisAlignment.start,
            ),
            gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LocationTile(
                  title: 'Latitude',
                  content: latitude.toStringAsFixed(2),
                ),
                LocationTile(
                  title: 'Longitude',
                  content: longitude.toStringAsFixed(2),
                ),
              ],
            ),
            divider,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LocationTile(
                  title: 'Altitude',
                  content: altitude.toStringAsFixed(2),
                ),
                LocationTile(
                  title: 'Accuracy',
                  content: accuracy.toStringAsFixed(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  const LocationTile({
    super.key,
    this.crossAlign = CrossAxisAlignment.center,
    required this.title,
    required this.content,
  });

  final CrossAxisAlignment crossAlign;
  final String title;
  final String content;

  TextStyle styleLight(double size) => TextStyle(
        color: Colors.white,
        fontSize: size,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          title,
          style: styleLight(18),
        ),
        Text(
          content,
          style: styleLight(24),
        ),
      ],
    );
  }
}

class WeatherDetails extends StatelessWidget {
  const WeatherDetails({
    super.key,
    this.temp = 52,
    this.humidity = 52,
    this.feelsLike = 52,
    this.weather = 'Partly Cloudy',
  });

  final double temp;
  final int humidity;
  final double feelsLike;
  final String weather;

  double kelvinToCelsius(double kelvin) => kelvin - 273.15;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '${kelvinToCelsius(temp).toStringAsFixed(2)}C',
          style: theme.textTheme.displayMedium,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather,
              style: theme.textTheme.labelLarge,
            ),
            Text(
              "Humidity: $humidity",
              style: theme.textTheme.labelSmall,
            ),
            Text(
              'Feels like: ${kelvinToCelsius(feelsLike).toStringAsFixed(2)}C',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
