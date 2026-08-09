import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/login_demo_widgets.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/view_state.dart';
import '../../data/models/offer_list_item.dart';
import '../../data/models/search_result.dart';
import '../../data/models/store_list_item.dart';
import '../../data/services/browsing_api_service.dart';
import '../widgets/offer_card.dart';
import '../widgets/store_card.dart';

/// Global search over `GET /api/search?q={query}`.
///
/// Requests are debounced (~400ms) and never sent for an empty/whitespace
/// query (the backend returns 400 for that case). Results are grouped into
/// matching stores and offers.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.autofocus = true,
    this.showBackButton = true,
    this.onBack,
  });

  /// Supplied by the shell. A shell tab has nothing on the navigator to pop,
  /// so it needs an explicit way back to the dashboard.
  final VoidCallback? onBack;

  /// Disabled when hosted as a bottom-navigation tab so switching to the tab
  /// does not pop the keyboard open unprompted.
  final bool autofocus;

  /// Hidden when the screen is hosted as a bottom-navigation tab.
  final bool showBackButton;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  final BrowsingApiService _service = BrowsingApiService();
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;
  ViewState _state = ViewState.initial;
  SearchResult? _result;
  String _error = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _result = null;
        _state = ViewState.initial;
      });
      return;
    }

    _debounce = Timer(_debounceDuration, () => _performSearch(trimmed));
  }

  Future<void> _performSearch(String query) async {
    setState(() => _state = ViewState.loading);

    try {
      final result = await _service.search(query);
      if (!mounted) return;
      // Ignore stale responses if the query changed while awaiting.
      if (query != _controller.text.trim()) return;
      setState(() {
        _result = result;
        _state = result.isEmpty ? ViewState.empty : ViewState.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (query != _controller.text.trim()) return;
      setState(() {
        _error = e.message;
        _state = ViewState.error;
      });
    } catch (_) {
      if (!mounted) return;
      if (query != _controller.text.trim()) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _state = ViewState.error;
      });
    }
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _result = null;
      _state = ViewState.initial;
    });
  }

  void _openStore(StoreListItem store) {
    Navigator.pushNamed(
      context,
      RouteNames.storeDetails,
      arguments: store.slug,
    );
  }

  void _openOffer(OfferListItem offer) {
    Navigator.pushNamed(
      context,
      RouteNames.offerDetails,
      arguments: offer.slug,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
                tooltip: 'Back to dashboard',
              ),
      ),
      body: LoginDemoBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildSearchField(),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _onQueryChanged,
      onSubmitted: (value) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          _debounce?.cancel();
          _performSearch(trimmed);
        }
      },
      decoration: InputDecoration(
        hintText: 'Search stores, brands, offers',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _clear,
              ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case ViewState.initial:
        return const EmptyView(
          title: 'Search Smart Money',
          message: 'Find stores and offers by name or brand.',
          icon: Icons.search_rounded,
        );
      case ViewState.loading:
        return const LoadingView(message: 'Searching...');
      case ViewState.error:
        return ErrorView(
          message: _error,
          onRetry: () {
            final trimmed = _controller.text.trim();
            if (trimmed.isNotEmpty) _performSearch(trimmed);
          },
        );
      case ViewState.empty:
        return const EmptyView(
          title: 'No results found',
          message: 'Try a different store, brand or keyword.',
          icon: Icons.search_off_rounded,
        );
      case ViewState.success:
        return _buildResults(_result!);
    }
  }

  Widget _buildResults(SearchResult result) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        if (result.stores.isNotEmpty) ...[
          _GroupHeader(
            icon: Icons.storefront_outlined,
            label: 'Stores',
            count: result.stores.length,
          ),
          const SizedBox(height: 12),
          for (final store in result.stores) ...[
            StoreCard(store: store, onTap: () => _openStore(store)),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
        if (result.offers.isNotEmpty) ...[
          _GroupHeader(
            icon: Icons.local_offer_outlined,
            label: 'Offers',
            count: result.offers.length,
          ),
          const SizedBox(height: 12),
          for (final offer in result.offers) ...[
            OfferCard(offer: offer, onTap: () => _openOffer(offer)),
            const SizedBox(height: 14),
          ],
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
