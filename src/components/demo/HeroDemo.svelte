<!--
  HeroDemo.svelte - Self-contained demo component for caipi.ai website

  MAINTENANCE GUIDE:
  This component mirrors the main app UI. When updating the app, check these mappings:

  | Demo Section          | App Component                              |
  |-----------------------|--------------------------------------------|
  | Titlebar              | ChatContainer.svelte (lines 208-263)       |
  | File tree             | FileExplorer.svelte, FileTreeItem.svelte   |
  | Chat messages         | ChatMessage.svelte                         |
  | Tool stack            | ToolCallStack.svelte, ToolStackIcon.svelte |
  | Tool expanded rows    | ToolExpandedRow.svelte                     |
  | Input + footer        | MessageInput.svelte                        |
  | Todo list             | TodoList.svelte                            |
  | Skills list           | SkillsList.svelte                          |
  | Tooltips              | tooltip.svelte                             |
  | CSS variables         | app.css (:root and .dark)                  |

  To update styling: Sync CSS variables from app.css into the <style> section below.
-->

<script lang="ts">
  // ============================================
  // Types
  // ============================================
  type Message = {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    tools?: Tool[];
  };

  type Tool = {
    id: string;
    type: string;
    target: string;
    status: 'completed' | 'running' | 'awaiting_permission';
  };

  type Todo = {
    id: string;
    text: string;
    done: boolean;
    active: boolean;
  };

  type FileEntry = {
    name: string;
    type: 'file' | 'folder';
    children?: FileEntry[];
  };

  type Model = 'opus' | 'sonnet' | 'haiku';
  type PermissionMode = 'default' | 'acceptEdits' | 'bypassPermissions';

  // ============================================
  // Mock Data - Mid-process scenario
  // ============================================
  const messages: Message[] = [
    {
      id: '1',
      role: 'user',
      content: "I just got back from Hawaii with a ton of photos. I copied them from my phone but they're in some weird format and my friends can't open them. Can you help me organize them and make them easier to share?",
    },
    {
      id: '2',
      role: 'assistant',
      content: "I'd love to help! Let me take a look.",
      tools: [
        { id: 't0', type: 'Skill', target: 'Photo Operations', status: 'completed' },
        { id: 't1', type: 'WebSearch', target: 'HEIC file format compatibility issues', status: 'completed' },
        { id: 't2', type: 'Glob', target: '~/Downloads/*.HEIC', status: 'completed' },
        { id: 't3', type: 'Bash', target: 'Extract EXIF dates using mdls', status: 'completed' },
        { id: 't4', type: 'Thinking', target: 'Planning organization strategy...', status: 'completed' },
      ],
    },
    {
      id: '3',
      role: 'assistant',
      content: `Found **47 photos** from your trip! They're all HEIC files (iPhone format) with generic names like \`IMG_4521.HEIC\`. Looking at the EXIF dates, they span 3 days. I can organize them into day folders, convert to JPG, and compress them for easier sharing. Sound good?`,
    },
    {
      id: '4',
      role: 'user',
      content: "Yes please!",
    },
    {
      id: '5',
      role: 'assistant',
      content: "Great! Let me sort them into folders based on the dates.",
      tools: [
        { id: 't5', type: 'Bash', target: 'Create day folders in ~/Pictures/Hawaii-2025', status: 'completed' },
        { id: 't6', type: 'Bash', target: 'Move 12 photos to day-1-arrival/', status: 'completed' },
        { id: 't7', type: 'Bash', target: 'Move 9 photos to day-2-beach/', status: 'completed' },
        { id: 't8', type: 'Bash', target: 'Move 14 photos to day-3-volcano/', status: 'completed' },
        { id: 't9', type: 'Write', target: '~/Pictures/Hawaii-2025/README.txt', status: 'completed' },
      ],
    },
    {
      id: '6',
      role: 'assistant',
      content: "Photos organized! I created a README with the summary. Now let me convert them to JPG.",
      tools: [
        { id: 't10', type: 'Bash', target: 'Convert HEIC to JPG at 80% quality using SIPS', status: 'awaiting_permission' },
      ],
    },
  ];

  const todos: Todo[] = [
    { id: '1', text: 'Scan Downloads folder', done: true, active: false },
    { id: '2', text: 'Sort photos into day folders', done: true, active: false },
    { id: '3', text: 'Convert HEIC to JPG', done: false, active: true },
    { id: '4', text: 'Compress and rename files', done: false, active: false },
  ];

  const fileTree: FileEntry[] = [
    { name: 'README.txt', type: 'file' },
    {
      name: 'day-1-arrival',
      type: 'folder',
      children: [
        { name: 'hawaii-day1-001.jpg', type: 'file' },
        { name: 'hawaii-day1-002.jpg', type: 'file' },
        { name: 'hawaii-day1-003.jpg', type: 'file' },
        { name: 'hawaii-day1-004.jpg', type: 'file' },
        { name: 'hawaii-day1-005.jpg', type: 'file' },
        { name: 'hawaii-day1-006.jpg', type: 'file' },
        { name: 'hawaii-day1-007.jpg', type: 'file' },
        { name: 'hawaii-day1-008.jpg', type: 'file' },
        { name: 'hawaii-day1-009.jpg', type: 'file' },
        { name: 'hawaii-day1-010.jpg', type: 'file' },
        { name: 'hawaii-day1-011.jpg', type: 'file' },
        { name: 'hawaii-day1-012.jpg', type: 'file' },
      ],
    },
    {
      name: 'day-2-beach',
      type: 'folder',
      children: [
        { name: 'hawaii-day2-001.jpg', type: 'file' },
        { name: 'hawaii-day2-002.jpg', type: 'file' },
        { name: 'hawaii-day2-003.jpg', type: 'file' },
        { name: 'hawaii-day2-004.jpg', type: 'file' },
        { name: 'hawaii-day2-005.jpg', type: 'file' },
        { name: 'hawaii-day2-006.jpg', type: 'file' },
        { name: 'hawaii-day2-007.jpg', type: 'file' },
        { name: 'hawaii-day2-008.jpg', type: 'file' },
        { name: 'hawaii-day2-009.jpg', type: 'file' },
      ],
    },
    {
      name: 'day-3-volcano',
      type: 'folder',
      children: [
        { name: 'hawaii-day3-001.jpg', type: 'file' },
        { name: 'hawaii-day3-002.jpg', type: 'file' },
        { name: 'hawaii-day3-003.jpg', type: 'file' },
        { name: 'hawaii-day3-004.jpg', type: 'file' },
        { name: 'hawaii-day3-005.jpg', type: 'file' },
        { name: 'hawaii-day3-006.jpg', type: 'file' },
        { name: 'hawaii-day3-007.jpg', type: 'file' },
        { name: 'hawaii-day3-008.jpg', type: 'file' },
        { name: 'hawaii-day3-009.jpg', type: 'file' },
        { name: 'hawaii-day3-010.jpg', type: 'file' },
        { name: 'hawaii-day3-011.jpg', type: 'file' },
        { name: 'hawaii-day3-012.jpg', type: 'file' },
        { name: 'hawaii-day3-013.jpg', type: 'file' },
        { name: 'hawaii-day3-014.jpg', type: 'file' },
      ],
    },
  ];

  // ============================================
  // Icons (inline SVGs - no dependencies)
  // ============================================
  const icon = (d: string, size = 14) => `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;

  const icons = {
    panelLeft: icon('<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/>'),
    panelRight: icon('<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/>'),
    home: icon('<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>'),
    sun: icon('<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>'),
    moon: icon('<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>'),
    folder: icon('<path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/>'),
    file: icon('<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/>'),
    chevronRight: icon('<path d="m9 18 6-6-6-6"/>'),
    chevronDown: icon('<path d="m6 9 6 6 6-6"/>'),
    circle: icon('<circle cx="12" cy="12" r="10"/>'),
    checkCircle2: icon('<circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/>'),
    loader2: icon('<path d="M21 12a9 9 0 1 1-6.219-8.56"/>'),
    search: icon('<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>'),
    terminal: icon('<polyline points="4 17 10 11 4 5"/><line x1="12" x2="20" y1="19" y2="19"/>'),
    pencil: icon('<path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/>'),
    check: icon('<path d="M20 6 9 17l-5-5"/>'),
    x: icon('<path d="M18 6 6 18"/><path d="m6 6 12 12"/>'),
    clock: icon('<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>'),
    shield: icon('<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/>'),
    alertTriangle: icon('<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/>'),
    arrowUp: icon('<path d="m5 12 7-7 7 7"/><path d="M12 19V5"/>'),
    brain: icon('<path d="M12 5a3 3 0 1 0-5.997.125 4 4 0 0 0-2.526 5.77 4 4 0 0 0 .556 6.588A4 4 0 1 0 12 18Z"/><path d="M12 5a3 3 0 1 1 5.997.125 4 4 0 0 1 2.526 5.77 4 4 0 0 1-.556 6.588A4 4 0 1 1 12 18Z"/><path d="M15 13a4.5 4.5 0 0 1-3-4 4.5 4.5 0 0 1-3 4"/><path d="M17.599 6.5a3 3 0 0 0 .399-1.375"/><path d="M6.003 5.125A3 3 0 0 0 6.401 6.5"/><path d="M3.477 10.896a4 4 0 0 1 .585-.396"/><path d="M19.938 10.5a4 4 0 0 1 .585.396"/><path d="M6 18a4 4 0 0 1-1.967-.516"/><path d="M19.967 17.484A4 4 0 0 1 18 18"/>'),
    sparkles: icon('<path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z"/><path d="M20 3v4"/><path d="M22 5h-4"/><path d="M4 17v2"/><path d="M5 18H3"/>'),
    bookOpen: icon('<path d="M12 7v14"/><path d="M3 18a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h5a4 4 0 0 1 4 4 4 4 0 0 1 4-4h5a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-6a3 3 0 0 0-3 3 3 3 0 0 0-3-3z"/>'),
    globe: icon('<circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/>'),
    eye: icon('<path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/>'),
  };

  const modelIcon = (size: 'large' | 'medium' | 'small') => {
    const rings = size === 'large' ? 3 : size === 'medium' ? 2 : 1;
    let c = '';
    if (rings >= 3) c += '<circle cx="12" cy="12" r="10"/>';
    if (rings >= 2) c += '<circle cx="12" cy="12" r="6"/>';
    c += '<circle cx="12" cy="12" r="2"/>';
    return `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">${c}</svg>`;
  };

  // ============================================
  // State
  // ============================================
  let theme = $state<'light' | 'dark'>('light');
  let leftSidebar = $state(true);
  let rightSidebar = $state(true);
  let model = $state<Model>('sonnet');
  let permissionMode = $state<PermissionMode>('default');
  let expandedFolders = $state(new Set(['day-1-arrival']));
  let expandedTools = $state(new Set<string>());
  let inputText = $state('');
  let extendedThinking = $state(true);
  let messagesEl: HTMLDivElement;

  $effect(() => {
    if (messagesEl) {
      messagesEl.scrollTop = messagesEl.scrollHeight;
    }
  });

  // ============================================
  // Configs
  // ============================================
  const modelConfig = {
    opus: { label: 'Opus 4.5', size: 'large' as const },
    sonnet: { label: 'Sonnet 4.5', size: 'medium' as const },
    haiku: { label: 'Haiku 4.5', size: 'small' as const },
  };

  const modeConfig = {
    default: { label: 'Default', icon: icons.shield, danger: false },
    acceptEdits: { label: 'Edit', icon: icons.pencil, danger: false },
    bypassPermissions: { label: 'Allow All', icon: icons.alertTriangle, danger: true },
  };

  const toolConfig: Record<string, { icon: string; iconColor: string; label: string }> = {
    Glob: { icon: icons.search, iconColor: 'text-blue-500', label: 'glob' },
    Bash: { icon: icons.terminal, iconColor: 'text-purple-500', label: 'bash' },
    Write: { icon: icons.pencil, iconColor: 'text-amber-500', label: 'create' },
    Read: { icon: icons.eye, iconColor: 'text-blue-500', label: 'view' },
    Skill: { icon: icons.sparkles, iconColor: 'text-purple-500', label: 'skill' },
    WebSearch: { icon: icons.globe, iconColor: 'text-emerald-500', label: 'search' },
    Thinking: { icon: icons.brain, iconColor: 'text-purple-500', label: 'thinking' },
  };

  // ============================================
  // Helpers
  // ============================================
  function cycleModel() {
    const models: Model[] = ['opus', 'sonnet', 'haiku'];
    model = models[(models.indexOf(model) + 1) % models.length];
  }

  function cyclePermission() {
    const modes: PermissionMode[] = ['default', 'acceptEdits', 'bypassPermissions'];
    permissionMode = modes[(modes.indexOf(permissionMode) + 1) % modes.length];
  }

  function toggleFolder(path: string) {
    const next = new Set(expandedFolders);
    next.has(path) ? next.delete(path) : next.add(path);
    expandedFolders = next;
  }

  function toggleToolStack(id: string) {
    const next = new Set(expandedTools);
    next.has(id) ? next.delete(id) : next.add(id);
    expandedTools = next;
  }

  function parseMarkdown(text: string): string {
    return text
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/```(\w*)\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>')
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/^- (.+)$/gm, '<li>$1</li>')
      .replace(/\n\n/g, '</p><p>')
      .replace(/(<li>[\s\S]*?<\/li>)+/g, '<ul>$&</ul>')
      .replace(/<\/ul><ul>/g, '')
      .replace(/^/, '<p>').replace(/$/, '</p>');
  }

  // Context indicator
  const contextPct = 18;
  const radius = 7;
  const circ = 2 * Math.PI * radius;
  const contextColor = $derived(`hsl(${120 - contextPct * 1.2}, 70%, 45%)`);
</script>

<div class="demo" class:dark={theme === 'dark'}>
  <div class="app">
    <!-- ==================== TITLEBAR ==================== -->
    <header class="titlebar">
      <div class="titlebar-left">
        <div class="traffic-lights">
          <span class="light red"></span>
          <span class="light yellow"></span>
          <span class="light green"></span>
        </div>
        <button class="icon-btn" onclick={() => leftSidebar = !leftSidebar}>{@html icons.panelLeft}</button>
        <button class="icon-btn">{@html icons.home}</button>
      </div>
      <div class="titlebar-center">Hawaii-2025</div>
      <div class="titlebar-right">
        <button class="icon-btn" onclick={() => theme = theme === 'dark' ? 'light' : 'dark'}>
          {@html theme === 'dark' ? icons.sun : icons.moon}
        </button>
        <button class="icon-btn" onclick={() => rightSidebar = !rightSidebar}>{@html icons.panelRight}</button>
      </div>
    </header>

    <!-- ==================== CONTENT ==================== -->
    <div class="content">
      <!-- LEFT SIDEBAR: File Explorer -->
      <aside class="sidebar left" class:collapsed={!leftSidebar}>
        <div class="sidebar-header">Files</div>
        <div class="file-tree">
          {#each fileTree as entry}
            {@const path = entry.name}
            {@const expanded = expandedFolders.has(path)}
            <button class="file-item" onclick={() => entry.type === 'folder' && toggleFolder(path)}>
              {#if entry.type === 'folder'}
                <span class="chevron">{@html expanded ? icons.chevronDown : icons.chevronRight}</span>
              {:else}
                <span class="spacer"></span>
              {/if}
              <span class="file-icon">{@html entry.type === 'folder' ? icons.folder : icons.file}</span>
              <span class="file-name">{entry.name}</span>
            </button>
            {#if entry.type === 'folder' && expanded && entry.children}
              {#each entry.children as child}
                {@const childPath = `${path}/${child.name}`}
                {@const childExpanded = expandedFolders.has(childPath)}
                <button class="file-item depth-1" onclick={() => child.type === 'folder' && toggleFolder(childPath)}>
                  {#if child.type === 'folder'}
                    <span class="chevron">{@html childExpanded ? icons.chevronDown : icons.chevronRight}</span>
                  {:else}
                    <span class="spacer"></span>
                  {/if}
                  <span class="file-icon">{@html child.type === 'folder' ? icons.folder : icons.file}</span>
                  <span class="file-name">{child.name}</span>
                </button>
                {#if child.type === 'folder' && childExpanded && child.children}
                  {#each child.children as grandchild}
                    <button class="file-item depth-2">
                      <span class="spacer"></span>
                      <span class="file-icon">{@html icons.file}</span>
                      <span class="file-name">{grandchild.name}</span>
                    </button>
                  {/each}
                {/if}
              {/each}
            {/if}
          {/each}
        </div>
      </aside>

      <!-- MAIN: Chat Area -->
      <main class="main">
        <div class="messages" bind:this={messagesEl}>
          {#each messages as msg (msg.id)}
            <!-- User divider -->
            {#if msg.role === 'user'}<div class="divider"></div>{/if}

            <!-- Message content -->
            <div class="message" class:user={msg.role === 'user'}>
              {@html parseMarkdown(msg.content)}
            </div>

            <!-- Tools -->
            {#if msg.tools && msg.tools.length > 0}
              {@const stackId = msg.id}
              {@const isExpanded = expandedTools.has(stackId)}
              {@const lastTool = msg.tools[msg.tools.length - 1]}
              {@const cfg = toolConfig[lastTool.type] || toolConfig.Bash}
              {@const needsPermission = lastTool.status === 'awaiting_permission'}
              <div class="tool-stack">
                <button class="tool-header" onclick={() => toggleToolStack(stackId)}>
                  <!-- Stacked circular icons -->
                  <div class="tool-icons" style="width: {(Math.min(msg.tools.length, 5) - 1) * 16 + 24}px">
                    {#each msg.tools.slice(-5) as tool, i}
                      {@const tc = toolConfig[tool.type] || toolConfig.Bash}
                      <div class="tool-stack-icon {tc.iconColor}" style="left: {i * 16}px; z-index: {i + 10};">
                        {@html tc.icon}
                      </div>
                    {/each}
                  </div>

                  <span class="tool-label">{cfg.label}</span>
                  <span class="tool-target">{lastTool.target}</span>

                  <!-- Permission buttons or count -->
                  {#if needsPermission}
                    <button class="permission-btn allow" onclick={(e) => e.stopPropagation()}>
                      {@html icons.check}
                    </button>
                    <button class="permission-btn deny" onclick={(e) => e.stopPropagation()}>
                      {@html icons.x}
                    </button>
                  {/if}

                  <span class="tool-count">{msg.tools.length}</span>
                  <span class="tool-chevron" class:expanded={isExpanded}>{@html icons.chevronDown}</span>
                </button>

                {#if isExpanded}
                  <div class="tool-expanded">
                    {#each msg.tools as tool}
                      {@const tc = toolConfig[tool.type] || toolConfig.Bash}
                      <div class="tool-row">
                        <span class="tool-row-icon {tc.iconColor}">{@html tc.icon}</span>
                        <span class="tool-row-label">{tc.label}</span>
                        <span class="tool-row-target">{tool.target}</span>
                        <span class="tool-row-status">
                          {#if tool.status === 'completed'}
                            <span class="text-green-500">{@html icons.check}</span>
                          {:else if tool.status === 'awaiting_permission'}
                            <span class="text-amber-500 animate-pulse">{@html icons.clock}</span>
                          {:else}
                            <span class="spinner">{@html icons.loader2}</span>
                          {/if}
                        </span>
                      </div>
                    {/each}
                  </div>
                {/if}
              </div>
            {/if}

            <!-- User divider -->
            {#if msg.role === 'user'}<div class="divider"></div>{/if}
          {/each}
        </div>

        <!-- INPUT -->
        <div class="input-area">
          <div class="input-card">
            <div class="textarea-wrap">
              <textarea bind:value={inputText} placeholder="What else can I help with?" rows="2"></textarea>
              <button class="send-btn" class:disabled={!inputText.trim()} disabled>{@html icons.arrowUp}</button>
            </div>
            <div class="input-footer">
              <div class="footer-left">
                <div class="tooltip-wrap">
                  <button class="footer-btn model" onclick={cycleModel}>
                    {@html modelIcon(modelConfig[model].size)}
                    <span>{modelConfig[model].label}</span>
                  </button>
                  <span class="tooltip">Claude Model</span>
                </div>
                <div class="tooltip-wrap">
                  <button class="footer-btn permission" class:danger={modeConfig[permissionMode].danger} onclick={cyclePermission}>
                    {@html modeConfig[permissionMode].icon}
                    <span>{modeConfig[permissionMode].label}</span>
                  </button>
                  <span class="tooltip">Permission Mode</span>
                </div>
                <div class="tooltip-wrap">
                  <button class="footer-btn thinking" class:active={extendedThinking} onclick={() => extendedThinking = !extendedThinking}>
                    {@html icons.brain}
                  </button>
                  <span class="tooltip">Extended Thinking</span>
                </div>
              </div>
              <div class="tooltip-wrap">
                <button class="footer-btn context">
                  <svg width="18" height="18" viewBox="0 0 18 18" style="transform: rotate(-90deg)">
                    <circle cx="9" cy="9" r={radius} fill="none" stroke="currentColor" stroke-width="2" opacity="0.2"/>
                    <circle cx="9" cy="9" r={radius} fill="none" stroke={contextColor} stroke-width="2" stroke-linecap="round" stroke-dasharray={circ} stroke-dashoffset={circ - (contextPct / 100) * circ}/>
                  </svg>
                  <span>{contextPct}%</span>
                </button>
                <span class="tooltip right">Context Usage</span>
              </div>
            </div>
          </div>
        </div>
      </main>

      <!-- RIGHT SIDEBAR: Context Panel -->
      <aside class="sidebar right" class:collapsed={!rightSidebar}>
        <!-- Todos -->
        <div class="sidebar-section">
          <div class="sidebar-header">Todos</div>
          <div class="todo-list">
            {#each todos as todo (todo.id)}
              <div class="todo-item" class:active={todo.active}>
                <span class="todo-icon" class:done={todo.done} class:running={todo.active}>
                  {#if todo.done}
                    {@html icons.checkCircle2}
                  {:else if todo.active}
                    <span class="spinner">{@html icons.loader2}</span>
                  {:else}
                    {@html icons.circle}
                  {/if}
                </span>
                <span class="todo-text" class:done={todo.done}>{todo.text}</span>
              </div>
            {/each}
          </div>
        </div>
        <!-- Skills -->
        <div class="sidebar-section">
          <div class="sidebar-header">Active Skills</div>
          <div class="skills-list">
            <div class="skill-item">
              <span class="skill-icon">{@html icons.bookOpen}</span>
              <span class="skill-name">Photo Operations</span>
            </div>
          </div>
        </div>
      </aside>
    </div>
  </div>
</div>

<style>
  /* ============================================
     CSS Variables - synced from app.css
     ============================================ */
  .demo {
    --background: oklch(1 0 0);
    --foreground: oklch(0.13 0.028 261.692);
    --card: oklch(1 0 0);
    --muted: oklch(0.967 0.003 264.542);
    --muted-foreground: oklch(0.551 0.027 264.364);
    --accent: oklch(0.967 0.003 264.542);
    --accent-foreground: oklch(0.21 0.034 264.665);
    --border: oklch(0.928 0.006 264.531);
    --radius: 0.625rem;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }

  .demo.dark {
    --background: oklch(0.13 0.028 261.692);
    --foreground: oklch(0.985 0.002 247.839);
    --card: oklch(0.21 0.034 264.665);
    --muted: oklch(0.278 0.033 256.848);
    --muted-foreground: oklch(0.707 0.022 261.325);
    --accent: oklch(0.278 0.033 256.848);
    --accent-foreground: oklch(0.985 0.002 247.839);
    --border: oklch(1 0 0 / 10%);
  }

  /* Tailwind-like color utilities */
  .demo :global(.text-blue-500) { color: oklch(0.6 0.18 250); }
  .demo :global(.text-purple-500) { color: oklch(0.6 0.18 300); }
  .demo :global(.text-amber-500) { color: oklch(0.75 0.15 75); }
  .demo :global(.text-green-500) { color: oklch(0.65 0.2 145); }
  .demo :global(.text-emerald-500) { color: oklch(0.65 0.17 165); }

  /* ============================================
     Tooltips
     ============================================ */
  .tooltip-wrap {
    position: relative;
    display: inline-flex;
  }

  .tooltip {
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: 8px;
    padding: 4px 8px;
    font-size: 11px;
    white-space: nowrap;
    background: var(--foreground);
    color: var(--background);
    border-radius: 4px;
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.15s, visibility 0.15s;
    z-index: 50;
  }

  .tooltip.bottom {
    bottom: auto;
    top: 100%;
    margin-bottom: 0;
    margin-top: 8px;
  }

  .tooltip::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    border: 4px solid transparent;
    border-top-color: var(--foreground);
    opacity: 0;
    transition: opacity 0.15s;
  }

  .tooltip.bottom::after {
    top: auto;
    bottom: 100%;
    border-top-color: transparent;
    border-bottom-color: var(--foreground);
  }

  .tooltip-wrap:hover .tooltip::after {
    opacity: 1;
  }

  .tooltip-wrap:hover .tooltip {
    opacity: 1;
    visibility: visible;
  }

  .tooltip.right {
    left: auto;
    right: 0;
    transform: none;
  }

  .tooltip.right::after {
    left: auto;
    right: 12px;
    transform: none;
  }

  /* ============================================
     Layout
     ============================================ */
  .app {
    background: var(--background);
    color: var(--foreground);
    border-radius: 12px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    height: 600px;
    box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
    border: 1px solid var(--border);
  }

  .demo.dark .app {
    border-color: oklch(1 0 0 / 25%);
  }

  .titlebar {
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
    position: relative;
  }

  .titlebar-left, .titlebar-right { display: flex; align-items: center; gap: 4px; z-index: 1; }
  .titlebar-center { position: absolute; left: 50%; transform: translateX(-50%); font-size: 13px; font-weight: 500; }

  .traffic-lights { display: flex; gap: 8px; margin-right: 12px; }
  .light { width: 12px; height: 12px; border-radius: 50%; }
  .light.red { background: #ff5f57; }
  .light.yellow { background: #febc2e; }
  .light.green { background: #28c840; }

  .icon-btn {
    width: 24px; height: 24px;
    display: flex; align-items: center; justify-content: center;
    border: none; background: transparent;
    color: var(--muted-foreground);
    border-radius: 6px; cursor: pointer;
    transition: background-color 0.15s;
  }
  .icon-btn:hover { background: var(--accent); color: var(--accent-foreground); }

  .content { display: flex; flex: 1; min-height: 0; }

  .sidebar {
    width: 192px; flex-shrink: 0;
    overflow: hidden; transition: width 0.2s ease;
    background: color-mix(in oklch, var(--muted) 50%, transparent);
    display: flex; flex-direction: column;
  }
  .sidebar.left { border-right: 1px solid var(--border); }
  .sidebar.right { border-left: 1px solid var(--border); }
  .sidebar.collapsed { width: 0; border-width: 0; }

  .sidebar-header {
    padding: 12px 12px 0;
    font-size: 10px; text-transform: uppercase;
    letter-spacing: 0.1em; font-weight: 600;
    color: color-mix(in oklch, var(--muted-foreground) 50%, transparent);
    margin-bottom: 12px;
  }

  .sidebar-section { flex: 1; min-height: 0; display: flex; flex-direction: column; }
  .sidebar-section:first-child { border-bottom: 1px solid var(--border); }

  .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
  .messages { flex: 1; overflow-y: auto; padding: 16px 24px; }

  /* ============================================
     File Tree
     ============================================ */
  .file-tree { flex: 1; overflow: auto; }
  .file-item {
    display: flex; align-items: center; gap: 4px;
    padding: 4px 8px; width: 100%;
    border: none; background: transparent;
    color: var(--foreground); text-align: left;
    border-radius: 6px; cursor: pointer;
    transition: background-color 0.15s;
  }
  .file-item:hover { background: color-mix(in oklch, var(--muted) 50%, transparent); }
  .file-item.depth-1 { padding-left: 20px; }
  .file-item.depth-2 { padding-left: 32px; }
  .chevron, .file-icon { color: var(--muted-foreground); display: flex; align-items: center; }
  .spacer { width: 14px; }
  .file-name { font-size: 12px; opacity: 0.8; }

  /* ============================================
     Messages
     ============================================ */
  .divider { padding: 16px 0; }
  .divider::after { content: ''; display: block; border-top: 1px solid color-mix(in oklch, var(--border) 50%, transparent); }

  .message { font-size: 13px; line-height: 1.6; color: color-mix(in oklch, var(--foreground) 90%, transparent); }
  .message.user { color: color-mix(in oklch, var(--foreground) 70%, transparent); font-style: italic; }
  .message :global(p) { margin: 0.5em 0; }
  .message :global(p:first-child) { margin-top: 0; }
  .message :global(p:last-child) { margin-bottom: 0; }
  .message :global(strong) { font-weight: 600; }
  .message :global(code) { background: var(--muted); padding: 0.15em 0.4em; border-radius: 4px; font-size: 0.9em; font-family: ui-monospace, monospace; }
  .message :global(pre) { background: var(--muted); padding: 12px; border-radius: 8px; overflow-x: auto; margin: 0.5em 0; }
  .message :global(pre code) { background: transparent; padding: 0; font-size: 12px; }
  .message :global(ul) { margin: 0.5em 0; padding-left: 1.5em; }
  .message :global(li) { margin: 0.25em 0; }

  /* ============================================
     Tool Stack - matches ToolCallStack.svelte
     ============================================ */
  .tool-stack {
    margin: 8px 0;
    border-radius: 8px;
    border: 1px solid var(--border);
    background: color-mix(in oklch, var(--muted) 50%, transparent);
    overflow: hidden;
  }

  .tool-header {
    display: flex; align-items: center; gap: 8px;
    padding: 0 12px; height: 40px; width: 100%;
    border: none; background: transparent;
    color: var(--foreground); cursor: pointer; text-align: left;
  }

  .tool-icons { position: relative; height: 24px; flex-shrink: 0; }

  /* Circular stacked icons - matches ToolStackIcon.svelte */
  .tool-stack-icon {
    position: absolute; top: 0;
    width: 24px; height: 24px;
    border-radius: 50%;
    background: var(--muted);
    border: 1px solid var(--border);
    display: flex; align-items: center; justify-content: center;
    transition: left 200ms ease-out;
  }

  .tool-label {
    font-size: 11px; font-weight: 500;
    text-transform: uppercase; letter-spacing: 0.05em;
    color: var(--muted-foreground); flex-shrink: 0;
  }

  .tool-target {
    font-size: 12px;
    color: color-mix(in oklch, var(--muted-foreground) 70%, transparent);
    flex: 1; min-width: 0;
    overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  }

  .permission-btn {
    width: 24px; height: 24px;
    border-radius: 6px; border: none;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: background-color 0.15s;
  }
  .permission-btn.allow {
    background: color-mix(in oklch, oklch(0.65 0.2 145) 15%, transparent);
    color: oklch(0.65 0.2 145);
  }
  .permission-btn.allow:hover { background: color-mix(in oklch, oklch(0.65 0.2 145) 25%, transparent); }
  .permission-btn.deny {
    background: color-mix(in oklch, oklch(0.65 0.2 25) 15%, transparent);
    color: oklch(0.65 0.2 25);
  }
  .permission-btn.deny:hover { background: color-mix(in oklch, oklch(0.65 0.2 25) 25%, transparent); }

  .tool-count {
    font-size: 11px; color: var(--muted-foreground);
    background: var(--muted); padding: 2px 6px; border-radius: 4px;
  }

  .tool-chevron {
    color: var(--muted-foreground);
    transition: transform 0.15s; display: flex;
  }
  .tool-chevron.expanded { transform: rotate(180deg); }

  /* Expanded rows - matches ToolExpandedRow.svelte */
  .tool-expanded {
    border-top: 1px solid var(--border);
    background: color-mix(in oklch, var(--muted) 30%, transparent);
  }

  .tool-row {
    display: flex; align-items: center; gap: 8px;
    padding: 2px 8px;
  }

  .tool-row-icon {
    width: 20px; height: 20px;
    display: flex; align-items: center; justify-content: center;
  }

  .tool-row-label {
    font-size: 11px; font-weight: 500;
    text-transform: uppercase; letter-spacing: 0.05em;
    color: var(--muted-foreground);
  }

  .tool-row-target {
    font-size: 12px;
    color: color-mix(in oklch, var(--muted-foreground) 70%, transparent);
    flex: 1; min-width: 0;
    overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  }

  .tool-row-status {
    display: flex; align-items: center;
  }

  .demo :global(.animate-pulse) {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }

  /* ============================================
     Input
     ============================================ */
  .input-area { border-top: 1px solid var(--border); padding: 16px; }

  .input-card {
    max-width: 768px; margin: 0 auto;
    background: var(--card);
    border-radius: 12px;
    border: 1px solid var(--border);
    box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
    overflow: hidden;
  }

  .textarea-wrap { position: relative; }
  .textarea-wrap textarea {
    width: 100%; padding: 12px 16px; padding-right: 56px;
    background: transparent; border: none; outline: none; resize: none;
    font-size: 13px; font-family: inherit; color: var(--foreground); line-height: 1.5;
  }
  .textarea-wrap textarea::placeholder { color: var(--muted-foreground); }

  .send-btn {
    position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
    width: 36px; height: 36px; border-radius: 8px; border: none;
    background: var(--foreground); color: var(--background);
    display: flex; align-items: center; justify-content: center;
    cursor: not-allowed;
  }
  .send-btn.disabled { opacity: 0.5; }

  .input-footer {
    display: flex; align-items: center; justify-content: space-between;
    padding: 4px; border-top: 1px solid var(--border);
  }

  .footer-left { display: flex; align-items: center; gap: 4px; }

  .footer-btn {
    display: flex; align-items: center; gap: 6px;
    padding: 6px 10px; border: 1px solid transparent; background: transparent;
    color: var(--muted-foreground); font-size: 11px;
    border-radius: 6px; cursor: pointer;
    transition: background-color 0.15s, color 0.15s, border-color 0.15s;
  }
  .footer-btn:hover { background: var(--accent); color: var(--accent-foreground); }
  .footer-btn.model { min-width: 100px; }
  .footer-btn.permission { min-width: 80px; }
  .footer-btn.permission.danger { color: oklch(0.65 0.2 25); }
  .footer-btn.thinking { padding: 6px; }
  .footer-btn.thinking.active {
    background: color-mix(in oklch, oklch(0.6 0.15 300) 10%, transparent);
    border-color: color-mix(in oklch, oklch(0.6 0.15 300) 30%, transparent);
    color: oklch(0.6 0.15 300);
  }
  .footer-btn.context { margin-left: auto; }

  /* ============================================
     Todos
     ============================================ */
  .todo-list {
    flex: 1; overflow-y: auto;
    padding: 0 12px 12px;
    display: flex; flex-direction: column; gap: 4px;
  }

  .todo-item {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 8px; border-radius: 8px;
  }

  .todo-item.active {
    background: color-mix(in oklch, oklch(0.7 0.15 45) 10%, transparent);
    border: 1px solid color-mix(in oklch, oklch(0.7 0.15 45) 20%, transparent);
  }

  .todo-icon {
    margin-top: 2px;
    color: color-mix(in oklch, var(--muted-foreground) 50%, transparent);
    display: flex; align-items: center;
  }
  .todo-icon.done { color: oklch(0.65 0.2 145); }
  .todo-icon.running { color: oklch(0.7 0.15 45); }

  .todo-text { font-size: 12px; opacity: 0.8; }
  .todo-text.done { text-decoration: line-through; color: var(--muted-foreground); }

  .spinner { display: inline-flex; animation: spin 1s linear infinite; }
  @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

  .skills-list {
    padding: 0 12px 12px;
    display: flex; flex-direction: column; gap: 4px;
  }

  .skill-item {
    display: flex; align-items: center; gap: 8px;
    padding: 8px; border-radius: 8px;
    background: color-mix(in oklch, var(--muted) 50%, transparent);
  }

  .skill-icon {
    color: var(--muted-foreground);
    display: flex; align-items: center;
  }

  .skill-name { font-size: 12px; opacity: 0.8; }
</style>
