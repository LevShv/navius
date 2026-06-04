import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../domain/entities/search_result.dart';
import '../../../../core/di/injection.dart';

class SearchBar extends StatelessWidget {
  final Function(SearchResult) onPlaceSelected;
  
  const SearchBar({
    super.key,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchBloc>(),
      child: _SearchBarContent(onPlaceSelected: onPlaceSelected),
    );
  }
}

class _SearchBarContent extends StatefulWidget {
  final Function(SearchResult) onPlaceSelected;
  
  const _SearchBarContent({required this.onPlaceSelected});
  
  @override
  State<_SearchBarContent> createState() => _SearchBarContentState();
}

class _SearchBarContentState extends State<_SearchBarContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Поле поиска
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
              decoration: InputDecoration(
                hintText: 'Поиск места...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (_controller.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchBloc>().add(ClearSearch());
                          _focusNode.unfocus();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Блок результатов (исправлен)
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              // Показываем блок если: есть результаты, или идет загрузка, или есть ошибка
              final shouldShow = state.results.isNotEmpty || 
                                 state.isLoading || 
                                 (state.error != null && _controller.text.isNotEmpty);
              
              if (!shouldShow) {
                return const SizedBox.shrink();
              }
              
              return Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Индикатор загрузки
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      
                      // Сообщение об ошибке (ничего не найдено)
                      if (state.error != null && !state.isLoading && state.results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              state.error!,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      
                      // Список результатов
                      ...state.results.map((result) => ListTile(
                        leading: const Icon(Icons.place, color: Colors.blue),
                        title: Text(result.name),
                        subtitle: Text(
                          result.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          widget.onPlaceSelected(result);
                          _controller.clear();
                          _focusNode.unfocus();
                          context.read<SearchBloc>().add(ClearSearch());
                        },
                      )).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}