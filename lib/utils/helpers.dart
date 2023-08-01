//Url validation
bool isValidUrl(String url) {
  final regex = RegExp(
      r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
  return regex.hasMatch(url);
}

String capitalize(String input) {
  if (input.isEmpty) {
    return input; // return the input string as is if it's empty
  }

  return input[0].toUpperCase() + input.substring(1);
}

String toTitleCase(String input) {
  if (input.isEmpty) {
    return input; // return the input string as is if it's empty
  }

  List<String> words = input.toLowerCase().split(' ');

  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    if (word.isNotEmpty) {
      words[i] = word[0].toUpperCase() + word.substring(1);
    }
  }

  return words.join(' ');
}

