import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final Function(int) onPageChanged;
  final Function(int) onRowsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.rowsPerPage,
    required this.rowsPerPageOptions,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  List<Widget> _buildPageButtons(int totalPages) {
    List<Widget> buttons = [];

    // Nút Previous
    buttons.add(
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: currentPage > 0
            ? () => onPageChanged(currentPage - 1)
            : null,
        tooltip: 'Trang trước',
      ),
    );

    if (totalPages <= 7) {
      // Nếu ít hơn hoặc bằng 7 trang, hiển thị tất cả
      for (int i = 0; i < totalPages; i++) {
        buttons.add(_buildPageButton(i));
      }
    } else {
      // Logic cho nhiều trang: hiển thị với dấu "..."
      // Luôn hiển thị trang 1
      buttons.add(_buildPageButton(0));

      if (currentPage > 3) {
        // Thêm dấu "..." nếu trang hiện tại cách xa đầu
        buttons.add(_buildEllipsis());
      }

      // Hiển thị các trang xung quanh trang hiện tại
      int startPage = currentPage - 1;
      int endPage = currentPage + 1;

      if (startPage < 1) startPage = 1;
      if (endPage >= totalPages - 1) endPage = totalPages - 2;

      for (int i = startPage; i <= endPage; i++) {
        if (i > 0 && i < totalPages - 1) {
          buttons.add(_buildPageButton(i));
        }
      }

      if (currentPage < totalPages - 4) {
        // Thêm dấu "..." nếu trang hiện tại cách xa cuối
        buttons.add(_buildEllipsis());
      }

      // Luôn hiển thị trang cuối
      buttons.add(_buildPageButton(totalPages - 1));
    }

    // Nút Next
    buttons.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: currentPage < totalPages - 1
            ? () => onPageChanged(currentPage + 1)
            : null,
        tooltip: 'Trang sau',
      ),
    );

    return buttons;
  }

  Widget _buildPageButton(int pageIndex) {
    final isActive = pageIndex == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => onPageChanged(pageIndex),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${pageIndex + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / rowsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildPageButtons(totalPages),
        ),
      ),
    );
  }
}
