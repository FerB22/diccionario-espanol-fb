import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/verb_conjugation.dart';
import '../services/tts_service.dart';

const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

class ConjugationScreen extends StatefulWidget {
  final int palabraId;
  final String verb;

  const ConjugationScreen({
    super.key,
    required this.palabraId,
    required this.verb,
  });

  @override
  State<ConjugationScreen> createState() => _ConjugationScreenState();
}

class _ConjugationScreenState extends State<ConjugationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VerbConjugation? _conjugation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadConjugation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConjugation() async {
    final res = await DatabaseHelper.instance.getConjugation(
      widget.palabraId,
      widget.verb,
    );
    if (mounted) {
      setState(() {
        _conjugation = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conjugación de ${widget.verb}',
          style: const TextStyle(
            fontFamily: 'Playfair',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Pronunciar verbo',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => TtsService.instance.speak(widget.verb),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? const Color(0xFF93C5FD) : _azulMarino,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          indicatorColor: _dorado,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
          ),
          tabs: const [
            Tab(text: 'No personales'),
            Tab(text: 'Indicativo'),
            Tab(text: 'Subjuntivo'),
            Tab(text: 'Imperativo'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _azulMarino))
          : _conjugation == null
              ? _buildEmptyState(isDark)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNonPersonalTab(isDark),
                    _buildTenseBlocksTab(_conjugation!.indicativeBlocks, isDark, moodTitle: 'Indicativo'),
                    _buildTenseBlocksTab(_conjugation!.subjunctiveBlocks, isDark, moodTitle: 'Subjuntivo'),
                    _buildImperativeTab(isDark),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 54,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontró la tabla de conjugación para "${widget.verb}".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Tab Formas no personales ───────────────────────────────────────────
  Widget _buildNonPersonalTab(bool isDark) {
    final c = _conjugation!;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final rowBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSectionHeader('FORMAS NO PERSONALES', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Infinitivo & Gerundio
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildHeaderCell('Infinitivo', isDark)),
                    Container(width: 1, height: 20, color: borderColor),
                    Expanded(child: _buildHeaderCell('Gerundio', isDark)),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              // Valores simples
              Container(
                color: rowBg,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildTappableValue(c.infinitive, isDark)),
                    Container(width: 1, height: 24, color: borderColor),
                    Expanded(child: _buildTappableValue(c.gerund, isDark)),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              // Header Compuestos
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildHeaderCell('Infinitivo compuesto', isDark)),
                    Container(width: 1, height: 20, color: borderColor),
                    Expanded(child: _buildHeaderCell('Gerundio compuesto', isDark)),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              // Valores compuestos
              Container(
                color: rowBg,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildTappableValue(c.infinitiveCompound, isDark)),
                    Container(width: 1, height: 24, color: borderColor),
                    Expanded(child: _buildTappableValue(c.gerundCompound, isDark)),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              // Header Participio
              Container(
                color: headerBg,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: _buildHeaderCell('Participio', isDark),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              // Valor Participio
              Container(
                color: rowBg,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: _buildTappableValue(c.participle, isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Tab Tiempos (Indicativo / Subjuntivo) ──────────────────────────────
  Widget _buildTenseBlocksTab(
    List<ConjugationTenseBlock> blocks,
    bool isDark, {
    required String moodTitle,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildTenseCard(block, isDark),
        );
      },
    );
  }

  Widget _buildTenseCard(ConjugationTenseBlock block, bool isDark) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final rowAltBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final rowBaseBg = isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Títulos del Tiempo
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Pronombres\npersonales',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: borderColor),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Text(
                    block.simpleTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? const Color(0xFFE2E8F0) : _azulMarino,
                    ),
                  ),
                ),
                if (block.compoundTitle != null) ...[
                  const SizedBox(width: 8),
                  Container(width: 1, height: 32, color: borderColor),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Text(
                      block.compoundTitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFFE2E8F0) : _azulMarino,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          // Filas por cada pronombre
          ...List.generate(block.rows.length, (i) {
            final row = block.rows[i];
            final bg = i.isEven ? rowBaseBg : rowAltBg;
            return Container(
              color: bg,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                children: [
                  // Pronombre
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.pronoun,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 28, color: borderColor.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  // Forma Simple
                  Expanded(
                    flex: 4,
                    child: _buildTappableValue(row.simple, isDark, align: TextAlign.center),
                  ),
                  // Forma Compuesta
                  if (block.compoundTitle != null) ...[
                    const SizedBox(width: 8),
                    Container(width: 1, height: 28, color: borderColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _buildTappableValue(row.compound ?? '', isDark, align: TextAlign.center),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 3. Tab Imperativo ─────────────────────────────────────────────────────
  Widget _buildImperativeTab(bool isDark) {
    final c = _conjugation!;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final rowAltBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final rowBaseBg = isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSectionHeader('IMPERATIVO', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildHeaderCell('Pronombres personales', isDark),
                    ),
                    Container(width: 1, height: 20, color: borderColor),
                    Expanded(
                      flex: 5,
                      child: _buildHeaderCell('Forma afirmativa', isDark),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),
              ...List.generate(c.imperativeRows.length, (i) {
                final row = c.imperativeRows[i];
                final bg = i.isEven ? rowBaseBg : rowAltBg;
                return Container(
                  color: bg,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          row.pronoun,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 24, color: borderColor.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: _buildTappableValue(row.simple, isDark, align: TextAlign.center),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Componentes de Soporte ────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Playfair',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: isDark ? const Color(0xFFF8FAFC) : _azulMarino,
      ),
    );
  }

  Widget _buildHeaderCell(String title, bool isDark) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFFE2E8F0) : _azulMarino,
      ),
    );
  }

  Widget _buildTappableValue(String text, bool isDark, {TextAlign align = TextAlign.center}) {
    if (text.isEmpty) {
      return Text(
        '—',
        textAlign: align,
        style: TextStyle(
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      );
    }

    return InkWell(
      onTap: () {
        final cleanToSpeak = text.split('/').first.split(' o ').first.trim();
        if (cleanToSpeak.isNotEmpty) {
          TtsService.instance.speak(cleanToSpeak);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
