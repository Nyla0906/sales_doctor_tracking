import 'dart:developer' as dev;

class PrettyLog {
  static void box(String title, String body) {
    const w = 90;

    String line(String s) => "║ ${s.padRight(w - 4)} ║";

    final top = "╔${"═" * (w - 2)}╗";
    final mid = "╠${"═" * (w - 2)}╣";
    final bot = "╚${"═" * (w - 2)}╝";

    final lines = body.split('\n');
    dev.log(top);
    dev.log(line(title));
    dev.log(mid);
    for (final l in lines) {
      var text = l;
      while (text.length > (w - 4)) {
        dev.log(line(text.substring(0, w - 4)));
        text = text.substring(w - 4);
      }
      dev.log(line(text));
    }
    dev.log(bot);
  }
}
