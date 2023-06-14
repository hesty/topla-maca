import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<int> _blackGridItemIndex = [0, 1, 2, 3, 4, 5, 9, 10, 14, 15, 18, 19, 20, 21, 25, 26];
  final Map<int, int> _fixedNumberWithIndex = {7: 6, 13: 3, 16: 6, 23: 2};
  final Map<int, int> _answerKeyWithIndex = {6: 2, 8: 1, 11: 1, 12: 9, 17: 7, 22: 4, 24: 1, 27: 8, 28: 9, 29: 2};
  final List<TextEditingController> _textEditingControllerList = List.generate(30, (index) => TextEditingController());
  final List<GlobalObjectKey<FormState>> _formKeyList = List.generate(30, (index) => GlobalObjectKey<FormState>(index));
  final Map<int, String> _imagePathsWithIndex = {
    1: 'assets/nine_down.png',
    2: 'assets/thirty_four_down.png',
    3: 'assets/four_down.png',
    5: 'assets/nine_right.png',
    10: 'assets/thirteen_right.png',
    15: 'assets/thirteen_right.png',
    18: 'assets/eleven_down.png',
    19: 'assets/three_down.png',
    21: 'assets/seven_right.png',
    26: 'assets/nineteen_right.png'
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffEAEBF1),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildRowButtons(context),
              _buildGridView(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xffEAEBF1),
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      centerTitle: true,
      title: const Text('Topla-maca'),
      leading: Tooltip(
        message: 'Cevapları Kontrol et',
        child: TextButton(
            onPressed: () => checkAnswer(),
            child: const Icon(
              Icons.checklist,
              color: Colors.black,
            )),
      ),
      actions: [
        TextButton(
            onPressed: () => clearAllFields(), child: const Text('Temizle', style: TextStyle(color: Colors.black)))
      ],
    );
  }

  Widget _buildRowButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
              ),
              onPressed: () {
                _showDialog(
                    title: 'Nasıl Oynanır?',
                    content:
                        "Boş sarı kutulara 0 ile 9 arasında, her sıra ve sütundaki rakamların toplamının ok işaretinde gösterilen sonucu verecek şekilde bir sayı yazmanızı gerektirir. Ok işaretlerinin yönü, toplama işlemini soldan sağa mı yoksa yukarıdan aşağıya mı yapacağınızı gösterir. Hiçbir sütunda ya da satırda bir rakamın tekrarlanmaması gerekmektedir. Örneğin, 4'e ulaşmak için 3 ve 1'i kullanabilirsiniz ama iki kez 2 kullanamazsınız.");
              },
              child: Text('Nasıl Oynanır?')),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          content: Image.asset('assets/answer_key.png'),
                        ));
              },
              child: Text('Cevap Anahtarı'))
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemCount: 30,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent, width: 2),
          color: _blackGridItemIndex.contains(index) ? const Color(0xff1F1F1F) : Colors.yellow,
        ),
        child: Center(
          child: _getGridChild(index),
        ),
      ),
    );
  }

  Widget _getGridChild(int index) {
    if (_imagePathsWithIndex.containsKey(index)) {
      return Image.asset(_imagePathsWithIndex[index]!);
    } else if (_fixedNumberWithIndex.containsKey(index)) {
      return Text(_fixedNumberWithIndex[index].toString(), style: const TextStyle(fontSize: 24));
    } else if (!_blackGridItemIndex.contains(index)) {
      return Form(
        key: _formKeyList[index],
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          controller: _textEditingControllerList[index],
          validator: (value) => value!.isEmpty ? 'Boş bırakılamaz' : null,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(counterText: '', hintStyle: TextStyle(fontSize: 24)),
          style: const TextStyle(fontSize: 24),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void checkAnswer() {
    if (_isAllCellFilled()) {
      if (_isAnswerCorrect()) {
        _showDialog(
          title: 'Tebrikler',
          content: 'Tüm cevaplar doğru',
        );
      } else {
        _showDialog(
          title: 'Hata',
          content: 'Cevaplarınızdan bazıları yanlış',
        );
      }
    } else {
      _showDialog(
        title: 'Hata',
        content: 'Tüm boşlukları doldurun',
      );
    }
  }

  bool _isAllCellFilled() {
    var filedCellCount = 0;

    for (int i = 0; i < 30; i++) {
      if (_answerKeyWithIndex.containsKey(i)) {
        if (_formKeyList[i].currentState!.validate()) filedCellCount++;
      }
    }

    return filedCellCount == 10;
  }

  bool _isAnswerCorrect() {
    var correctAnswerCount = 0;

    for (int i = 0; i < 30; i++) {
      if (_answerKeyWithIndex.containsKey(i)) {
        if (_textEditingControllerList[i].text == _answerKeyWithIndex[i].toString()) correctAnswerCount++;
      }
    }

    return correctAnswerCount == 10;
  }

  void _showDialog({required String title, required String content}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Tamam', style: TextStyle(color: Colors.black)))
            ],
          );
        });
  }

  void clearAllFields() {
    for (int i = 0; i < 30; i++) {
      if (_answerKeyWithIndex.containsKey(i)) {
        _textEditingControllerList[i].clear();
        _formKeyList[i].currentState!.reset();
      }
    }
  }
}
