import re

with open('lib/features/communities/presentation/screens/community_detail_screen.dart', 'r') as f:
    text = f.read()

# Make stateful tab selection
if 'int _selectedTab = 0;' not in text:
    st_start = text.find('class _CommunityDetailScreenState extends State<CommunityDetailScreen> {')
    insert_pos = text.find('{', st_start) + 1
    text = text[:insert_pos] + '\n  int _selectedTab = 0;\n' + text[insert_pos:]

# Update texts
text = text.replace("'COMMUNITY'", "'COMUNIDAD'")
text = text.replace("} Members'", "} Miembros'")
text = text.replace("' • ', style: TextStyle(color: Colors.white70, fontSize: 12)", "''")
text = text.replace("Text('42 Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12))", "Container()")
# Tabs names and interactivity
tab_row_match = re.search(r'Row\(\s*mainAxisAlignment: MainAxisAlignment.spaceEvenly,\s*children.*?_buildTabItem.*?_buildTabItem.*?_buildTabItem.*?\),\s*\)', text, re.DOTALL)
if tab_row_match:
    new_tabs = '''Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(onTap: () => setState(() => _selectedTab = 0), child: _buildTabItem(Icons.dynamic_feed, 'Feed', _selectedTab == 0 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 0)),
                            const VerticalDivider(width: 1, indent: 15, endIndent: 15, color: Colors.black12),
                            GestureDetector(onTap: () => setState(() => _selectedTab = 1), child: _buildTabItem(Icons.photo_library_outlined, 'Galería', _selectedTab == 1 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 1)),
                            const VerticalDivider(width: 1, indent: 15, endIndent: 15, color: Colors.black12),
                            GestureDetector(onTap: () => setState(() => _selectedTab = 2), child: _buildTabItem(Icons.folder_open_outlined, 'Recursos', _selectedTab == 2 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 2)),
                          ],
                        )'''
    text = text[:tab_row_match.start()] + new_tabs + text[tab_row_match.end():]

# In feed list logic
sliver_list_match = re.search(r'SliverList\(\s*delegate: SliverChildBuilderDelegate.*?,$', text, re.DOTALL | re.MULTILINE)

feed_conditional = '''
              if (_selectedTab == 1)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('La galería está vacía', style: TextStyle(color: Colors.black54)))))
              else if (_selectedTab == 2)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No hay recursos disponibles', style: TextStyle(color: Colors.black54)))))
              else if (provider.isLoadingPosts)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())))
              else
                SliverList(
'''
text = text.replace('''if (provider.isLoadingPosts)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())))
              else
                SliverList(''', feed_conditional)

# Members sheet function update
members_sheet = """
  void _showMembersSheet(BuildContext context, CommunityProvider provider, int communityId) {
    provider.loadMembers(communityId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (ctx, scrollController) {
            return Consumer<CommunityProvider>(
              builder: (ctx, p, _) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    const Text('Integrantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: p.isLoadingMembers
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: p.members.length,
                              itemBuilder: (ctx, index) {
                                final m = p.members[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: m.profilePhotoPath != null ? CachedNetworkImageProvider(m.profilePhotoPath!) : null,
                                    child: m.profilePhotoPath == null ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(m.fullName),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
"""

if "_showMembersSheet" not in text:
    st_start = text.find('void _showMembersOptions')
    text = text[:st_start] + members_sheet + '\n  ' + text[st_start:]

text = text.replace("// TODO: Navigate to members screen\n                  ScaffoldMessenger.of(context).showSnackBar(\n                    const SnackBar(content: Text('Lista de integrantes pendiente')),\n                  );", "_showMembersSheet(context, context.read<CommunityProvider>(), community.id);")

with open('lib/features/communities/presentation/screens/community_detail_screen.dart', 'w') as f:
    f.write(text)
