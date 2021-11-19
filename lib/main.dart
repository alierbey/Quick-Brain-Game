import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // animasyon için gerekli olan değişkenler
  AnimationController _controller;
  Animation<double> _animation;

  // shared preferences için _prefs nesnesi oluşturduk
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // her fonksiyonun içinde gerekli olduğu için işlemi belirlediğimiz değişken
  int hangiIslem = 0;

  // ekrana yazdırırken hangi işareti basacağımızı bleirttiğimiz işaret
  String islemIsaret = "";

  // işlemlerde kullanılan sayı değişkenleri tanımlanır.
  int sayi1 = 0;
  int sayi2 = 0;

  /* islemlerin integer karşılıkları
   * 0 topla, 1 çıkar,  2 çarp,  3 = böl
   */

  @override
  void initState() {
    super.initState();

    // islemin isaretini ekrana yazdırmak için shared preferencestan okuyarak
    // hangiIslem değişkenine atar ve ekrana bastırmak icin isaretBelirle string değişkenine işaret atar.
    islemBelirle();

    // rastgele sayıları belirlemek için kullanılan fonksiyondur.
    sayilariAta();

    // cevapları üretir ve sayılara göre bir doğru cevabı ekler.
    cevapUret();

    // Oyunun sonunda gelen game over için animasyon
    _controller = AnimationController(
        duration: const Duration(
          milliseconds: 1500,
        ),
        vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    _controller.repeat();
  }

  // işlemBelirle fonksiyonu shared preferences da daha önce işlem seçilmişmi diye bakar
  // islemIsaret değişkeni ekrana isaret basmak için kullandığımız globak bir değişkendir.
  // visible kontrolleri ayarlar kısmında hangisini Ok olacağını belirtmek için kullanılır.
  void islemBelirle() async {
    // hangi işlemlerden sorular gelecek onun için shared preferences kaydı kontrol edilir.

    final SharedPreferences prefs = await _prefs;
    hangiIslem = (prefs.getInt('islem') ?? 0);
    String islem = "";

    setState(() {
      if (hangiIslem == 0) {
        islem = "toplama";
        islemIsaret = "+";
        visibleAddition = true;
      } else if (hangiIslem == 1) {
        islem = "çıkarma";
        islemIsaret = "-";
        visibleSubstraction = true;
      } else if (hangiIslem == 2) {
        islem = "bölme";
        islemIsaret = "/";
        visibleDivision = true;
      } else if (hangiIslem == 3) {
        islem = "çarpma";
        islemIsaret = "*";
        visibleSubstraction = true;
      }
    });

    print("islem $islem");
    sayilariAta();
    cevapUret();
  }

  List shuffle(List items) {
    var random = Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void sayilariAta() {
    print("sayıları ata");
    var rng = Random();
    setState(() {
      sayi1 = rng.nextInt(9) + 1;
      sayi2 = rng.nextInt(9) + 1;
      print("sayılar sayı1 : $sayi1 sayi2: $sayi2");
    });
  }

  List<int> cevaplar = [];
  List randomCevaplar = [];

  void cevapUret() {
    print("cevapları uret");
    cevaplar = [];
    // bu fonksiyonda random cevaplar üretilecek
    // gercek sonuç cevaplar arasına dahil edilerek karıştırılacak

    var rng = Random();

    setState(() {
      cevaplar.add(rng.nextInt(50));
      cevaplar.add(rng.nextInt(50));
      cevaplar.add(rng.nextInt(50));
      print(cevaplar);
      print(hangiIslem);
      if (hangiIslem == 0) {
        cevaplar.add(sayi1 + sayi2);
      } else if (hangiIslem == 1) {
        cevaplar.add(sayi1 - sayi2);
      } else if (hangiIslem == 2) {
        cevaplar.add((sayi1 / sayi2).toInt());
      } else if (hangiIslem == 3) {
        cevaplar.add(sayi1 * sayi2);
      }
    });
    // cevaplari karıştır
    print(cevaplar);
    randomCevaplar = shuffle(cevaplar);
  }

  Timer timer1;
  double ust1 = -100,
      sol1 = 10,
      ust2 = -100,
      sol2 = 90,
      ust3 = -100,
      sol3 = 170,
      ust4 = -100,
      sol4 = 250,
      zeminBottom = 250,
      balonYukseklik = 100;
  int puan = 0, hiz = 1;

  void baslat() {
    puan = 0;

    visibleBaslat = false;
    visibleIslem = true;
    visibleBitti = false;
    visibleLevel = false;
    visibleSettings = false;

    timer1 = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        ust1 = ust1 + hiz;
        ust2 = ust2 + hiz;
        ust3 = ust3 + hiz;
        ust4 = ust4 + hiz;

        if (ust1 + balonYukseklik + 30 >= ekranYukseklik - zeminBottom) {
          timer.cancel();
          ust1 = -100;
          ust2 = -100;
          ust3 = -100;
          ust4 = -100;
          visibleBaslat = true;
          visibleIslem = false;
          visibleBitti = true;
          visibleSettings = true;
        }
      });
    });
  }

  void cevapKontrol(int cevap) {
    int dogruCevap = 0;

    if (hangiIslem == 0) {
      dogruCevap = sayi1 + sayi2;
    } else if (hangiIslem == 1) {
      dogruCevap = sayi1 - sayi2;
    } else if (hangiIslem == 2) {
      dogruCevap = (sayi1 / sayi2).toInt();
    } else if (hangiIslem == 3) {
      dogruCevap = sayi1 * sayi2;
    }
    setState(() {
      if (dogruCevap == randomCevaplar[cevap]) {
        sayilariAta();
        cevapUret();
        ust1 = -100;
        ust2 = -100;
        ust3 = -100;
        ust4 = -100;
      } else {
        timer1.cancel();
        ust1 = -100;
        ust2 = -100;
        ust3 = -100;
        ust4 = -100;
        visibleBaslat = true;
        visibleIslem = false;
        visibleBitti = true;
        visibleSettings = true;
      }
    });
  }

  void puanKontrol() {
    if (puan == 50) {
      hiz = 2;
    } else if (puan == 150) {
      hiz = 3;
    } else if (puan == 300) {
      hiz = 3;
    } else if (puan == 450) {
      hiz = 4;
    } else if (puan == 600) {
      hiz = 5;
    } else if (puan == 800) {
      hiz = 6;
    } else if (puan == 1000) {
      hiz = 7;
    }
  }

  void islemSec(int islem) async {
    // print("islem $islem");
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("islem", islem);
    hangiIslem = islem;

    setState(() {
      if (hangiIslem == 0) {
        islemIsaret = "+";
        visibleAddition = true;
        visibleSubstraction = false;
        visibleDivision = false;
        visibleMultiplication = false;
      } else if (hangiIslem == 1) {
        islemIsaret = "-";
        visibleAddition = false;
        visibleSubstraction = true;
        visibleDivision = false;
        visibleMultiplication = false;
      } else if (hangiIslem == 2) {
        islemIsaret = "/";
        visibleAddition = false;
        visibleSubstraction = false;
        visibleDivision = true;
        visibleMultiplication = false;
      } else if (hangiIslem == 3) {
        islemIsaret = "*";
        visibleAddition = false;
        visibleSubstraction = false;
        visibleDivision = false;
        visibleMultiplication = true;
      }
    });
    sayilariAta();
    cevapUret();
  }

  double ekranYukseklik = 0;
  double ekranGenislik = 0;

  var visibleBaslat = true;
  var visibleIslem = false;
  var visibleBitti = false;
  var visibleLevel = true;
  var visibleSettings = true;
  var visibleSettingsScreen = false;
  var visibleSettingsLevel = false;

  // for operation
  var visibleAddition = false;
  var visibleSubstraction = false;
  var visibleDivision = false;
  var visibleMultiplication = false;

  void settings() {
    setState(() {
      visibleBitti = false;
      visibleBaslat = false;
      visibleSettingsScreen = true;
    });
  }

  bool useMobileLayout = false;
  @override
  Widget build(BuildContext context) {
    ekranYukseklik = MediaQuery.of(context).size.height;
    ekranGenislik = MediaQuery.of(context).size.width;

    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                child: (useMobileLayout)
                    ? Image.asset(
                        "assets/images/bg.png",
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/bg_tablet.png",
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              top: ust1,
              left: sol1,
              height: balonYukseklik,
              child: TextButton(
                  onPressed: () {
                    puan = puan + 50;
                    ust1 = -100;
                    // Random random = new Random();
                    // int randomSayi = random.nextInt(350);
                    // sol1 = randomSayi.toDouble();
                    puanKontrol();

                    cevapKontrol(0);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        child: Image.asset("assets/images/balon1.png"),
                      ),
                      Positioned(
                        top: 30,
                        left: 21,
                        child: Text(
                          randomCevaplar[0].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      )
                    ],
                  )),
            ),
            Positioned(
              top: ust2,
              left: sol2,
              height: balonYukseklik,
              child: TextButton(
                  onPressed: () {
                    puan = puan + 50;
                    ust2 = -100;
                    // Random random = new Random();
                    // int randomSayi = random.nextInt(350);
                    // sol2 = randomSayi.toDouble();
                    puanKontrol();

                    cevapKontrol(1);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        child: Image.asset("assets/images/balon1.png"),
                      ),
                      Positioned(
                        top: 30,
                        left: 21,
                        child: Text(
                          randomCevaplar[1].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      )
                    ],
                  )),
            ),
            Positioned(
              top: ust3,
              left: sol3,
              height: balonYukseklik,
              child: TextButton(
                  onPressed: () {
                    puan = puan + 50;
                    ust3 = -100;
                    // Random random = new Random();
                    // int randomSayi = random.nextInt(350);
                    // sol3 = randomSayi.toDouble();
                    puanKontrol();

                    cevapKontrol(2);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        child: Image.asset("assets/images/balon1.png"),
                      ),
                      Positioned(
                        top: 30,
                        left: 21,
                        child: Text(
                          randomCevaplar[2].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      )
                    ],
                  )),
            ),
            Positioned(
              top: ust4,
              left: sol4,
              height: balonYukseklik,
              child: TextButton(
                  onPressed: () {
                    puan = puan + 50;
                    ust4 = -100;
                    // Random random = new Random();
                    // int randomSayi = random.nextInt(350);
                    // sol4 = randomSayi.toDouble();
                    puanKontrol();

                    cevapKontrol(3);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        child: Image.asset("assets/images/balon1.png"),
                      ),
                      Positioned(
                        top: 30,
                        left: 21,
                        child: Text(
                          randomCevaplar[3].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      )
                    ],
                  )),
            ),
            Positioned(
              bottom: ekranYukseklik / 2,
              left: ekranGenislik / 2 - (ekranGenislik / 4),
              child: Visibility(
                visible: visibleBitti,
                child: Container(
                  width: ekranGenislik / 2,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Center(
                      child: Text(
                    "Game Over",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _animation.value * 25,
                    ),
                  )),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                width: ekranGenislik,
                height: 255,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Text(""),
                )),
            Positioned(
              bottom: 100,
              left: ekranGenislik / 2 - (ekranGenislik / 4),
              child: Visibility(
                visible: visibleBaslat,
                child: TextButton(
                  onPressed: baslat,
                  child: Container(
                    width: ekranGenislik / 2,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber,
                    ),
                    child: const Center(
                      child: Text(
                        "Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: zeminBottom,
              width: ekranGenislik,
              child: RaisedButton(
                color: Colors.black,
                onPressed: () {},
              ),
            ),
            Positioned(
                right: 10,
                top: 10,
                child: SafeArea(
                  child: Text(
                    '$puan',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            Positioned(
              bottom: 100,
              left: ekranGenislik / 2 - (ekranGenislik / 4),
              child: Visibility(
                visible: visibleIslem,
                child: TextButton(
                  onPressed: () {},
                  child: Container(
                    width: ekranGenislik / 2,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber,
                    ),
                    child: Center(
                      child: Text(
                        sayi1.toString() +
                            " " +
                            islemIsaret +
                            " " +
                            sayi2.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   bottom: 10,
            //   left: 20,
            //   width: 75,
            //   child: Visibility(
            //     visible: visibleLevel,
            //     child: TextButton(
            //       onPressed: settings,
            //       child: Image.asset("assets/images/iconsettings.png"),
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: 10,
              right: 20,
              width: 75,
              child: Visibility(
                visible: visibleSettings,
                child: TextButton(
                  onPressed: settings,
                  child: Image.asset("assets/images/iconsettings.png"),
                ),
              ),
            ),
            Positioned(
              top: ekranYukseklik * 0.1,
              left: ekranGenislik * 0.1,
              right: ekranGenislik * 0.1,
              bottom: ekranYukseklik * 0.4,
              child: Visibility(
                visible: visibleSettingsScreen,
                child: Container(
                  width: ekranGenislik * 0.8,
                  height: ekranYukseklik * 0.5,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.9),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Operation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: () {
                          islemSec(0);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Addition",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Visibility(
                              visible: visibleAddition,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: const Text("Ok")),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          islemSec(1);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Substraction",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Visibility(
                              visible: visibleSubstraction,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: const Text("Ok")),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          islemSec(2);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Division",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Visibility(
                              visible: visibleDivision,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: const Text("Ok")),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          islemSec(3);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Multiplication",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Visibility(
                              visible: visibleMultiplication,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: const Text("Ok")),
                            )
                          ],
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              visibleSettingsScreen = false;
                              visibleBaslat = true;
                            });
                          },
                          child: Container(
                            width: ekranGenislik / 2,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: const Center(
                              child: Text("OK"),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
