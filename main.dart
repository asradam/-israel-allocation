import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IsraelAllocationApp());
}

class AllocationRecord {
  final String number;
  final String date;
  final String source;
  final String note;

  AllocationRecord({
    required this.number,
    required this.date,
    required this.source,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'number': number, 'date': date, 'source': source, 'note': note
  };

  factory AllocationRecord.fromJson(Map<String, dynamic> json) =>
      AllocationRecord(
        number: json['number'] ?? '',
        date: json['date'] ?? '',
        source: json['source'] ?? 'שלי',
        note: json['note'] ?? '',
      );
}

class IsraelAllocationApp extends StatefulWidget {
  const IsraelAllocationApp({super.key});
  @override
  State<IsraelAllocationApp> createState() => _IsraelAllocationAppState();
}

class _IsraelAllocationAppState extends State<IsraelAllocationApp> {
  String language = 'he';
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ישראל הקצאה',
      locale: Locale(language),
      supportedLocales: const [Locale('he'), Locale('en'), Locale('ar'), Locale('ru')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0756A5)),
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0756A5),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        fontFamily: 'Roboto',
      ),
      home: Directionality(
        textDirection: language == 'he' || language == 'ar'
            ? TextDirection.rtl : TextDirection.ltr,
        child: HomeScreen(
          language: language,
          notifications: notifications,
          onLanguageChanged: (v) => setState(() => language = v),
          onNotificationsChanged: (v) => setState(() => notifications = v),
        ),
      ),
    );
  }
}

String tr(String lang, String key) {
  const values = {
    'he': {
      'home':'ראשי','history':'היסטוריה','settings':'הגדרות',
      'hello':'ניהול מספרי הקצאה','subtitle':'כל מספרי ההקצאה שלך במקום אחד',
      'add':'הוספת מספר הקצאה','add_hint':'הזן מספר שהתקבל מרשות המסים',
      'number':'מספר הקצאה','date':'תאריך','source':'מקור המספר',
      'mine':'התקבל אצלי','other':'התקבל מאחרים','save':'שמירה',
      'cancel':'ביטול','recent':'מספרים אחרונים','empty':'עדיין לא נוספו מספרי הקצאה',
      'pdf':'PDF','share':'שיתוף PDF','alerts':'התראות','alerts_desc':'קבלת התראות ועדכונים',
      'language':'שפה','security':'אבטחה','prototype':'גרסת אבטיפוס',
      'official':'המספרים נשמרים כפי שהוזנו. הפקת מספר אמיתי תתבצע רק בחיבור מאושר לרשות המסים.',
      'note':'הערה (לא חובה)','delete':'מחיקה','saved':'נשמר בהצלחה',
    },
    'en': {
      'home':'Home','history':'History','settings':'Settings','hello':'Allocation management',
      'subtitle':'All your allocation numbers in one place','add':'Add allocation number',
      'add_hint':'Enter a number received from the Tax Authority','number':'Allocation number',
      'date':'Date','source':'Number source','mine':'Received by me','other':'Received from others',
      'save':'Save','cancel':'Cancel','recent':'Recent numbers','empty':'No allocation numbers added yet',
      'pdf':'PDF','share':'Share PDF','alerts':'Notifications','alerts_desc':'Receive alerts and updates',
      'language':'Language','security':'Security','prototype':'Prototype version',
      'official':'Numbers are stored as entered. Real issuance requires an approved Tax Authority connection.',
      'note':'Note (optional)','delete':'Delete','saved':'Saved successfully',
    },
    'ar': {
      'home':'الرئيسية','history':'السجل','settings':'الإعدادات','hello':'إدارة أرقام التخصيص',
      'subtitle':'جميع أرقام التخصيص في مكان واحد','add':'إضافة رقم تخصيص',
      'add_hint':'أدخل الرقم الذي استلمته من سلطة الضرائب','number':'رقم التخصيص',
      'date':'التاريخ','source':'مصدر الرقم','mine':'استلمته بنفسي','other':'استلمته من آخرين',
      'save':'حفظ','cancel':'إلغاء','recent':'الأرقام الأخيرة','empty':'لم تتم إضافة أرقام بعد',
      'pdf':'PDF','share':'مشاركة PDF','alerts':'الإشعارات','alerts_desc':'تلقي التنبيهات والتحديثات',
      'language':'اللغة','security':'الأمان','prototype':'نسخة تجريبية',
      'official':'يتم حفظ الأرقام كما أُدخلت. الإصدار الفعلي يتطلب اتصالاً معتمداً بسلطة الضرائب.',
      'note':'ملاحظة (اختياري)','delete':'حذف','saved':'تم الحفظ بنجاح',
    },
    'ru': {
      'home':'Главная','history':'История','settings':'Настройки','hello':'Управление номерами распределения',
      'subtitle':'Все ваши номера в одном месте','add':'Добавить номер',
      'add_hint':'Введите номер, полученный от налогового управления','number':'Номер распределения',
      'date':'Дата','source':'Источник номера','mine':'Получен мной','other':'Получен от других',
      'save':'Сохранить','cancel':'Отмена','recent':'Последние номера','empty':'Номера пока не добавлены',
      'pdf':'PDF','share':'Поделиться PDF','alerts':'Уведомления','alerts_desc':'Получать уведомления и обновления',
      'language':'Язык','security':'Безопасность','prototype':'Пробная версия',
      'official':'Номера сохраняются в том виде, в котором введены. Для выдачи нужен одобренный доступ к налоговому управлению.',
      'note':'Примечание (необязательно)','delete':'Удалить','saved':'Успешно сохранено',
    }
  };
  return values[lang]?[key] ?? values['he']![key] ?? key;
}

class HomeScreen extends StatefulWidget {
  final String language;
  final bool notifications;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onNotificationsChanged;
  const HomeScreen({
    super.key, required this.language, required this.notifications,
    required this.onLanguageChanged, required this.onNotificationsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  List<AllocationRecord> records = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('allocation_records');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      records = list.map(AllocationRecord.fromJson).toList();
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('allocation_records',
      jsonEncode(records.map((e) => e.toJson()).toList()));
  }

  Future<void> _addRecord() async {
    final number = TextEditingController();
    final note = TextEditingController();
    String source = 'שלי';
    final lang = widget.language;
    final result = await showDialog<AllocationRecord>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
        title: Text(tr(lang, 'add')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: number, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: tr(lang, 'number'), hintText: tr(lang, 'add_hint'))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: source,
            decoration: InputDecoration(labelText: tr(lang, 'source')),
            items: [
              DropdownMenuItem(value: 'שלי', child: Text(tr(lang, 'mine'))),
              DropdownMenuItem(value: 'מאחרים', child: Text(tr(lang, 'other'))),
            ],
            onChanged: (v) => setDialog(() => source = v ?? 'שלי'),
          ),
          const SizedBox(height: 12),
          TextField(controller: note, decoration: InputDecoration(labelText: tr(lang, 'note'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(lang, 'cancel'))),
          FilledButton(onPressed: () {
            if (number.text.trim().isEmpty) return;
            Navigator.pop(ctx, AllocationRecord(
              number: number.text.trim(),
              date: DateTime.now().toIso8601String().substring(0, 10),
              source: source, note: note.text.trim(),
            ));
          }, child: Text(tr(lang, 'save'))),
        ],
      )),
    );
    if (result != null) {
      setState(() => records.insert(0, result));
      await _persist();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(lang, 'saved'))));
    }
  }

  Future<void> _makePdf(AllocationRecord record) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: font),
      build: (_) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Center(child: pw.Container(
          padding: const pw.EdgeInsets.all(28),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue800, width: 2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
            pw.Text('ישראל הקצאה', style: pw.TextStyle(font: font, fontSize: 25, color: PdfColors.blue900)),
            pw.SizedBox(height: 20),
            pw.Text('מספר הקצאה', style: pw.TextStyle(font: font, fontSize: 19)),
            pw.SizedBox(height: 12),
            pw.Text(record.number, style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 18),
            pw.Text('תאריך: ${record.date}', style: pw.TextStyle(font: font, fontSize: 13)),
            pw.Text('מקור: ${record.source}', style: pw.TextStyle(font: font, fontSize: 13)),
            if (record.note.isNotEmpty) pw.Text('הערה: ${record.note}', style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 24),
            pw.Text('מסמך עזר שהופק באפליקציה — אינו אישור רשמי של רשות המסים',
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
          ]),
        )),
      ),
    ));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'allocation_${record.number}.pdf');
  }

  Future<void> _deleteRecord(int index) async {
    setState(() => records.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final pages = [
      _dashboard(lang),
      _history(lang),
      _settings(lang),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 34, height: 34,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.description_outlined, color: Color(0xFF0756A5))),
          const SizedBox(width: 10),
          const Text('ישראל הקצאה', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : pages[tab],
      floatingActionButton: tab == 0 || tab == 1
        ? FloatingActionButton.extended(onPressed: _addRecord,
            icon: const Icon(Icons.add), label: Text(tr(lang, 'add')))
        : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: tr(lang, 'home')),
          NavigationDestination(icon: const Icon(Icons.history), label: tr(lang, 'history')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: tr(lang, 'settings')),
        ],
      ),
    );
  }

  Widget _dashboard(String lang) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF064B91), Color(0xFF1684D8)]),
        borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr(lang, 'hello'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(tr(lang, 'subtitle'), style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 22),
        Row(children: [
          const Icon(Icons.numbers, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Text('${records.length}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(tr(lang, 'history'), style: const TextStyle(color: Colors.white)),
        ]),
      ]),
    ),
    const SizedBox(height: 16),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      const Icon(Icons.info_outline, color: Color(0xFF0756A5)),
      const SizedBox(width: 10),
      Expanded(child: Text(tr(lang, 'official'), style: const TextStyle(fontSize: 12))),
    ]))),
    const SizedBox(height: 18),
    Text(tr(lang, 'recent'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    if (records.isEmpty) _empty(lang) else ...records.take(3).map((r) => _recordTile(r, lang, records.indexOf(r))),
  ]);

  Widget _history(String lang) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr(lang, 'history'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    if (records.isEmpty) _empty(lang) else ...records.asMap().entries.map((e) => _recordTile(e.value, lang, e.key)),
  ]);

  Widget _empty(String lang) => Card(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(children: [
      const Icon(Icons.folder_open_outlined, size: 42, color: Colors.blueGrey),
      const SizedBox(height: 12), Text(tr(lang, 'empty')),
    ]),
  ));

  Widget _recordTile(AllocationRecord r, String lang, int index) => Card(
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFE5F1FC),
        child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF0756A5))),
      title: Text(r.number, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${r.date} • ${r.source == 'שלי' ? tr(lang, 'mine') : tr(lang, 'other')}${r.note.isEmpty ? '' : '\n${r.note}'}'),
      isThreeLine: r.note.isNotEmpty,
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'pdf') _makePdf(r);
          if (v == 'delete') _deleteRecord(index);
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'pdf', child: Text(tr(lang, 'share'))),
          PopupMenuItem(value: 'delete', child: Text(tr(lang, 'delete'))),
        ],
      ),
    ),
  );

  Widget _settings(String lang) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr(lang, 'settings'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 14),
    Card(child: ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF0756A5)),
      title: Text(tr(lang, 'language')),
      trailing: DropdownButton<String>(
        value: lang,
        items: const [
          DropdownMenuItem(value: 'he', child: Text('עברית')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
          DropdownMenuItem(value: 'ru', child: Text('Русский')),
        ],
        onChanged: (v) { if (v != null) widget.onLanguageChanged(v); },
      ),
    )),
    Card(child: SwitchListTile(
      secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF0756A5)),
      title: Text(tr(lang, 'alerts')), subtitle: Text(tr(lang, 'alerts_desc')),
      value: widget.notifications, onChanged: widget.onNotificationsChanged,
    )),
    Card(child: ListTile(
      leading: const Icon(Icons.lock_outline, color: Color(0xFF0756A5)),
      title: Text(tr(lang, 'security')),
      subtitle: const Text('Firebase Authentication / Biometric – integration pending'),
    )),
    const SizedBox(height: 16),
    Center(child: Text(tr(lang, 'prototype'), style: const TextStyle(color: Colors.blueGrey))),
  ]);
}
