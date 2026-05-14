import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:tan_network/models/user_model.dart';
import 'package:tan_network/theme/app_theme.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isLoading = true;
  List<UserModel> _topEarners = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final earners = await ref.read(apiServiceProvider).getLeaderboard();
      setState(() {
        _topEarners = earners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LEADERBOARD'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLeaderboard,
              child: _topEarners.isEmpty
                  ? const Center(
                      child: Text(
                        'No miners found yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTop3(),
                          const SizedBox(height: 30),
                          _buildRemainingList(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildTop3() {
    if (_topEarners.isEmpty) return const SizedBox();

    final gold = _topEarners.isNotEmpty ? _topEarners[0] : null;
    final silver = _topEarners.length > 1 ? _topEarners[1] : null;
    final bronze = _topEarners.length > 2 ? _topEarners[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Silver (Rank 2)
        if (silver != null)
          _PodiumItem(
            user: silver,
            rank: 2,
            height: 140,
            reward: '700 TAN',
            color: const Color(0xFFC0C0C0),
          ),
        const SizedBox(width: 10),
        // Gold (Rank 1)
        if (gold != null)
          _PodiumItem(
            user: gold,
            rank: 1,
            height: 180,
            reward: '1000 TAN',
            color: const Color(0xFFFFD700),
          ),
        const SizedBox(width: 10),
        // Bronze (Rank 3)
        if (bronze != null)
          _PodiumItem(
            user: bronze,
            rank: 3,
            height: 120,
            reward: '500 TAN',
            color: const Color(0xFFCD7F32),
          ),
      ],
    );
  }

  Widget _buildRemainingList() {
    if (_topEarners.length <= 3) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Challengers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        ..._topEarners.skip(3).toList().asMap().entries.map((entry) {
          final index = entry.key + 4;
          final user = entry.value;
          return _buildLeaderboardTile(user, index);
        }),
      ],
    );
  }

  Widget _buildLeaderboardTile(UserModel user, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                (user.profileImage != null && user.profileImage!.isNotEmpty)
                ? NetworkImage(
                    '${ref.read(apiServiceProvider).baseUrl.replaceAll('/api', '')}${user.profileImage}',
                  )
                : null,
            child: (user.profileImage == null || user.profileImage!.isEmpty)
                ? Text(user.name[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${user.balance.toStringAsFixed(2)} TAN',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final UserModel user;
  final int rank;
  final double height;
  final String reward;
  final Color color;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.height,
    required this.reward,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 35,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Consumer(
                  builder: (context, ref, _) {
                    final imageUrl =
                        (user.profileImage != null &&
                            user.profileImage!.isNotEmpty)
                        ? '${ref.read(apiServiceProvider).baseUrl.replaceAll('/api', '')}${user.profileImage}'
                        : null;
                    return CircleAvatar(
                      radius: rank == 1 ? 36 : 31,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null
                          ? Text(
                              user.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: rank == 1 ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: 0,
                child: Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD700),
                  size: 30,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reward,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
