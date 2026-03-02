
import 'package:flutter/material.dart';


class SearchableDropdown extends StatefulWidget {
  final String hint;
  final List<String> items;
  final String? value;
  final Function(String) onSelected;

  const SearchableDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onSelected,
    this.value,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}
class _SearchableDropdownState extends State<SearchableDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    filteredItems = widget.items;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 6),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔍 Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    onChanged: (value) {
                      setState(() {
                        filteredItems = widget.items
                            .where((e) => e
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                      });
                      _overlayEntry?.markNeedsBuild();
                    },
                  ),
                  const SizedBox(height: 8),

                  // 📜 List
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(child: Text("No data"))
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // style: AppFonts.arcPop1(),
                          ),
                          onTap: () {
                            widget.onSelected(item);
                            _closeDropdown();
                          },
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: SizedBox(
          height: 52, // ⭐ FORCE SAME HEIGHT
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,

              constraints: const BoxConstraints(
                minHeight: 52,
                maxHeight: 52,
              ),

              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: widget.hint,

              filled: true,
              fillColor: const Color(0xFFF8F9FB), // ⭐ modern light bg

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xFF6B7280),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // ⭐ softer
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB), // light border
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB), // ⭐ modern blue focus
                  width: 1.4,
                ),
              ),
            ),

            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.value ?? widget.hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // style: AppFonts.arcPop1().copyWith(
                //   color: widget.value == null
                //       ? const Color(0xFF9CA3AF) // hint grey
                //       : const Color(0xFF111827), // selected text
                // ),
              ),
            ),
          )


        ),
      ),
    );
  }





  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    super.dispose();
  }
}
