import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/w3w_provider.dart';
import '../models/w3w_models.dart';

class W3WAutoSuggestField extends StatefulWidget {
  final String? hintText;
  final Function(W3WSuggestion)? onSuggestionSelected;
  final Function(String)? onTextChanged;
  final W3WCoordinates? focus;
  final String? clipToCountry;

  const W3WAutoSuggestField({
    super.key,
    this.hintText = 'Enter three words (e.g., index.home.raft)',
    this.onSuggestionSelected,
    this.onTextChanged,
    this.focus,
    this.clipToCountry,
  });

  @override
  State<W3WAutoSuggestField> createState() => _W3WAutoSuggestFieldState();
}

class _W3WAutoSuggestFieldState extends State<W3WAutoSuggestField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onTextChanged?.call(text);

    if (text.isNotEmpty) {
      context.read<W3WProvider>().autoSuggest(
            input: text,
            focus: widget.focus,
            clipToCountry: widget.clipToCountry,
          );
      setState(() {
        _showSuggestions = true;
      });
    } else {
      context.read<W3WProvider>().clearSuggestions();
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionTap(W3WSuggestion suggestion) {
    _controller.text = suggestion.words;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onSuggestionSelected?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      context.read<W3WProvider>().clearSuggestions();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Consumer<W3WProvider>(
      builder: (context, provider, child) {
        if (provider.suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = provider.suggestions[index];
              return ListTile(
                title: Text(
                  suggestion.words,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${suggestion.country ?? ''} ${suggestion.nearestPlace ?? ''}'
                      .trim(),
                ),
                trailing: Text('Rank: ${suggestion.rank}'),
                onTap: () => _onSuggestionTap(suggestion),
              );
            },
          ),
        );
      },
    );
  }
}
