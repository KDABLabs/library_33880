class Utils {
  static String beautifyTitle(String title) {
    final int slashIndex = title.lastIndexOf(' / ');

    if (slashIndex != -1) {
      title = title.replaceRange(slashIndex, slashIndex + 3, '\n');
    }

    final int dashIndex = title.lastIndexOf(' - ');

    if (dashIndex != -1) {
      title = title.replaceRange(dashIndex, dashIndex + 3, '\n');
    }

    return title;
  }

  static String beautifyAvailability(String availability) {
    return availability;
  }
}
