import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_ttf_parser/flutter_ttf_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTF Parser Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FontParserPage(),
    );
  }
}

class FontParserPage extends StatefulWidget {
  const FontParserPage({super.key});

  @override
  State<FontParserPage> createState() => _FontParserPageState();
}

class _FontParserPageState extends State<FontParserPage> {
  TtfFont? _font;
  String? _error;
  bool _isLoading = false;
  String _selectedFont = 'song_ti.ttf';

  final List<String> _availableFonts = [
    'song_ti.ttf',
    'hei_ti.ttf',
    'kai_ti.ttf',
    'fang_song.ttf',
    'microsoft_yahei.ttf',
    'times_new_roman.ttf',
    'source_han_sans.ttf',
    'da_biao_song.ttf',
    'xiao_biao_song.ttf',
    'cu_song_jian.ttf',
    'fangzheng_weibei.ttf',
  ];

  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _font = null;
    });

    try {
      // 从 assets 加载字体文件
      print('开始加载字体: $_selectedFont');
      final ByteData data = await rootBundle.load('assets/fonts/$_selectedFont');
      final Uint8List bytes = data.buffer.asUint8List();
      print('字体文件加载成功，大小: ${bytes.length} 字节');

      // 解析字体
      print('开始解析字体...');
      final parser = TtfParser();
      final font = parser.parse(bytes);
      print('字体解析成功！');

      if (!mounted) return;

      setState(() {
        _font = font;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      // 打印详细的错误信息
      print('=' * 80);
      print('❌ 字体解析失败！');
      print('字体文件: $_selectedFont');
      print('错误类型: ${e.runtimeType}');
      print('错误信息: $e');
      print('-' * 80);
      print('堆栈跟踪:');
      print(stackTrace);
      print('=' * 80);
      
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      // 重新抛出异常以便调试
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTF 字体解析器'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // 字体选择器
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Text('选择字体：', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFont,
                    isExpanded: true,
                    items: _availableFonts.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(font),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFont = value;
                        });
                        _loadFont();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('解析错误：', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text(_error!, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    : _font == null
                        ? const Center(child: Text('未加载字体'))
                        : _buildFontInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildFontInfo() {
    if (_font == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          '基本信息',
          Icons.info_outline,
          [
            _buildInfoRow('字体名称', _font!.name.fontName ?? '未知'),
            _buildInfoRow('字体家族', _font!.name.fontFamily ?? '未知'),
            _buildInfoRow('子家族', _font!.name.subFamily ?? '未知'),
            _buildInfoRow('PostScript 名称', _font!.name.fontNamePostScript ?? '未知'),
            _buildInfoRow('版本', _font!.name.nameTableVersion ?? '未知'),
            _buildInfoRow('版权信息', _font!.name.copyright ?? '未知'),
            _buildInfoRow('制造商', _font!.name.manufacturer ?? '未知'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          '技术参数',
          Icons.settings,
          [
            _buildInfoRow('字形数量', '${_font!.numGlyphs}'),
            _buildInfoRow('EM 单位', '${_font!.unitsPerEm}'),
            _buildInfoRow('上升高度', '${_font!.hhea.ascent}'),
            _buildInfoRow('下降高度', '${_font!.hhea.descent}'),
            _buildInfoRow('行间距', '${_font!.hhea.lineGap}'),
            _buildInfoRow('最大前进宽度', '${_font!.hhea.advanceWidthMax}'),
            _buildInfoRow('字形版本', '${_font!.head.version.toStringAsFixed(2)}'),
            _buildInfoRow('字体修订版', '${_font!.head.fontRevision.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          '字形边界',
          Icons.crop_free,
          [
            _buildInfoRow('X 最小值', '${_font!.head.xMin}'),
            _buildInfoRow('Y 最小值', '${_font!.head.yMin}'),
            _buildInfoRow('X 最大值', '${_font!.head.xMax}'),
            _buildInfoRow('Y 最大值', '${_font!.head.yMax}'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          '字符映射',
          Icons.text_fields,
          [
            _buildInfoRow('映射字符数', '${_font!.cmap.charToGlyphIndexMap.length}'),
            _buildInfoRow('语言 ID', _font!.cmap.languageID?.toString() ?? '未设置'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCharacterSamples(),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSamples() {
    if (_font == null) return const SizedBox();

    // 获取一些示例字符的信息
    final sampleChars = ['A', 'B', 'a', 'b', '中', '文', '字', '体'];
    final samples = <Map<String, dynamic>>[];

    for (final char in sampleChars) {
      final glyphInfo = _font!.getGlyphInfo(char);
      if (glyphInfo != null) {
        samples.add({
          'char': char,
          'glyphIndex': glyphInfo.index,
          'contours': glyphInfo.numberOfContours,
          'xMin': glyphInfo.xMin,
          'yMin': glyphInfo.yMin,
          'xMax': glyphInfo.xMax,
          'yMax': glyphInfo.yMax,
        });
      }
    }

    if (samples.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.font_download, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '字形示例',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('字符')),
                  DataColumn(label: Text('索引')),
                  DataColumn(label: Text('轮廓数')),
                  DataColumn(label: Text('X 范围')),
                  DataColumn(label: Text('Y 范围')),
                ],
                rows: samples.map((sample) {
                  return DataRow(cells: [
                    DataCell(Text(sample['char'], style: const TextStyle(fontSize: 20))),
                    DataCell(Text('${sample['glyphIndex']}')),
                    DataCell(Text('${sample['contours']}')),
                    DataCell(Text('${sample['xMin']} ~ ${sample['xMax']}')),
                    DataCell(Text('${sample['yMin']} ~ ${sample['yMax']}')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
